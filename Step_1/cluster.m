%% 
% Code written by 
% A S M Jonayat
% Ph.D. Candidate
% Dept. of Mechanical and Nuclear Engineering
% The Pennsylvania State University, University Park - 16802
% 
% Distributed as part of the publication - 
% Interaction trends between single metal atoms and oxide supports identified with density functional theory and statistical learning
% Nolan J. O’Connor, A S M Jonayat, Michael J. Janik*, Thomas P. Senftle*

% Department of Chemical Engineering, bDepartment of Mechanical and Nuclear Engineering, The Pennsylvania State University, University Park, PA 16802 (USA)
% Department of Chemical and Biomolecular Engineering, Rice University, Houston, TX 77005 (USA)
% *mjanik@engr.psu.edu
% *tsenftle@rice.edu

%%
clear all;
clc
diary 'log.txt'
disp('Importing Data');

%% Import the data: Binding Energy Data
[~, ~, raw] = xlsread('Binding_energyV4.xlsx','binding_energy');
raw = raw(2:end,:);
%raw = raw(2:92,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[1,2]);
raw = raw(:,3);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
B = cellVectors(:,1);       % Support oxide metal name
A = cellVectors(:,2);       % Adamtom metal name
BE_eV = data(:,1);          % Binding energy (eV)

%% Clear temporary variables
clearvars data raw cellVectors;


%% Import the Oxide formation and head of sub. data
[~, ~, raw] = xlsread('Binding_energyV4.xlsx','oxide_properties');
raw = raw(2:14,[1,6:7]);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);
raw = raw(:,[2,3]);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
metal = cellVectors(:,1);       % Adatom metal name
Hs_eV = data(:,1);              % Heat of oxide formation of adatom metal oxide
Hf_eV = data(:,2);              % Heat of subblimination of adatom metal oxide

%% Clear temporary variables
clearvars data raw cellVectors;


%% Import the data: Surface Properties
[~, ~, raw] = xlsread('Binding_energyV4.xlsx','surface_properties');
raw = raw(2:end,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);
raw = raw(:,[2,3,4,5,6,7,8,9,10,11,12]);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
surface = cellVectors(:,1);     % surface oxide metal atom name
Ox_vac_eV = data(:,1);          % oxygen vacancy energy (eV) 
wf_eV = data(:,2);              % work function of the surface (eV)
surface_energy = data(:,3);     % surface energy  (mev/A^2)
cn_m_b = data(:,4);             % coordination number of Metal (of metal oxide) in bulk
cn_m_s = data(:,5);             % coordination number of Metal (of metal oxide) in surface    
cn_o_b = data(:,6);             % coordination number of Oxygen (of metal oxide) in bulk
cn_o_s = data(:,7);            % coordination number of Oxygen (of metal oxide) in surface
bv_b = data(:,8);               % Bond valence of metal (of metal oxide) in bulk
bv_s = data(:,9);               % Bond valence of metal (of metal oxide) in surface
s_ion_3 = data(:,10);
s_ion_4 = data(:,11);
%% Clear temporary variables
clearvars data raw cellVectors;

%% Import the data : atom properties
[~, ~, raw] = xlsread('Binding_energyV4.xlsx','atomic_properties');
raw = raw(3:22,[1:12,14:15,17:20]);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);
raw = raw(:,[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
atom_name = cellVectors(:,1);   % atom name
Z = data(:,1);                  % Atomic Number
Chi_P = data(:,2);              % Electronegativity - Pauling Scale
Chi_MB = data(:,3);             % Electronegativity - Martynov-Batsanov (scaled to Pauling)
ionization_1_eV = data(:,4);    % 1st ionization energy (NIST) eV
ionization_2_eV = data(:,5);   % 2nd ionization energy (NIST) eV
EA_eV = data(:,6);              % Electron Affinity (eV)
HOMO_eV = data(:,7);            % HOMO from VASP PW91 calculations
LUMO_eV = data(:,8);            % LUMO from VASP PW91 calculations
Zunger_rs = data(:,9);          % Zunger orbital radii, rs
Zunger_rp = data(:,10);         % Zunger orbital radii, rp
Zunger_rd = data(:,11);         % Zunger orbital radii, rd
WC_rs = data(:,12);             % Waber and Cromer radii, rs
WC_rp = data(:,13);             % Waber and Cromer radii, rp
Val_elec = data(:,14);          % Number of valence electrons
nws13 = data(:,15);             % Miedema - 1st parameter
phi = data(:,16);               % Miedema - 2nd parameter
Chi_MB_un = data(:,17);         % Electronegativity - Martynov-Batsanov (unscaled - recalculated using NIST ionization values)

%% Clear temporary variables
clearvars data raw cellVectors;


% END OF IMPORT
%% Create D matrix
% Hs, Hf, Oxv [Units eV]
% Atomic Properties
n_s=size(BE_eV,1);
head_1={'m_Z', 's_Z', 'o_Z', 'm_Chi_P', 's_Chi_P', 'o_Chi_P', 'm_Chi_MB', 's_Chi_MB', 'o_Chi_MB', 'm_ion_1', 'm_ion_2', 's_ion_1', 's_ion_2', 'o_ion_1', 'o_ion_2', 'm_EA', 's_EA', 'o_EA', ...
    'm_HOMO', 'm_LUMO', 's_HOMO', 's_LUMO', 'o_HOMO', 'o_LUMO', 'm_rs_Z', 'm_rp_Z',  's_rs_Z', 's_rp_Z', 'o_rs_Z', 'o_rp_Z', 'm_rs_WC', 'm_rp_WC', 's_rs_WC', 's_rp_WC', 'o_rs_WC', 'o_rp_WC', 'm_N_val', 's_N_val', 'o_N_val', ...
    'm_n13', 's_n13', 'm_phi', 's_phi', 'm_Chi_MB_un', 's_Chi_MB_un', 'o_Chi_MB_un', 'Hs', 'Hf'};
n_ap=size(head_1);
D_p1=zeros(n_s(1),n_ap(2));
% Surface Properties
head_2={'Oxv', 'W', 'gamma', 'CMB', 'CMS', 'COB', 'COS', 'BVB', 'BVS', 's_ion_3', 's_ion_4'};
n_sp=size(head_2);
D_p2=zeros(n_s(1),n_sp(2));


for i=1:n_s(1)
    idm=find(strcmp(atom_name,A(i)));
    ids=find(strncmp(atom_name,B(i),2));
    ido=find(strcmp(atom_name,'O'));
    idsp=find(strcmp(surface,B(i)));
    idms=find(strcmp(metal,A(i)));
    %X = sprintf('Row %d matA %d matB %d', i, id1, id2);
    %disp(X)
    D_p1(i,:)=[Z(idm) Z(ids) Z(ido) Chi_P(idm) Chi_P(ids) Chi_P(ido) Chi_MB(idm) Chi_MB(ids) Chi_MB(ido) ionization_1_eV(idm) ionization_2_eV(idm) ionization_1_eV(ids) ionization_2_eV(ids) ionization_1_eV(ido) ionization_2_eV(ido) EA_eV(idm) EA_eV(ids) EA_eV(ido)  ...
        HOMO_eV(idm) LUMO_eV(idm) HOMO_eV(ids) LUMO_eV(ids) HOMO_eV(ido) LUMO_eV(ido) Zunger_rs(idm) Zunger_rp(idm) Zunger_rs(ids) Zunger_rp(ids) Zunger_rs(ido) Zunger_rp(ido) WC_rs(idm) WC_rp(idm) WC_rs(ids) WC_rp(ids) WC_rs(ido) WC_rp(ido) Val_elec(idm) Val_elec(ids) Val_elec(ido) ...
        nws13(idm) nws13(ids) phi(idm) phi(ids) Chi_MB_un(idm) Chi_MB_un(ids) Chi_MB_un(ido) Hs_eV(idms) Hf_eV(idms)];
    D_p2(i,:)=[Ox_vac_eV(idsp) wf_eV(idsp) surface_energy(idsp) cn_m_b(idsp) cn_m_s(idsp) cn_o_b(idsp) cn_o_s(idsp) bv_b(idsp) bv_s(idsp) s_ion_3(idsp) s_ion_4(idsp)];
    
end
% End of data import


disp('Generating Feature Set');

%% Energy terms: E_Pauling - Metal Adatom, Surface metal atom and Oxygen atom
D_P=D_p1(:,4:5);
h_P=head_1(4:5);
unit=ones(1,size(D_P,2));
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);

% 1st_stage
list={'/abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list,1);
list = {'^r'; '^I'; '^2'};
[d_fP,h_fP,u_fP]=genfeature(d_f2,h_f2,u_f2,list,1);
% 2nd stage 
%list={'/abs'};
%[d_f4,h_f4,u_f4]=genfeature2(d_f2,h_f2,u_f2,list,0);

%[D_pauling,unis] = optcU([d_f3 d_f2 d_f4]);
%h_paulingTemp = [h_f3 h_f2 h_f4];
%u_paulingTemp = [u_f3 u_f2 u_f4];
%h_pauling=h_paulingTemp(unis);
%u_pauling=u_paulingTemp(unis);

%% Ionization
D_P=[D_p1(:,10:15) D_p2(:,10:11)];
h_P=[head_1(10:15) head_2(10:11)];
unit=ones(1,size(D_P,2));
% Pre-Process
list={'+abs'};
[d_m,h_m,u_m]=genfeature2(D_P(:,1:2),h_P(1:2),unit(1:2),list,1);
%[d_o,h_o,u_o]=genfeature2(D_P(:,5:6),h_P(5:6),unit(5:6),list,1);
[d_s,h_s,u_s]=genfeature2(D_P(:,7:8),h_P(7:8),unit(7:8),list,1);
d_1=[d_m d_s];
h_1=[h_m h_s];
unit=[u_m u_s];
% 1st stage
list={'-abs'};
unit = [1 1 2 1 1 2];
[d_2,h_2,u_2]=genfeature2(d_1,h_1,unit,list,1);
% 2nd stage
list={'/absu'};
[d_3,h_3,u_3]=genfeature2(d_2,h_2,u_2,list,1);
% 3rd stage 
list={'^r','^I','^2'};
[d_ion,h_ion,u_ion]=genfeature(d_3,h_3,u_3,list,1);

%% EA 
D_P=D_p1(:,16:17);
h_P=head_1(16:17);
unit=ones(1,size(D_P,2));
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);

% 1st_stage
list={'-abs','/abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list,1);
[C,ia,ic]=unique(d_f2','rows','stable');
d_f2=d_f2(:,ia);
h_f2=h_f2(ia);
u_f2=u_f2(ia);
list = {'^r'; '^I'; '^2'};
[d_EA,h_EA,u_EA]=genfeature(d_f2,h_f2,u_f2,list,1);

%% HOMO-LUMO
D_P=D_p1(:,19:22);
h_P=head_1(19:22);
unit=ones(1,size(D_P,2));
list={'-abs', '/abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);
list={'/abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1(:,5:10),h_f1(5:10),u_f1(5:10),list,0);
list = {'^r'; '^I'; '^2'};
[d_fh,h_fh,u_fh]=genfeature([d_f1 d_f2],[h_f1 h_f2],[u_f1 u_f2],list);

%% Surface properties (Hs,Hf,Oxv,wf)
D_P_temp=D_p1(:,47)-D_p1(:,48);
h_P_temp={'(Hs-Hf)'};
D_P=[D_p1(:,47:48) D_P_temp D_p2(:,1:2)];
h_P=[head_1(47:48) h_P_temp head_2(1:2)];
unit=[1 1 2 1 1];
list={'-abs', '/absu', '+abs', '*absu'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,0);
unit=[5 6 1 1 3];
list={'-abs', '/absu', '+abs', '*absu'};
[d_f2,h_f2,u_f2]=genfeature2(D_P,h_P,unit,list,0);
unit=[5 6 1 3 1];
list={'-abs', '/absu', '+abs', '*absu'};
[d_f3,h_f3,u_f3]=genfeature2(D_P,h_P,unit,list,0);
list = {'^r'; '^I'; '^2'};
[d_fs,h_fs,u_fs]=genfeature([D_P d_f1 d_f2 d_f3],[h_P h_f1 h_f2 h_f3],[ones(1,size(D_P,2)) u_f1 u_f2 u_f3],list);

% Check for uniq columns
[C,ia,ic]=unique(d_fs','rows','stable');
d_fs=d_fs(:,ia);
h_fs=h_fs(ia);
u_fs=u_fs(ia);

%% surface energy
D_P=D_p2(:,3);
h_P=head_2(3);
unit=ones(1,size(D_P,2));   % unit vector is used to make sure the function only operates on values with same units
list = {'^r'; '^I'; '^2'};
[d_fg,h_fg,u_fg]=genfeature(D_P,h_P,unit,list);

%% Zunger Radius
D_P=D_p1(:,25:28);
h_P=head_1(25:28);
unit=[1 1 2 2];
list={'+abs', '-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,0);
u_f1=ones(1,size(d_f1,2));
list={'+abs','-abs','/abs','*abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list);
list = {'^r'; '^I'; '^2'};
[d_fz,h_fz,u_fz]=genfeature([D_P d_f2],[h_P h_f2],[ones(1,size(D_P,2)) u_f2],list);

%% Atomic Number (Z)
D_P=D_p1(:,[1:2]);
h_P=head_1([1:2]);
unit=ones(1,size(D_P,2));
list={'-abs', '/abs','*abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,0);
list={'+abs','-abs','/abs','*abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list,1);
list = {'^r'; '^I'; '^2'};
[d_fnd,h_fnd,u_fnd]=genfeature([D_P d_f2],[h_P h_f2],[unit u_f2],list,1);

%% Valence Electron (Nval)
D_P=D_p1(:,[37:38]);
h_P=head_1([37:38]);
unit=ones(1,size(D_P,2));
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,0);
list = {'^r'; '^I'; '^2'};
[d_fnv,h_fnv,u_fnv]=genfeature([D_P d_f1],[h_P h_f1],[unit u_f1],list);

%% Co-ordination Number (CN)
D_P=D_p2(:,[4:7]);
h_P=head_2([4:7]);
%unit=ones(1,size(D_P,2));
unit = [1 1 2 2];
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,0);
list={'+abs'; '-abs'; '/abs'};
u_f1=ones(1,size(d_f1,2));
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list,1);
list = {'^r'; '^I'; '^2'};
[d_fcn,h_fcn,u_fcn]=genfeature([D_P d_f2],[h_P h_f2],[unit u_f2],list);
%check for nan or inf and remove
c_col=find(any(isinf(d_fcn)) | any(isnan(d_fcn)));
d_fcn(:,c_col)=[];
h_fcn(:,c_col)=[];
u_fcn(:,c_col)=[];
[C,ia,ic]=unique(d_fcn','rows','stable');
d_fcn=d_fcn(:,ia);
h_fcn=h_fcn(ia);
u_fcn=u_fcn(ia);
% end check
%% BV
D_P=D_p2(:,[8:9]);
h_P=head_2([8:9]);
unit=ones(1,size(D_P,2));
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);
list = {'^r'; '^I'; '^2'};
[d_fbv,h_fbv,u_fbv]=genfeature(d_f1,h_f1,u_f1,list);



%% Extra Parameters

%% Weber Cramer Radius
D_P=D_p1(:,31:34);
h_P=head_1(31:34);
unit=[1 1 2 2];
list={'+abs', '-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,0);
u_f1=ones(1,size(d_f1,2));
list={'+abs','-abs','/abs','*abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list);
list = {'^r'; '^I'; '^2'};
[d_fwc,h_fwc,u_fwc]=genfeature([D_P d_f2],[h_P h_f2],[ones(1,size(D_P,2)) u_f2],list);

%% Energy terms: E_MB - Metal Adatom, Surface metal atom and Oxygen atom
D_P=D_p1(:,7:8);
h_P=head_1(7:8);
unit=ones(1,size(D_P,2));
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);

% 1st_stage
list={'/abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list,1);
list = {'^r'; '^I'; '^2'};
[d_fMB,h_fMB,u_fMB]=genfeature(d_f2,h_f2,u_f2,list,1);
%% Energy terms: E_MB (unscaled) - Metal Adatom, Surface metal atom and Oxygen atom
D_P=D_p1(:,44:45);
h_P=head_1(44:45);
unit=ones(1,size(D_P,2));
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);

% 1st_stage
list={'/abs'};
[d_f2,h_f2,u_f2]=genfeature2(d_f1,h_f1,u_f1,list,1);
list = {'^r'; '^I'; '^2'};
[d_fMBU,h_fMBU,u_fMBU]=genfeature(d_f2,h_f2,u_f2,list,1);

%% Phi and chi _ Miedema Parameters
D_P=D_p1(:,40:43);
h_P=head_1(40:43);
unit=[1 1 2 2];
list={'-abs'};
[d_f1,h_f1,u_f1]=genfeature2(D_P,h_P,unit,list,1);
list = {'^2'};
[d_fMD,h_fMD,u_fMD]=genfeature(d_f1,h_f1,u_f1,list,1);


%% 
disp('Adding Up matrix'); 
D_s= [d_fP d_ion d_EA d_fh d_fs d_fg d_fz d_fnd d_fnv d_fcn d_fbv d_fMD];
h_s= [h_fP h_ion h_EA h_fh h_fs h_fg h_fz h_fnd h_fnv h_fcn h_fbv h_fMD];

% Final cleaning just in case
c_col=find(any(isinf(D_s)) | any(isnan(D_s)));
D_s(:,c_col)=[];
h_s(:,c_col)=[];

%% 
disp('Running BIG DATA generation step!!');

% special function to avoid multiplication that produces columns with 1
list={'*absI'};
unit=ones(1,size(D_s,2));
[d_f1,h_f1,u_f1]=genfeature2p(D_s,h_s,unit,list,1);

% keep unique descriptors only
[C,ia,ic]=unique(d_f1','rows','stable');

% final unscaled descriptor dataset
d_f1=d_f1(:,ia);
% final headers 
h_f1=h_f1(ia);
% final unit flags - not going to be used in future
u_f1=u_f1(ia);

disp('Saving Data');
save('data_set.mat')

diary off
