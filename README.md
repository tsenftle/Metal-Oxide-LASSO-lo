# Metal-Oxide-LASSO-lo

Code written by 
 A S M Jonayat
 Ph.D. Candidate
 Dept. of Mechanical and Nuclear Engineering
 The Pennsylvania State University, University Park - 16802
 
Distributed as part of the publication - 
Interaction trends between single metal atoms and oxide supports identified with density functional theory and statistical learning
Nolan J. O’Connor, A S M Jonayat, Michael J. Janik*, Thomas P. Senftle*

www.nature.com/articles/s41929-018-0094-5

Department of Chemical Engineering, Department of Mechanical and Nuclear Engineering, The Pennsylvania State University, University Park, PA 16802 (USA)
Department of Chemical and Biomolecular Engineering, Rice University, Houston, TX 77005 (USA)
 *mjanik@engr.psu.edu
 *tsenftle@rice.edu

The Code is devided into three parts - 

1. Step 1: Read excel file with primary descriptors and generate secondary dataset
2. Step 2: Use LASSO to find out top descriptors for Binding energy 
3. Step 3: Use lo regression to find best 1D-5D descriptors. 

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
