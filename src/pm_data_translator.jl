
function get_pm_map(sys::PSY.System)
    pm_map = Dict(
        "branch" => get_pm_map(sys, PSY.ACBranch),
        "dcline" => get_pm_map(sys, PSY.DCBranch),
        "bus" => get_pm_map(sys, PSY.Bus),
        "shunt" => get_pm_map(sys, PSY.FixedAdmittance),
        "load" => get_pm_map(sys, PSY.StaticLoad),
        "gen" => get_pm_map(sys, PSY.Generator),
        "storage" => get_pm_map(sys, PSY.Storage),
    )
    return pm_map
end

function get_pm_map(sys::PSY.System, ::Type{T}) where {T <: PSY.Component}
    return Dict(string(ix) => d for (ix, d) in enumerate(PSY.get_components(T, sys)))
end

function get_components_to_pm(
    sys::PSY.System,
    device_type::Type{T},
) where {T <: PSY.Component}
    devices = PSY.get_components(T, sys)
    PM_devices = Dict{String, Any}()
    for (ix, device) in enumerate(devices)
        PM_devices["$(ix)"] = get_component_to_pm(ix, device)
    end
    return PM_devices
end

"""
Creates a PowerModels data dictionary from a PowerSystems `System`. To populate time series
data in the resulting dataset, pass `start_time` kwarg along with either `period` for a
single time period, or `time_periods` to create a multi-network dataset with multiple time periods

# Arguments
- `sys::System`: PowerSystems System

# Key word arguments
- `name::String`: system name
- `start_time::DateTime`: `System` forecast initial time
- `time_periods::UnitRange{Int}=1:PSY.get_forecast_horizon(sys)`: indices for selecting forecast periods. Valid extent is `1:horizon`
- `period::Int=1`: index for selecting forecast period. Valid options
"""
function get_pm_data(sys::PSY.System; kwargs...)
    PSY.set_units_base_system!(sys, "SYSTEM_BASE")

    ac_lines = get_components_to_pm(sys, PSY.ACBranch)
    dc_lines = get_components_to_pm(sys, PSY.DCBranch)
    pm_buses = get_components_to_pm(sys, PSY.Bus)
    pm_shunts = get_components_to_pm(sys, PSY.FixedAdmittance)
    pm_gens = get_components_to_pm(sys, PSY.Generator)
    pm_loads = get_components_to_pm(sys, PSY.StaticLoad)
    pm_storages = get_components_to_pm(sys, PSY.Storage)
    pm_areas = get_components_to_pm(sys, PSY.Area)

    pm_data_translation = Dict{String, Any}(
        "bus" => pm_buses,
        "branch" => ac_lines,
        "baseMVA" => PSY.get_base_power(sys),
        "per_unit" => true,
        "storage" => pm_storages,
        "dcline" => dc_lines,
        "gen" => pm_gens,
        "switch" => Dict{String, Any}(), #not present in PSY
        "shunt" => pm_shunts,
        "load" => pm_loads,
        "areas" => pm_areas,
        "name" => get(kwargs, :name, ""), # TODO: add name to PSY.System
        "source_type" => "PowerSystems.jl",
        "source_version" => PSY.DATA_FORMAT_VERSION,
    )

    start_time = get(kwargs, :start_time, nothing)
    if !isnothing(start_time)
        if haskey(kwargs, :time_periods)
            time_periods = get(kwargs, :time_periods, 1:PSY.get_forecast_horizon(sys))
            @info "applying the $time_periods periods from the $start_time forecast"
            pm_data_translation = apply_time_series(
                pm_data_translation,
                sys,
                kwargs[:start_time],
                time_periods,
            )
        else
            period = get(kwargs, :period, 1)
            @info "applying the $period period from the $start_time forecast"
            apply_time_period!(pm_data_translation, sys, kwargs[:start_time], period)
        end
    end

    return pm_data_translation
end

function get_time_series_to_pm!(
    pm_data::Dict{String, Any},
    pm_category::String,
    pm_id::String,
    component::T,
    start_time::Dates.DateTime,
    time_periods::Union{UnitRange{Int}, Int},
) where {T <: PSY.Component}
    return # do nothing by default
end

function check_forecasts(sys::PSY.System)
    if PSY.get_time_series_counts(sys) == (0, 0, 0)
        throw(error("System has no time series: cannot create multinetwork"))
    elseif isempty(PSY.get_forecast_initial_times(sys))
        throw(
            error(
                "System has no Forecast data: run `PowerSystems.transform_single_time_series!`",
            ),
        )
    end
end

"""
Applies time series data from a PowerSystems `System` to a PowerModels data dictionary.

# Arguments
- `pm_data::Dict{String, Any}`: PowerModels dictionary data
- `sys::System`: PowerSystems System
- `start_time::Dates.DateTime`: initial time of `Forecast`
- `time_periods::UnitRange{Int}`: time period indices of `Forecast`
"""
function apply_time_series(
    pm_data::Dict{String, Any},
    sys::PSY.System,
    start_time::Dates.DateTime,
    time_periods::UnitRange{Int},
)
    check_forecasts(sys)
    pm_data =
        PM._IM.ismultinetwork(pm_data) ? pm_data :
        PM.replicate(pm_data, length(time_periods))
    @assert length(pm_data["nw"]) == length(time_periods)

    pm_map = get_pm_map(sys)

    for key in ["load", "gen", "shunt"]
        for (id, device) in pm_map[key]
            get_time_series_to_pm!(pm_data, key, id, device, start_time, time_periods)
        end
    end
    return pm_data
end

"""
Applies a single time period of time series data from a PowerSystems `System` to a PowerModels data dictionary.

# Arguments
- `pm_data::Dict{String, Any}`: PowerModels dictionary data
- `sys::System`: PowerSystems System
- `start_time::Dates.DateTime`: initial time of `Forecast`
- `time_period::Int`: time period index of `Forecast`
"""
function apply_time_period!(
    pm_data::Dict{String, Any},
    sys::PSY.System,
    start_time::Dates.DateTime,
    time_period::Int,
)
    check_forecasts(sys)
    pm_map = get_pm_map(sys)

    for key in ["load", "gen", "shunt"]
        for (id, device) in pm_map[key]
            get_time_series_to_pm!(pm_data, key, id, device, start_time, time_period)
        end
    end
    return pm_data
end
