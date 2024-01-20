function plot_random_climb(wall::String="original")

    if wall == "original"
        KB = Kilterboard_original()
    elseif wall == "homewall"
        KB = Kilterboard_homewall()
    else
        error("Wall not found.")
    end

    climb = rand(get_all_climbs(KB).frames)

    return plot_climb(climb, KB)
end

function plot_heatmap(board_angle::Int=45, wall::String="original", grade::String="All")

    if wall == "original"
        KB = Kilterboard_original()
    elseif wall == "original_wide"
        KB = Kilterboard_original_wide()
    elseif wall == "homewall"
        KB = Kilterboard_homewall()
    else
        print("Wall not found.")
    end

    return heatmap(KB, board_angle, grade)
end