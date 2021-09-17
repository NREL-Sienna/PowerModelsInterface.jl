function get_component_to_pm(ix::Int, bus::PSY.Bus)
    number = PSY.get_number(bus)
    zone = PSY.get_load_zone(bus)
    PM_bus = Dict{String, Any}(
        "zone" => isnothing(zone) ? "1" : PSY.get_name(zone),
        "bus_i" => number,
        "bus_type" => PM_BUSTYPES[PSY.get_bustype(bus)],
        "vmax" => PSY.get_voltage_limits(bus).max,
        "area" => 1,
        "vmin" => PSY.get_voltage_limits(bus).min,
        "index" => number,
        "va" => PSY.get_angle(bus),
        "vm" => PSY.get_magnitude(bus),
        "base_kv" => PSY.get_base_voltage(bus),
        "name" => PSY.get_name(bus),
        "source_id" => ["bus", number],
    )

    return PM_bus
end

function get_components_to_pm(sys::PSY.System, ::Type{PSY.Bus})
    buses = PSY.get_components(PSY.Bus, sys)
    PM_buses = Dict{String, Any}()

    for (ix, bus) in enumerate(buses)
        PM_buses[string(PSY.get_number(bus))] = get_component_to_pm(ix, bus)
    end
    return PM_buses
end

function get_pm_map(sys::PSY.System, ::Type{PSY.Bus})
     return Dict(string(PSY.get_number(b)) => b for b in PSY.get_components(PSY.Bus, sys))
end
