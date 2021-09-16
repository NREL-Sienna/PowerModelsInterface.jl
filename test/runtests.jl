using PowerModelsInterface
using PowerSystems
import InfrastructureSystems
using PowerSystemCaseBuilder
import PowerSystemCaseBuilder: PSITestSystems
using PowerModels
using Dates
import JuMP
import Ipopt
import Cbc
import SCS
import Memento

# Test Packages
using Test
using Logging

# Code Quality Tests
import Aqua
Aqua.test_unbound_args(PowerModelsInterface)
Aqua.test_undefined_exports(PowerModelsInterface)
Aqua.test_ambiguities(PowerModelsInterface)

ipopt_solver =
    JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
ipopt_ws_solver = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "tol" => 1e-6,
    "mu_init" => 1e-4,
    "print_level" => 0,
)

cbc_solver = JuMP.optimizer_with_attributes(Cbc.Optimizer, "logLevel" => 0)
# juniper_solver = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-4, "print_level"=>0), "log_levels"=>[])
scs_solver = JuMP.optimizer_with_attributes(
    SCS.Optimizer,
    #"max_iters" => 500000,
    "eps" => 1e-4,
    "verbose" => 0,
)

const MODEL_SOLVER_MAP =
    Dict(ACPPowerModel => ipopt_solver, SOCWRConicPowerModel => scs_solver)

const PM = PowerModels
const PSY = PowerSystems
const PMI = PowerModelsInterface
const PSB = PowerSystemCaseBuilder
const IS = InfrastructureSystems

PM_BASE_DIR = abspath(joinpath(dirname(Base.find_package("PowerModels")), ".."))
PM_DATA_DIR = joinpath(PM_BASE_DIR, "test", "data")

LOG_FILE = "power-models-interface.log"
LOG_LEVELS = Dict(
    "Debug" => Logging.Debug,
    "Info" => Logging.Info,
    "Warn" => Logging.Warn,
    "Error" => Logging.Error,
)

memento_logger = Memento.config!("error")

"""
Copied @includetests from https://github.com/ssfrr/TestSetExtensions.jl.
Ideally, we could import and use TestSetExtensions.  Its functionality was broken by changes
in Julia v0.7.  Refer to https://github.com/ssfrr/TestSetExtensions.jl/pull/7.
"""

"""
Includes the given test files, given as a list without their ".jl" extensions.
If none are given it will scan the directory of the calling file and include all
the julia files.
"""
macro includetests(testarg...)
    if length(testarg) == 0
        tests = []
    elseif length(testarg) == 1
        tests = testarg[1]
    else
        error("@includetests takes zero or one argument")
    end

    quote
        tests = $tests
        rootfile = @__FILE__
        if length(tests) == 0
            tests = readdir(dirname(rootfile))
            tests = filter(
                f ->
                    startswith(f, "test_") && endswith(f, ".jl") && f != basename(rootfile),
                tests,
            )
        else
            tests = map(f -> string(f, ".jl"), tests)
        end
        println()
        for test in tests
            print(splitext(test)[1], ": ")
            include(test)
            println()
        end
    end
end

function get_logging_level_from_env(env_name::String, default)
    level = get(ENV, env_name, default)
    return IS.get_logging_level(level)
end

function run_tests()
    logging_config_filename = get(ENV, "SIIP_LOGGING_CONFIG", nothing)
    if logging_config_filename !== nothing
        config = IS.LoggingConfiguration(logging_config_filename)
    else
        config = IS.LoggingConfiguration(
            filename = LOG_FILE,
            file_level = Logging.Info,
            console_level = Logging.Error,
        )
    end
    console_logger = ConsoleLogger(config.console_stream, config.console_level)

    IS.open_file_logger(config.filename, config.file_level) do file_logger
        levels = (Logging.Info, Logging.Warn, Logging.Error)
        multi_logger =
            IS.MultiLogger([console_logger, file_logger], IS.LogEventTracker(levels))
        global_logger(multi_logger)

        if !isempty(config.group_levels)
            IS.set_group_levels!(multi_logger, config.group_levels)
        end

        # Testing Topological components of the schema
        @time @testset "Begin PowerModelsInterface tests" begin
            @includetests ARGS
        end

        @test length(IS.get_log_events(multi_logger.tracker, Logging.Error)) == 1
        @info IS.report_log_summary(multi_logger)
    end
end

logger = global_logger()

try
    run_tests()
finally
    # Guarantee that the global logger is reset.
    global_logger(logger)
    nothing
end
