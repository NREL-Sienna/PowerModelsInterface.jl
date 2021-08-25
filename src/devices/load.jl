function get_device_to_pm(
    ix::Int,
    load::L,
    device_formulation::Type{D},
) where {D <: Any, L <: PSY.StaticLoad}
    PM_load = Dict{String,Any}(
        "source_id" => ["bus", PSY.get_name(PSY.get_bus(load))],
        "load_bus" => PSY.get_number(PSY.get_bus(load)),
        "status" => Int64(PSY.get_available(load)),
        "qd" => PSY.get_reactive_power(load), # TODO: get load from time series
        "pd" => PSY.get_active_power(load),  # TODO: get load from time series
        "index" => ix,
    )
    return PM_load
end

function get_loads_to_pm(sys::PSY.system, ::Type{T}) where T <: PSY.StaticLoad
    loads = PSY.get_components(T, sys)
    PM_loads = Dict{String, Any}()

    for (ix, load) in enumerate(loads)
        PM_loads["$(ix)"] = get_device_to_pm(ix, load, Any)
    end
    return PM_shunts
end