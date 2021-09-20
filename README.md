# PowerModelsInterface.jl

[![Main - CI](https://github.com/NREL-SIIP/PowerModelsInterface.jl/actions/workflows/master-tests.yml/badge.svg)](https://github.com/NREL-SIIP/PowerModelsInterface.jl/actions/workflows/master-tests.yml)
[![codecov](https://codecov.io/gh/nrel-siip/PowerModelsInterface.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/nrel-siip/PowerModelsInterface.jl)
[![Documentation](https://github.com/NREL-SIIP/PowerModelsInterface.jl/workflows/Documentation/badge.svg)](https://nrel-siip.github.io/PowerModelsInterface.jl/latest)
[<img src="https://img.shields.io/badge/slack-@SIIP/PMI-blue.svg?logo=slack">](https://join.slack.com/t/nrel-siip/shared_invite/zt-glam9vdu-o8A9TwZTZqqNTKHa7q3BpQ)
PowerModelsInterface.jl is a Julia package for accessing routines from [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) with data contained in [PowerSystems.jl](https://github.com/nrel-siip/PowerSystems.jl).

**This package is under development and is a work in progress.** The 0.1.0 tag is being used in the development of PowerSimulations.jl and it is subject to change. Current features will remain supported, and if new features are particularly useful, please open an issue. As always, PRs are welcome.

## Installation

```julia
julia> ]
(v1.6) pkg> add PowerModelsInterface
```

## Usage

`PowerModelsInterface.jl` allows users to translate [PowerSystems.jl](https://github.com/NREL-SIIP/PowerSystems.jl) data into `PowerModels.jl` format and provides interfaces to key `PowerModels.jl` modeling functions. In particular, `PowerModelsInterface.jl` has three main capabilities:

1. Translate a [PowerSystems.jl `System`](https://nrel-siip.github.io/PowerSystems.jl/stable/modeler_guide/system/) into a [PowerModels.jl data model `Dict`](https://lanl-ansi.github.io/PowerModels.jl/stable/network-data/)

```julia
using PowerSystems, PowerModelsInterface, Dates
using PowerSystemCaseBuilder # data library
sys = build_system(PSITestSystems, "c_sys5") # example dataset

pm_data = get_pm_data(sys)
```

2. Apply time series from a [PowerSystems.jl `System`](https://nrel-siip.github.io/PowerSystems.jl/stable/modeler_guide/system/) to populate a [PowerModels.jl `Dict`](https://lanl-ansi.github.io/PowerModels.jl/stable/network-data/) or a [multi-network `Dict`](https://lanl-ansi.github.io/PowerModels.jl/stable/multi-networks/)

```julia
pm_data = get_pm_data(sys, start_time = DateTime("2024-01-02T00:00:00"), period = 4) #applies data from the 4th period of the 2nd forecast to pm_data

mn_data = get_pm_data(sys, start_time = DateTime("2024-01-02T00:00:00"), time_periods = 1:4) #applies data from the 4th period of the 2nd forecast to pm_data
```

3. Build and solve models with PowerModels using data from PowerSystems

```julia
using Ipopt

run_ac_opf(sys, Ipopt.Optimizer)

run_opf(
    sys,
    ACPPowerModel,
    Ipopt.Optimizer,
    start_time = DateTime("2024-01-02T00:00:00"),
    period = 4,
)

run_mn_opf(
    sys,
    ACPPowerModel,
    Ipopt.Optimizer,
    start_time = DateTime("2024-01-02T00:00:00"),
    time_periods = 1:24,
)
```

## Development

Contributions to the development and enahancement of PowerSimulations is welcome. Please see [CONTRIBUTING.md](https://github.com/NREL-SIIP/PowermodelsInterface.jl/blob/master/CONTRIBUTING.md) for code contribution guidelines.

## License

PowerSimulations is released under a BSD [license](https://github.com/NREL/PowermodelsInterface.jl/blob/master/LICENSE). PowerSimulations has been developed as part of the Scalable Integrated Infrastructure Planning (SIIP)
initiative at the U.S. Department of Energy's National Renewable Energy Laboratory ([NREL](https://www.nrel.gov/))
