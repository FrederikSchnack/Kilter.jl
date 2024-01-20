function placement_to(product_size_id::Int)
    h = SQLite.DBInterface.execute(db.x, """SELECT leds.position, placements.id, holes.x, holes.y
                                            FROM leds  
                                            INNER JOIN placements
                                            ON leds.hole_id = placements.hole_id
                                            INNER JOIN holes
                                            ON leds.hole_id = holes.id
                                            WHERE leds.product_size_id=$product_size_id 
                                            """)
    dh = DataFrames.DataFrame(h)

    pl_to_pos = Dict{Int, Int}()
    pl_to_coo = Dict{Int, Tuple{Float64, Float64}}()
    # pos_to_coo = Dict{Int, Tuple{Int, Int}}()

    for k in eachrow(dh)
        pl_to_pos[k.id] = (k.position)
        pl_to_coo[k.id] = (k.x, k.y)
        # pos_to_coo[k.position] = (k.x, k.y)
    end

    return pl_to_pos, pl_to_coo
end

# function placement_to_coordinates()
#     h = SQLite.DBInterface.execute(db.x, """SELECT x, y, placements.id 
#                                             FROM holes  
#                                             INNER JOIN placements
#                                             ON holes.id = placements.hole_id 
#                                             """)
#     dh = DataFrames.DataFrame(h)

#     pl_to_co = Dict{Int, Tuple{Int, Int}}()
#     for k in eachrow(dh)
#         pl_to_co[k.id] = (k.x, k.y)
#     end

#     return pl_to_co
# end

# function placements_to_holes()
#     h = SQLite.DBInterface.execute(db.x, """SELECT id, hole_id FROM placements """)
#     dh = DataFrames.DataFrame(h)

#     placement_to_hold = Dict{Int, Int}()
#     for k in eachrow(dh)
#         placement_to_hold[k.id] = k.hole_id
#     end

#     return placement_to_hold
# end

# function holes_to_pos(product_size_id::Int)
#     h = SQLite.DBInterface.execute(db.x, """SELECT id, x, y FROM holes WHERE id IN (SELECT hole_id FROM leds WHERE product_size_id=$product_size_id )""")
#     dh = DataFrames.DataFrame(h)

#     hole_to_pos = Dict{Int, Tuple{Int, Int}}()
#     for k in eachrow(dh)
#         hole_to_pos[k.id] = (k.x, k.y)
#     end

#     return hole_to_pos
# end

# function leds_to_color(product_id::Int)
#     h = SQLite.DBInterface.execute(db.x, """SELECT id, screen_color FROM placement_roles WHERE product_id = $product_id""")
#     dh = DataFrames.DataFrame(h)

#     led_to_color = Dict{Int, String}()
#     for k in eachrow(dh)
#         led_to_color[k.id] = k.screen_color
#     end

#     return led_to_color
# end

function leds_to_color()
    h = SQLite.DBInterface.execute(db.x, """SELECT id, screen_color FROM placement_roles""")
    dh = DataFrames.DataFrame(h)

    led_to_color = Dict{Int, String}()
    for k in eachrow(dh)
        led_to_color[k.id] = k.screen_color
    end

    return led_to_color
end


function get_image_files(product_size_id::Int)
    l = SQLite.DBInterface.execute(db.x, """SELECT image_filename FROM product_sizes_layouts_sets WHERE product_size_id=$product_size_id""")
    dl = DataFrames.DataFrame(l)
    
    ll = SQLite.DBInterface.execute(db.x, """SELECT image_filename FROM product_sizes WHERE id=$product_size_id""")
    dll = DataFrames.DataFrame(ll) 
    
    return path_to_data.x .* vcat(dll.image_filename, dl.image_filename)
end

function get_all_established_climbs(KB::Board)
    # * with some restrictions
   
    restr = """ SELECT name, frames, setter_username, fa_username, climb_stats.angle,  difficulty_average, ascensionist_count, quality_average
    FROM climbs
    INNER JOIN climb_stats
    ON climbs.uuid = climb_stats.climb_uuid
    WHERE is_listed = 1 and is_draft = 0 and frames_count = 1 and layout_id = $(KB.layout_id) and edge_bottom >= $(KB.edge_bottom_top[1]) and edge_top <= $(KB.edge_bottom_top[2]) and edge_left >= $(KB.edge_left_right[1]) and edge_right <= $(KB.edge_left_right[2])  and ascensionist_count >= 1 and product_size_id=$(KB.product_size_id)"""

    d = SQLite.DBInterface.execute(db.x, restr)

    return DataFrames.DataFrame(d)
end


function get_all_climbs(KB::Board)
    # * with some restrictions
   
    restr = """ SELECT name, uuid, difficulty_average, climb_stats.angle, frames, setter_username, fa_username, ascensionist_count, quality_average
    FROM climbs
    INNER JOIN climb_stats
    ON climbs.uuid = climb_stats.climb_uuid
    INNER JOIN product_sizes_layouts_sets
    ON climbs.layout_id = product_sizes_layouts_sets.layout_id 
    WHERE climbs.is_listed = 1 and is_draft = 0 and frames_count = 1 and climbs.layout_id = $(KB.layout_id) and edge_bottom >= $(KB.edge_bottom_top[1]) and edge_top <= $(KB.edge_bottom_top[2]) and edge_left >= $(KB.edge_left_right[1]) and edge_right <= $(KB.edge_left_right[2]) and product_size_id=$(KB.product_size_id)"""

    d = SQLite.DBInterface.execute(db.x, restr)

    return DataFrames.DataFrame(d)
end

function get_all_climbs()
    # * with some restrictions
   
    restr = """ SELECT *
    FROM climbs
    INNER JOIN climb_stats
    ON climbs.uuid = climb_stats.climb_uuid
    INNER JOIN product_sizes_layouts_sets
    ON climbs.layout_id = product_sizes_layouts_sets.layout_id 
    WHERE climbs.is_listed = 1 and is_draft = 0 and frames_count = 1 """

    d = SQLite.DBInterface.execute(db.x, restr)

    return DataFrames.DataFrame(d)
end

# Some important artifacts
# h = SQLite.DBInterface.execute(db, """SELECT * FROM layouts""")
# dh = DataFrames.DataFrame(h)
# 
# h = SQLite.DBInterface.execute(db, """SELECT * FROM holes WHERE id IN (SELECT hole_id FROM leds WHERE product_size_id=10 )""")
# dh = DataFrames.DataFrame(h)


# l = SQLite.DBInterface.execute(db, """SELECT * FROM product_sizes_layouts_sets WHERE product_size_id=28""")
# dl = DataFrames.DataFrame(l)



# c = SQLite.DBInterface.execute(db.x, """SELECT * FROM climbs WHERE climbs.setter_username ="JohannesFinnstein" """)
# dc = DataFrames.DataFrame(c)

# h = SQLite.DBInterface.execute(db, """SELECT * FROM placements WHERE layout_id=1 AND (set_id=1 OR set_id=20)""")
# dh = DataFrames.DataFrame(h)


# """db
# db_tables
# 31-element Vector{SQLite.DBTable}:
#  SQLite.DBTable("shared_syncs", Tables.Schema:
#  :table_name            Union{Missing, String}
#  :last_synchronized_at  Union{Missing, String})

#  SQLite.DBTable("products", Tables.Schema:
#  :id                  Missing
#  :name                Union{Missing, String}
#  :is_listed           Missing
#  :password            Union{Missing, String}
#  :min_count_in_frame  Missing
#  :max_count_in_frame  Missing)

#  SQLite.DBTable("product_sizes", Tables.Schema:
#  :id              Missing
#  :product_id      Missing
#  :edge_left       Union{Missing, Int64}
#  :edge_right      Union{Missing, Int64}
#  :edge_bottom     Union{Missing, Int64}
#  :edge_top        Union{Missing, Int64}
#  :name            Union{Missing, String}
#  :description     Union{Missing, String}
#  :image_filename  Union{Missing, String}
#  :position        Missing
#  :is_listed       Missing)

#  SQLite.DBTable("holes", Tables.Schema:
#  :id                Missing
#  :product_id        Missing
#  :name              Union{Missing, String}
#  :x                 Union{Missing, Int64}
#  :y                 Union{Missing, Int64}
#  :mirrored_hole_id  Missing
#  :mirror_group      Missing)

#  SQLite.DBTable("leds", Tables.Schema:
#  :id               Missing
#  :product_size_id  Missing
#  :hole_id          Missing
#  :position         Missing)

#  SQLite.DBTable("products_angles", Tables.Schema:
#  :product_id  Missing
#  :angle       Union{Missing, Int64})

#  SQLite.DBTable("layouts", Tables.Schema:
#  :id                 Missing
#  :product_id         Missing
#  :name               Union{Missing, String}
#  :instagram_caption  Union{Missing, String}
#  :is_mirrored        Missing
#  :is_listed          Missing
#  :password           Union{Missing, String}
#  :created_at         Union{Missing, String})

#  SQLite.DBTable("sets", Tables.Schema:
#  :id    Missing
#  :name  Union{Missing, String}
#  :hsm   Missing)

#  SQLite.DBTable("product_sizes_layouts_sets", Tables.Schema:
#  :id               Missing
#  :product_size_id  Missing
#  :layout_id        Missing
#  :set_id           Missing
#  :image_filename   Union{Missing, String}
#  :is_listed        Missing)

#  SQLite.DBTable("placement_roles", Tables.Schema:
#  :id            Missing
#  :product_id    Missing
#  :position      Missing
#  :name          Union{Missing, String}
#  :full_name     Union{Missing, String}
#  :led_color     Union{Missing, String}
#  :screen_color  Union{Missing, String})

#  SQLite.DBTable("users", Tables.Schema:
#  :id          Missing
#  :username    Union{Missing, String}
#  :created_at  Union{Missing, String})

#  SQLite.DBTable("user_permissions", Tables.Schema:
#  :user_id  Missing
#  :name     Union{Missing, String})

#  SQLite.DBTable("user_syncs", Tables.Schema:
#  :user_id               Missing
#  :table_name            Union{Missing, String}
#  :last_synchronized_at  Union{Missing, String})

#  SQLite.DBTable("wall_expungements", Tables.Schema:
#  :wall_uuid              Union{Missing, String}
#  :created_at             Union{Missing, String}
#  :rejection_reason_code  Missing)

#  SQLite.DBTable("walls_sets", Tables.Schema:
#  :wall_uuid  Union{Missing, String}
#  :set_id     Missing)

#  SQLite.DBTable("climb_cache_fields", Tables.Schema:
#  :climb_uuid          Union{Missing, String}
#  :ascensionist_count  Missing
#  :display_difficulty  Missing
#  :quality_average     Missing)

#  SQLite.DBTable("attempts", Tables.Schema:
#  :id        Missing
#  :position  Missing
#  :name      Union{Missing, String})

#  SQLite.DBTable("difficulty_grades", Tables.Schema:
#  :difficulty    Missing
#  :boulder_name  Union{Missing, String}
#  :route_name    Union{Missing, String}
#  :is_listed     Missing)

#  SQLite.DBTable("climb_stats", Tables.Schema:
#  :climb_uuid            Union{Missing, String}
#  :angle                 Missing
#  :display_difficulty    Missing
#  :benchmark_difficulty  Missing
#  :ascensionist_count    Missing
#  :difficulty_average    Missing
#  :quality_average       Missing
#  :fa_username           Union{Missing, String}
#  :fa_at                 Union{Missing, String})

#  SQLite.DBTable("tags", Tables.Schema:
#  :entity_uuid  Union{Missing, String}
#  :user_id      Missing
#  :name         Union{Missing, String}
#  :is_listed    Missing)

#  SQLite.DBTable("android_metadata", Tables.Schema:
#  :locale  Union{Missing, String})

#  SQLite.DBTable("circuits", Tables.Schema:
#  :uuid         Union{Missing, String}
#  :name         Union{Missing, String}
#  :description  Union{Missing, String}
#  :color        Union{Missing, String}
#  :user_id      Missing
#  :is_public    Missing
#  :is_listed    Missing
#  :created_at   Union{Missing, String}
#  :updated_at   Union{Missing, String})

#  SQLite.DBTable("circuits_climbs", Tables.Schema:
#  :circuit_uuid  Union{Missing, String}
#  :climb_uuid    Union{Missing, String}
#  :position      Missing)

#  SQLite.DBTable("kits", Tables.Schema:
#  :serial_number   Union{Missing, String}
#  :name            Union{Missing, String}
#  :is_autoconnect  Missing
#  :is_listed       Missing
#  :created_at      Union{Missing, String}
#  :updated_at      Union{Missing, String})

#  SQLite.DBTable("climb_random_positions", Tables.Schema:
#  :climb_uuid  Union{Missing, String}
#  :position    Union{Missing, Int64})

#  SQLite.DBTable("walls", Tables.Schema:
#  :uuid                   Union{Missing, String}
#  :user_id                Missing
#  :name                   Union{Missing, String}
#  :product_id             Missing
#  :is_adjustable          Missing
#  :angle                  Missing
#  :layout_id              Missing
#  :product_size_id        Missing
#  :hsm                    Missing
#  :serial_number          Union{Missing, String}
#  :created_at             Union{Missing, String}
#  :rejection_reason_code  Missing)

#  SQLite.DBTable("beta_links", Tables.Schema:
#  :climb_uuid        Union{Missing, String}
#  :link              Union{Missing, String}
#  :foreign_username  Union{Missing, String}
#  :angle             Union{Missing, Int64}
#  :thumbnail         Union{Missing, String}
#  :is_listed         Missing
#  :created_at        Union{Missing, String})

#  SQLite.DBTable("bids", Tables.Schema:
#  :uuid        Union{Missing, String}
#  :user_id     Missing
#  :climb_uuid  Union{Missing, String}
#  :angle       Missing
#  :is_mirror   Missing
#  :bid_count   Missing
#  :comment     Union{Missing, String}
#  :climbed_at  Union{Missing, String}
#  :created_at  Union{Missing, String})

#  SQLite.DBTable("ascents", Tables.Schema:
#  :uuid                   Union{Missing, String}
#  :wall_uuid              Union{Missing, String}
#  :climb_uuid             Union{Missing, String}
#  :angle                  Missing
#  :is_mirror              Missing
#  :user_id                Missing
#  :attempt_id             Missing
#  :bid_count              Missing
#  :quality                Missing
#  :difficulty             Missing
#  :is_benchmark           Missing
#  :comment                Union{Missing, String}
#  :climbed_at             Union{Missing, String}
#  :created_at             Union{Missing, String}
#  :rejection_reason_code  Missing)

#  SQLite.DBTable("climbs", Tables.Schema:
#  :uuid             Union{Missing, String}
#  :layout_id        Missing
#  :setter_id        Missing
#  :setter_username  Union{Missing, String}
#  :name             Union{Missing, String}
#  :description      Union{Missing, String}
#  :hsm              Missing
#  :edge_left        Missing
#  :edge_right       Missing
#  :edge_bottom      Missing
#  :edge_top         Missing
#  :angle            Union{Missing, Int64}
#  :frames_count     Missing
#  :frames_pace      Missing
#  :frames           Union{Missing, String}
#  :is_draft         Missing
#  :is_listed        Missing
#  :created_at       Union{Missing, String})

#  SQLite.DBTable("placements", Tables.Schema:
#  :id                         Missing
#  :layout_id                  Missing
#  :hole_id                    Missing
#  :set_id                     Missing
#  :default_placement_role_id  Missing)
#  """