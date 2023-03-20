# Kilter.jl

## What is a Kilterboard? 

The [Kilterboard](https://settercloset.com/pages/the-kilter-board) is a light-up app-controlled Climbing wall that  connects you to a worldwide database of boulder problems. There is an Original Layout Kilter Board (the standard, made for gyms) and a Homewall Layout designed for smaller spaces and home users.

## This project

The aim of this project is two-fold:
* Firstly, to analyse established boulder problems in different ways, e.g. which holds are used often, at which angles and at what difficulty. 
In the process, we aim to implement some advanced filtering of problems.
* Finally, we want to generate/propose new boulder problems given a certain input, e.g. angle, grade, some holds that should be contained... (Yes this will probably use some [machine learning](https://images.squarespace-cdn.com/content/v1/592c721986e6c0040d5a263e/1500835784786-FLPND3SN0XG8WFNDKQ86/image-asset.gif))

Ideally these features will be provided in some interactive web interface.


## Example
```jl
using Kilter

plot_heatmap(45, "original")

plot_heatmap(30, "homewall")
```

Original 45°         | Homewall 30°
:-------------------------:|:-------------------------:
![](https://user-images.githubusercontent.com/22898700/225465223-671b96b3-c97f-4679-80c3-e4b55cf755ac.png)  |  ![](https://user-images.githubusercontent.com/22898700/225465244-58322dfb-b689-440a-b0c5-dcfc8b8de878.png)

## Running in the Browser locally using Genie.jl
```
julia -e "cd(\"app/\"); using Pkg; Pkg.activate(\".\"); using GenieFramework; Genie.loadapp(); up(async=false);"
```

### Acknowledgements
There is a similar ![project](https://github.com/Declan-Stockdale-Garbutt/KilterBoard_climb_generator) written in Python, that I have not too much looked into. All data used is publicly available in the Kilterboard app by Aurora Climbing. 
