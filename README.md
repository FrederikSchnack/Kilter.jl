<p align="center">
<picture>
 <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/ca5e3dc60e81338af25a6dfc300bdf03d370cfdb/app/public/css/inv_image.svg">
 <img alt="Shows an illustrated sun in light color mode and a moon with stars in dark color mode." src="https://raw.githubusercontent.com/FrederikSchnack/Kilter.jl/ca5e3dc60e81338af25a6dfc300bdf03d370cfdb/app/public/css/image.svg">
</picture>
</p>

# Kilter.jl
## What is a Kilterboard? 

The [Kilterboard](https://settercloset.com/pages/the-kilter-board) is a light-up app-controlled Climbing wall that  connects you to a worldwide database of boulder problems. There is an Original Layout Kilter Board (the standard, made for gyms) and a Homewall Layout designed for smaller spaces and home users.

## This project

~~The aim of this project is two-fold:~~
~~* Firstly, to analyse established boulder problems in different ways, e.g. which holds are used often, at which angles and at what difficulty. 
In the process, we aim to implement some advanced filtering of problems.~~
~~* Finally, we want to generate/propose new boulder problems given a certain input, e.g. angle, grade, some holds that should be contained... (Yes this will probably use some [machine learning](https://images.squarespace-cdn.com/content/v1/592c721986e6c0040d5a263e/1500835784786-FLPND3SN0XG8WFNDKQ86/image-asset.gif))~~

We try to provide a set of tools for analyzing and playing around with the kilterboardapp data. This is done via the: 
* A Genie web-dashboard, soon to be hosted. 
* Julia package, which allows to create own experiments with it.

This project only provides support for the most common kilterboard configurations, but is interchangable with other auroraclimbing applications like the grasshopper or tension board. 

## Example
### Genie Dashboard
<img src="https://i.imgur.com/gUHS6t0.png"/>

### Julia Code
```jl
using Kilter

plot_heatmap(45, "original")

plot_heatmap(30, "homewall")
```

Original 45°         | Homewall 30°
:-------------------------:|:-------------------------:
![](https://user-images.githubusercontent.com/22898700/225465223-671b96b3-c97f-4679-80c3-e4b55cf755ac.png)  |  ![](https://user-images.githubusercontent.com/22898700/225465244-58322dfb-b689-440a-b0c5-dcfc8b8de878.png)

## Running the dashboard in the Browser locally using Genie.jl
```
julia -e "cd(\"app/\"); using Pkg; Pkg.activate(\".\"); using GenieFramework; Genie.loadapp(); up(async=false);"
```
### Acknowledgements
* ![KilterBoard_climb_generator](https://github.com/Declan-Stockdale-Garbutt/KilterBoard_climb_generator): A project trying to generate kilterboard climbs via AI, which we didn't look too much into. 
* ![BoardLib](https://github.com/lemeryfertitta/BoardLib): A nice and complete project, collecting API calls for the auroraclimbing apps. This was very helpful for understanding the kitlerboard api. 
* ![fake_kilter_board](https://github.com/1-max-1/fake_kilter_board): A very nice resource for understanding the packet structure of the bluetooth communication with the kilterboard. 

All data used is publicly available in the Kilterboard app by Aurora Climbing. 
