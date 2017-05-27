#include <iostream>
//Used for sleeping functions
#include <unistd.h> 
//srand, rand
#include <stdlib.h>
//time     
#include <time.h>      
//math
#include <math.h>
//writing to a file
#include <fstream> 


using namespace std;


int main(int argc, char *argv[]) {
	
	srand (time(NULL));
	
	float previous_error = 0,
			error = 0,
	
			integral = 0,
			derivative = 0,
			
			kP = .2,// .1,
			kI = .1,// 1 /*.1*/,
			kD = .05, //.4 /*.05*/,
			
			setpoint = 75,
			measured_value = 65,
			dt = 1,
			delta = 1,
			
			output = 0;
			
	int	time_off = 0;
	float diff = 0;
	float T_0 = 0;
	
	int time_heater_on = 0;
	
	float temp_off = 0;
	
	const float ambient_temp = 63;
	const float newton_constant = -.001155;
	
	ofstream myfile;
	
	myfile.open ("dataPIDMAN.txt");	
			
			
	uint i = 0;
			
	const uint oneSecond = 1000000;
			
	
	while(i < 60*60*6)
	{

		error = setpoint - measured_value;
		
		if(error > 0)
			temp_off += error;
		else 
			temp_off -= error;
		
		if(error > .5 || error < -.5)
		//if(error > .5)
		{
			integral = integral + error*dt;
			derivative = (error - previous_error)/dt;
			output = kP*error + kI*integral + kD*derivative;
			previous_error = error;
			
			time_heater_on++;
			
			measured_value = measured_value + output;
			
			
		}
		else if ((error <= .5 && error >= -.5) && (previous_error > .5 || previous_error < -.5)) {
			time_off = 0;
			diff = measured_value - ambient_temp;
			T_0 = measured_value;
			
			measured_value = ambient_temp + (diff)*exp(newton_constant*(time_off++));
			
			previous_error = error;
		}
		else{
			measured_value = ambient_temp + (diff)*exp(newton_constant*(time_off++));
		}

	 //}
//	else if (condition) {
		
//	}
		//*((rand()%5 -2));
		
		
		/*
		The output can only control the actuator that is able to add heat
		or add cooling to the system.
		
		The measured value will also be based on the rate of change of the environment.
		
		We don't have access to the outside temperature, but we can study how the temperature is changing when left to its natural state and model this change with newtons law of cooling.
		
		We know that the heating and cooling systems will be able to add x amount of H (Heat) and C (Cooling) to the system every T (time interval) they are on.
		
		Assume that they heat up and cool intstantly and have a constant amount of +-Heat that they introduce to the system.
		
		We will also need to ta
		
		*/
		
		//usleep(oneSecond*dt/1000);
		
		/*cout << "Iteration: " << i++ << "\n"
			  << "Error: " << error << "\n"
			  << "Integral: " << integral << "\n"
			  << "Derivative: " << derivative << "\n" 
			  << "Output: " << output << "\n"
			  << "Set Point: " << setpoint << "\n" 
			  << "Measured Value: " << measured_value <<"\n\n"; */
			
		//cout << i++ << ": "<< measured_value << endl;
		
		if(i < 400)
			myfile << i << " "<< measured_value << endl;
		
		i++;
	}
	cout << "Time Heater On = " << time_heater_on << "s"<< endl;
	cout << "Energy Consumed = " << time_heater_on*300 << "J" << endl;
	cout << "Sum Temp Diff = " << temp_off << endl;
	
	myfile.close();
	  return 0;
}