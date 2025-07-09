For running this code:
go to the lib folder and then run firefly.ex file
terminal: iex firefly.ex 
then FireflyFestival.start() , you can pass number of fireflies. i have default set it to 50.

Code Structure

start/0,1: it will initialize and start the simulation
fireflyProcess/1: Main firefly initialize random start time
fireflyLoop/4: it handles firefly state transitions
blinksCheck/3: it process incoming blink messages
printResult/1: display the fireflies state.

