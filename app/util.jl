struct Kdata
    KB::Kilter.Board
    layout::PlotlyBase.Layout
    climbs::DataFrame
end

function Kdata_original()
    KB = Kilter.Kilterboard_original()

    gh = "https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/main/"
    layout = PlotlyBase.Layout(
        xaxis = attr(visible=false, showgrid=false, range=(0,KB.sizes[1])),
        yaxis = attr(visible=false, showgrid=false, scaleanchor="x", range=(KB.sizes[2], 0)),
        images=[
            attr(
                x=0,
                sizex=KB.sizes[1],
                y=0,
                sizey=KB.sizes[2],
                xref="x",
                yref="y",
                opacity=1.0,
                layer="below",
                source=gh * KB.image_links[k][3:end]
            )
            for k = 2:3
        ],
        plot_bgcolor= "#2E2E2E",
       # width = KB.sizes[1], 
       # height = KB.sizes[2],
       # autosize=true,
        margin=attr(l=0,r=0,t=0,b=0),
    )

    climbs = Kilter.get_all_climbs(KB)
    climbs[!, "grade"] = Kilter.get_grade.(climbs.difficulty_average)
    rename!(climbs, "name" => "Name", 
    "difficulty_average" => "difficulty_average",
    "angle" => "Angle", "frames" => "frames",
    "setter_username" => "Setter", "fa_username" => "FA",
    "ascensionist_count" => "#sends", "quality_average" => "Quality", 
    "grade" => "Grade")

    return Kdata(KB, layout, climbs)
end

function Kdata_home()

    KB = Kilter.Kilterboard_homewall()

    gh = "https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/main/"
    layout = PlotlyBase.Layout(
    xaxis = attr(visible=false, showgrid=false, range=(0,KB.sizes[1])),
    yaxis = attr(visible=false, showgrid=false, scaleanchor="x", range=(KB.sizes[2], 0)),
    images=[
        attr(
            x=0,
            sizex=KB.sizes[1],
            y=0,
            sizey=KB.sizes[2],
            xref="x",
            yref="y",
            opacity=1.0,
            layer="below",
            source=gh * KB.image_links[k][3:end]
        )
        for k = 2:3
    ],
    plot_bgcolor= "#2E2E2E",
    #width = KB.sizes[1], 
    #height = KB.sizes[2],
    #height = 800,
    #autosize=true,
    margin=attr(l=0,r=0,t=0,b=0),
    )

    climbs = Kilter.get_all_climbs(KB)
    climbs[!, "grade"] = Kilter.get_grade.(climbs.difficulty_average)

    rename!(climbs, "name" => "Name", 
    "difficulty_average" => "difficulty_average",
    "angle" => "Angle", "frames" => "frames",
    "setter_username" => "Setter", "fa_username" => "FA",
    "ascensionist_count" => "#sends", "quality_average" => "Quality", 
    "grade" => "Grade")

    return Kdata(KB, layout, climbs)
end


  ### PLOTTING TOOLS ###

  function frame_to_plot(frame::String, KB::Kilter.Board)
      fr, col = Kilter.climb_to_placement(frame)
      fr = getindex.(Ref(KB.frame_to_pos), fr)
      col = getindex.(Ref(KB.led_to_color), col)
      x_p, y_p = Kilter.unzip(fr)
  
      return PlotData(
        x = x_p,
        y = y_p,
        mode = "markers",
        plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
        marker = Dict(:color => "#" .* col, :size => 20, :opacity => 0.6)
      )
  
  end


  function plot_all_climbs(KB::Kilter.Board, color_ind::Vector{Int})
    pos = collect(values(KB.frame_to_pos))
    x_p, y_p = Kilter.unzip(pos)

    col = ["#e0e0e0" for _ in eachindex(pos)]
    if !isempty(color_ind)
        col[color_ind] .= "#ba1111"
    end

    return PlotData(
        x = x_p,
        y = y_p,
        mode = "markers",
        plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
        marker = Dict(:color => col, :size => 20, :opacity => 0.6)
      )
  end