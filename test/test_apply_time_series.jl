
@testset "Test time series data application" begin
    sys = PSB.build_system(PSB.PSITestSystems, "c_sys5")
    pmi_data = PMI.get_pm_data(sys)

    mn_data =
        PMI.apply_time_series(pmi_data, sys, last(PSY.get_forecast_initial_times(sys)), 3:5)

    @test mn_data["multinetwork"]
    @test length(mn_data["nw"]) == 3

    pmi_mn_data = PMI.get_pm_data(
        sys,
        initial_time = last(PSY.get_forecast_initial_times(sys)),
        time_periods = 3:5,
    )

    @test mn_data == pmi_mn_data

    tp_data = PMI.get_pm_data(
        sys,
        initial_time = first(PSY.get_forecast_initial_times(sys)),
        period = 5,
    )

    @test tp_data != pmi_data

    PMI.apply_time_period!(pmi_data, sys, first(PSY.get_forecast_initial_times(sys)), 5)

    @test tp_data == pmi_data

    #TODO: add tests to verify data is being applied correctly
end
