Interactive Relatedness Picker v1.0
by Michael Bates

This is a simple tool built in R using the Shiny and ShinyWidgets packages amongst others to allow clients to easily compare the relatedness between any two or more aniamls.

The app requires a GRM.

So far from testing there are a few minor bugs here and there:
- You have to have more than one sire selected otherwise it has a "2-dimensional data" error
- I have tested it for proper large GRMs of 1000x1000 size and it works but is very very slow so best to use it for preselected breeding animals.