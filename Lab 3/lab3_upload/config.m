load('gmonths.mat');
load('pv_digitizer.mat');
load('pv_dcdc_digitizer.mat');
load('batt_dcdc_digitizer.mat');
load('battery_digitizer.mat');

%%% Retrive MPP point given the pv curves digitized %%%
G = [250; 500; 750; 1000];
pv_I = zeros(4,1);
pv_V = zeros(4,1);
mpp_pv_line_250 = [pv_line_250(:,1), pv_line_250(:,1).*pv_line_250(:,2)];
mpp_pv_line_500 = [pv_line_500(:,1), pv_line_500(:,1).*pv_line_500(:,2)];
mpp_pv_line_750 = [pv_line_750(:,1), pv_line_750(:,1).*pv_line_750(:,2)];
mpp_pv_line_1000 = [pv_line_1000(:,1), pv_line_1000(:,1).*pv_line_1000(:,2)];
[~,i] = max(mpp_pv_line_250(:,2));
v_c = pv_line_250(i,:);
pv_V(1) = v_c(1);
pv_I(1) = v_c(2);
[~,i] = max(mpp_pv_line_500(:,2));
v_c = pv_line_500(i,:);
pv_V(2) = v_c(1);
pv_I(2) = v_c(2);
[~,i] = max(mpp_pv_line_750(:,2));
v_c = pv_line_750(i,:);
pv_V(3) = v_c(1);
pv_I(3) = v_c(2);
[m,i] = max(mpp_pv_line_1000(:,2));
v_c = pv_line_1000(i,:);
pv_V(4) = v_c(1);
pv_I(4) = v_c(2);

%%% pv module dcdc converter
dcdc_pv_V = dcdcpv_eff(:,1);
dcdc_pv_eff = dcdcpv_eff(:,2);

%%% battery dcdc converter
dcdc_batt_I = dcdc_batt(:,1);
dcdc_batt_eff = dcdc_batt(:,2);

%%% battery model
samples = [0:0.01:1];
disc1c = interp1(line1c(:,1), line1c(:,2), samples);
disc05c = interp1(line05c(:,1), line05c(:,2), samples);
batt_res = (disc1c - disc05c)./(3.2-16);
batt_Voc = disc1c + batt_res*3.2;

% sensor activation durantion 
air_time = 30; 
methane_time = 30; 
temp_time = 6; 
mic_time = 12; 
transmit_time = 24; 
mc_time = 6; 

% activation delay
% parallel exec
air_delay = 0; 
methane_delay = 0; 
temp_delay = 0; 
mic_delay = 0;
mc_delay = 30; 
transmit_delay = mc_delay + mc_time;

% period
% setting 1: 120 (2 minutes)
% setting 2: 60*10 (10 minutes)
period = 120; 

% pulse width: % of period when sensor is active
air_pulse = (air_time * 100)/period; 
methane_pulse = (methane_time * 100)/period; 
temp_pulse = (temp_time *100)/period; 
mic_pulse = (mic_time * 100)/period; 
mc_pulse = (mc_time*100)/period; 
transmit_pulse = (transmit_time * 100)/period; 

% simulation length
sim_length = Gmonth(size(Gmonth, 1),1);


