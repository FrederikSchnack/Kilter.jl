module App

using Stipple, StippleUI, StipplePlotly
using PlotlyBase, DataFrames
using GenieFramework
@genietools

#make sure to:
#using Pkg
#Pkg.add(path="../")
using Kilter

include("util.jl")

const kdata = Dict{String, Kdata}("Original" => Kdata_original(), "Homewall" => Kdata_home())


@mounted watchplots()


@handlers begin
  
  @in board = "Original"
  @in board_angle::Union{Vector{Dict}, Dict}=Dict("max" => 50, "min" => 40)
  @in grade::Union{Vector{Dict}, Dict}=Dict("max" => 33, "min" => 10)
  @in climbs_selection = []
  @in side_sel_holds = Vector{Int}()

  #PlotlyEvents
  @in side_plot_data_click = []

  @out plot_data = PlotData()
  @out layout = PlotlyBase.Layout()
  @out side_layout = PlotlyBase.Layout()

  @out climbs = DataTable()
  @out grade_label = Dict()
  @out table_pagination=DataTablePagination(rows_per_page=12)
  # Side plot
  @out side_plot_data = PlotData()

  @onchange isready begin
    @show "App is loaded"
    @show board
    @show grade 


    grade_label = Dict("min" => Kilter.get_grade(grade["min"]), "max" => Kilter.get_grade(grade["max"]))
    sel_holds = collect(keys(kdata[board].KB.frame_to_pos))[side_sel_holds]

    climbs_ = kdata[board].climbs
    climbs = DataTable(climbs_[(board_angle["min"] .<= climbs_.Angle .<= board_angle["max"])  .* (grade["min"] .<= climbs_.difficulty_average .<= grade["max"]) .* ( [all(contains.(s, string.(sel_holds))) for s in climbs_.frames]), ["Name", "Grade", "Setter", "FA", "#sends"]])

    layout = kdata[board].layout
    
    side_layout = kdata[board].layout
    side_plot_data = plot_all_climbs(kdata[board].KB, side_sel_holds)

    if !isempty(climbs_selection)
      name = climbs_selection[]["Name"]
      climbs_ = kdata[board].climbs
      frames = climbs_[climbs_.Name .== name, :].frames[1]
      plot_data = frame_to_plot(frames, kdata[board].KB)
    end
  end

  @onchange side_plot_data_click begin
    @show side_plot_data_click

    if !isempty(side_plot_data_click)
      hold_num = side_plot_data_click[]["points"][]["pointIndex"] +1

      if hold_num ∈ side_sel_holds
        deleteat!(side_sel_holds, side_sel_holds .== hold_num)
      else
        push!(side_sel_holds, hold_num)
      end

      sel_holds = collect(keys(kdata[board].KB.frame_to_pos))[side_sel_holds]
      side_plot_data = plot_all_climbs(kdata[board].KB, side_sel_holds)

      plot_data = PlotData()

      climbs_ = kdata[board].climbs
      climbs = DataTable(climbs_[(board_angle["min"] .<= climbs_.Angle .<= board_angle["max"])  .* (grade["min"] .<= climbs_.difficulty_average .<= grade["max"]) .* ( [all(contains.(s, string.(sel_holds))) for s in climbs_.frames]), ["Name", "Grade", "Setter", "FA", "#sends"]])
    end

  end
  

  @onchange board begin
    @show board

    side_sel_holds = Vector{Int}()
    sel_holds = collect(keys(kdata[board].KB.frame_to_pos))[side_sel_holds]

    side_plot_data = plot_all_climbs(kdata[board].KB, side_sel_holds)
    plot_data = PlotData()
    layout = kdata[board].layout
    side_layout = kdata[board].layout
    climbs_ = kdata[board].climbs
    climbs = DataTable(climbs_[(board_angle["min"] .<= climbs_.Angle .<= board_angle["max"])  .* (grade["min"] .<= climbs_.difficulty_average .<= grade["max"]) .* ( [all(contains.(s, string.(sel_holds))) for s in climbs_.frames]), ["Name", "Grade", "Setter", "FA", "#sends"]])
  end

  @onchange board_angle begin
    @show board_angle

    plot_data = PlotData()
    climbs_ = kdata[board].climbs
    sel_holds = collect(keys(kdata[board].KB.frame_to_pos))[side_sel_holds]
    climbs = DataTable(climbs_[(board_angle["min"] .<= climbs_.Angle .<= board_angle["max"]) .* (grade["min"] .<= climbs_.difficulty_average .<= grade["max"]) .* ( [all(contains.(s, string.(sel_holds))) for s in climbs_.frames]), ["Name", "Grade", "Setter", "FA", "#sends"]])

  end

  @onchange grade begin
    @show grade

    grade_label = Dict("min" => Kilter.get_grade(grade["min"]), "max" => Kilter.get_grade(grade["max"]))
    plot_data = PlotData()
    climbs_ = kdata[board].climbs
    sel_holds = collect(keys(kdata[board].KB.frame_to_pos))[side_sel_holds]
    climbs = DataTable(climbs_[(board_angle["min"] .<= climbs_.Angle .<= board_angle["max"])  .* (grade["min"] .<= climbs_.difficulty_average .<= grade["max"]) .* ( [all(contains.(s, string.(sel_holds))) for s in climbs_.frames]), ["Name", "Grade", "Setter", "FA", "#sends"]])

  end


  @onchange climbs_selection  begin
    @show climbs_selection

    if !isempty(climbs_selection)
      name = climbs_selection[]["Name"]
      climbs_ = kdata[board].climbs
      frames = climbs_[climbs_.Name .== name, :].frames[1]
      plot_data = frame_to_plot(frames, kdata[board].KB)
    else
      plot_data = PlotData()
    end

  end

end

@page("/", "app.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(title="Kilter Dashboard"))

end