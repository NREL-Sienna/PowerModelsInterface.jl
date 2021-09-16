function get_component_to_pm(
    ix::Int,
    storage::S,
    device_formulation::Type{D},
) where {D <: Any, S <: PSY.Storage}
    qlims = PSY.get_reactive_power_limits(storage)
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
        "qmax" => isnothing(qlims) ? 0.0 : qlims.max,
        "qmin" => isnothing(qlims) ? 0.0 : qlims.min,
        "charge_rating" => PSY.get_input_active_power_limits(storage).max,
        "discharge_efficiency" => PSY.get_efficiency(storage).out,
    )
    return PM_storage
end
