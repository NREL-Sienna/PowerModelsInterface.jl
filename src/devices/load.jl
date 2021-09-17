function get_component_to_pm(ix::Int, load::L) where {L <: PSY.StaticLoad}
    PM_load = Dict{String, Any}(
        "source_id" => ["bus", PSY.get_name(PSY.get_bus(load))],
        "load_bus" => PSY.get_number(PSY.get_bus(load)),
        "status" => Int64(PSY.get_available(load)),
        "qd" => PSY.get_reactive_power(load), # TODO: get Q load from time series
        "pd" => PSY.get_active_power(load),
        "index" => ix,
    )
    return PM_load
end

function get_component_to_pm(ix::Int, shunt::L) where {L <: PSY.FixedAdmittance}
    PM_shunt = Dict{String, Any}(
        "source_id" => ["bus", PSY.get_name(PSY.get_bus(shunt))],
        "shunt_bus" => PSY.get_number(PSY.get_bus(shunt)),
        "status" => Int64(PSY.get_available(shunt)),
        "gs" => real(PSY.get_Y(shunt)),
        "bs" => imag(PSY.get_Y(shunt)),
        "index" => ix,
    )
    return PM_shunt
end

function get_time_series_to_pm!(
    pm_data::Dict{String, Any},
    pm_category::String,
    pm_id::String,
    device::T,
    initial_time::Dates.DateTime,
    time_periods::UnitRange{Int},
) where {T <: PSY.StaticLoad}
    psy_forecast_name = "max_active_power" # change this line for different forecasts
    pm_field_name = "pd" # change this line to apply forecast to different fields

    ts_data = PSY.get_time_series_values(
        PSY.Deterministic,
        device,
        psy_forecast_name,
        initial_time = initial_time,
        len = last(time_periods),
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
    initial_time::Dates.DateTime,
    time_period::Int,
) where {T <: PSY.StaticLoad}
    psy_forecast_name = "max_active_power" # change this line for different forecasts
    pm_field_name = "pd"# change this line to apply forecast to different fields

    ts_data = PSY.get_time_series_values(
        PSY.Deterministic,
        device,
        psy_forecast_name,
        initial_time = initial_time,
        len = time_period,
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
