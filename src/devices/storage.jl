function get_device_to_pm(
    ix::Int,
    storage::S,
    device_formulation::Type{D},
) where {D <: Any, S <: PSY.Storage}
    PM_storage = Dict{String, Any}(
        "x" => 0.0,
        "r" => 0.0,
        "ps" => 0.0,
        "qs" => 0.0,
        "p_loss" => 0.0,
        "q_loss" => 0.0,
        "energy" => PSY.get_initial_energy(storage),
        "energy_rating" => PSY.get_state_of_charge_limits(storage).max,
        "thermal_rating" => PSY.get_rating(storage),
        "status" => PSY.get_available(storage),
        "source_id" => Any["storage", ix],
        "discharge_rating" => PSY.get_output_active_power_limits(storage).max,
        "storage_bus" => PSY.get_number(PSY.get_bus(storage)),
        "name" => PSY.get_name(storage),
        "charge_efficiency" => PSY.get_efficiency(storage).in,
        "index" => ix,
        "qmax" => PSY.get_max_reactive_power(storage),
        "qmin" => PSY.get_reactive_power_limits(storage).min,
        "charge_rating" => PSY.get_input_active_power_limits(storage).max,
        "discharge_efficiency" => PSY.get_efficiency(storage).out,
    )
    return PM_storage
end

function get_storages_to_pm(sys::PSY.system, ::Type{T}) where {T <: PSY.Storage}
    storages = PSY.get_components(T, sys)
    PM_storages = Dict{String, Any}()

    for (ix, storage) in enumerate(storages)
        PM_storages["$(ix)"] = get_device_to_pm(ix, storage, Any)
    end
    return PM_storages
end
