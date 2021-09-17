
const PM_BUSTYPES = Dict{PSY.BusTypes, Int}(
    PSY.BusTypes.ISOLATED => 4,
    PSY.BusTypes.PQ => 1,
    PSY.BusTypes.PV => 2,
    PSY.BusTypes.REF => 3,
    PSY.BusTypes.SLACK => 3,
)

const ACCEPTED_PM_DATA_KWARGS = [:name, :start_time, :time_periods, :period]
