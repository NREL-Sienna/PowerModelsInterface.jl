function bus_gen_values(data, solution, value_key)
    bus_pg = Dict(i => 0.0 for (i, bus) in data["bus"])
    for (i, gen) in data["gen"]
        bus_pg["$(gen["gen_bus"])"] += solution["gen"][i][value_key]
    end
    return bus_pg
end

function parse_pm_pmi(file)
    pm_data = PowerModels.parse_file(file)
    pmi_data = PMI.get_pm_data(System(file))
    #TODO: remove the following for loop once PM#v0.20.0 is tagged
    for id in keys(pmi_data["bus"])
        pm_data["bus"][id] = pmi_data["bus"][id]
    end
    return pm_data, pmi_data
end

@testset "Test Power Flow" begin
    file = joinpath(PM_DATA_DIR, "matpower", "case5.m")
    for (model, solver) in MODEL_SOLVER_MAP
        @testset "Testing $model with $(solver.optimizer_constructor.name.module)" begin
            pm_result = run_pf(file, model, solver)
            pmi_result = run_pf(System(file), model, solver)

            @test pm_result["termination_status"] == pmi_result["termination_status"]
            @test isapprox(pm_result["objective"], pmi_result["objective"]; atol = 1e-2)
        end
    end
end

@testset "Test Optimal PowerFlow" begin
    file = joinpath(PM_DATA_DIR, "matpower", "case5.m")
    data = PowerModels.parse_file(file)
    pmi_data = PMI.get_pm_data(System(file))

    for (model, solver) in MODEL_SOLVER_MAP
        pm_result = run_opf(data, model, solver)
        pmi_result = run_opf(pmi_data, model, solver)

        @test pm_result["termination_status"] == pmi_result["termination_status"]
        @test isapprox(pm_result["objective"], pmi_result["objective"]; atol = 1.8e1)
    end
end

@testset "Test DC PowerFlow" begin
    file = joinpath(PM_DATA_DIR, "matpower", "case5.m")
    data, pmi_data = parse_pm_pmi(file)
    pm_native = compute_dc_pf(data)
    pm_opt = run_dc_pf(data, ipopt_solver)
    ps_native = compute_dc_pf(System(file))
    ps_opt = run_dc_pf(System(file), ipopt_solver)

    @test ps_opt["termination_status"] == pm_opt["termination_status"] == LOCALLY_SOLVED

    for (i, bus) in data["bus"]
        @test isapprox(
            pm_opt["solution"]["bus"][i]["va"],
            ps_opt["solution"]["bus"][i]["va"];
            atol = 1e-7,
        )
        @test isapprox(
            pm_native["solution"]["bus"][i]["va"],
            ps_native["solution"]["bus"][i]["va"];
            atol = 1e-7,
        )
    end
end

@testset "5-bus case" begin
    file = joinpath(PM_DATA_DIR, "matpower", "case5.m")
    data, pmi_data = parse_pm_pmi(file)

    pm_native = compute_ac_pf(data)
    pm_opt = run_ac_pf(data, ipopt_solver)

    ps_native = compute_ac_pf(pmi_data)
    ps_opt = run_ac_pf(pmi_data, ipopt_solver)

    @test ps_opt["termination_status"] == pm_opt["termination_status"] == LOCALLY_SOLVED

    bus_pg_pm_opt = bus_gen_values(data, pm_opt["solution"], "pg")
    bus_qg_pm_opt = bus_gen_values(data, pm_opt["solution"], "qg")

    bus_pg_pm_native = bus_gen_values(data, pm_native["solution"], "pg")
    bus_qg_pm_native = bus_gen_values(data, pm_native["solution"], "qg")

    bus_pg_ps_opt = bus_gen_values(pmi_data, ps_opt["solution"], "pg")
    bus_qg_ps_opt = bus_gen_values(pmi_data, ps_opt["solution"], "qg")

    bus_pg_ps_native = bus_gen_values(pmi_data, ps_native["solution"], "pg")
    bus_qg_ps_native = bus_gen_values(pmi_data, ps_native["solution"], "qg")

    for (i, bus) in data["bus"]
        @test isapprox(
            pm_opt["solution"]["bus"][i]["va"],
            ps_opt["solution"]["bus"][i]["va"];
            atol = 1e-7,
        )
        @test isapprox(
            pm_opt["solution"]["bus"][i]["vm"],
            ps_opt["solution"]["bus"][i]["vm"];
            atol = 1e-7,
        )
        @test isapprox(
            pm_native["solution"]["bus"][i]["va"],
            ps_native["solution"]["bus"][i]["va"];
            atol = 1e-7,
        )
        @test isapprox(
            pm_native["solution"]["bus"][i]["vm"],
            ps_native["solution"]["bus"][i]["vm"];
            atol = 1e-7,
        )

        @test isapprox(bus_pg_pm_opt[i], bus_pg_ps_opt[i]; atol = 1e-6)
        @test isapprox(bus_qg_pm_opt[i], bus_qg_ps_opt[i]; atol = 1e-2)
        @test isapprox(bus_pg_pm_native[i], bus_pg_ps_native[i]; atol = 1e-6)
        @test isapprox(bus_qg_pm_native[i], bus_qg_ps_native[i]; atol = 1e-2)
    end
end
