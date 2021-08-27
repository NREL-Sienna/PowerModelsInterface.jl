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

function PMmap(sys::PSY.System, template = default_template())
    PMmap_ac = get_pm_map_branches(sys, PSY.ACBranch, template.branches)
    PMmap_dc = get_pm_map_branches(sys, PSY.DCBranch, template.branches, length(PMmap_ac))
    PMmap_bus = get_pm_map_buses(sys, PSY.Bus)
    return PMmap(PMmap_bus, PMmap_ac, PMmap_dc)
end

# dummy template to enable default PSY -> PM mapping but allow for more control in PSI
function default_template()
    template = (
        branches = Dict{Symbol, Any}(
            :ACBranch => (formulation = Any, component_type = PSY.ACBranch),
            :DCBranch => (formulation = Any, component_type = PSY.DCBranch),
        ),
        devices = Dict{Symbol, Any}(
            :gens => (formulation = Any, component_type = PSY.Generator),
        ),
        network = PM.AbstractPowerModel,
    )
    return template
end

function get_pm_data(sys::PSY.System, template = default_template(), name::String = "")
    ac_lines = get_branches_to_pm(sys, PSY.ACBranch, template.branches, template.network)

    dc_lines = get_branches_to_pm(
        sys,
        PSY.DCBranch,
        template.branches,
        template.network,
        length(ac_lines),
    )

    pm_buses = get_buses_to_pm(sys, PSY.Bus)
    pm_shunts = get_shunts_to_pm(sys, PSY.FixedAdmittance)
    pm_gens = get_gens_to_pm(sys, PSY.Generator, template.devices, template.network)
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
        #"areas" => Dict{String, Any}(), # TODO: add if present in System
        "name" => name, # TODO: add name arg to function
        "source_type" => "PowerSystems.jl",
        "source_version" => PSY.DATA_FORMAT_VERSION,
    )

    return pm_data_translation
end

function apply_time_period!(
    pm_data::Dict{String, Any},
    sys::PSY.System,
    period::Dates.DateTime,
)
    #TODO: function apply time series from forecasts to the replicated network
end

function apply_time_series!(
    pm_data::Dict{String, Any},
    sys::PSY.System,
    initial_time::Dates.DateTime,
    time_periods::Int,
)
    multi_network = PM.replicate(pm_data, time_periods)
    for (ix, nw) in multi_network["nw"]
        period = initial_time + (PSY.get_resolution(sys) * (parse(Int64, ix) - 1))
        apply_time_period!(nw, sys, period)
    end
end
