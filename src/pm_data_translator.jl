# allows PSI to keep track of which PM element corresponds to a specific PSY element
struct PMmap
    bus::Dict{Int, PSY.Bus}
    arcs::Dict{
        NamedTuple{(:from_to, :to_from), Tuple{Tuple{Int, Int, Int}, Tuple{Int, Int, Int}}},
        t where t <: PSY.ACBranch,
    }
    arcs_dc::Dict{
        NamedTuple{(:from_to, :to_from), Tuple{Tuple{Int, Int, Int}, Tuple{Int, Int, Int}}},
        t where t <: PSY.DCBranch,
    }
end

# dummy template to enable default PSY -> PM mapping but allow for more control in PSI
function default_template()
    template = (
        branches = Dict{Symbol, Any}(
        :ACBranch => (device_model = Any, component_type = PSY.ACBranch),
        :DCBranch => (device_model = Any, component_type = PSY.DCBranch),
        ),
        devices = Dict{Symbol, Any}(
            :gens => (device_model = Any, component_type = PSY.ACBranch),
            ),
        transmission = PM.AbstractPowerModel,
    )
    return template
end

function pass_to_pm(sys::PSY.System, pm_model, initial_time::Dates.DateTime, time_periods::Int, template = default_template())
    ac_lines, PMmap_ac = get_branches_to_pm(sys, PSY.ACBranch, template.branches, template.network)
    dc_lines, PMmap_dc = get_branches_to_pm(sys, PSY.DCBranch, template.branches, template.network, length(ac_lines))
    pm_buses = get_buses_to_pm(sys, PSY.Bus)
    pm_shunts = get_shunts_to_pm(sys, PSY.FixedAdmittance, template.devices)
    pm_gens = get_gens_to_pm(sys, PSY.Generator, template.devices, Any)
    pm_loads = get_loads_to_pm(sys, PSY.StaticLoad)
    pm_storages = get_storages_to_pm(sys, PSY.Storage)

    pm_data_translation = Dict{String, Any}(
        "bus" => pm_buses,
        "branch" => ac_lines,
        "baseMVA" => PSY.get_base_power(sys),
        "per_unit" => true,
        "storage" => pm_storages,
        "dcline" => dc_lines,
        "gen" => pm_gens,
        "switch" => Dict{String, Any}(), #not present in PSY
        "shunt" => pm_shunts,
        "load" => pm_loads,
    )

    pm_psy_data_map = PM.replicate(PM_translation, time_periods)

    #TODO: function apply time series from forecasts to the replicated network

    return pm_data_translation, pm_psy_data_map
end
