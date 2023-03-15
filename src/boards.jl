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
    #
    edge_left_right::Tuple{Int, Int}
    edge_bottom_top::Tuple{Int, Int}
    image_links::Vector{String}
    #
    placement_to_hole::Dict{Int, Int}
    hole_to_pos::Dict{Int, Tuple{Int, Int}}
    led_to_color::Dict{Int, String}
end

function Kilterboard_original()
    name = "Kilter Board Original: 12 x 12 with kickboard"
    product_id = 1
    product_size_id = 10
    layout_id = 1
    edge_left_right=(0,144)
    edge_bottom_top=(0,156)

    return Board(name, product_id, product_size_id, layout_id, 
    edge_left_right, edge_bottom_top, get_image_files(product_size_id), placements_to_holes(), holes_to_pos(product_size_id), leds_to_color(product_id))
end

function Kilterboard_homewall()
    name = "Kilter Board Homewall: 10 x 12 Full Ride LED Kit"
    product_id = 7
    product_size_id = 25
    layout_id = 8
    edge_left_right=(-56,56)
    edge_bottom_top=(-12, 144)

    return Board(name, product_id, product_size_id, layout_id, 
    edge_left_right, edge_bottom_top, get_image_files(product_size_id), placements_to_holes(), holes_to_pos(product_size_id), leds_to_color(product_id))
end