# Allows UMAP to be called on Experiment objects
function UMAP.umap(e::Experiment, n_components=2; kwargs...)
    umap(convert(Matrix, getdata(e))', n_components; kwargs...)
end