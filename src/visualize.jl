function climb_to_placement(frames::String)
    red = parse.(Int, split(frames, ['p', 'r'], keepempty=false))
    return red[1:2:end], red[2:2:end]
end

unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

function create_layout(KB::Board)
    gh = "https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/main/"
    xs, ys = KB.sizes
    return PlotlyJS.Layout(
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
            for k = 2:length(KB.image_links)
        ],
        plot_bgcolor= "#2E2E2E",
        width = xs, 
        height = ys,
        margin=attr(l=0,r=0,t=0,b=0),
    )
end

function plot_climb(frames::String, KB::Board)
    layout = create_layout(KB)

    fr, col = climb_to_placement(frames)
    fr = getindex.(Ref(KB.frame_to_coordinate), fr)
    col = getindex.(Ref(KB.led_to_color), col)
    x_p, y_p = unzip(fr)
    plot_data = PlotlyJS.scatter(x=x_p ,y=y_p, mode="markers", marker=attr(color=col, size=10, opacity=0.6))
    
    return PlotlyJS.plot(plot_data, layout)
end