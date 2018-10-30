
static String SketchName = "BD_Cumulative";

/*
  BD_Cumulative.pde
  by R M L Evans
  
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

  See readme.txt for more info.
*/

int RandomNumberSeed = 7;
float  mu = 0.0046188;  // Mutation strength
float  BirthRate = 80.0;
int    L = 128;            // Linear size of LxL lattice
boolean HalfAndHalf = false;  // Sets initial condition: true for lattice divided into greedy and generous region; false for random strategy at each site.


class Agent{
  float offer;
  float accept;
  float wealth;
  double birthday;
  
  Agent(float offer_, float accept_){
    offer = offer_;
    accept = accept_;
    wealth = 0.0;
    birthday = t;
  }
  
  void InheritFrom(Agent parent){
    wealth = 0.0;
    birthday = t;
    offer = parent.offer + random(-Mutation,Mutation);
    if (offer > 1.0) offer = 1.0;
    if (offer < 0.0) offer = 0.0;
    accept = parent.accept + random(-Mutation,Mutation);
    if (accept > 1.0) accept = 1.0;
    if (accept < 0.0) accept = 0.0;
  }
  
}

Agent[][] agent;

float SP = 0.5;  // Bias due to selection pressure; this fraction of deaths are competitively selected (as opposed to random within the neighbourhood).
double    t = 0;  // Time
int    LSquared,logt=-999;
double  tmax;
float  Mutation;  // Sets the half-width of a uniform distribution. Standard deviation is mu=Mutation/sqrt(3).
boolean CommandLine = false;
static String[] CommandLineArgs;

static public void main(String args[]) {    // Overwrite PApplet's main entry point, in order to implement command line parsing
  CommandLineArgs=new String[args.length+1];
  CommandLineArgs[0] = SketchName; 
  for(int i=0; i<args.length; i++) CommandLineArgs[i+1]=args[i];
  PApplet.main(CommandLineArgs);
}

void setup(){
  int i,j;
  
// Check for command line arguements and, if they exist, update the parameters
  if (CommandLineArgs.length > 1){
    if (CommandLineArgs.length != 7){
      println("Wrong number of command line arguments!");
      println("Require: (int)RandomNumberSeed (float)mu (float)BirthRate (int)L (boolean)HalfAndHalf (float)tmax");
      exit();
    }
    CommandLine = true;
    RandomNumberSeed = int(CommandLineArgs[1]);
    mu = float(CommandLineArgs[2]);
    BirthRate = float(CommandLineArgs[3]);
    L = int(CommandLineArgs[4]);
    HalfAndHalf = boolean(CommandLineArgs[5]);
    tmax = (double)float(CommandLineArgs[6]);
  }
  Mutation = mu*1.732050808;
  LSquared = L*L;
  
//  size(210+L*2+10,(L*2>403)?(L*2):403);  // Processing 2 allows dynamic sizing of window.
  size(476,403);                            // Processing 3 requires hard-coding of window size.

  randomSeed(RandomNumberSeed);

// Initialize the agents:
  agent = new Agent[L][L];
  if (HalfAndHalf) for (i=0; i<L; i++) for (j=0; j<L; j++){
    agent[i][j] = new Agent((i<L/2)?0.0:1.0,(i<L/2)?0.0:random(1.0));
  }
  else for (i=0; i<L; i++) for (j=0; j<L; j++){
    agent[i][j] = new Agent(random(1.0),random(1.0));
  }
  
// If applet was launched from the command line, simulate for specified duration then exit...
  if(CommandLine){
    while(t<tmax){
      timestep();
      if ((int)(4*log((float)t))>logt){
        logt = (int)(4*log((float)t));
        OutputData();
      }
    }
    OutputData();
    exit();
  } 
//...otherwise proceed to iterate draw().
}

void draw(){
  int i,j,iterations;
  float maxwealth=0.0;
    
  for(iterations=1;iterations<=50000;iterations++) timestep();

  OutputData();

//Update graphics:
  background(0);
  colorMode(HSB,1.25);
  stroke(0.5,1.25,1.25);
  line(0,200,200,200);
  line(0,200,0,0);
  line(0,402,200,402);
  line(0,402,0,202);
  noStroke();
  //Draw scale:
  for (j=0; j<=100; j++){
    fill(j*0.01,1.25,1.25);
    rect(210+L*2+3,j*2,7,2);
  }
  //Draw population:
  for(i=0; i<L; i++) for(j=0; j<L; j++){
    fill(1.0-agent[i][j].offer,1.25,1.25);
    rect(210+i*2,j*2,2,2);
    fill(0,0,1.25);
    rect(int(200*agent[i][j].offer),int(200*(1.0-agent[i][j].accept)),1,1);
    if (agent[i][j].wealth>maxwealth) maxwealth = agent[i][j].wealth;
  }  
  for(i=0; i<L; i++) for(j=0; j<L; j++){
    fill(1.0-agent[i][j].offer,1.25,1.25);
    rect(210+i*2,j*2,2,2);
    fill(0,0,1.25);
    rect(int(200*agent[i][j].offer),int(200*(1.0-(agent[i][j].wealth/maxwealth)))+202,1,1);
  }  
}

void OutputData(){
  int i,j;
  float totaloffer=0,totalaccept=0,totalwealth=0,totalage=0;
  float meanoffer,meanaccept,meanwealth,meanage;
  float totsqoffdev=0,totsqaccdev=0,totsqhealdev=0,totsqagedev=0;
  float offdev,tot3offdev=0,tot4offdev=0;

  for(i=0; i<L; i++) for(j=0; j<L; j++){
    totaloffer += agent[i][j].offer;
    totalaccept += agent[i][j].accept;
    totalwealth += agent[i][j].wealth;
    totalage += (t-agent[i][j].birthday);
  }
  meanoffer = totaloffer/LSquared;
  meanaccept = totalaccept/LSquared;
  meanwealth = totalwealth/LSquared;
  meanage = totalage/LSquared;
  for(i=0; i<L; i++) for(j=0; j<L; j++){
    offdev = agent[i][j].offer - meanoffer;
    totsqoffdev += offdev*offdev;
    tot3offdev += offdev*offdev*offdev;
    tot4offdev += offdev*offdev*offdev*offdev;
    totsqaccdev += (agent[i][j].accept-meanaccept)*(agent[i][j].accept-meanaccept);
    totsqhealdev += (agent[i][j].wealth-meanwealth)*(agent[i][j].wealth-meanwealth);
    totsqagedev += (t-agent[i][j].birthday-meanage)*(t-agent[i][j].birthday-meanage);
  }
  println();
  println("RandomNumberSeed, mu, BirthRate, L, HalfAndHalf, t, <offer>, <accept>, <wealth>, <age>, offer SD, accept SD, wealth SD, age SD, offer skewness, offer kurtosis");
  print(RandomNumberSeed+", "+mu+", "+BirthRate+", "+L+", "+HalfAndHalf+", "+t+", ");
  print(meanoffer+", "+meanaccept+", "+meanwealth+", "+meanage+", ");
  print(sqrt(totsqoffdev/LSquared)+", "+sqrt(totsqaccdev/LSquared)+", "+sqrt(totsqhealdev/LSquared)+", "+sqrt(totsqagedev/LSquared)+", ");
  println((tot3offdev/LSquared)/((totsqoffdev/LSquared)*sqrt(totsqoffdev/LSquared))+", "+(((tot4offdev/LSquared)/((totsqoffdev/LSquared)*(totsqoffdev/LSquared)))-3.0));
}

void timestep(){
  int i,j,i1,j1,k,neighbour,weakest=0;
  int[] ii = new int[4];
  int[] jj = new int[4];
  float offer,total,r,reciprocal,neighbourwealth,lowestwealth=0;
  double dt;

  reciprocal=1.0/BirthRate;
  dt = ((BirthRate<1.0)?1.0:reciprocal)/LSquared;
  for (int repeat=1; repeat<=20; repeat++){
   t += dt;
  //Play game at a random site:
   if (random(1.0)<reciprocal){
    i = int(random(float(L)));
    j = int(random(float(L)));
    //Choose a random neighbour to play with:
    switch (int(random(4))){
      case 0:
        i1 = (i+1)%L;
        j1 = j;
        break;
      case 1:
        i1 = i;
        j1 = (j+1)%L;
        break;
      case 2:
        i1 = (i+L-1)%L;
        j1 = j;
        break;
      case 3:
        i1 = i;
        j1 = (j+L-1)%L;
        break;
      default:
        i1 = j1 = 0;
        exit();
        break;
    }
    //Play the Ultimatum Game:
    if ((offer=agent[i][j].offer) >= agent[i1][j1].accept){
      agent[i1][j1].wealth += offer;
      agent[i][j].wealth += 1.0-offer;
    }
   }
   
  //Random birth:
    if (random(1.0)<BirthRate){
      //Randomly choose a an agent to reproduce:
      i = int(random(float(L)));
      j = int(random(float(L)));
      //Find all neighbours:
      ii[0] = (i+1)%L;
      jj[0] = j;
      ii[1] = i;
      jj[1] = (j+1)%L;
      ii[2] = (i+L-1)%L;
      jj[2] = j;
      ii[3] = i;
      jj[3] = (j+L-1)%L;
      //Find the weakest neighbour (or a random one) to replace, searching them in a random order to avoid bias in a tie.
      neighbour = int(random(4));
      weakest = neighbour;
      if (random(1.0)<SP) for (k=0; k<4; k++){
        neighbour = (neighbour+1)%4;
        neighbourwealth = agent[ii[neighbour]][jj[neighbour]].wealth;
        if ( (k==0) || (neighbourwealth < lowestwealth) ){
          lowestwealth = neighbourwealth;
          weakest = neighbour;
        }
      }
      agent[ii[weakest]][jj[weakest]].InheritFrom(agent[i][j]);
    }    
  }
}