
function add_pm_cost!(
    PM_gen::Dict{String, Any},
    op_cost::T,
    base::Float64,
) where {T <: PSY.ThreePartCost}
    PM_gen["startup"] = PSY.get_start_up(op_cost)
    PM_gen["shutdown"] = PSY.get_shut_down(op_cost)
    add_pm_var_cost!(PM_gen, PSY.get_variable(op_cost), base, PSY.get_fixed(op_cost))
    return PM_gen
end

function add_pm_cost!(
    PM_gen::Dict{String, Any},
    op_cost::T,
    base::Float64,
) where {T <: PSY.TwoPartCost}
    PM_gen["shutdown"] = 0.0
    PM_gen["startup"] = 0.0
    add_pm_var_cost!(PM_gen, PSY.get_variable(op_cost), base, PSY.get_fixed(op_cost))
    return PM_gen
end

# polynomial cost
function add_pm_var_cost!(
    PM_gen::Dict{String, Any},
    var_cost::PSY.VariableCost{Tuple{Float64, Float64}},
    base::Float64,
    fixed::Float64,
)
    cost = PSY.get_cost(var_cost)
    PM_gen["model"] = 2
    PM_gen["cost"] = Vector{Float64}()
    PM_gen["ncost"] = cost[1] != 0.0 ? 3 : cost[2] != 0.0 ? 2 : 0
    PM_gen["ncost"] == 0 && return PM_gen

    for idx in (4 - PM_gen["ncost"]):2
        push!(PM_gen["cost"], cost[idx])
        PM_gen["cost"] = PM_gen["cost"] .* base
    end
    push!(PM_gen["cost"], fixed)
    return PM_gen
end

# pwl cost
function add_pm_var_cost!(
    PM_gen::Dict{String, Any},
    var_cost::PSY.VariableCost{Vector{Tuple{Float64, Float64}}},
    base::Float64,
    fixed::Float64,
)
    PM_gen["model"] = 1
    PM_gen["ncost"] = length(var_cost)
    PM_gen["cost"] = Vector{Float64}()
    for c in PSY.get_cost(var_cost)
        push!(PM_gen["cost"], last(c))
        push!(PM_gen["cost"], first(c) + fixed)
    end
    return PM_gen
end

# scalar cost
function add_pm_var_cost!(
    PM_gen::Dict{String, Any},
    var_cost::PSY.VariableCost{Float64},
    base::Float64,
    fixed::Float64,
)
    PM_gen["model"] = 2
    PM_gen["ncost"] = length(var_cost)
    PM_gen["cost"] = [PSY.get_cost(var_cost) + fixed]
    return PM_gen
end

function pm_gen_core(gen::T, ix::Int) where {T <: PSY.Generator}
    PM_gen = Dict{String, Any}(
        "index" => ix,
        "name" => PSY.get_name(gen),
        "gen_bus" => PSY.get_number(PSY.get_bus(gen)),
        "source_id" => convert(Vector{Any}, split(PSY.get_name(gen), "-")),
        "mbase" => PSY.get_base_power(gen),
        "gen_status" => Int(PSY.get_available(gen)),
        "pg" => PSY.get_active_power(gen),
        "qg" => PSY.get_reactive_power(gen),
        "vg" => PSY.get_magnitude(PSY.get_bus(gen)),
        "pmax" => PSY.get_max_active_power(gen),
        "qmax" => PSY.get_max_reactive_power(gen),
        "type" => string(PSY.get_prime_mover(gen)),
    )
    return PM_gen
end

function get_component_to_pm(ix::Int, gen::T) where {T <: PSY.ThermalGen}
    PM_gen = pm_gen_core(gen, ix)
    ramplims = PSY.get_ramp_limits(gen)
    ramp = isnothing(ramplims) ? 9999.0 : getfield(ramplims, :up)
    merge!(
        PM_gen,
        Dict{String, Any}(
            "pmin" => PSY.get_active_power_limits(gen).min,
            "fuel" => string(PSY.get_fuel(gen)),
            "ramp_10" => ramp,
            "qmin" => PSY.get_reactive_power_limits(gen).min,
            "gen_status" => Int(PSY.get_status(gen)),
        ),
    )
    add_pm_cost!(PM_gen, PSY.get_operation_cost(gen), gen.internal.units_info.base_value)
    return PM_gen
end

function get_component_to_pm(ix::Int, gen::T) where {T <: PSY.RenewableGen}
    PM_gen = pm_gen_core(gen, ix)
    merge!(
        PM_gen,
        Dict{String, Any}("pmin" => 0.0, "qmin" => PSY.get_reactive_power_limits(gen).min),
    )
    add_pm_cost!(PM_gen, PSY.get_operation_cost(gen), gen.internal.units_info.base_value)
    return PM_gen
end

function get_component_to_pm(ix::Int, gen::T) where {T <: PSY.RenewableFix}
    PM_gen = pm_gen_core(gen, ix)
    merge!(PM_gen, Dict{String, Any}("pmin" => 0.0, "qmin" => 0.0))
    return PM_gen
end

function get_component_to_pm(ix::Int, gen::T) where {T <: PSY.HydroGen}
    PM_gen = pm_gen_core(gen, ix)
    ramp = PSY.get_ramp_limits(gen).up
    merge!(
        PM_gen,
        Dict{String, Any}(
            "pmin" => PSY.get_active_power_limits(gen).min,
            "ramp_10" => ramp,
            "qmin" => PSY.get_reactive_power_limits(gen).min,
        ),
    )
    add_pm_cost!(PM_gen, PSY.get_operation_cost(gen), gen.internal.units_info.base_value)
    return PM_gen
end

function get_time_series_to_pm!(
    pm_data::Dict{String, Any},
    pm_category::String,
    pm_id::String,
    device::T,
    start_time::Dates.DateTime,
    time_periods::UnitRange{Int},
) where {T <: PSY.RenewableGen}
    psy_forecast_name = "max_active_power" # change this line for different forecasts
    pm_field_name = "pmax" # change this line to apply forecast to different fields

    ts_data = PSY.get_time_series_values(
        PSY.AbstractDeterministic,
        device,
        psy_forecast_name,
        start_time = start_time,
    )
    if haskey(pm_data, "nw")
        pm_update = Dict{String, Any}("nw" => Dict{String, Any}())
        for (t, nw) in pm_data["nw"]
            pm_update["nw"][t] = Dict(
                pm_category => Dict(
                    pm_id =>
                        Dict(pm_field_name => ts_data[time_periods[parse(Int, t)]]),
                ),
            )
        end
    else
        throw(@error "cannot apply time series to single period data")
    end

    PM.update_data!(pm_data, pm_update)
end

function get_time_series_to_pm!(
    pm_data::Dict{String, Any},
    pm_category::String,
    pm_id::String,
    device::T,
    start_time::Dates.DateTime,
    time_period::Int,
) where {T <: PSY.RenewableGen}
    psy_forecast_name = "max_active_power" # change this line for different forecasts
    pm_field_name = "pmax"# change this line to apply forecast to different fields

    ts_data = PSY.get_time_series_values(
        PSY.AbstractDeterministic,
        device,
        psy_forecast_name,
        start_time = start_time,
    )
    if haskey(pm_data, "nw")
        throw(@error "cannot apply single time period data to multi-network")
    else
        pm_update = Dict{String, Any}(
            pm_category => Dict(pm_id => Dict(pm_field_name => ts_data[time_period])),
        )
    end

    PM.update_data!(pm_data, pm_update)
end
