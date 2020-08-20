"""Return information in an experiment `e` in column(s) `feature` after filtering with filter `f`.
"""
function diagnostic(e::Experiment,
                    f::AbstractFilter;
                    features = [:Metadata_Row, :Metadata_Column, :Metadata_Field])
    subdata = e.data[filterEntriesExperiment(e, f),:]
    return(subdata[:,features])
end