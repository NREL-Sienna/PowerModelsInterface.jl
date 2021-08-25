
function add_pm_cost!(PM_gen::Dict{String, Any}, op_cost::T) where {T <: PSY.ThreePartCost}
    #TODO figure out how to convert PSY cost into PM cost
    PM_gen["shutdown"] = PSY.get_start_up(op_cost)
    PM_gen["startup"] = PSY.get_shut_down(op_cost)
    add_pm_var_cost!(PM_gen, PSY.get_variable(op_cost))
    return PM_gen
end

function add_pm_cost!(PM_gen::Dict{String, Any}, op_cost::T) where {T <: PSY.TwoPartCost}
    #TODO figure out how to convert PSY cost into PM cost
    PM_gen["shutdown"] = 0.0
    PM_gen["startup"] = 0.0
    add_pm_var_cost!(PM_gen, PSY.get_variable(op_cost))
    return PM_gen
end

# polynomial cost
function add_pm_var_cost!(PM_gen::Dict{String, Any}, var_cost::VariableCost{Tuple})
    PM_gen["model"] = 2
    PM_gen["ncost"] = length(var_cost)
    PM_gen["cost"] = [c for c in reverse(PSY.get_cost(var_cost))]
    return PM_gen
end

# pwl cost
function add_pm_var_cost!(
    PM_gen::Dict{String, Any},
    var_cost::VariableCost{Vector{Tuple{Float64, Float64}}},
)
    PM_gen["model"] = 1
    PM_gen["ncost"] = length(var_cost)
    PM_gen["cost"] = Vector{Float64}()
    for c in var_cost
        push!(PM_gen["cost"], last(c))
        push!(PM_gen["cost"], first(c))
    end
    return PM_gen
end

function pm_gen_core(gen::T) where {T <: PSY.Generator}
    PM_gen = Dict{String, Any}(
        "index" => ix,
        "name" => PSY.get_name(gen),
        "gen_bus" => PSY.get_number(PSY.get_bus(gen)),
        "source_id" => ["gen", ix],
        "mbase" => PSY.get_base_power(gen),
        "gen_status" => PSY.get_available(gen),
        "pg" => PSY.get_active_power(gen),
        "qg" => PSY.get_reactive_power(gen),
        "vg" => PSY.get_magnitude(PSY.get_bus(gen)),
        "pmax" => PSY.get_max_active_power(gen),
        "qmax" => PSY.get_max_reactive_power(gen),
        "qmin" => PSY.get_reactive_power_limits(gen).min,
        "type" => string(PSY.get_prime_mover(gen)),
    )
    return PM_gen
end

function get_device_to_pm(
    ix::Int,
    gen::Type{T},
    device_formulation::Type{D},
) where {D <: Any, T <: PSY.ThermalGen}
    PM_gen = pm_gen_core(gen)
    ramp = PSY.get_ramp_limits(gen).up
    merge!(
        PM_gen,
        Dict{String, Any}(
            "pmin" => PSY.get_active_power_limits(gen).min,
            "fuel" => string(PSY.get_fuel(gen)),
            "ramp_q" => ramp,
            "ramp_agc" => ramp,
            "ramp_10" => ramp,
            "ramp_30" => ramp,
        ),
    )
    add_pm_cost!(PM_gen, PSY.get_operational_cost(gen))
    return PM_gen
end

function get_device_to_pm(
    ix::Int,
    gen::Type{T},
    device_formulation::Type{D},
) where {D <: Any, T <: PSY.RenewableGen}
    PM_gen = pm_gen_core(gen)
    merge!(PM_gen, Dict{String, Any}("pmin" => 0.0))
    add_pm_cost!(PM_gen, PSY.get_operational_cost(gen))
    return PM_gen
end

function get_device_to_pm(
    ix::Int,
    gen::Type{T},
    device_formulation::Type{D},
) where {D <: Any, T <: PSY.HydroGen}
    PM_gen = pm_gen_core(gen)
    ramp = PSY.get_ramp_limits(gen).up
    merge!(
        PM_gen,
        Dict{String, Any}(
            "pmin" => PSY.get_active_power_limits(gen).min,
            "ramp_q" => ramp,
            "ramp_agc" => ramp,
            "ramp_10" => ramp,
            "ramp_30" => ramp,
        ),
    )
    add_pm_cost!(PM_gen, PSY.get_operational_cost(gen))
    return PM_gen
end

function get_gens_to_pm(
    sys::PSY.System,
    gen_type::Type{T},
    gen_template::Dict{Symbol, Any},
    system_formulation::Type{S},
    start_idx = 0,
) where {T <: PSY.Generator, S <: PM.AbstractPowerModel}
    PM_gens = Dict{String, Any}()

    for (d, device_model) in gen_template
        !(device_model.component_type <: gen_type) && continue
        start_idx += length(PM_gens)
        for (i, gen) in enumerate(get_components(device_model.component_type, sys))
            ix = i + start_idx
            PM_gens["$(ix)"] = get_device_to_pm(ix, gen, device_model.formulation)
        end
    end
    return PM_gens
end
