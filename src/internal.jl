"""[intended for internal use only]
Make sure an Experiment's data are numerical 
and do not include missing values, NaNs or infs.
"""
function _assert_clean_data(e::Experiment)
	# Column type cannot be used as for instance a Union type 
	# could support missing values but the selected data subset
	# might contain only numbers

	# This excludes strings and missings (and more)
	hasnumbers = getdata(e) |> 
					x -> isa.(x, Number) |> 
					eachcol |> 
					x -> all.(x) |> 
					all
	@assert hasnumbers "Selected data include non-numeric values."

	# Exclude NaNs
	hasnonans = getdata(e) |> 
					x -> isnan.(x) |> 
					eachcol |> 
					x -> any.(x) |> 
					any |> ~
	@assert hasnonans "Selected data include NaNs."

	# Exclude Inf
	hasnoinf = getdata(e) |> 
					x -> isinf.(x) |> 
					eachcol |> 
					x -> any.(x) |> 
					any |> ~
	@assert hasnoinf "Selected data include Inf values."
end

"""[intended for internal use only]
Convert all selected data columns to floats
"""
function _data_to_float!(e::Experiment)
    # Make sure all values are numbers
    @assert all( [x <: Number for x in eltype.(eachcol(getdata(e)))] )
    # Convert each column to floats
    for colname in names(getdata(e))
        e.data[!,colname] = float.(e.data[:,colname])
    end
end
