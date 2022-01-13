load('gmonths.mat')

%%% Retrive MPP point given the pv curves digitized %%%
load('pv_digitizer.mat')
G = [250; 500; 750; 1000];
I = zeros(4,1);
V = zeros(4,1);
mpp_pv_line_250 = [pv_line_250(:,1), pv_line_250(:,1).*pv_line_250(:,2)];
mpp_pv_line_500 = [pv_line_500(:,1), pv_line_500(:,1).*pv_line_500(:,2)];
mpp_pv_line_750 = [pv_line_750(:,1), pv_line_750(:,1).*pv_line_750(:,2)];
mpp_pv_line_1000 = [pv_line_1000(:,1), pv_line_1000(:,1).*pv_line_1000(:,2)];
[~,i] = max(mpp_pv_line_250(:,2));
v_c = pv_line_250(i,:);
V(1) = v_c(1);
I(1) = v_c(2);
[~,i] = max(mpp_pv_line_500(:,2));
v_c = pv_line_500(i,:);
V(2) = v_c(1);
I(2) = v_c(2);
[~,i] = max(mpp_pv_line_750(:,2));
v_c = pv_line_750(i,:);
V(3) = v_c(1);
I(3) = v_c(2);
[m,i] = max(mpp_pv_line_1000(:,2));
v_c = pv_line_1000(i,:);
V(4) = v_c(1);
I(4) = v_c(2);
%%%

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

