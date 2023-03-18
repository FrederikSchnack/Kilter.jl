module App

using Stipple, StippleUI, StipplePlotly
using PlotlyBase, DataFrames
using GenieFramework
@genietools

include("../src/Kilter.jl")
using .Kilter

include("util.jl")

const kdata = Dict{String, Kdata}("Original" => Kdata_original(), "Homewall" => Kdata_home())


@handlers begin
  

  @in board = "Original"
  @in board_angle = 45
  @in grade = (15, 20)
  @in climbs_selection = []

  @out plot_data = PlotData()
  @out layout = PlotlyBase.Layout()
  @out climbs = DataTable()
  
  @onchange isready begin
    @show "App is loaded"
    @show board
  
    layout = kdata[board].layout
    climbs_ = kdata[board].climbs
    climbs = DataTable(climbs_[(climbs_.Angle .== board_angle) .* (grade[1] .<= climbs_.difficulty_average .<= grade[2]), ["Name", "Grade", "Setter", "FA", "#sends"]])
  end

  @onchange board begin
    @show board
    plot_data = PlotData()
    layout = kdata[board].layout
    climbs_ = kdata[board].climbs
    climbs = DataTable(climbs_[(climbs_.Angle .== board_angle) .* (grade[1] .<= climbs_.difficulty_average .<= grade[2]), ["Name", "Grade", "Setter", "FA", "#sends"]])
  end

  @onchange  climbs_selection  begin
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

@page("/", "app.jl.html")

end