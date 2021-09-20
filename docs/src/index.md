# PowerModelsInterface.jl

```@meta
CurrentModule = PowerModelsInterface
```

### Overview

`PowerModelsInterface.jl` is a [`Julia`](http://www.julialang.org) package that provides
an interface between [PowerSystems.jl](https://github.com/NREL-SIIP/PowerSystems.jl) and
[PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl). `PowerModelsInterface.jl` has
been developed under NREL's [SIIP Initiative](https://github.com/NREL-SIIP).

### Installation

The latest stable release of `PowerModelsInterface.jl` can be installed using the Julia
package manager with

```Julia
] add PowerModelsInterface
```

For the current development version, "checkout" this package with

```Julia
] add PowerModelsInterface#main
```

### Usage

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

------------
PowerModelsInterface has been developed as part of the [Scalable Integrated Infrastructure Planning (SIIP) initiative](https://www.nrel.gov/analysis/siip.html) at the U.S. Department of Energy's National Renewable Energy Laboratory
([NREL](https://www.nrel.gov/))
