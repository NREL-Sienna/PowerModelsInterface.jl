function get_device_to_pm(
    ix::Int,
    shunt::L,
    device_formulation::Type{D},
) where {D <: Any, L <: PSY.FixedAdmittance}
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

function get_shunts_to_pm(sys::PSY.System, ::Type{T}) where {T <: PSY.FixedAdmittance}
    shunts = PSY.get_components(T, sys)
    PM_shunts = Dict{String, Any}()

    for (ix, shunt) in enumerate(shunts)
        PM_shunts["$(ix)"] = get_device_to_pm(ix, shunt, Any)
    end
    return PM_shunts
end
