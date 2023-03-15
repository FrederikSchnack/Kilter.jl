function climb_to_placement(frames::String)
    red = parse.(Int, split(frames, ['p', 'r'], keepempty=false))
    return tuple.(red[1:2:end], red[2:2:end])
end


function scatter(frame::String, KB::Board)

    background = load(KB.image_links[2])
    ys, xs = size(background)
    x1p, x2p = KB.edge_left_right
    y1p, y2p = KB.edge_bottom_top
    xp = x2p - x1p
    yp = y2p - y1p
    scale = xs/xp

    plt = plot(background, legend=false, axis=false, grid=false, background=:transparent, size=(xs, ys))

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