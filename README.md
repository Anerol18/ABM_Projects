# ABM_Projects
Projects on Agent Based Models

Bees Pollination Simulator
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
