using Documenter, BioProfiling

makedocs(sitename="BioProfiling.jl",
		 pages = [
	        "BioProfiling.jl" => "index.md",
	        "API" => "api.md",
	        "Examples" => "examples.md"
         ],
         authors = "Loan Vulliard" )

deploydocs(
    repo = "github.com/menchelab/BioProfiling.jl.git",
)
