function heatmap(KB::Board, board_angle::Int, grade::String="All")

    climbs = get_all_climbs(KB)
    if grade == "All"
        frames = climbs[climbs.angle .== board_angle, :].frames
    else
        climbs = climbs[get_grade.(climbs.difficulty_average) .== grade, :]
        frames = climbs[climbs.angle .== board_angle, :].frames
    end

    placements = deepcopy(KB.placement_to_hole)  
    placements.vals .= 0

    for c in frames
        red = parse.(Int, split(c, ['p', 'r'], keepempty=false))
        for k in red[1:2:end]
            placements[k] += 1
        end
    end

    maxh = maximum(placements.vals)

    # Visualizing
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

    for (k, v) in placements
        if v != 0
            hole = KB.placement_to_hole[k]
            pos = KB.hole_to_pos[hole]
            pos =  (pos[1] - x1p, y2p - pos[2])
            scatter!(plt, scale.* pos, markercolor = :red, markersize=40*v/maxh, markeralpha=0.6)
        end
    end
         
    return plt
end