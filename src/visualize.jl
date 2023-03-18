function climb_to_placement(frames::String)
    red = parse.(Int, split(frames, ['p', 'r'], keepempty=false))
    return red[1:2:end], red[2:2:end]
end


function scatter(frame::String, KB::Board)

    background = load(KB.image_links[2])
    ys, xs = size(background)
    x1p, x2p = KB.edge_left_right
    y1p, y2p = KB.edge_bottom_top
    xp = x2p - x1p
    yp = y2p - y1p
    scale = xs/xp

    plt = plot(background, legend=false, axis=false, grid=false, background="#2E2E2E", size=(xs, ys))

    for p in KB.image_links
        f = load(p)
        plot!(plt, f)
    end

    placement = climb_to_placement(frame)
    for l in placement
        hole = KB.placement_to_hole[l[1]]
        pos =  KB.hole_to_pos[hole]
        pos =  (pos[1] - x1p, y2p - pos[2])
        scatter!(plt, scale.* pos, markercolor = "#"*KB.led_to_color[l[2]], markersize=10, markeralpha=0.6)
    end

    return plt
end

# c = SQLite.DBInterface.execute(db.x, """SELECT * FROM climbs WHERE climbs.setter_username ="JohannesFinnstein" """)
# dc = DataFrame(c)

# frames = "p1075r15p1169r12p1233r13p1235r13p1287r13p1325r13p1375r13p1395r14p1521r15"
# frames2 = "p1164r12p1233r13p1271r13p1272r13p1325r13p1391r14p1460r15p1493r15p1509r15p1536r15p1554r15"

function scatter_js(frames::String, KB::Board)
    gh = "https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/main/"
    xs, ys = KB.sizes
    layout = Layout(
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

    fr, col = climb_to_placement(frames)
    fr = getindex.(Ref(KB.frame_to_pos), fr)
    col = getindex.(Ref(KB.led_to_color), col)
    x_p, y_p = unzip(fr)
    plot_data = PlotlyJS.scatter(x=x_p ,y=y_p, mode="markers", marker=attr(color=col, size=10, opacity=0.6))
    
    return plot(plot_data, layout)


end

unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))