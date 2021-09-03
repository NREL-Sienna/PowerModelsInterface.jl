
# TODO: add tests
# test PMmap
# test time series data insertion

GEN_EQ_FIELDS = ["gen_bus", "mbase", "pmax", "pmin", "model"]# "startup", "shutdown", "ncost", "cost", "qmin", "qmax"]
BUS_EQ_FIELDS = ["bus_i", "index", "bus_type", "name", "base_kv", "vmin", "vmax"]
BRANCH_EQ_FIELDS = ["f_bus", "t_bus", "br_status", "transformer", "br_r", "br_x"]
#=    "g_to",
    "g_fr",
    "b_fr",
    "b_to",
    "angmin",
    "angmax",
]=#

function compare_devices(pm_devices, pmi_devices, fields, match_expr)
    for (ix, pm_device) in pm_devices
        pmi_device_match = [d for (k, d) in pmi_devices if match_expr(d, pm_device)]
        for pmi_device in pmi_device_match
            match = true
            for field in fields
                match = isapprox(pm_device[field], pmi_device[field], atol = 0.01)
                !match && @show field, pm_device[field], pmi_device[field]
                !match && break
            end
            @test match
        end
    end
end

function compare_pm_pmi(fname::String)
    pm_data = PM.parse_file(fname)
    sys = System(fname)
    pmi_data = PMI.get_pm_data(sys)

    @test isempty(setdiff(keys(pm_data), keys(pmi_data)))
    for (cat, pm_devices) in pm_data
        @testset "$cat" begin
            @test haskey(pmi_data, cat)
            pmi_devices = get(pmi_data, cat, nothing)
            if !(typeof(pm_devices) <: AbstractString)
                @test isempty(setdiff(keys(pm_devices), keys(pmi_devices)))
                # TODO: check the indexing of buses, gens, and lines
                if cat == "gen"
                    compare_devices(
                        pm_devices,
                        pmi_devices,
                        GEN_EQ_FIELDS,
                        (d, pmd) -> d["gen_bus"] == pmd["gen_bus"],
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
                        (d, pmd) ->
                            (d["f_bus"] == pmd["f_bus"]) && (d["t_bus"] == pmd["t_bus"]),
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
