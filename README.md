# UltimatumGame
Evolutionary modelling using the Stochastic Spatial ultimatum game.

BD_Cumulative.pde  by R M L Evans
  
Code for simulation of model pubished at 
www.nature.com/articles/s41598-018-34384-w
in:

"Pay-off scarcity causes evolution of risk-aversion and extreme altruism", 
R M L Evans, Sci. Rep (2018) 8:16074. 


Coded in "processing" language, a java-based (C-derived) language, freely available at
https://processing.org/

For real-time graphical output, launch the code directly from the processing IDE.
To set parameters and output text, the code can be compiled and exported to an executable, then 

launched from the comman line, specifying the parameters:
(int)RandomNumberSeed (float)mu (float)BirthRate (int)L (boolean)HalfAndHalf (float)tmax

e.g.

.\BD_Cumulative.exe 6 0.005 100 128 false 10000.0

or, to redirect output to a text file for further analysis:

.\BD_Cumulative.exe 6 0.005 100 128 false 10000.0 > .\BD_CumulatBR100M0.008.csv

Thus a set of simulations may be run sytematically by executing a batch file such as 

exampleBatchScript.bat



Algorithm of the Stochastic Spatial Ultimatum Game B-D Process (Random birth causes a fitness-dependent death):

Agents filling a square grid are chosen at random play the Ultimatum Game,
making an offer to a randomly chosen one of their four immediate neighbours.
The offerer is chosen stochastically at a mean rate of once per agent per 
timestep. Also stochastically, with a mean rate of BirthRate per agent, agents
are selected randomly to reproduce. Their offspring replaces either the weakest of the 
parent's four neighbours (with probability SP) or a random neighbour (with probability 
1-SP). 

Offspring inherit none of the parent's wealth.
They inherit the parent's offer and acceptance values +/- a uniformly 
distributed random mutation of standard deviation mu.

