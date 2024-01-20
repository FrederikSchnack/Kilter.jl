function login(username::String, password::String)

    j = Dict("username" => username, "password" => password)
    url = "https://api.kilterboardapp.com/v1/logins"
    post = HTTP.request("POST", url, ["Content-Type" => "application/json"], json(j))

    return JSON.Parser.parse(String(post.body))

end

get_token(username::String, password::String) = login(username, password)["token"]

function login()
    return login("kilterdashboard", "kilterdashboard")
end

get_token() = login()["token"]

function explore(token::String, search::String)

    h = Dict("authorization" => "Bearer "*token)
    url = "https://api.kilterboardapp.com/explore"
    get = HTTP.request("GET", url, headers=h, query=["q" => search])

    return JSON.Parser.parse(String(get.body))["results"]
end


function get_logbook(token::String, user_id::String)

    url = "https://api.kilterboardapp.com/v1/users/"*user_id*"/logbook?types=ascent"
    h = Dict("authorization" => "Bearer "*token)
    lb = HTTP.request("GET", url, headers=h)

    return JSON.Parser.parse(String(lb.body))["logbook"]
end

function get_user(token::String, user_id::String)
    url = "https://api.kilterboardapp.com/v2/users/"*user_id
    h = Dict("authorization" => "Bearer "*token)
    u = HTTP.request("GET", url, headers=h)

    return JSON.Parser.parse(String(u.body))["user"]
end

function get_image(filename::String)
    return HTTP.download("https://api.kilterboardapp.com/img/"*filename) |> load
end



function shared_sync(tables=[],shared_syncs=[])
    """
    Shared syncs are used to download data from the board. They are not authenticated.

    :param tables: list of tables to download. The following are valid:
        "products",
        "product_sizes",
        "holes",
        "leds",
        "products_angles",
        "layouts",
        "product_sizes_layouts_sets",
        "placements",
        "sets",
        "placement_roles",
        "climbs",
        "climb_stats",
        "beta_links",
        "attempts",
        "kits",
    """
    url = "https://api.kilterboardapp.com/v1/sync"
    t = SQLite.DBInterface.execute(db.x,"""SELECT table_name, last_synchronized_at FROM shared_syncs""") |> DataFrame
    shared_syncs = [Dict("table_name" => tt.table_name, "last_synchronized_at" => tt.last_synchronized_at) for tt in eachrow(t)]
    tables = [
        "products",
        "product_sizes",
        "holes",
        "leds",
        "products_angles",
        "layouts",
        "product_sizes_layouts_sets",
        "placements",
        "sets",
        "placement_roles",
        "climbs",
        "climb_stats",
        "beta_links",
        "attempts",
        "kits",
    ]

    j = Dict("client"=> Dict("enforces_product_passwords"=> 1,
                            "enforces_layout_passwords"=> 1,
                            "manages_power_responsibly"=> 1,
                            "ufd"=> 1),
            "GET" => Dict("query" => Dict("syncs" => Dict( "shared_syncs" => shared_syncs),
                                        "tables"=> tables,
                                        "include_multiframe_climbs"=> 1,
                                        "include_all_beta_links"=> 1,
                                        "include_null_climb_stats"=> 1
                                        )
                        )
            )

    p = HTTP.request("POST", url, ["Content-Type" => "application/json"], json(j))

    return JSON.Parser.parse(String(p.body))["PUT"]
end

function download_db_apkpure()
    url = "https://d.cdnpure.com/b/APK/com.auroraclimbing.kilterboard?version=latest"
    zip = HTTP.request("GET", url)    
    write("/tmp/kilterboard.zip", zip.body)
end 

function get_climb_stats(token::String, climb_id::String, angle::String)
    url = "https://api.kilterboardapp.com/v1/climbs/"*climb_id*"/info"

    a = Dict("angle" => angle)
    h = Dict("authorization" => "Bearer "*token)
    u = HTTP.request("GET", url, headers=h,  query=a)

    return JSON.Parser.parse(String(u.body))
end
