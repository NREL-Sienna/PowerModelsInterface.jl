@testset "Test Power Flow" begin
    for (model, solver) in MODEL_SOLVER_MAP
        result = run_pf("../test/data/matpower/case5.m", model, solver)

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 0; atol = 1e-2)

        result = run_pf(System("../test/data/matpower/case5.m"), model, solver)

        @test result["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result["objective"], 0; atol = 1e-2)
    end
end

@testset "Test Optimal PowerFlow" begin
    for (model, solver) in MODEL_SOLVER_MAP
        result = run_opf("../test/data/matpower/case5.m", model, solver)

        @test result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 15051.4; atol = 1e1)

        result = run_opf(System("../test/data/matpower/case5.m"), model, solver)

        @test result["termination_status"] == OPTIMAL
        @test isapprox(result["objective"], 15051.4; atol = 1e1)
    end
end

@testset "Test DC PowerFlow" begin
    file = "../test/data/matpower/case5.m"
    result_pm = run_dc_pf(PowerModels.parse_file(file), ipopt_solver)
    pm_native = compute_dc_pf(System("file"))
    pm_opt = run_dc_pf(System("file"), ipopt_solver)

    for (i,bus) in data["bus"]
        result_pm = result["solution"]["bus"][i]["va"]
        pm_native = result["solution"]["bus"][i]["va"]
        pm_opt = native["solution"]["bus"][i]["va"]
        @test isapprox(result_pm, pm_native; atol = 1e-10)
        @test isapprox(result_pm, pm_opt; atol = 1e-10)
    end
end

@testset "5-bus case" begin
        file = "../test/data/matpower/case5.m"
        result_pm = run_ac_pf(PowerModels.parse_file(file), ipopt_solver)
        pm_native = compute_ac_pf(System(file))
        pm_opt = run_ac_pf(System(file), ipopt_solver)

        @test pm_opt["termination_status"] == LOCALLY_SOLVED

        bus_pg_pm = bus_gen_values(data, result_pm["solution"], "pg")
        bus_pg_pm = bus_gen_values(data, result_pm["solution"], "qg")

        bus_pg_native = bus_gen_values(data, pm_native["solution"], "pg")
        bus_qg_native = bus_gen_values(data, pm_native["solution"], "qg")

        bus_pg_native = bus_gen_values(data, pm_native["solution"], "pg")
        bus_qg_native = bus_gen_values(data, pm_native["solution"], "qg")

        for (i,bus) in data["bus"]
            @test isapprox(result["solution"]["bus"][i]["va"], native["solution"]["bus"][i]["va"]; atol = 1e-7)
            @test isapprox(result["solution"]["bus"][i]["vm"], native["solution"]["bus"][i]["vm"]; atol = 1e-7)

            @test isapprox(bus_pg_nlp[i], bus_pg_nls[i]; atol = 1e-6)
            @test isapprox(bus_qg_nlp[i], bus_qg_nls[i]; atol = 1e-6)
        end
end
