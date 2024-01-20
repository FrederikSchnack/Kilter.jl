module App
    using Stipple, StippleUI, StipplePlotly
    using PlotlyBase, DataFrames
    using GenieFramework

    @genietools

    using Kilter

    include("util.jl")

    const kdata = Dict{String, Kdata}("Original" => Kdata_original(), "Homewall" => Kdata_home())

    @mounted watchplots()

    @app begin
        
        @in mode::String = "selection"
        @in board::String = "Original"
        @in board_angle::Dict{String, Int} = Dict("max" => 50, "min" => 40)
        @in grade::Dict{String, Int} = Dict("max" => 33, "min" => 10)
        @in username::String = "Username"
        @in climbs_selection::Vector{Dict{String, Any}} = Dict{String, Any}[]
        @in hold_plot_data_click::Vector{Dict{String, Any}} = Dict{String, Any}[]

        @out avatar_img::String = "https://t3.ftcdn.net/jpg/05/53/79/60/360_F_553796090_XHrE6R9jwmBJUMo9HKl41hyHJ5gqt9oz.jpg"
        @out user_text::String = "Waiting for username. Displaying all climbs for this setting."
        @out grade_label::Dict{String, String} = Dict("min" => Kilter.get_grade(10), "max" => Kilter.get_grade(33))
        @out data::DataTable = DataTable()
        @out histo::PlotData = PlotData()
        @out heatmap::PlotData = PlotData()
        @out hold_plot::PlotData = PlotData()
        @out selection_plot::PlotData = PlotData()
        @out table_pagination::DataTablePagination = DataTablePagination(rows_per_page=7, sort_by="#sends", descending=true)
        @out plot_layout::PlotlyBase.Layout = PlotlyBase.Layout()
        @out histo_layout::PlotlyBase.Layout = PlotlyBase.Layout(plot_bgcolor= "#2E2E2E", paper_bgcolor = "#2E2E2E",
                                                height = 300, margin=attr(l=0,r=0,t=0,b=0),
                                                font=attr(color="#FFFFFF", bgcolor= "#2E2E2E"))

        
        @private user_id::Int = 0
        @private climbs::Dict{String, DataFrame} = Dict("Original" => DataFrame(), "Homewall" =>DataFrame())
        @private hold_selection::Vector{Int} = Int[]
        @private sel_filter::BitVector = BitVector()

        @onchange isready begin
            @show "App is loaded"

            filter = (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"])
            data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])
            
            plot_layout = kdata[board].layout
            histo = plot_histogram(grade, kdata[board].climbs, filter)
            
            sel_filter = BitVector([1 for _ in eachindex(filter)])
            hold_selection = Int[]
            hold_plot = plot_all_climbs(kdata[board], hold_selection)
            heatmap = plot_heatmap(kdata[board], kdata[board].climbs, filter)
        end
        
        @onchange username begin
            @show username

            climbs_selection = []
            hold_selection = []
            hold_plot = plot_all_climbs(kdata[board], hold_selection)

            token = Kilter.get_token()
            expl = Kilter.explore(token, username)
            user_id = 0

            for r in expl
                r["_type"] != "user" && continue

                if r["username"] == username
                    user_id = r["id"]
                    break
                end
            end

            @show user_id

            # user found
            if user_id != 0
                name, avatar, lb = extract_user(token, user_id)

                if !isnothing(avatar)
                    avatar_img = "https://api.kilterboardapp.com/img/"*avatar
                else
                    avatar_img = "https://t3.ftcdn.net/jpg/05/53/79/60/360_F_553796090_XHrE6R9jwmBJUMo9HKl41hyHJ5gqt9oz.jpg"
                end
                
                if !isnothing(name)
                    user_text = name * " with " * string(length(lb)) * " ascents."
                else
                    user_text = "User found with " * string(length(lb)) * " ascents."
                end

                # user has ascents
                if !isempty(lb)
                    logbook = DataFrame(lb)
                    logbook[!, "Personal Grade"] = Kilter.get_grade.(logbook.difficulty)
                    climbs["Original"] = unique(DataFrames.innerjoin(logbook, kdata["Original"].climbs, on = [:climb_uuid => :uuid, :angle => :Angle]))
                    climbs["Homewall"] = unique(DataFrames.innerjoin(logbook, kdata["Homewall"].climbs, on = [:climb_uuid => :uuid, :angle => :Angle]))

                    filter = (board_angle["min"] .<= climbs[board].angle .<= board_angle["max"])  .* (grade["min"] .<= climbs[board].difficulty .<= grade["max"] ) 
                    data = DataTable(climbs[board][filter, ["Name", "angle",  "Personal Grade", "Grade", "#sends", "Setter", "comment", "climbed_at"]])
                    sel_filter = BitVector([1 for _ in eachindex(filter)])

                    histo = plot_histogram(grade, climbs[board], filter) 
                    heatmap = plot_heatmap(kdata[board], climbs[board], filter)

                    user_text *= " Sandbagger score: " * string(sandbag_score(climbs))
                else
                    climbs = Dict("Original" => DataFrame(), "Homewall" => DataFrame())
                    data = DataTable()
                    histo = plot_histogram(grade)
                    heatmap = PlotData()
                end

                # user has ascents
            else
                user_text = "User " * username * " not found. Displaying all climbs for this setting."
                avatar_img = "https://t3.ftcdn.net/jpg/05/53/79/60/360_F_553796090_XHrE6R9jwmBJUMo9HKl41hyHJ5gqt9oz.jpg"
                climbs = Dict("Original" => DataFrame(), "Homewall" => DataFrame())

                filter = (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"]) 
                data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])
                sel_filter = BitVector([1 for _ in eachindex(filter)])

                histo = plot_histogram(grade, kdata[board].climbs, filter) 
                heatmap = plot_heatmap(kdata[board], kdata[board].climbs, filter)
            end

        end


        @onchange grade begin
            @show grade

            climbs_selection = []

            grade_label = Dict("min" => Kilter.get_grade(grade["min"]), "max" => Kilter.get_grade(grade["max"]))

            if !isempty(climbs[board]) 
                filter = (board_angle["min"] .<= climbs[board].angle .<= board_angle["max"])  .* (grade["min"] .<= climbs[board].difficulty .<= grade["max"]) .* sel_filter
                data = DataTable(climbs[board][filter, ["Name", "angle",  "Personal Grade", "Grade", "#sends", "Setter", "comment", "climbed_at"]])

                histo = plot_histogram(grade, climbs[board], filter) 
                heatmap = plot_heatmap(kdata[board], climbs[board], filter)

            elseif user_id == 0
                filter = (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"]) .* sel_filter
                data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])

                histo = plot_histogram(grade, kdata[board].climbs, filter)
                heatmap = plot_heatmap(kdata[board], kdata[board].climbs, filter)
            end
        end

        @onchange board_angle begin
            @show board_angle

            climbs_selection = []

            if !isempty(climbs[board]) 
                filter = (board_angle["min"] .<= climbs[board].angle .<= board_angle["max"])  .* (grade["min"] .<= climbs[board].difficulty .<= grade["max"]) .* sel_filter
                data = DataTable(climbs[board][filter, ["Name", "angle",  "Personal Grade", "Grade", "#sends", "Setter", "comment", "climbed_at"]])

                histo = plot_histogram(grade, climbs[board], filter)
                heatmap = plot_heatmap(kdata[board], climbs[board], filter)

            elseif user_id == 0
                filter = (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"]) .* sel_filter
                data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])

                histo = plot_histogram(grade, kdata[board].climbs, filter)
                heatmap = plot_heatmap(kdata[board], kdata[board].climbs, filter)
            end
        end

        @onchange board begin
            @show board

            climbs_selection = []
            
            hold_selection = Int[]
            hold_plot = plot_all_climbs(kdata[board], hold_selection)

            plot_layout = kdata[board].layout

            if !isempty(climbs[board])
                filter = (board_angle["min"] .<= climbs[board].angle .<= board_angle["max"])  .* (grade["min"] .<= climbs[board].difficulty .<= grade["max"])
                data = DataTable(climbs[board][filter, ["Name", "angle",  "Personal Grade", "Grade", "#sends", "Setter", "comment", "climbed_at"]])

                histo = plot_histogram(grade, climbs[board], filter)
                heatmap = plot_heatmap(kdata[board], climbs[board], filter)
                sel_filter = [1 for _ in eachindex(filter)]

            elseif user_id == 0
                filter = (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"])
                data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])

                histo = plot_histogram(grade, kdata[board].climbs, filter)
                heatmap = plot_heatmap(kdata[board], kdata[board].climbs, filter)                
                sel_filter = [1 for _ in eachindex(filter)]
            end
        end

        @onchange climbs_selection begin
            @show climbs_selection

            if isempty(climbs_selection)
                selection_plot = PlotData()
            elseif  !isempty(climbs[board])
                name = climbs_selection[1]["Name"]
                frames = climbs[board][climbs[board].Name .== name, :].frames[1]
                selection_plot = frame_to_plot(frames, kdata[board].KB)
            else
                name = climbs_selection[1]["Name"]
                frames = kdata[board].climbs[kdata[board].climbs.Name .== name, :].frames[1]
                selection_plot = frame_to_plot(frames, kdata[board].KB)
            end

        end

        @onchange hold_plot_data_click begin
            @show hold_plot_data_click

            if !isempty(hold_plot_data_click)
                xy = (hold_plot_data_click[1]["cursor"]["x"], hold_plot_data_click[1]["cursor"]["y"])
                ind = argmin( sum( abs.(c .- xy)) for c in kdata[board].cords)
                
            
                if ind ∈ hold_selection
                    deleteat!(hold_selection, hold_selection .== ind)
                else
                    push!(hold_selection, ind)
                end

                hold_plot = plot_all_climbs(kdata[board], hold_selection)
                
                frames = map.(x -> kdata[board].cord_to_frame[kdata[board].cords[x]], hold_selection)
                @show frames

                if !isempty(climbs[board])
                    if !isempty(frames)
                        sel_filter = prod(hcat([contains.(climbs[board].frames, string(s)) for s in frames]...), dims=2)[:]
                    else
                        sel_filter = BitVector([1 for _ in eachindex(climbs[board].frames)])
                    end

                    filter = sel_filter .* (board_angle["min"] .<= climbs[board].angle .<= board_angle["max"])  .* (grade["min"] .<= climbs[board].difficulty .<= grade["max"])
                    data = DataTable(climbs[board][filter, ["Name", "angle",  "Personal Grade", "Grade", "#sends", "Setter", "comment", "climbed_at"]])
                    histo = plot_histogram(grade, climbs[board], filter)

                elseif user_id == 0
                    if !isempty(frames)
                        sel_filter = prod(hcat([contains.(kdata[board].climbs.frames, string(s)) for s in frames]...), dims=2)[:]
                    else
                        sel_filter = BitVector([1 for _ in eachindex(kdata[board].climbs.frames)])
                    end

                    filter = sel_filter .* (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"])
                    data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])
                    histo = plot_histogram(grade, kdata[board].climbs, filter)

                end
                
                selection_plot = PlotData()
                
            end

        end

        @onchange mode begin
            @show mode 

            climbs_selection = []

            if !isempty(climbs[board]) 
                filter = (board_angle["min"] .<= climbs[board].angle .<= board_angle["max"])  .* (grade["min"] .<= climbs[board].difficulty .<= grade["max"])
                data = DataTable(climbs[board][filter, ["Name", "angle",  "Personal Grade", "Grade", "#sends", "Setter", "comment", "climbed_at"]])
               
                sel_filter = BitVector([1 for _ in eachindex(filter)])

                histo = plot_histogram(grade, climbs[board], filter)
                heatmap = plot_heatmap(kdata[board], climbs[board], filter)
                hold_selection = Int[]
                hold_plot = plot_all_climbs(kdata[board], hold_selection)

            elseif user_id == 0

                filter = (board_angle["min"] .<= kdata[board].climbs.Angle .<= board_angle["max"])  .* (grade["min"] .<= kdata[board].climbs.difficulty_average .<= grade["max"]) 
                data = DataTable(kdata[board].climbs[filter, ["Name", "Angle", "Grade", "#sends", "Setter"]])
                sel_filter = BitVector([1 for _ in eachindex(filter)])

                histo = plot_histogram(grade, kdata[board].climbs, filter)
                heatmap = plot_heatmap(kdata[board], kdata[board].climbs, filter)
                hold_selection = Int[]
                hold_plot = plot_all_climbs(kdata[board], hold_selection)
            end


        end

    end

    @page("/", "app.jl.html")

end