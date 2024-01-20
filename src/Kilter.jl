module Kilter

    using SQLite, DataFrames, JSON, HTTP
    using Images, PlotlyJS, PlotlyJS.WebIO

    function __init__()
        if basename(pwd()) == "Kilter.jl"
            path_to_data[] = "./data/"
        elseif basename(pwd()) == "app"
            path_to_data[] = "../data/"
        else
            error("Path not correct! Current:" * basename(pwd()))
        end

        db[] = SQLite.DB(path_to_data.x*"db.sqlite3")
    end

    const path_to_data = Ref{String}()
    const db = Ref{SQLite.DB}()
    
    const grades = Dict{Int, String}(
        10 => "4a/V0",
        11 => "4b/V0",
        12 => "4c/V0",
        13 => "5a/V1",
        14 => "5b/V1",
        15 => "5c/V2",
        16 => "6a/V3",
        17 => "6a+/V3",
        18 => "6b/V4",
        19 => "6b+/V4",
        20 => "6c/V5",
        21 => "6c+/V5",
        22 => "7a/V6",
        23 => "7a+/V7",
        24 => "7b/V8",
        25 => "7b+/V8",
        26 => "7c/V9",
        27 => "7c+/V10",
        28 => "8a/V11",
        29 => "8a+/V12",
        30 => "8b/V13",
        31 => "8b+/V14",
        32 => "8c/V15",
        33 => "8c+/V16")

    get_grade(x::Real) = grades[round(Int, x)]

    include("boards.jl")
    include("queries.jl")
    include("visualize.jl")
    include("analysis.jl")
    include("examples.jl")
    include("packets.jl")
    include("api.jl")
    
    export plot_random_climb, plot_heatmap
end
