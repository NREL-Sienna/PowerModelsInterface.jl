using PowerSimulations
using PowerSystems
using PowerSystemCaseBuilder
import PowerSystemCaseBuilder: PSITestSystems
using PowerModels

# Test Packages
using Test
using Logging

# Code Quality Tests
import Aqua
Aqua.test_unbound_args(PowerModelsInterface)
Aqua.test_undefined_exports(PowerModelsInterface)
Aqua.test_ambiguities(PowerModelsInterface)


ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6, "print_level"=>0)
ipopt_ws_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6, "mu_init"=>1e-4, "print_level"=>0)

cbc_solver = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel"=>0)
# juniper_solver = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-4, "print_level"=>0), "log_levels"=>[])
scs_solver = JuMP.optimizer_with_attributes(SCS.Optimizer, "max_iters"=>100000, "eps"=>1e-4, "verbose"=>0)

const MODEL_SOLVER_MAP = Dict(
    ACPPowerModel => ipopt_solver,
    SOCWRConicPowerModel => scs_solver


)
