function heatmap(KB::Board, board_angle::Int, grade::String="All")

    climbs = get_all_climbs(KB)
    if grade == "All"
        frames = climbs[climbs.angle .== board_angle, :].frames
    else
        climbs = climbs[get_grade.(climbs.difficulty_average) .== grade, :]
        frames = climbs[climbs.angle .== board_angle, :].frames
    end

    counter = Dict{Tuple{Float64, Float64}, Int}()
    for c in frames
        fr, = climb_to_placement(c)
        
        # fr = getindex.(Ref(KB.frame_to_coordinate), fr)

        # ff = []
        # for f in fr
        #     if haskey(KB.frame_to_coordinate, f)
        #         push!(ff, KB.frame_to_coordinate[f])
        #     end
        # end

        for ff in fr
            f = KB.frame_to_coordinate[ff]
            if haskey(counter, f)
                counter[f] +=1
            else
                counter[f] = 1
            end
        end
    end


    gh = "https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/main/"
    xs, ys = KB.sizes
    layout = PlotlyJS.Layout(
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
                source=gh * KB.image_links[k]
            )
            for k = 2:3
        ],
        plot_bgcolor= "#2E2E2E",
        width = xs, 
        height = ys,
        margin=attr(l=0,r=0,t=0,b=0),
    )

    plot_data = typeof(PlotlyJS.scatter())[]
    X = Float64[]
    Y = Float64[]
    V = Float64[]
    for (p, v) in counter
        x_p, y_p = p
        push!(X, x_p)
        push!(Y, y_p)
        push!(V, v)
    end
    V *= 50/maximum(V)


    plot_data = PlotlyJS.scatter(x=X ,y=Y, mode="markers", marker=attr(color=:red, size=V, opacity=0.6))
               
    return PlotlyJS.plot(plot_data, layout)
end

function scatter_plot_frames(coordinates::Vector{Tuple{Float64, Float64}}, color_index::Vector{Int})
    x,y = unzip(coordinates)
    colors = ["#e0e0e0" for _ in eachindex(coordinates)]
    if !isempty(color_index)
        colors[color_index] .= "#ba1111"
    end

    return PlotlyJS.scatter(x=x ,y=y, mode="markers", marker=attr(color=colors, size=20, opacity=0.6))
end


function get_selection(KB::Board)
    coordinates = collect(values(KB.frame_to_coordinate))

    coordinate_to_frame = KB.frame_to_coordinate |> collect .|> reverse |> Dict

    color_index = Int[]
    layout = create_layout(KB)

    plot_data = scatter_plot_frames(coordinates, color_index)

    p = PlotlyJS.plot(plot_data, layout)

    display(p)

    selection = Int[]

    on(p["click"]) do data
        pt = find_closest_hold(data["points"][1]["x"], data["points"][1]["y"], coordinates)
        sel = KB.frame_to_position[coordinate_to_frame[pt]]
        ind = findfirst(x -> x == pt, coordinates)

        if sel ∈ selection 
            deleteat!(selection, selection .== sel)
            deleteat!(color_index, color_index .== ind)
        else
            push!(selection, sel)
            push!(color_index, ind)
        end

        @show selection 
        colors = ["#e0e0e0" for _ in eachindex(coordinates)]
        if !isempty(color_index)
            colors[color_index] .= "#ba1111"
        end
        PlotlyJS.restyle!(p, marker = attr(color=colors, size = 20, opacity=0.6))
    end
        
    
end

function find_closest_hold(x::Real, y::Real, cords::Vector{Tuple{Float64, Float64}})
    xc, yc = unzip(cords)

    xp = xc[argmin(abs.(xc .- x))]
    yp = yc[argmin(abs.(yc .- y))]

    return (xp, yp)

end


function image_to_selection(KB::Board, image_link::String, scale::Float64=1.0, offset_x::Int=0, offset_y::Int=0)
    cords = collect(values(KB.frame_to_coordinate))
   # cords = map( x -> round.(Int, x), cords)
   coordinate_to_frame = KB.frame_to_coordinate |> collect .|> reverse |> Dict

    im = load(image_link) |> transpose
    nx, ny = size(im)

    frames = Int[]
    colors = String[]
    for  c in cords 
        (x,y) =  round.(Int, scale .* c)
        x += offset_x
        y += offset_y
        ((0 > x) || (x > nx)) && continue
        ((0 > y) || (y > ny)) && continue
        @show im[x,y]
        col = RGB(im[x, y]) .* 255
        @show col
        col = round.(Int, (col.r, col.g, col.b))
        push!(colors, bytes2hex(UInt8.(col)))
        push!(frames, coordinate_to_frame[c])
    end



    return frames, colors
end


function plot_from_position(KB::Board, frames::Vector{Int}, colors::Vector{String})
    layout = create_layout(KB)
    coordinates = getindex.(Ref(KB.frame_to_coordinate), frames)
    x,y = unzip(coordinates)


    plot_data = PlotlyJS.scatter(x=x ,y=y, mode="markers", marker=attr(color='#'.*colors, size=20, opacity=0.6))


    p = PlotlyJS.plot(plot_data, layout)
end