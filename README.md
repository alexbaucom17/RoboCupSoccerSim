# RoboCupSoccerSim

This project is a MATLAB simulation designed to model RoboCup SPL matches. It's primary function is to allow testing of various player behaviors in a controlled environment. It is also designed to able to easily use reinforcement learning to learn new behaviors.

## Requirements
MATLAB (written and tested in R2016a but *should* be compatable with any recent release)

Parallel Computing Toolbox if you want to run simulations in parallel

A reasonably recent computer if you want to run the simulation in realtime (or faster)

## Usage
To run a single game use the Run_Game script

To run many games use the ParallelTesting script

The Config file has all of the configuration parameters and documentation for each of them

For details on the inner workings of the simulation, see the next section

## Details
All files are documented with comments so please read through those as well if you want to understand more

Files in the root directory are high level files that are used to run the simulation and edit parameters.

Files in the game directory are functions to run and manage various aspects of the simulation. The GameController file is the main high level file to run the match.

Files in the @ball directory define the ball object, which handles simulating the ball motion

Files in the @player directory define the player object, which handles simulating player motion and behavior

Files in the @world directory define the world object, which holds information about the world that the players can 'observe'

The simulation is designed to be able to easily pass different behavior files into it for testing different configurations. All these behavior files must be located in the @player folder to be considered a method of the player object. Currently the player behavior is set up to accept motion files for simple behavior FSM but it is very simple to change the behavior file call in the player.update() method to accept an entire behavior file instead of just a motion file. Read through the player.update() method and the behavior_simpleFSM file to understand how the test files get called.

## License
MIT License

Copyright (c) 2016 Alex Baucom

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
