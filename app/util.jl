struct Kdata
    KB::Kilter.Board
    layout::PlotlyBase.Layout
    climbs::DataFrame
    cords::Vector{Tuple{Float64, Float64}}
    cord_to_frame::Dict{Tuple{Float64, Float64}, Int}
end

function create_layout(KB::Kilter.Board)
    gh = "https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/main/"
    xs, ys = KB.sizes
    return PlotlyBase.Layout(
        xaxis = attr(visible=false, showgrid=false, range=(0,xs)),
        yaxis = attr(visible=false, showgrid=false, scaleanchor="x", range=(ys, 0)),
        images=[
            attr(
                x=0,
                sizex=xs,
                y=0,
                sizey=ys,
                xref="x",
                yref="y",
                opacity=1.0,
                layer="below",
                source=gh * KB.image_links[k][findfirst("data", KB.image_links[k])[1]:end]
            )
            for k = 2:length(KB.image_links)
        ],
        plot_bgcolor= "#2E2E2E",
        #width = xs, 
        #height = ys,
        autosize=true,
        margin=attr(l=0,r=0,t=0,b=0),
    )
end

function Kdata_original()
    KB = Kilter.Kilterboard_original_wide()

    layout = create_layout(KB)

    climbs = unique(Kilter.get_all_climbs(KB))
    climbs[!, "grade"] = Kilter.get_grade.(climbs.difficulty_average)
    rename!(climbs, "name" => "Name", 
    "difficulty_average" => "difficulty_average",
    "angle" => "Angle", "frames" => "frames",
    "setter_username" => "Setter", "fa_username" => "FA",
    "ascensionist_count" => "#sends", "quality_average" => "Quality", 
    "grade" => "Grade")

    coordinate_to_frame = KB.frame_to_coordinate |> collect .|> reverse |> Dict

    return Kdata(KB, layout, climbs, collect(values(KB.frame_to_coordinate)), coordinate_to_frame)
end

function Kdata_home()

    KB = Kilter.Kilterboard_homewall()
    
    layout = create_layout(KB)

    climbs = unique(Kilter.get_all_climbs(KB))
    climbs[!, "grade"] = Kilter.get_grade.(climbs.difficulty_average)

    rename!(climbs, "name" => "Name", 
    "difficulty_average" => "difficulty_average",
    "angle" => "Angle", "frames" => "frames",
    "setter_username" => "Setter", "fa_username" => "FA",
    "ascensionist_count" => "#sends", "quality_average" => "Quality", 
    "grade" => "Grade")

    coordinate_to_frame = KB.frame_to_coordinate |> collect .|> reverse |> Dict

    return Kdata(KB, layout, climbs, collect(values(KB.frame_to_coordinate)), coordinate_to_frame)
end

function extract_user(token::String, user_id::Int)
    user = Kilter.get_user(token, string(user_id))
    
    if user["is_public"]
        logbook = Kilter.get_logbook(token, string(user_id))
    else
        logbook = []
    end

    return user["name"], user["avatar_image"], logbook
end

    function sandbag_score(climbs::Dict{String, DataFrame})
        score = 1.0

        for (_,c) in climbs
            n, = size(c)
            for (pg, ag, sends) in eachrow(c[:, ["difficulty", "difficulty_average", "#sends"]])
                diff = (ag - pg)
                score += sign(diff)/n * log(2+sends) * log(1 + abs(diff))
            end
        end

        return  round(score, digits=2)
    end

  ### PLOTTING TOOLS ###

  function frame_to_plot(frame::String, KB::Kilter.Board)
      fr, col = Kilter.climb_to_placement(frame)
      fr = getindex.(Ref(KB.frame_to_coordinate), fr)
      col = getindex.(Ref(KB.led_to_color), col)
      x_p, y_p = Kilter.unzip(fr)
  
      return PlotData(
        x = x_p,
        y = y_p,
        mode = "markers",
        plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
        marker = Dict(:color => "#" .* col, :size => 20, :opacity => 0.6),
      )
  
  end

    function plot_histogram(grade::Dict{String, Int}, climbs::DataFrame, filter::BitVector)
        return PlotData(
                    x= Kilter.get_grade.(grade["min"]:1:grade["max"]), 
                    y = [sum(x .== round.(Int, climbs[filter, "difficulty_average"])) for x in grade["min"]:grade["max"]],
                    plot = StipplePlotly.Charts.PLOT_TYPE_BAR,
                    marker=Dict(:color=>"#1976d2")
                )
    end

    function plot_histogram(grade::Dict{String, Int})
        return PlotData(
                    x= Kilter.get_grade.(grade["min"]:1:grade["max"]), 
                    y = [0 for x in grade["min"]:grade["max"]],
                    plot = StipplePlotly.Charts.PLOT_TYPE_BAR,
                    marker=Dict(:color=>"#1976d2")
                )
    end

  function plot_heatmap(kdata::Kdata, climbs::DataFrame, filter::BitVector)
    frames = climbs[filter, :].frames

    counter = Dict{Tuple{Float64, Float64}, Int}()
    for c in frames
        fr, = Kilter.climb_to_placement(c)
        
        for ff in fr
            f = kdata.KB.frame_to_coordinate[ff]
            if haskey(counter, f)
                counter[f] +=1
            else
                counter[f] = 1
            end
        end
    end

    X = Float64[]
    Y = Float64[]
    V = Float64[]
    for (p, v) in counter
        x_p, y_p = p
        push!(X, x_p)
        push!(Y, y_p)
        push!(V, v)
    end

    !isempty(V) &&  (V *= 60/maximum(V))

    return PlotData(
        x = X,
        y = Y,
        mode = "markers",
        plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
        marker = Dict(:color => "#1976d2", :size => V, :opacity => 0.6)
      )
  end


  function plot_all_climbs(kdata::Kdata, color_ind::Vector{Int})
    pos = kdata.cords
    x_p, y_p = Kilter.unzip(pos)

    col = ["#e0e0e0" for _ in eachindex(pos)]
    if !isempty(color_ind)
        col[color_ind] .= "#1976d2"
    end

    return PlotData(
        x = x_p,
        y = y_p,
        mode = "markers",
        plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
        marker = Dict(:color => col, :size => 20, :opacity => 0.6)
      )
  end