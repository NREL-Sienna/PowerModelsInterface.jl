
function get_components_to_pm(sys::PSY.System, ::Type{T}) where {T <: PSY.Area}
    areas = PSY.get_components(PSY.Area, sys)

    PM_areas = Dict{String, Any}()

    for (ix, area) in enumerate(areas)
        buses = PSY.get_buses(sys, area)
        ref_bus = [b for b in buses if PSY.get_bustype(b) == PSY.BusTypes.REF]
        if length(ref_bus) == 1
            ref_bus = ref_bus[1]
        elseif PSY.BusTypes.PV ∈ PSY.get_bustype.(buses)
            # get largest gen bus
            pv_buses = [b for b in buses if PSY.get_bustype(b) == PSY.BusTypes.PV]
            gens = PSY.get_components(PSY.Generator, sys, x -> PSY.get_bus(x) ∈ pv_buses)
            ref_bus = PSY.get_bus(
                last(sort(collect(gens), by = x -> PSY.get_max_active_power(x))),
            )
        else
            ref_bus = buses[1]
        end

        PM_areas["$(ix)"] = Dict{String, Any}(
            "source_id" => ["areas", ix],
            "col_1" => ix,
            "col_2" => PSY.get_number(ref_bus),
            "index" => ix,
        )
    end
    return PM_areas
end
