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
			
			kP = 1,
			kI = 0 /*.1*/,
			kD = 0 /*.05*/,
			
			setpoint = 75,
			measured_value = 65,
			dt = 1,
			delta = 1,
			
			output = 0;
			
	int	time_off = 0;
	float diff = 0;
	float T_0 = 0;
	
	int time_heater_on = 0;
	int total_heater_on = 0;
	
	float temp_off = 0;
	
	const float ambient_temp = 63;
	
	const float heater_temp = 90; 
	const float heater_constant = -.002345;
	
	float heat_temp_const = 0;
	
	const float newton_constant = -.001155;
	
	bool set_heater = true;
	
	ofstream myfile;
	
	myfile.open ("dataPID1.txt");	
			
			
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
			if(set_heater)
			{
				heat_temp_const = measured_value - heater_temp;
				set_heater = false;
			}
			integral = integral + error*dt;
			derivative = (error - previous_error)/dt;
			//output = kP*error + kI*integral + kD*derivative;
			previous_error = error;
			
			total_heater_on++;
			
			//measured_value = measured_value + output;
			
			measured_value = heater_temp + heat_temp_const*exp(heater_constant*(time_heater_on++));
			
			
		}
		else if ((error <= .5 && error >= -.5) && (previous_error > .5 || previous_error < -.5)) {
			time_off = 0;
			time_heater_on = 0;
			
			set_heater = true;
			
			diff = measured_value - ambient_temp;
			T_0 = measured_value;
			
			measured_value = ambient_temp + (diff)*exp(newton_constant*(time_off++));
			
			previous_error = error;
		}
		else{
			measured_value = ambient_temp + (diff)*exp(newton_constant*(time_off++));
		}

		if(i <= 1000)
			myfile << i << " "<< measured_value << endl;
		
		i++;
	}
	cout << "Time Heater On = " << total_heater_on << "s"<< endl;
	cout << "Energy Consumed = " << total_heater_on*300 << "J" << endl;
	cout << "Sum Temp Diff = " << temp_off << endl;
	
	myfile.close();
	  return 0;
}