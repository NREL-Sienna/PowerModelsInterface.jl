
function get_component_to_pm(
    ix::Int,
    branch::PSY.PhaseShiftingTransformer,
    device_formulation::Type{D},
) where {D <: Any}
    f_bus = PSY.get_number(PSY.get_arc(branch).from)
    t_bus = PSY.get_number(PSY.get_arc(branch).to)
    PM_branch = Dict{String, Any}(
        "source_id" => ["transformer", f_bus, t_bus, 0, PSY.get_name(branch), 0],
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => PSY.get_α(branch),
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch),
        "f_bus" => f_bus,
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => t_bus,
        "b_to" => PSY.get_primary_shunt(branch),
        "index" => ix,
        "angmin" => -π / 4,
        "angmax" => π / 4,
        "transformer" => true,
        "tap" => PSY.get_tap(branch),
    )
    return PM_branch
end

function get_component_to_pm(
    ix::Int,
    branch::PSY.Transformer2W,
    device_formulation::Type{D},
) where {D <: Any}
    f_bus = PSY.get_number(PSY.get_arc(branch).from)
    t_bus = PSY.get_number(PSY.get_arc(branch).to)
    PM_branch = Dict{String, Any}(
        "source_id" => ["transformer", f_bus, t_bus, 0, PSY.get_name(branch), 0],
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => 0.0,
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch),
        "f_bus" => f_bus,
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => t_bus,
        "b_to" => PSY.get_primary_shunt(branch),
        "index" => ix,
        "angmin" => -π / 4,
        "angmax" => π / 4,
        "transformer" => true,
        "tap" => 1.0,
    )
    return PM_branch
end

function get_component_to_pm(
    ix::Int,
    branch::PSY.TapTransformer,
    device_formulation::Type{D},
) where {D <: Any}
    f_bus = PSY.get_number(PSY.get_arc(branch).from)
    t_bus = PSY.get_number(PSY.get_arc(branch).to)
    PM_branch = Dict{String, Any}(
        "source_id" => ["transformer", f_bus, t_bus, 0, PSY.get_name(branch), 0],
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => 0.0,
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch),
        "f_bus" => f_bus,
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => t_bus,
        "b_to" => PSY.get_primary_shunt(branch),
        "index" => ix,
        "angmin" => -π / 4,
        "angmax" => π / 4,
        "transformer" => true,
        "tap" => PSY.get_tap(branch),
    )
    return PM_branch
end

function get_component_to_pm(
    ix::Int,
    branch::PSY.ACBranch,
    device_formulation::Type{D},
) where {D <: Any}
    f_bus = PSY.get_number(PSY.get_arc(branch).from)
    t_bus = PSY.get_number(PSY.get_arc(branch).to)
    PM_branch = Dict{String, Any}(
        "source_id" => ["branch", f_bus, t_bus, PSY.get_name(branch)],
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => 0.0,
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_b(branch).from,
        "f_bus" => f_bus,
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => t_bus,
        "b_to" => PSY.get_b(branch).to,
        "index" => ix,
        "angmin" => PSY.get_angle_limits(branch).min,
        "angmax" => PSY.get_angle_limits(branch).max,
        "transformer" => false,
        "tap" => 1.0,
    )
    return PM_branch
end

function get_component_to_pm(
    ix::Int,
    branch::PSY.HVDCLine,
    device_formulation::Type{D},
) where {D <: Any}
    f_bus = PSY.get_number(PSY.get_arc(branch).from)
    t_bus = PSY.get_number(PSY.get_arc(branch).to)
    PM_branch = Dict{String, Any}(
        "source_id" => ["branch", f_bus, t_bus, PSY.get_name(branch)],
        "loss1" => PSY.get_loss(branch).l1,
        "mp_pmax" => PSY.get_reactive_power_limits_from(branch).max,
        "model" => 2,
        "shutdown" => 0.0,
        "pmaxt" => PSY.get_active_power_limits_to(branch).max,
        "pmaxf" => PSY.get_active_power_limits_from(branch).max,
        "startup" => 0.0,
        "loss0" => PSY.get_loss(branch).l1,
        "pt" => 0.0,
        "vt" => PSY.get_magnitude(PSY.get_arc(branch).to),
        "qmaxf" => PSY.get_reactive_power_limits_from(branch).max,
        "pmint" => PSY.get_active_power_limits_to(branch).min,
        "f_bus" => f_bus,
        "mp_pmin" => PSY.get_reactive_power_limits_from(branch).min,
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => t_bus,
        "index" => ix,
        "qmint" => PSY.get_reactive_power_limits_to(branch).min,
        "qf" => 0.0,
        "cost" => 0.0,
        "pminf" => PSY.get_active_power_limits_from(branch).min,
        "qt" => 0.0,
        "qminf" => PSY.get_reactive_power_limits_from(branch).min,
        "vf" => PSY.get_magnitude(PSY.get_arc(branch).from),
        "qmaxt" => PSY.get_reactive_power_limits_to(branch).max,
        "ncost" => 0,
        "pf" => 0.0,
    )
    return PM_branch
end