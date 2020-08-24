"""Return information in an experiment `e` in column(s) `feature` after filtering with filter `f`.
"""
function diagnostic(e::Experiment,
                    f::AbstractFilter;
                    features = [:Metadata_Row, :Metadata_Column, :Metadata_Field])
    subdata = e.data[filterEntriesExperiment(e, f),:]
    return(subdata[:,features])
end

"""Get path to images in an experiment `e` stored in feature `s` after filtering with filter `f`.
If `center` is true, the path will be returned together with the center of the filtered entries, 
assuming they are stored in variables `:AreaShape_Center_X`, `:AreaShape_Center_X_1`, 
`:AreaShape_Center_Y` and `:AreaShape_Center_Y_1` (default if you merge nuclear and cytoplasm 
measurements from CellProfiler outputs).
"""
function diagnosticURLImage(e::Experiment,
                            f::RMP.AbstractFilter,
                            s::Symbol;
                            center = false)
    diagCols = [s]
    if center
        centerCols = [:AreaShape_Center_X, :AreaShape_Center_Y, 
                      :AreaShape_Center_X_1, :AreaShape_Center_Y_1]
        append!(diagCols, centerCols)
    end
    diagCellCoord = diagnostic(e, f, features = diagCols)
    
    diagURL = diagCellCoord[:,s]
    unique!(diagURL)
    
    if !center
        # Center of regions of interest are not required      
        return(diagURL)
    else
        diagURLtoCenters = Dict(x => Array{Int64,2}(undef,0,2) for x in diagURL)
        for (url,cx,cy,nx,ny) in eachrow(diagCellCoord)
            diagURLtoCenters[url] = vcat(diagURLtoCenters[url],  [[cx,nx] [cy,ny]])
        end
        return((diagURL, map(x -> diagURLtoCenters[x], diagURL)))
    end
end