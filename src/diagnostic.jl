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
assuming they are stored in variables `AreaShape_Center_X`, `AreaShape_Center_X_1`, 
`AreaShape_Center_Y` and `AreaShape_Center_Y_1`.  
If `rgx` provides a list of regex substitutions, it will be applied on all file paths in the 
output (which is useful if you're in a different file system or environment as the one described
in the `Experiment`'s data).
"""
function diagnosticURLImage(e::Experiment,
                            f::AbstractFilter,
                            s::Symbol;
                            center = false, 
                            rgx = nothing)
    diagCols = [s]
    if center
        centerCols = [:AreaShape_Center_X, :AreaShape_Center_Y, 
                      :AreaShape_Center_X_1, :AreaShape_Center_Y_1]
        append!(diagCols, centerCols)
    end
    diagCellCoord = diagnostic(e, f, features = diagCols)
    
    diagURL = diagCellCoord[:,s]
    unique!(diagURL)
    if rgx !== nothing
        diagURL = map(x -> reduce(replace, rgx, init=x), diagURL)
    end
    
    if !center
        # Center of regions of interest are not required      
        return(diagURL)
    else
        diagURLtoCenters = Dict(x => Array{Int64,2}(undef,0,2) for x in diagURL)
        for (url,cx,cy,nx,ny) in eachrow(diagCellCoord)
            if rgx !== nothing
                url = reduce(replace, rgx, init=url)
            end
            diagURLtoCenters[url] = vcat(diagURLtoCenters[url],  [[cx,nx] [cy,ny]])
        end
        return((diagURL, map(x -> diagURLtoCenters[x], diagURL)))
    end
end

"""[intended for internal use only]
Return color image (handle merging of 3 channels if needed)
"""
function colimgifrgb(imgPath, rgb)
	if rgb === nothing
		# Images don't have to be merged (e.g. already RGB)
    	return(load(imgPath))
    else
    	# Use the transformations provided in `rgb` to get a
    	# color image
    	imgR = reduce(replace, rgb[1], init=imgPath)
    	imgG = reduce(replace, rgb[2], init=imgPath)
    	imgB = reduce(replace, rgb[3], init=imgPath)
    	return(getColorImage(imgR, imgG, imgB))
    end
end

"""[intended for internal use only]
Assemble output file name for a given path and folder structure
"""
function outimgpath(imgpath, basepath, keepsubfolders)
	name_ending = join(split(imgpath, "/")[end-keepsubfolders:end], "/")
	name = string(basepath, name_ending)
	name_folder = join(split(name, "/")[1:end-1], "/")
	mkpath(name_folder)
	return(string(basepath, name_ending))
end


"""Get images in an experiment `e` whose location is stored in feature `s` after filtering with filter `f`.
Images will be saved at the `path` provided if `saveimages` is set to true, 
while keeping up to `keepsubfolders` folders from the original folder structure of the images. 
If `center` is true, crosses will indicate the center of selected objects, 
assuming they are stored in variables `:AreaShape_Center_X`, `:AreaShape_Center_X_1`, 
`:AreaShape_Center_Y` and `:AreaShape_Center_Y_1` (default if you merge nuclear and cytoplasm 
measurements from CellProfiler outputs).  
Display up to `showlimit` images if `show` is true.  
If `rgx` provides a list of regex substitutions, it will be applied on all image paths 
(which is useful if you're in a different file system or environment as the one described
in the `Experiment`'s data).
If `rgb` provides a list of 3 lists of regex substitutions, it will be applied to generate
the path to 3 images.
"""
function diagnosticImages(e::Experiment,
                          f::AbstractFilter,
                          s::Symbol;
                          path = "./",
                          saveimages = true,
                          show = false,
                          center = false, 
                          showlimit::Int64 = 20, 
                          rgb = nothing,
                          rgx = nothing,
                          keepsubfolders = 0)

    # Get addresses of images matching criteria
    imagesURL = diagnosticURLImage(e, f, s; center = center, rgx = rgx)

    # A limit is set to the number of images displayed by default
    # To avoid overflowing notebooks
    showcounter = 0
    if !center  
        for imgPath = imagesURL
        	colImg = colimgifrgb(imgPath, rgb)
            if show & (showcounter < showlimit)
                showcounter += 1
                display(colImg)
            end
            if saveimages
            	save(outimgpath(imgPath, path, keepsubfolders), colImg)
            elseif showcounter >= showlimit | !show
            	# Images are not displayed nor saved
            	# so we can safely exit
            	break
            end
        end
    else
        # We highlight the center of region of interests provided
        for (imgPath, imgCenters) = zip(imagesURL[1], imagesURL[2])
            # Combine them into a single image, display if required and save it
            colImg = colimgifrgb(imgPath, rgb)

            # Add white crosses around each center
            for (x,y) = eachrow(imgCenters)
                x += 1
                y += 1
                view(colImg, max(y-10,1):min(y+10,size(colImg)[1]), x) .= RGB(1,1,1)
                view(colImg, y, max(x-10,1):min(x+10,size(colImg)[2])) .= RGB(1,1,1)
            end
            if show & (showcounter < showlimit)
                showcounter += 1
                display(colImg)
            end
            if saveimages
            	save(outimgpath(imgPath, path, keepsubfolders), colImg)
            elseif showcounter >= showlimit | !show
            	# Images are not displayed nor saved
            	# so we can safely exit
            	break
            end
        end
    end
    return true
end

"""[intended for internal use only]
Return an (intensity-normalized) color image, given `R`, `G` and `B` the paths to
3 single-channel images."""
function getColorImage(R::String, G::String, B::String; normalize = true)
    imgR = load(R);
    imgG = load(G);
    imgB = load(B);

    if normalize
        imgR ./= maximum(imgR)
        imgG ./= maximum(imgG)
        imgB ./= maximum(imgB)
    end
    colorview(RGB, imgR, imgG, imgB)
end