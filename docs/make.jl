using Documenter, RMP

makedocs(sitename="RMP.jl",
		 pages = [
	        "RMP.jl" => "index.md",
	        "API" => "api.md",
	        "Examples" => "examples.md"
         ],
         authors = "Loan Vulliard" )

deploydocs(
    repo = "github.com/menchelab/BioProfiling.jl.git",
)
