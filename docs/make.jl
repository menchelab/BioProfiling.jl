using Documenter, BioProfiling

makedocs(sitename="BioProfiling.jl",
		 pages = [
	        "BioProfiling.jl" => "index.md",
	        "API" => "api.md",
	        "Running BioProfiling.jl online with codespaces" => "codespaces.md",
	        "Examples" => "examples.md"
         ],
         authors = "Loan Vulliard" )

deploydocs(
    repo = "github.com/menchelab/BioProfiling.jl.git",
)
