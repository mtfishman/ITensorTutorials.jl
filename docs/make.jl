using ITensorTutorials
using Documenter

DocMeta.setdocmeta!(ITensorTutorials, :DocTestSetup, :(using ITensorTutorials); recursive=true)

makedocs(;
    modules=[ITensorTutorials],
    authors="Matthew Fishman <mfishman@flatironinstitute.org> and contributors",
    repo="https://github.com/mtfishman/ITensorTutorials.jl/blob/{commit}{path}#{line}",
    sitename="ITensorTutorials.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mtfishman.github.io/ITensorTutorials.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mtfishman/ITensorTutorials.jl",
    devbranch="main",
)
