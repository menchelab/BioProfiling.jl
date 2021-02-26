""" Compute the Mahalanobis Distance to center (MDC)
    in a dataset 'data' for a given perturbation of indices 'iPert' 
    compared to a reference of indices 'iRef'."""
function distance_mahalanobis_center(data, iPert, iRef)
    setPert = Matrix(data[iPert,:])
    setRef = Matrix(data[iRef,:])

    mdCenter = dropdims(mean(setRef, dims = 1), dims = 1)
    mdCov = cov(setRef)

    pertCenter = dropdims(mean(setPert, dims = 1), dims = 1)
    
    MD = mahalanobis(pertCenter, mdCenter, mdCov)
    
    return(MD)
end

""" Permute labels and compute the Mahalanobis Distance to center (MDC)
    in a dataset 'data' for a given perturbation of indices 'iPert' 
    compared to a reference of indices 'iRef', to create an empirical distribution."""
function shuffled_distance_mahalanobis_center(data, iPert, iRef; nbRep = 250)
    setPert = data[iPert,:]
    setRef = data[iRef,:]  
    set = Matrix(vcat(setRef, setPert))
    
    function iterShufMD()
        nset = size(set, 1)
        npert = size(setPert, 1)
        nref = size(setRef, 1)
        shuffSet = set[sample(1:nset, nset; replace = false),:]
        # Take random subsets of corresponding sizes
        shuffSetPert = shuffSet[1:npert,:]
        shuffSetRef = shuffSet[(npert+1):(npert+nref),:]

        # Compute Mahalanobis Distance
        
        mdCenter = dropdims(mean(shuffSetRef, dims = 1), dims = 1)
        mdCov = cov(shuffSetRef)
        
        pertCenter = dropdims(mean(shuffSetPert, dims = 1), dims = 1)
    
        MD = mahalanobis(pertCenter, mdCenter, mdCov)
        return(MD)
    end       
    
    return(map(x -> iterShufMD(), 1:nbRep))
end

""" Compute the median Mahalanobis Distance (MD)
    in a dataset 'data' for a given perturbation of indices 'iPert' 
    compared to a reference of indices 'iRef'."""
function distance_mahalanobis_median(data, iPert, iRef)
    setPert = data[iPert,:]
    setRef = Matrix(data[iRef,:])

    mdCenter = dropdims(mean(setRef, dims = 1), dims = 1)
    mdCov = cov(setRef)
    
    MD = median(map(x -> mahalanobis(x, mdCenter, mdCov), eachrow(setPert)))
    return(MD)
end

""" Permute labels and compute the median Mahalanobis Distance (RMD)
    in a dataset 'data' for a given perturbation of indices 'iPert' 
    compared to a reference of indices 'iRef', to create an empirical distribution."""
function shuffled_distance_mahalanobis_median(data, iPert, iRef; nbRep = 250)
    setPert = data[iPert,:]
    setRef = data[iRef,:]  
    set = Matrix(vcat(setRef, setPert))
    
    function iterShufMD()
        nset = size(set, 1)
        npert = size(setPert, 1)
        nref = size(setRef, 1)
        shuffSet = set[sample(1:nset, nset; replace = false),:]
        # Take random subsets of corresponding sizes
        shuffSetPert = shuffSet[1:npert,:]
        shuffSetRef = shuffSet[(npert+1):(npert+nref),:]

        # Compute Mahalanobis Distance
        
        mdCenter = dropdims(mean(shuffSetRef, dims = 1), dims = 1)
        mdCov = cov(shuffSetRef)

        MD = median(map(x -> mahalanobis(x, mdCenter, mdCov), eachrow(DataFrame(shuffSetPert))))
        return(MD)
    end       
    
    return(map(x -> iterShufMD(), 1:nbRep))
end


""" Compute the median Robust Mahalanobis Distance (RMD)
    in a dataset 'data' for a given perturbation of indices 'iPert' 
    compared to a reference of indices 'iRef'.
    See https://e-archivo.uc3m.es/bitstream/handle/10016/24613/ws201710.pdf """
function distance_robust_mahalanobis_median(data, iPert, iRef)
    setPert = data[iPert,:]
    setRef = data[iRef,:] 

    # Ensure that we have enough points to compute distance
    if ((size(setPert)[1] < 2*size(data, 2))|(size(setRef)[1] < 2*size(data, 2)))
        return(missing)
    end
    # NB: having less points than twice the number of dimensions leads to singularity
    
    # Compute Minimum Covariance Determinant and corresponding Robust Mahalanobis Distance
    @rput setRef

    R"""
    if (!require("robustbase")) install.packages("robustbase", 
                                repos = "https://cloud.r-project.org")
    library(robustbase)

    set.seed(777)
    mcd <- covMcd(setRef)
    mcdCenter <- mcd$center
    mcdCov <- mcd$cov
    """
    @rget mcdCenter
    @rget mcdCov
    
    RMD = median(map(x -> mahalanobis(x, mcdCenter, mcdCov), eachrow(setPert)))
    return(RMD)
end

""" Permute labels and compute the median Robust Mahalanobis Distance (RMD)
    in a dataset 'data' for a given perturbation of indices 'iPert' 
    compared to a reference of indices 'iRef', to create an empirical distribution."""
function shuffled_distance_robust_mahalanobis_median(data, iPert, iRef; nbRep = 250)
    setPert = data[iPert,:]
    setRef = data[iRef,:]  
    set = vcat(setRef, setPert)

    nset = size(set, 1)
    npert = size(setPert, 1)
    nref = size(setRef, 1)
    
    # Ensure that we have enough points to compute distance
    if ((size(setPert)[1] < 2*size(data, 2))|(size(setRef)[1] < 2*size(data, 2)))
        return(repeat([missing], nbRep))
    end
    # NB: having less points than twice the number of dimensions leads to singularity
    
    function iterShufRMD()
        shuffSet = set[sample(1:nset, nset; replace = false),:]
        # Take random subsets of corresponding sizes
        shuffSetPert = shuffSet[1:npert,:]
        shuffSetRef = shuffSet[(npert+1):(npert+nref),:]

        # Compute Minimum Covariance Determinant and corresponding Robust Mahalanobis Distance
        @rput shuffSetRef
        
        R"""
        if (!require("robustbase")) install.packages("robustbase", 
                                    repos = "https://cloud.r-project.org")
        library(robustbase)

        set.seed(3895)
        mcd <- covMcd(shuffSetRef)
        mcdCenter <- mcd$center
        mcdCov <- mcd$cov
        """
        @rget mcdCenter
        @rget mcdCov

        RMD = median(map(x -> mahalanobis(x, mcdCenter, mcdCov), eachrow(shuffSetPert)))
        return(RMD)
    end       
    
    return(map(x -> iterShufRMD(), 1:nbRep))
end

""" Compute the Robust Hellinger Distance (RHD)
    in a dataset `data` for a given perturbation of indices `iPert` 
    compared to a reference of indices `iRef`."""
function distance_robust_hellinger(data, iPert, iRef)
    setPert = data[iPert,:]
    setRef = data[iRef,:] 

    # Ensure that we have enough points to compute distance
    if ((size(setPert)[1] < 2*size(data, 2))|(size(setRef)[1] < 2*size(data, 2)))
        return(missing)
    end
    # NB: having less points than twice the number of dimensions leads to singularity
    
    # Compute Minimum Covariance Determinant and corresponding Robust Hellinger Distance
    @rput setRef
    @rput setPert

    R"""
    if (!require("robustbase")) install.packages("robustbase", 
                                repos = "https://cloud.r-project.org")
    library(robustbase)

    set.seed(777)
    mcd1 <- covMcd(setRef)
    mcdCenter1 <- mcd1$center
    mcdCov1 <- mcd1$cov
    
    # We set the seed twice to always
    # find the same estimators given
    # the same sample
    set.seed(777)
    mcd2 <- covMcd(setPert)
    mcdCenter2 <- mcd2$center
    mcdCov2 <- mcd2$cov
    """
    @rget mcdCenter1
    @rget mcdCov1
    @rget mcdCenter2
    @rget mcdCov2
    
    RHD = hellinger(mcdCenter1, mcdCov1, mcdCenter2, mcdCov2)
    return(RHD)
end

""" Permute labels and compute the Robust Hellinger Distance (RHD)
    in a dataset `data` for a given perturbation of indices `iPert` 
    compared to a reference of indices `iRef`, to create an empirical distribution."""
function shuffled_distance_robust_hellinger(data, iPert, iRef; nbRep = 250)
    setPert = data[iPert,:]
    setRef = data[iRef,:]  
    set = vcat(setRef, setPert)

    nset = size(set, 1)
    npert = size(setPert, 1)
    nref = size(setRef, 1)
    
    # Ensure that we have enough points to compute distance
    if ((size(setPert)[1] < 2*size(data, 2))|(size(setRef)[1] < 2*size(data, 2)))
        return(repeat([missing], nbRep))
    end
    # NB: having less points than twice the number of dimensions leads to singularity
    
    function iterShufRHD()
        shuffSet = set[sample(1:nset, nset; replace = false),:]
        # Take random subsets of corresponding sizes
        shuffSetPert = shuffSet[1:npert,:]
        shuffSetRef = shuffSet[(npert+1):(npert+nref),:]

        # Compute Minimum Covariance Determinant and corresponding Robust Mahalanobis Distance
        @rput shuffSetRef
        @rput shuffSetPert
        
        R"""
        if (!require("robustbase")) install.packages("robustbase", 
                                    repos = "https://cloud.r-project.org")
        library(robustbase)

        set.seed(777)
        mcd <- covMcd(shuffSetRef)
        mcdCenter1 <- mcd$center
        mcdCov1 <- mcd$cov
        
        # We set the seed twice to always
        # find the same estimators given
        # the same sample
        set.seed(777)
        mcd <- covMcd(shuffSetPert)
        mcdCenter2 <- mcd$center
        mcdCov2 <- mcd$cov
        """
        @rget mcdCenter1
        @rget mcdCov1        
        @rget mcdCenter2
        @rget mcdCov2
        

        RHD = hellinger(mcdCenter1, mcdCov1, mcdCenter2, mcdCov2)
        return(RHD)
    end       
    
    return(map(x -> iterShufRHD(), 1:nbRep))
end


""" Compute the Robust Morphological Perturbation Value (RMPV)
    for a given Experiment `e`, for all levels of a column `s`,
    compared to rows matching a given filter `f` or where `s`
    is equal to `ref`. 
    The RMPV quantifies the significance of changes between all
    conditions (levels in `s`) and a reference condition (defined
    by the filter `f`). 
    In brief, the distance of type `dist` between points of each 
    perturbation and points of the reference is computed and its 
    statistical significance is defined using a permutation test
    in which the perturbation and reference labels are shuffled 
    `nb_rep` times.
    If `process_pool` is a pool of worker processes, they will
    be used for parallel computation in the permutation test.
    This returns a DataFrame with three columns:
    * `Condition`: the levels in `s`
    * `Distance`: the distance between a condition and the 
    reference 
    * `RMPV`: the RMPV (empirical p-value corrected for multiple
    testing)
    """
function robust_morphological_perturbation_value end

# If filter provided for reference
function robust_morphological_perturbation_value(e::AbstractExperiment, 
                                                 s::Symbol, 
                                                 f::AbstractFilter; 
                                                 nb_rep::Int = 250,
                                                 dist::Symbol = :RobHellinger,
                                                 process_pool = nothing)
    if dist == :RobHellinger
        selected_distance = distance_robust_hellinger
        shuffled_distance = shuffled_distance_robust_hellinger 
    elseif dist == :RobMedMahalanobis
        selected_distance = distance_robust_mahalanobis_median
        shuffled_distance = shuffled_distance_robust_mahalanobis_median
    elseif dist == :MedMahalanobis
        selected_distance = distance_mahalanobis_median
        shuffled_distance = shuffled_distance_mahalanobis_median
    elseif dist == :CenterMahalanobis
        selected_distance = distance_mahalanobis_center
        shuffled_distance = shuffled_distance_mahalanobis_center
    else 
        throw(DomainError(dist, "Invalid `dist` argument. "*
                                "Only :RobHellinger "*
                                "and :RobMedMahalanobis "*
                                "and :MedMahalanobis "*
                                "and :CenterMahalanobis "*
                                "are supported"))
    end

    # All conditions considered
    cnd_levels = levels(e.data[e.selectedEntries,s])

    # Actual observed distances
    allRD = map(x -> selected_distance(getdata(e), 
                                        filterEntriesExperiment(e, Filter(x, s)), 
                                        filterEntriesExperiment(e, f)), 
                cnd_levels)

    # Shuffled distances
    if isnothing(process_pool)
        allShuffRD = map(x -> shuffled_distance(getdata(e), 
                                                filterEntriesExperiment(e, Filter(x, s)), 
                                                filterEntriesExperiment(e, f), 
                                                nbRep = nb_rep), 
                         cnd_levels)
    else
        sendto(workers(), e=e, 
                          s=s,
                          f=f,
                          nb_rep=nb_rep)
        allShuffRD = pmap(x -> shuffled_distance(getdata(e), 
                                            filterEntriesExperiment(e, Filter(x, s)), 
                                            filterEntriesExperiment(e, f), 
                                            nbRep = nb_rep), 
                     process_pool,
                     cnd_levels)
    end

    # Missing values might need to be handled explicitely
    @assert !any(ismissing.(allRD))

    # Compute the Robust Morphological Perturbation Value
    plateRMPV = DataFrame()
    plateRMPV.RMPV = adjust([mean(obs .< sim) for (obs, sim) 
                in zip(allRD, allShuffRD)], BenjaminiHochberg())
    plateRMPV.Distance = allRD
    plateRMPV.Condition = cnd_levels

    return(plateRMPV)
end

# If reference value provided for reference
function robust_morphological_perturbation_value(e::AbstractExperiment, 
                                                 s::Symbol, 
                                                 ref; 
                                                 nb_rep::Int = 250,
                                                 dist::Symbol = :RobHellinger,
                                                 processes::Int = 1)
    ref_filter = Filter(ref, s)
    return(robust_morphological_perturbation_value(e, 
                                                   s, 
                                                   ref_filter;
                                                   nb_rep,
                                                   dist))
end

