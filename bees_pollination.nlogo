breed [bees bee]
breed [trees tree]
breed [flowers flower]
breed [hives hive]
breed [weather-displays weather-display]


bees-own [visited-flowers pesticide-timer toxicity life-timer]
flowers-own[visit-count]
trees-own [flower-count visited-flowers bees-generated]
hives-own [weather]

to setup
  clear-all
  create-agents
  setup-hive
  ask patches [
    set pcolor rgb 34 139 34
  ]
  ;; Add random toxic patches if pesticides are present
  if num-pesticides > 0 [
    add-random-toxic-patches num-pesticides
  ]
  assign-weather-shape
  create-weather-display
  reset-ticks
end

to go
  assign-weather-shape
  let max-ticks 5000 ;; lenght of 1 pollination season
  ;; Reset pesticide effects if no pesticides are present
  if num-pesticides = 0 [
    ask bees [
      set pesticide-timer 0
      set toxicity "none"
    ]
  ]

  ;; Stop the simulation if all tree flowers are visited or max ticks reached (end of season)
  if all-tree-flowers-visited? or ticks >= max-ticks [
    stop
  ]

  ;; Bees perform their actions
  ask bees [
    move
    visit-flowers
    pollinate-trees
    check-pesticide
    age
  ]

  ;; Trees check if they are fully visited
  ask trees [
    check-if-fully-visited
  ]

  ;; Change weather every 100 ticks
  ask hives [
    if ticks mod 100 = 0 [
      set weather one-of ["sunny" "cloudy" "stormy"]
      ]
  ]
  tick
end

to create-agents
  ;; Create bees with initial properties
  create-bees num-bees
  [
    set shape "bee"
    set size 0.5
    set color yellow
    setxy random-xcor random-ycor
    set visited-flowers []  ;; Start with an empty list of visited flowers
    set pesticide-timer 0
    set toxicity "none"
    set life-timer 1000 + random 1000
  ]

  ;; Create trees with initial properties
  create-trees num-trees [
    set shape "tree"
    set color green
    set size 3
    setxy random-xcor random-ycor
    set flower-count 10 + random 10
    set visited-flowers 0
    set bees-generated false
  ]

  ;; Create flowers with initial properties
  create-flowers num-flowers [
    set shape "flower"
    set color red
    set size 0.7
    set visit-count 0
    setxy random-xcor random-ycor
  ]
end

to setup-hive
  ;; Create a hive with initial properties
  create-hives 1 [
    set shape "hex"
    set size 2.5
    set color rgb 255 223 0
    setxy max-pxcor - 1 min-pycor + 1
    set label "Hive"
    set label-color white
    set weather "sunny"
  ]
end

to generate-bees [num]
  ask hives [
    ;; Generate new bees with specific properties
    hatch-bees 5 [
      set shape "bee"
      set size 0.5
      set color red
      setxy xcor ycor
      set visited-flowers []  ;; Start with an empty list of visited flowers
      set pesticide-timer 0
      set toxicity "none"
      set life-timer 1000 + random 1000
      set label ""
    ]
  ]
end

to move
  let selected-hive one-of hives
  let current-weather [weather] of selected-hive

  ;; Bees move differently based on weather and pesticides
  if current-weather = "sunny" [
    if pesticide-timer > 0 [
      right random 360
      if toxicity = "low" [ fd 0.7 + random-float 0.2 ] ;; low speed reduction
      if toxicity = "medium" [ fd 0.5 + random-float 0.2 ] ;; medium speed reduction
      if toxicity = "high" [ fd 0.2 + random-float 0.1 ] ;; high speed reduction
    ]
    if pesticide-timer = 0 [
      right random 360
      forward 0.8 + random-float 0.4
    ]
  ]

  if current-weather = "cloudy" [
    if pesticide-timer > 0 [
      right random 360
      if toxicity = "low" [ fd 0.7 + random-float 0.2 ] ;; low speed reduction
      if toxicity = "medium" [ fd 0.5 + random-float 0.2 ] ;; medium speed reduction
      if toxicity = "high" [ fd 0.2 + random-float 0.1 ] ;; high speed reduction
    ]
    if pesticide-timer = 0 [
      right random 360
      forward 0.6 + random-float 0.3
    ]
  ]

  if current-weather = "stormy" [
    forward 0 ;; Stop moving during the storm
  ]
end

;; Bees visit and interact with nearby flowers
to visit-flowers
  let nearby-flower one-of flowers in-radius 1
  if nearby-flower != nobody [
    ask nearby-flower [
      set visit-count visit-count + 1
      if visit-count >= 5 [
        set color blue  ;; Change flower color when fully visited
      ]
    ]
  ]
end

;; Bees pollinate trees if they are on the same patch
to pollinate-trees
  if pesticide-timer > 0 [
    if toxicity = "low" [ if random-float 1 < 0.8 [stop] ;;80% chance to pollinate, 20% chance to stop
  ]
    if toxicity = "medium" [ if random-float 1 < 0.5 [stop] ;;50% chance to pollinate, 50% chance to stop
  ]
    if toxicity = "high" [ if random-float 1 < 0.2 [stop] ;;20% chance to pollinate, 80% chance to stop
  ]
  ]

  if pesticide-timer = 0 [
  let tree-here one-of trees-here
  if tree-here != nobody [
    ask tree-here [
      if visited-flowers < flower-count [
        set visited-flowers visited-flowers + 1
      ]
    ]
  ]
 ]
end

to check-if-fully-visited
  ;; Change tree color if all flowers have been visited
  if visited-flowers >= flower-count and not bees-generated [
    set color yellow  ;; Change color to indicate full pollination
    set bees-generated true  ;; Mark that bees have been generated
    ask hives [
      generate-bees 1  ;; Command to generate bees when the tree is fully visited
    ]
  ]
end

to-report all-tree-flowers-visited?
  report sum [visited-flowers] of trees >= sum [flower-count] of trees
end

;; Add random patches of pesticides of different toxicity level using the slider
to add-random-toxic-patches [pesticides]
  repeat pesticides [
    let random-patch one-of patches with [pcolor = rgb 34 139 34]
    ask random-patch [
      if toxicity-level = 1 [ set pcolor pink ]
      if toxicity-level = 2 [ set pcolor orange ]
      if toxicity-level = 3 [ set pcolor red ]
    ]
  ]
end

to check-pesticide
  if num-pesticides = 0 [
    set pesticide-timer 0
    set toxicity "none"
    stop
  ]
  if pcolor = pink [
    set pesticide-timer 2000 ;; Set pesticide timer for low toxicity
    set toxicity "low"
  ]
  if pcolor = orange [
    set pesticide-timer 2000 ;; Set pesticide timer for medium toxicity
    set toxicity "medium"
  ]
  if pcolor = red [
    set pesticide-timer 2000 ;; Set pesticide timer for high toxicity
    set toxicity "high"
  ]
end


to age
  if pesticide-timer > 0 [
    set pesticide-timer pesticide-timer - 1
    ;; Gradually penalize life-timer based on toxicity level
    if toxicity = "low" [
      set life-timer max (list 0 (life-timer - 0.1))
    ]
    if toxicity = "medium" [
      set life-timer max (list 0 (life-timer - 0.3))
    ]
    if toxicity = "high" [
      set life-timer max (list 0 (life-timer - 0.5))
    ]
  ]

  ;; Regular aging
  set life-timer life-timer - 0.87
  if life-timer <= 0 [
    die
  ]
end

to create-weather-display
  create-weather-displays 1 [
    set shape "sun"  ;; Initial shape, will change based on weather
    set size 3
    set color rgb 255 165 0
    setxy (max-pxcor - 2) (max-pycor - 2)
  ]
end



to assign-weather-shape
  let selected-hive one-of hives
  let current-weather [weather] of selected-hive

 ;; Update the shape of the weather display
 ask weather-displays [
    if current-weather = "sunny" [
      set shape "sun"
      set color rgb 255 165 0
      setxy (max-pxcor - 2) (max-pycor - 2)
    ]
    if current-weather = "cloudy" [
      set shape "cloud"
      set color grey
      setxy (max-pxcor - 2) (max-pycor - 2)
    ]
    if current-weather = "stormy" [
      set shape "storm"
      set color grey
      ;;set size 6
      setxy (max-pxcor - 2) (max-pycor - 2)
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1009
810
-1
-1
23.97
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
200.0

BUTTON
12
21
76
54
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
96
22
159
55
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
79
182
112
num-trees
num-trees
1
30
15.0
1
1
NIL
HORIZONTAL

SLIDER
10
125
182
158
num-flowers
num-flowers
1
150
70.0
1
1
NIL
HORIZONTAL

SLIDER
9
170
181
203
num-bees
num-bees
1
30
15.0
1
1
NIL
HORIZONTAL

MONITOR
1137
38
1253
83
Visited flowers of trees
sum [visited-flowers] of trees
17
1
11

PLOT
1056
167
1256
317
Visited flowers of trees
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [visited-flowers] of trees"

SLIDER
9
214
181
247
num-pesticides
num-pesticides
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
10
260
182
293
toxicity-level
toxicity-level
1
3
2.0
1
1
NIL
HORIZONTAL

MONITOR
1055
39
1126
84
Total bees
count bees
17
1
11

MONITOR
1056
101
1257
146
Weather
[weather] of one-of hives
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model simulates one season of the pollination process of apple trees by bees. It explores how many bees are needed to effectively fertilize apple trees so that apples can grow. 


For a single apple tree, having 5-10 active bees visiting throughout the day can usually suffice. However, in an orchard, one hive per acre is the general guideline for effective pollination.


Factors Influencing Pollination:
Weather: Cold, rainy, or windy weather can reduce bee activity.
Pesticides of different level of toxicity.
Competing Flowers: Other blooming flowers nearby might distract bees from the apple flowers.
In this model we study honeybees that are the most common pollinators, but not to be forget are bumblebees and solitary bees that are also very effective.


## TRENDS
The randomized positions of trees and flowers and pesticides can give very different results launching the simulation several times with the same settings.
However the general trends are that fewer bees with less trees tends to have more difficult to survive.
Grass flowers distracts the bees from tree pollination so the time to pollinate will be longer the more grass flowers we add.
Add trees will make the colony grow exponentially.
Add pesticides, specially when more than 5, can give very drastic results.


## HOW IT WORKS

The model uses agents (bees, trees, flowers, hives, and weather) to simulate the pollination process. 
Bees move around the environment, visiting flowers and trees. 
When a bee visits a flower, it increases the flower's visit count and the flower becomes blue.
When a bee visits a tree, it increases the tree's visited flower count. Trees change color to yellow when all their flowers have been visited, indicating full pollination.
The generation of new bees depends on the tree pollination. 
New bees span every time that a tree is fully pollinated, simulating the food resourcing of the bees. The new bees are generated with a red head in order to differenciate them from the original bees.
The model also simulates the effects of pesticides of 3 levels of toxicity on bees, which can reduce their lifespan and affect their behavior.
The weather also has an impact on the behavior of the bees. When it's sunny no effects on bees, when it's cloudy they are slower with less pollination, and when it's stormy they do not move with no pollination.


## HOW TO USE IT

Setup: Click the setup button to initialize the model. This creates bees, trees, flowers, and a hive.
Go: Click the go button to start the simulation. Bees will begin moving, visiting flowers, and pollinating trees.
Sliders: Adjust the number of bees (num-bees), trees (num-trees), flowers (num-flowers), pesticides (num-pesticides) and pesticides toxicity (toxicity-level) using the sliders. Click setup after using the sliders. The model will update accordingly.
Weather: The weather changes every 100 ticks, affecting bee movement.


## THINGS TO NOTICE

Observe how bees interact with flowers and trees, thanks also to the monitors on total bees, visited flowers of trees, weather and visited flowers plot.
Notice the change in tree color when all flowers on a tree have been visited.
Watch how the weather affects bee movement and activity.
Pay attention to the impact of pesticides on bee lifespan and behavior.



## THINGS TO TRY

Increase or decrease the number of bees and observe the effect on pollination efficiency.
Adjust the number of trees and flowers to see how it impacts the pollination process.
Introduce pesticides and observe their impact on bee behavior and lifespan.
Experiment with different pesticides toxicity levels to see how they affect bee activity.


## EXTENDING THE MODEL

Introduce night and day patterns.
Add more detailed behaviors for bees, such as returning to the hive after a certain number of visits or during the night.
Implement different types of flowers with varying attractiveness to bees.
Introduce more complex weather patterns, such as temperature and seasonality, and their effects on bee activity.
Add more detailed pesticide effects, such as less toxic during the night while bees are in the hive.
Add predators or parasites agents that can impact bees activity such as Varroa destructor.
Add new hives once a colony is complete and need to split.
Add various stages of pollination in a tree to monitor the ongoing pollination status.


## NETLOGO FEATURES

The model uses breeds to define different types of agents (bees, trees, flowers, hives, and weather displays).
The ask command is used extensively to control agent behavior.
The model uses patch colors to represent different pesticide levels.
The hatch command is used to generate new bees.
The stormy turtle has bee created from scratch since it was not available in the library.
Some colors have been customised using custom rgb color model.


## RELATED MODELS

This model has bee created from scratch based on my research on bees pollination.


## CREDITS AND REFERENCES

This model was created to explore the pollination process of apple trees by bees. For more information on bee pollination and its importance, refer to resources on agricultural science and entomology.

https://bees.techno-science.ca/english/bees/pollination/default.php
https://en.wikipedia.org/wiki/Pollination
https://plantura.garden/uk/insects/bees/bee-pollination
https://en.wikipedia.org/wiki/List_of_crop_plants_pollinated_by_bees
https://www.farmers.gov/blog/value-birds-and-bees
https://wonderopolis.org/wonder/how-many-flowers-can-a-bee-pollinate
https://www.orkin.com/pests/stinging-pests/bees/honey-bees/honey-bee-colony
https://en.wikipedia.org/wiki/Varroa_destructor
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 152 149 77 163 67 195 67 211 74 234 85 252 100 264 116 276 134 286 151 300 167 285 182 278 206 260 220 242 226 218 226 195 222 166
Polygon -16777216 true false 150 149 128 151 114 151 98 145 80 122 80 103 81 83 95 67 117 58 141 54 151 53 177 55 195 66 207 82 211 94 211 116 204 139 189 149 171 152
Polygon -7500403 true true 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
Polygon -16777216 true false 70 185 74 171 223 172 224 186
Polygon -16777216 true false 67 211 71 226 224 226 225 211 67 211
Polygon -16777216 true false 91 257 106 269 195 269 211 255
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100

bee2
true
0
Polygon -1184463 false false 165 150 180 135 195 120 195 210 165 180
Polygon -1184463 false false 135 150 105 120 105 210 135 180
Rectangle -1184463 true false 120 150 120 180
Circle -1184463 true false 129 144 42
Polygon -1184463 true false 135 180 135 180 150 195 165 180
Polygon -16777216 true false 150 180
Circle -16777216 true false 135 135 30
Line -1184463 false 150 150 135 120
Line -1184463 false 150 150 165 120

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

cloud2
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hex
false
0
Polygon -7500403 true true 0 150 75 30 225 30 300 150 225 270 75 270

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

storm
false
0
Circle -7500403 true true 96 81 108
Circle -7500403 true true 96 141 108
Circle -7500403 true true 141 51 108
Circle -7500403 true true 165 120 122
Circle -7500403 true true 30 60 120
Circle -7500403 true true 13 118 126
Polygon -7500403 true true 135 150 135 150 150 135 135 150
Polygon -13345367 true false 120 165 90 195 120 240 105 300 165 240 135 195 165 120 120 165
Circle -7500403 true true 105 45 60

sun
false
0
Circle -7500403 true true 75 75 150
Polygon -7500403 true true 300 150 240 120 240 180
Polygon -7500403 true true 150 0 120 60 180 60
Polygon -7500403 true true 150 300 120 240 180 240
Polygon -7500403 true true 0 150 60 120 60 180
Polygon -7500403 true true 60 195 105 240 45 255
Polygon -7500403 true true 60 105 105 60 45 45
Polygon -7500403 true true 195 60 240 105 255 45
Polygon -7500403 true true 240 195 195 240 255 255

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
