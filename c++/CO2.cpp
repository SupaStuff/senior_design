#include <iostream>
//writing to a file
#include <fstream> 

using namespace std;


int main(int argc, char *argv[]) {
	
	float co2_init = 300; //ppm
	float co2_desired = 1000;
	float volume = 1;
	float flow_rate = 900.0/3600.0;
	float plant_absorb = 723.0/3600.0; 
	float co2_amount = co2_init;
	float threshold = 300;
	
	int i = 0;
	
	ofstream myfile;
	
	myfile.open ("dataCO2.txt");	
	
	while (i < 6*3600) 
	{
		if(co2_amount < co2_desired && (threshold >= 300) )
		{
			co2_amount = co2_amount + flow_rate - plant_absorb;
		}
		else
		{
			co2_amount =  co2_amount - plant_absorb;
			threshold -= plant_absorb;
			if (threshold <= 0)
				threshold = 300;
		}
		myfile << i << "  " << co2_amount << endl;
		
		i++;
	}
	
	
	myfile.close();
	return 0;
	
}