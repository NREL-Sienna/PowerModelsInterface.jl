const pm_bustypes = Dict{PSY.BusTypes, Int}(
    PSY.BusTypes.ISOLATED => 4,
    PSY.BusTypes.PQ => 1,
    PSY.BusTypes.PV => 2,
    PSY.BusTypes.REF => 3,
    PSY.BusTypes.SLACK => 3,
)

function get_device_to_pm(
    ix::Int,
    bus::B,
    device_formulation::Type{D},
) where {D <: Any, B <: PSY.Bus}
    number = PSY.get_number(bus)
    PM_bus = Dict{String, Any}(
        "zone" => 1,
        "bus_i" => PSY.get_number(bus),
        "bus_type" => pm_bustypes[PSY.get_bustype(bus)],
        "vmax" => PSY.get_voltage_limits(bus).max,
        "area" => 1,
        "vmin" => PSY.get_voltage_limits(bus).min,
        "index" => PSY.get_number(bus),
        "va" => PSY.get_angle(bus),
        "vm" => PSY.get_magnitude(bus),
        "base_kv" => PSY.get_base_voltage(bus),
        "inj_p" => 0.0,
        "inj_q" => 0.0,
        "name" => PSY.get_name(bus),
    )

    return PM_bus
end

function get_devices_to_pm(sys::PSY.System, ::Type{T}) where {T <: PSY.Bus}
    buses = PSY.get_components(PSY.Bus, sys)
    PM_buses = Dict{String, Any}()

    for (ix, bus) in enumerate(buses)
        number = PSY.get_number(bus)
        PM_buses["$(number)"] = get_device_to_pm(ix, bus, Any)
    end
    return PM_buses
end

function get_pm_map(sys::PSY.System, ::Type{T}) where {T <: PSY.Bus}
    buses = PSY.get_components(PSY.Bus, sys)
    pm_map = Dict{String, PSY.Bus}()

    for bus in buses
        number = PSY.get_number(bus)
        if PSY.get_bustype(bus) != PSY.BusTypes.ISOLATED::PSY.BusTypes
            pm_map["$number"] = bus
        end
    end
    return pm_map
end
