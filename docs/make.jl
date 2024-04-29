using ClosestPointSTL
using Documenter

DocMeta.setdocmeta!(ClosestPointSTL, :DocTestSetup, :(using ClosestPointSTL); recursive=true)

makedocs(;
    modules=[ClosestPointSTL],
    authors="Oriol Colomese <oriol.colomes@gmail.com>",
    sitename="ClosestPointSTL.jl",
    format=Documenter.HTML(;
        canonical="https://oriolcg.github.io/ClosestPointSTL.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/oriolcg/ClosestPointSTL.jl",
    devbranch="main",
)
