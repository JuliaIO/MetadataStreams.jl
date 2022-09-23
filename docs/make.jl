using MetadataStreams
using Documenter

DocMeta.setdocmeta!(MetadataStreams, :DocTestSetup, :(using MetadataStreams); recursive=true)

makedocs(;
    modules=[MetadataStreams],
    authors="Zachary P. Christensen <zchristensen7@gmail.com> and contributors",
    repo="https://github.com/Tokazama/MetadataStreams.jl/blob/{commit}{path}#{line}",
    sitename="MetadataStreams.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Tokazama.github.io/MetadataStreams.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Tokazama/MetadataStreams.jl",
    devbranch="main",
)
