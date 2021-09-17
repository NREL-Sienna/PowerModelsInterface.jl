# PowerModelsInterface.jl

[![codecov](https://codecov.io/gh/nrel-siip/PowerModelsInterface.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/nrel-siip/PowerModelsInterface.jl)

PowerModelsInterface.jl is a Julia package for accessing routines from [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) with data contained in [PowerSystems.jl](https://github.com/nrel-siip/PowerSystems.jl).

## Installation

```julia
julia> ]
(v1.6) pkg> add https://github.com/nrel-siip/PowerModelsInterfaces.jl
```

## Usage

`PowerModelsInterface.jl` allows users to translate [PowerSystems.jl](https://github.com/NREL-SIIP/PowerSystems.jl) data into `PowerModels.jl` format and provides interfaces to key `PowerModels.jl` modeling functions. In particular, `PowerModelsInterface.jl` has three main capabilities:

1. Translate a [PowerSystems.jl `System`](https://nrel-siip.github.io/PowerSystems.jl/stable/modeler_guide/system/) into a [PowerModels.jl `Dict`](https://lanl-ansi.github.io/PowerModels.jl/stable/network-data/)

```julia
using PowerSystems, PowerModelsInterface
using PowerSystemCaseBuilder # data library
sys = build_system(PSITestSystems, "c_sys5") # example dataset

pm_data = get_pm_data(sys)
```

2. Apply time series from a [PowerSystems.jl `System`](https://nrel-siip.github.io/PowerSystems.jl/stable/modeler_guide/system/) to populate a [PowerModels.jl `Dict`](https://lanl-ansi.github.io/PowerModels.jl/stable/network-data/) or a [multi-network `Dict`](https://lanl-ansi.github.io/PowerModels.jl/stable/multi-networks/)

```julia
pm_data = get_pm_data(sys, initial_time = get_forecast_initial_times(sys)[2], period = 4) #applies data from the 4th period of the 2nd forecast to pm_data

mn_data = get_pm_data(sys, initial_time = get_forecast_initial_times(sys)[2], time_periods = 1:4) #applies data from the 4th period of the 2nd forecast to pm_data
```

3. Build and solve models with PowerModels using data from PowerSystems

```julia
using Ipopt

run_ac_opf(sys, Ipopt.Optimizer)

run_opf(
    sys,
    ACPPowerModel,
    Ipopt.Optimizer,
    initial_time = get_forecast_initial_times(sys)[2],
    period = 4,
)

run_mn_opf(
    sys,
    ACPPowerModel,
    Ipopt.Optimizer,
    initial_time = get_forecast_initial_times(sys)[2],
    time_periods = 1:get_forecast_horizon(sys),
)
```

## Development

Contributions to the development and enahancement of PowerSimulations is welcome. Please see [CONTRIBUTING.md](https://github.com/NREL-SIIP/PowerSimulations.jl/blob/master/CONTRIBUTING.md) for code contribution guidelines.

## License

PowerSimulations is released under a BSD [license](https://github.com/NREL/PowerSimulations.jl/blob/master/LICENSE). PowerSimulations has been developed as part of the Scalable Integrated Infrastructure Planning (SIIP)
initiative at the U.S. Department of Energy's National Renewable Energy Laboratory ([NREL](https://www.nrel.gov/))
