
# TODO: add tests
# test PMmap
# test time series data insertion

GEN_EQ_FIELDS = ["gen_bus", "mbase", "pmax", "pmin", "startup", "shutdown", "ncost", "cost"]#"qmin", "qmax"]
BUS_EQ_FIELDS = ["bus_i", "index", "base_kv", "vmin", "vmax"] #, "name", "bus_type"]
BRANCH_EQ_FIELDS = ["f_bus", "t_bus", "br_status", "br_r", "br_x"] #"transformer"]
#=    "g_to",
    "g_fr",
    "b_fr",
    "b_to",
    "angmin",
    "angmax",
]=#
COMPARISON_CATS = [
    "bus",
    "branch",
    "baseMVA",
    "per_unit",
    "storage",
    "dc_line",
    "gen",
    #"switch", #not represented in PSY
    "areas",
    "shunt",
    "load",
    "name",
    "source_type",
    "source_version",
]

function compare_devices(pm_devices, pmi_devices, fields, match_expr)
    for (ix, pm_device) in pm_devices
        pmi_device_match = [d for (k, d) in pmi_devices if match_expr(d, pm_device)]
        for pmi_device in pmi_device_match
            match = true
            for field in fields
                if haskey(pm_device, field)
                    match = isapprox(pm_device[field], pmi_device[field], atol = 0.01)
                    !match && @show ix, field, pm_device[field], pmi_device[field]
                    !match && break
                end
            end
            @test match
        end
    end
end

function select_matching_br(pmi_device, pm_device)
    br_type = first(pmi_device["source_id"])
    first(pm_device["source_id"]) != br_type && return false

    if br_type == "transformer"
        id = last(split(pmi_device["source_id"][end - 1], "_"))
    else
        id = replace(last(split(pmi_device["source_id"][end], "_")), "Branch " => "")
    end
    return pm_device["index"] == parse(Int, id)
end

function compare_pm_pmi(fname::String)
    pm_data = try
        PM.parse_file(fname)
    catch
        @warn "skipping testing of $fname due to PowerModels parsing error"
        return
    end
    sys = System(fname)
    pmi_data = PMI.get_pm_data(sys)

    # there is no guarantee that we represent all data categories that PM does, so filter by the ones we care about
    pm_cats = intersect(COMPARISON_CATS, keys(pm_data))

    @test isempty(setdiff(pm_cats, keys(pmi_data)))
    for cat in pm_cats
        pm_devices = pm_data[cat]
        @testset "$cat" begin
            @test haskey(pmi_data, cat)
            pmi_devices = get(pmi_data, cat, nothing)
            if !(typeof(pm_devices) <: AbstractString)
                @test isempty(setdiff(keys(pm_devices), keys(pmi_devices)))
                if cat == "gen"
                    compare_devices(
                        pm_devices,
                        pmi_devices,
                        GEN_EQ_FIELDS,
                        (d, pmd) ->
                            join(strip.(string.(d["source_id"])), "-") ==
                            join(strip.(string.(pmd["source_id"])), "-"),
                    )
                elseif cat == "bus"
                    compare_devices(
                        pm_devices,
                        pmi_devices,
                        BUS_EQ_FIELDS,
                        (d, pmd) -> d["index"] == pmd["index"],
                    )
                elseif cat == "branch"
                    compare_devices(
                        pm_devices,
                        pmi_devices,
                        BRANCH_EQ_FIELDS,
                        select_matching_br,
                    )
                end
            end
        end
    end
end

@testset "Test PMI and PM data equivelance" begin
    for (root, dirs, files) in walkdir(PM_DATA_DIR)
        for file in files
            if !occursin("parser_test", file)
                @testset "$file" begin
                    compare_pm_pmi(joinpath(root, file))
                end
            end
        end
    end
end
