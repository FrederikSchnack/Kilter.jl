struct Board
    name::String
    product_id::Int
    product_size_id::Int
    layout_id::Int
    edge_left_right::Tuple{Int, Int}
    edge_bottom_top::Tuple{Int, Int}
    sizes::Tuple{Int, Int}
    image_links::Vector{String}
    frame_to_coordinate::Dict{Int, Tuple{Float64, Float64}}
    frame_to_position::Dict{Int, Int}
    led_to_color::Dict{Int, String}
end

function Kilterboard_original()
    name = "Kilter Board Original: 12 x 12 with kickboard"
    product_id = 1
    product_size_id = 10
    layout_id = 1
    x1p, x2p = (0,144)
    y1p, y2p = (0,156)
    
    image_links = get_image_files(product_size_id)

    # Scaling positions
    background = load(image_links[2])
    ys, xs = size(background)
    xp = x2p - x1p
    scale = xs/xp
    
    # get placements to position and coordinates 
    pl_to_pos, pl_to_coo = placement_to(product_size_id)

    # scale coordinates for plotting background
    for v in keys(pl_to_coo)
        x,y = pl_to_coo[v]
        pl_to_coo[v] = scale .* (x - x1p, y2p - y)
    end

    return Board(name, product_id, product_size_id, layout_id,  (x1p, x2p), (y1p, y2p), (xs, ys), image_links, pl_to_coo, pl_to_pos, leds_to_color())
end

function Kilterboard_original_wide()
    name = "Kilter Board Original: 16 x 12  Super Wide with kickboard"
    product_id = 1
    product_size_id = 28
    layout_id = 1
    x1p, x2p = (-24,168)
    y1p, y2p = (0,156)
    
    image_links = get_image_files(product_size_id)

    # Scaling positions
    background = load(image_links[2])
    ys, xs = size(background)
    xp = x2p - x1p
    scale = xs/xp

    # get placements to position and coordinates 
    pl_to_pos, pl_to_coo = placement_to(product_size_id)

    # scale coordinates for plotting background
    for v in keys(pl_to_coo)
        x,y = pl_to_coo[v]
        pl_to_coo[v] = scale .* (x - x1p, y2p - y)
    end

    return Board(name, product_id, product_size_id, layout_id,  (x1p, x2p), (y1p, y2p), (xs, ys), image_links, pl_to_coo, pl_to_pos, leds_to_color())
end

function Kilterboard_homewall()
    name = "Kilter Board Homewall: 10 x 12 Full Ride LED Kit"
    product_id = 7
    product_size_id = 25
    layout_id = 8
    x1p, x2p =(-56,56)
    y1p, y2p =(-12, 144)

    image_links = get_image_files(product_size_id)

    # Scaling positions
    background = load(image_links[1])
    ys, xs = size(background)
    xp = x2p - x1p
    scale = xs/xp

    # get placements to position and coordinates 
    pl_to_pos, pl_to_coo = placement_to(product_size_id)

    # scale coordinates for plotting background
    for v in keys(pl_to_coo)
        x,y = pl_to_coo[v]
        pl_to_coo[v] = scale .* (x - x1p, y2p - y)
    end

    return Board(name, product_id, product_size_id, layout_id,  (x1p, x2p), (y1p, y2p), (xs, ys),image_links, pl_to_coo, pl_to_pos, leds_to_color())
end