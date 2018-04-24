# Metal-Oxide-LASSO-lo

The Code is devided into three parts - 

1. Step 1: Read excel file with primary descriptors and generate secondary dataset
2. Step 2: Use LASSO to find out top descriptors for Binding energy 
3. Step 3: Use lo (1D-5D) regression to find best (1D-5D) descriptors. 

All files are provided in this directory. 

Step 1: 
Dir: ./Step_1
MATLAB CODE: cluster.m
INPUT: Binding_energyV4.xlsx
OUTPUT: data_set.mat (matlab data file) 

Step 2: 
Dir: ./Step_2
MATLAB CODE: analysis.m
INPUT: data_set.mat
OUTPUT: a. lasso_final.mat (matlab data file)
        b. lasso_param.txt (results of LASSO analysis)

Step 3: 
Dir: ./Step_3
MATLAB CODE: analysis.m
OUTPUTS: a. log_L1.txt : Results of lo fits
	 b. jpgs for DFT vs predicted for 1D-5D
	 c. raw data for plots in b.
