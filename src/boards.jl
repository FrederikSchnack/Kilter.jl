"""
    Similar to 
    SQLite.DBTable("walls", Tables.Schema:
    :uuid                   Union{Missing, String}
    :user_id                Missing
    :name                   Union{Missing, String}
    :product_id             Missing
    :is_adjustable          Missing
    :angle                  Missing
    :layout_id              Missing
    :product_size_id        Missing
    :hsm                    Missing
    :serial_number          Union{Missing, String}
    :created_at             Union{Missing, String}
    :rejection_reason_code  Missing)

    But only store:
"""

struct Board
    name::String
    product_id::Int
    product_size_id::Int
    layout_id::Int
    edge_left_right::Tuple{Int, Int}
    edge_bottom_top::Tuple{Int, Int}
    sizes::Tuple{Int, Int}
    image_links::Vector{String}
    frame_to_pos::Dict{Int, Tuple{Float64, Float64}}
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

    p_t_h = placements_to_holes()
    h_t_po = holes_to_pos(product_size_id)

    frame_to_pos = Dict{Int, Tuple{Float64, Float64}}()

    for (k,v) in p_t_h
        if v ∈ keys(h_t_po)
            pos = h_t_po[v]
            frame_to_pos[k] =  scale .* (pos[1] - x1p, y2p - pos[2])
        end
    end

    return Board(name, product_id, product_size_id, layout_id,  (x1p, x2p), (y1p, y2p), (xs, ys), image_links,frame_to_pos, leds_to_color(product_id))
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

    p_t_h = placements_to_holes()
    h_t_po = holes_to_pos(product_size_id)

    frame_to_pos = Dict{Int, Tuple{Float64, Float64}}()

    for (k,v) in p_t_h
        if v ∈ keys(h_t_po)
            pos = h_t_po[v]
            frame_to_pos[k] =  scale .* (pos[1] - x1p, y2p - pos[2])
        end
    end

    return Board(name, product_id, product_size_id, layout_id,  (x1p, x2p), (y1p, y2p), (xs, ys),image_links,frame_to_pos, leds_to_color(product_id))
end