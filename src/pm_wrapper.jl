
function run_opf(system::PSY.System, model_type::Type, optimizer; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return run_opf(
        pmi_data,
        model_type,
        optimizer;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function run_mn_opf(system::PSY.System, model_type::Type, optimizer; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return run_mn_opf(
        pmi_data,
        model_type,
        optimizer;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function run_pf(system::PSY.System, model_type::Type, optimizer; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return run_pf(
        pmi_data,
        model_type,
        optimizer;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function run_ac_pf(system::PSY.System, optimizer; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return run_ac_pf(
        pmi_data,
        optimizer;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function run_dc_pf(system::PSY.System, optimizer; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return run_dc_pf(
        pmi_data,
        optimizer;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function compute_ac_pf(system::PSY.System; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return compute_ac_pf(
        pmi_data,
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function compute_dc_pf(system::PSY.System; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return compute_dc_pf(
        pmi_data,
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function run_model(system::PSY.System, model_type::Type, optimizer, build_method; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return run_model(
        pmi_data,
        model_type,
        optimizer,
        build_method;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end

function instantiate_model(system::PSY.System, model_type::Type, build_method; kwargs...)
    pmi_data = get_pm_data(system; kwargs...)
    return instantiate_model(
        pmi_data,
        model_type,
        build_method;
        (k for k in kwargs if first(k) ∉ ACCEPTED_PM_DATA_KWARGS)...,
    )
end
