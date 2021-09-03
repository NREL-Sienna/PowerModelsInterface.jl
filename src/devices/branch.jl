
function get_device_to_pm(
    ix::Int,
    branch::PSY.PhaseShiftingTransformer,
    device_formulation::Type{D},
) where {D <: Any}
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => PSY.get_α(branch),
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch) / 2,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_primary_shunt(branch) / 2,
        "index" => ix,
        "angmin" => -π / 2,
        "angmax" => π / 2,
        "transformer" => true,
        "tap" => PSY.get_tap(branch),
    )
    return PM_branch
end

# TODO: move this to PSI
#=
function get_device_to_pm(
    ix::Int,
    branch::PSY.PhaseShiftingTransformer,
    device_formulation::Type{StaticBranchUnbounded},
)
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "shift" => PSY.get_α(branch),
        "br_x" => PSY.get_x(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch) / 2,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_primary_shunt(branch) / 2,
        "index" => ix,
        "angmin" => -π / 2,
        "angmax" => π / 2,
        "transformer" => true,
        "tap" => PSY.get_tap(branch),
    )
    return PM_branch
end
=#

function get_device_to_pm(
    ix::Int,
    branch::PSY.Transformer2W,
    device_formulation::Type{D},
) where {D <: Any}
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => 0.0,
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch) / 2,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_primary_shunt(branch) / 2,
        "index" => ix,
        "angmin" => -π / 2,
        "angmax" => π / 2,
        "transformer" => true,
        "tap" => 1.0,
    )
    return PM_branch
end

# TODO: move this to PSI
#=
function get_device_to_pm(
    ix::Int,
    branch::PSY.Transformer2W,
    device_formulation::Type{StaticBranchUnbounded},
)
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "shift" => 0.0,
        "br_x" => PSY.get_x(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch) / 2,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_primary_shunt(branch) / 2,
        "index" => ix,
        "angmin" => -π / 2,
        "angmax" => π / 2,
        "transformer" => true,
        "tap" => 1.0,
    )
    return PM_branch
end
=#

function get_device_to_pm(
    ix::Int,
    branch::PSY.TapTransformer,
    device_formulation::Type{D},
) where {D <: Any}
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => 0.0,
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch) / 2,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_primary_shunt(branch) / 2,
        "index" => ix,
        "angmin" => -π / 2,
        "angmax" => π / 2,
        "transformer" => true,
        "tap" => PSY.get_tap(branch),
    )
    return PM_branch
end

# TODO: move this to PSI
#=
function get_device_to_pm(
    ix::Int,
    branch::PSY.TapTransformer,
    device_formulation::Type{StaticBranchUnbounded},
)
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "shift" => 0.0,
        "br_x" => PSY.get_x(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_primary_shunt(branch) / 2,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_primary_shunt(branch) / 2,
        "index" => ix,
        "angmin" => -π / 2,
        "angmax" => π / 2,
        "transformer" => true,
        "tap" => PSY.get_tap(branch),
    )
    return PM_branch
end
=#

function get_device_to_pm(
    ix::Int,
    branch::PSY.ACBranch,
    device_formulation::Type{D},
) where {D <: Any}
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "rate_a" => PSY.get_rate(branch),
        "shift" => 0.0,
        "rate_b" => PSY.get_rate(branch),
        "br_x" => PSY.get_x(branch),
        "rate_c" => PSY.get_rate(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_b(branch).from,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_b(branch).to,
        "index" => ix,
        "angmin" => PSY.get_angle_limits(branch).min,
        "angmax" => PSY.get_angle_limits(branch).max,
        "transformer" => false,
        "tap" => 1.0,
    )
    return PM_branch
end

# TODO: move this to PSI
#=
function get_device_to_pm(
    ix::Int,
    branch::PSY.ACBranch,
    device_formulation::Type{StaticBranchUnbounded},
)
    PM_branch = Dict{String, Any}(
        "br_r" => PSY.get_r(branch),
        "shift" => 0.0,
        "br_x" => PSY.get_x(branch),
        "g_to" => 0.0,
        "g_fr" => 0.0,
        "b_fr" => PSY.get_b(branch).from,
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
        "b_to" => PSY.get_b(branch).to,
        "index" => ix,
        "angmin" => PSY.get_angle_limits(branch).min,
        "angmax" => PSY.get_angle_limits(branch).max,
        "transformer" => false,
        "tap" => 1.0,
    )
    return PM_branch
end
=#

function get_device_to_pm(
    ix::Int,
    branch::PSY.HVDCLine,
    device_formulation::Type{D},
) where {D <: Any}
    PM_branch = Dict{String, Any}(
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
        "f_bus" => PSY.get_number(PSY.get_arc(branch).from),
        "mp_pmin" => PSY.get_reactive_power_limits_from(branch).min,
        "br_status" => Float64(PSY.get_available(branch)),
        "t_bus" => PSY.get_number(PSY.get_arc(branch).to),
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
#=
function get_pm_map(
    sys::PSY.System,
    branch_type::Type{T},
    branch_template::Dict{Symbol, Any},
    start_idx = 0,
) where {T <: PSY.Branch}
    PMmap_br = Dict{
        NamedTuple{(:from_to, :to_from), Tuple{Tuple{Int, Int, Int}, Tuple{Int, Int, Int}}},
        t where t <: T,
    }()

    for (d, device_model) in branch_template
        !(device_model.component_type <: branch_type) && continue
        start_idx += length(PMmap_br)
        branches = PSY.get_components(device_model.component_type, sys)
        for (i, branch) in enumerate(branches)
            ix = i + start_idx
            arc = PSY.get_arc(branch)
            f = PSY.get_number(PSY.get_from(arc))
            t = PSY.get_number(PSY.get_to(arc))
            PMmap_br[(from_to = (ix, f, t), to_from = (ix, t, f))] = branch
        end
    end
    return PMmap_br
end
=#
# TODO: move this to PSI
#=
function get_branches_to_pm(
    sys::PSY.System,
    system_formulation::Type{PTDFPowerModel},
    ::Type{T},
    start_idx = 0,
) where {T <: PSY.DCBranch}
    PM_branches = Dict{String, Any}()
    PMmap_br = Dict{
        NamedTuple{(:from_to, :to_from), Tuple{Tuple{Int, Int, Int}, Tuple{Int, Int, Int}}},
        t where t <: T,
    }()

    return PM_branches, PMmap_br
end
=#
