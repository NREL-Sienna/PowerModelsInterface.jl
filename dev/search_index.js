var documenterSearchIndex = {"docs":
[{"location":"PowerModelsInterface/#API_ref","page":"API","title":"PowerModelsInterface API Reference","text":"","category":"section"},{"location":"PowerModelsInterface/","page":"API","title":"API","text":"Modules = [PowerModelsInterface]","category":"page"},{"location":"PowerModelsInterface/#PowerModelsInterface.apply_time_period!-Tuple{Dict{String, Any}, PowerSystems.System, Dates.DateTime, Int64}","page":"API","title":"PowerModelsInterface.apply_time_period!","text":"Applies a single time period of time series data from a PowerSystems System to a PowerModels data dictionary.\n\nArguments\n\npm_data::Dict{String, Any}: PowerModels dictionary data\nsys::System: PowerSystems System\nstart_time::Dates.DateTime: initial time of Forecast\ntime_period::Int: time period index of Forecast\n\n\n\n\n\n","category":"method"},{"location":"PowerModelsInterface/#PowerModelsInterface.apply_time_series-Tuple{Dict{String, Any}, PowerSystems.System, Dates.DateTime, UnitRange{Int64}}","page":"API","title":"PowerModelsInterface.apply_time_series","text":"Applies time series data from a PowerSystems System to a PowerModels data dictionary.\n\nArguments\n\npm_data::Dict{String, Any}: PowerModels dictionary data\nsys::System: PowerSystems System\nstart_time::Dates.DateTime: initial time of Forecast\ntime_periods::UnitRange{Int}: time period indices of Forecast\n\n\n\n\n\n","category":"method"},{"location":"PowerModelsInterface/#PowerModelsInterface.get_pm_data-Tuple{PowerSystems.System}","page":"API","title":"PowerModelsInterface.get_pm_data","text":"Creates a PowerModels data dictionary from a PowerSystems System. To populate time series data in the resulting dataset, pass start_time kwarg along with either period for a single time period, or time_periods to create a multi-network dataset with multiple time periods\n\nArguments\n\nsys::System: PowerSystems System\n\nKey word arguments\n\nname::String: system name\nstart_time::DateTime: System forecast initial time\ntime_periods::UnitRange{Int}=1:PSY.get_forecast_horizon(sys): indices for selecting forecast periods. Valid extent is 1:horizon\nperiod::Int=1: index for selecting forecast period. Valid options\n\n\n\n\n\n","category":"method"},{"location":"#PowerModelsInterface.jl","page":"Welcome Page","title":"PowerModelsInterface.jl","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"CurrentModule = PowerModelsInterface","category":"page"},{"location":"#Overview","page":"Welcome Page","title":"Overview","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"PowerModelsInterface.jl is a Julia package that provides an interface between PowerSystems.jl and PowerModels.jl. PowerModelsInterface.jl has been developed under NREL's SIIP Initiative.","category":"page"},{"location":"#Installation","page":"Welcome Page","title":"Installation","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"The latest stable release of PowerModelsInterface.jl can be installed using the Julia package manager with","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"] add PowerModelsInterface","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"For the current development version, \"checkout\" this package with","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"] add PowerModelsInterface#main","category":"page"},{"location":"#Usage","page":"Welcome Page","title":"Usage","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"PowerModelsInterface.jl allows users to translate PowerSystems.jl data into PowerModels.jl format and provides interfaces to key PowerModels.jl modeling functions. In particular, PowerModelsInterface.jl has three main capabilities:","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"Translate a PowerSystems.jl System into a PowerModels.jl Dict","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"using PowerSystems, PowerModelsInterface\nusing PowerSystemCaseBuilder # data library\nsys = build_system(PSITestSystems, \"c_sys5\") # example dataset\n\npm_data = get_pm_data(sys)","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"Apply time series from a PowerSystems.jl System to populate a PowerModels.jl Dict or a multi-network Dict","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"pm_data = get_pm_data(sys, start_time = DateTime(\"2024-01-02T00:00:00\"), period = 4) #applies data from the 4th period of the 2nd forecast to pm_data\n\nmn_data = get_pm_data(sys, start_time = DateTime(\"2024-01-02T00:00:00\"), time_periods = 1:4) #applies data from the 4th period of the 2nd forecast to pm_data","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"Build and solve models with PowerModels using data from PowerSystems","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"using Ipopt\n\nrun_ac_opf(sys, Ipopt.Optimizer)\n\nrun_opf(\n    sys,\n    ACPPowerModel,\n    Ipopt.Optimizer,\n    start_time = DateTime(\"2024-01-02T00:00:00\"),\n    period = 4,\n)\n\nrun_mn_opf(\n    sys,\n    ACPPowerModel,\n    Ipopt.Optimizer,\n    start_time = DateTime(\"2024-01-02T00:00:00\"),\n    time_periods = 1:24,\n)","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"PowerModelsInterface has been developed as part of the Scalable Integrated Infrastructure Planning (SIIP) initiative at the U.S. Department of Energy's National Renewable Energy Laboratory (NREL)","category":"page"}]
}
