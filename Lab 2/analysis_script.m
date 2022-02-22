images = functions_script.all_images_banchmark;
n_images = size(images, 2);
n_transf_hb = 11;
n_transf_histeq = 1;
n_transf_hv = 10;
n_transf_hl = 10;
n_transf_hbl = 10;
n_transf_hlv = 10;
n_transf_hbv = 10;
n_transf_hblv = 10;
n_transf = n_transf_hb + n_transf_histeq + n_transf_hv + n_transf_hl;
n_transf = n_transf + n_transf_hbl + n_transf_hbv + n_transf_hlv + n_transf_hblv;
efficiency = zeros(n_transf, n_images);
distortion = zeros(n_transf, n_images);

%{
for i = 1:n_images
    % load the image
    A = imread(images(i));

    % Transform from gray scale to RGB
    if (size(A, 3) == 1)
        clear S;
        S(:,:,1) = A;
        S(:,:,2) = A;
        S(:,:,3) = A;
        A = S;
    end
    
    % apply all defined transformations for each transformation,
    %   save the resulting efficiency and distorsion in the E and D matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Hungry blue
    [hb_dist, hb_eff] = functions_script.hungryblue(A);
    efficiency(1:n_transf_hb, i) = hb_eff;
    distortion(1:n_transf_hb, i) = hb_dist;
    % Histogram equalization
    k = n_transf_hb;
    [histeq_dist, histeq_eff] = functions_script.histogram_eq(A);
    efficiency(k+1:k+n_transf_histeq, i) = histeq_eff;
    distortion(k+1:k+n_transf_histeq, i) = histeq_dist;
    % Hungry Value
    k = k + n_transf_histeq;
    [hv_dist, hv_eff] = functions_script.hungryvalue(A);
    efficiency(k+1:k+n_transf_hv, i) = hv_eff;
    distortion(k+1:k+n_transf_hv, i) = hv_dist;
    % Hungry Luminance
    k = k + n_transf_hv;
    [hl_dist, hl_eff] = functions_script.hungryluminance(A);
    efficiency(k+1:k+n_transf_hl, i) = hl_eff;
    distortion(k+1:k+n_transf_hl, i) = hl_dist;
    % Hungry Blue and Value
    k = k + n_transf_hl;
    [hbv_dist, hbv_eff] = functions_script.hungrybluevalue(A);
    efficiency(k+1:k+n_transf_hbv, i) = hbv_eff;
    distortion(k+1:k+n_transf_hbv, i) = hbv_dist;
    % Hungry Luminance and Value
    k = k + n_transf_hbv;
    [hlv_dist, hlv_eff] = functions_script.hungryluminancevalue(A);
    efficiency(k+1:k+n_transf_hlv, i) = hlv_eff;
    distortion(k+1:k+n_transf_hlv, i) = hlv_dist;
    % Hungry Blue and Luminance
    k = k + n_transf_hlv;
    [hbl_dist, hbl_eff] = functions_script.hungryblueluminance(A);
    efficiency(k+1:k+n_transf_hbl, i) = hbl_eff;
    distortion(k+1:k+n_transf_hbl, i) = hbl_dist;
    % Hungry Blue, Luminance and Value
    k = k + n_transf_hbl;
    [hblv_dist, hblv_eff] = functions_script.hungryall(A);
    efficiency(k+1:k+n_transf_hblv, i) = hblv_eff;
    distortion(k+1:k+n_transf_hblv, i) = hblv_dist;
end

save('results', 'images', 'distortion', 'efficiency');

% statistical analysis on the efficiency and distorsion of images
% ...
metric = efficiency ./ ((1+distortion).^30);

% Hungry blue evaluation
subplot(1,2,1);
x_label = {'90%','80%','70%','60%','50%','40%','30%','20%','10%','0%'};
boxplot(transpose(distortion(2:11,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(2:11,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Histogram equalization evaluation
subplot(1,2,1);
boxplot(transpose(distortion(12,:)), 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(12,:)), 'symbol', '');
ylabel('Efficiency');

% Hungry value evaluation
subplot(1,2,1);
x_label = {'90%','80%','70%','60%','50%','40%','30%','20%','10%','0%'};
boxplot(transpose(distortion(13:22,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(13:22,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Hungry luminance evaluation
subplot(1,2,1);
x_label = {'90%','80%','70%','60%','50%','40%','30%','20%','10%','0%'};
boxplot(transpose(distortion(23:32,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(23:32,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Hungry blue and hungry value
subplot(1,2,1);
x_label = {'95%','90%','85%','80%','75%','70%','65%','60%','55%','50%'};
boxplot(transpose(distortion(33:42,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(33:42,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Hungry luminance and hungry value
subplot(1,2,1);
x_label = {'95%','90%','85%','80%','75%','70%','65%','60%','55%','50%'};
boxplot(transpose(distortion(43:52,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(43:52,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Hungry blue and hungry luminance
subplot(1,2,1);
x_label = {'95%','90%','85%','80%','75%','70%','65%','60%','55%','50%'};
boxplot(transpose(distortion(53:62,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(53:62,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Hungry all
subplot(1,2,1);
x_label = {'95%','90%','85%','80%','75%','70%','65%','60%','55%','50%'};
boxplot(transpose(distortion(63:72,:)), 'Label', x_label, 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(63:72,:)), 'Label', x_label, 'symbol', '');
ylabel('Efficiency');

% Interpolation of efficiency under distortion constraint
n_images = size(images, 2);
eff = zeros(7, n_images, 4);
inter(1,:) = [2:11];
inter(2,:) = [13:22];
inter(3,:) = [23:32];
inter(4,:) = [33:42];
inter(5,:) = [43:52];
inter(6,:) = [53:62];
inter(7,:) = [63:72];
for t = 1:4
    target = 0.01*t;
    for i = 1:n_images
        for g = 1:7
            c = 5.0;
            l = 0.0;
            r = 10.0;
            dist0 = [0; distortion(inter(g,:), i)];
            s = interp1([0:10], dist0, c);
            while (abs(target-s) >= 0.001 && abs(10.0-c) >= 0.01)
                if (s > target)
                    r = c;
                else
                    l = c;
                end
                c = (r+l)/2.0;
                s = interp1([0:10], dist0, c);
            end
            %efficiency hungry blue under constraint 1% distortion
            effic0 = [0; efficiency(inter(g,:), i)];
            eff(g, i, t) = interp1([0:10], effic0, c);
        end
    end
end

eff_mean = mean(eff, 2);
eff_2(1,:) = eff_mean(:,:,1);
eff_2(2,:) = eff_mean(:,:,2);
eff_2(3,:) = eff_mean(:,:,3);
eff_2(4,:) = eff_mean(:,:,4);
X = categorical({'1%', '2%', '3%', '4%'});
X = reordercats(X,{'1%', '2%', '3%', '4%'});
b = bar(X,eff_2);
b(1).FaceColor = [231.0/255, 124.0/255, 141.0/251];
b(2).FaceColor = [198.0/255, 146.0/255, 85.0/251];
b(3).FaceColor = [152.0/255, 162.0/255, 85.0/251];
b(4).FaceColor = [86.0/255, 173.0/255, 116.0/251];
b(5).FaceColor = [94.0/255, 165.0/255, 197.0/251];
b(6).FaceColor = [162.0/255, 145.0/255, 225.0/251];
b(7).FaceColor = [226.0/255, 116.0/255, 207.0/251];

%}


                    %%%%%%%%%% Second day %%%%%%%%%%
                    
images = functions_script.all_images_banchmark;
n_images = size(images, 2);
n_transf = 5*17 ; %only dvs + 2 transformations for 5 different
    % values of Vdd + 3 transformations with 5 different parameters for
    % each Vdd
efficiency_dvs = zeros(n_transf, n_images);
distortion_dvs = zeros(n_transf, n_images);

for i = 1:n_images
    % load the image
    A = imread(images(i));

    % Transform from gray scale to RGB
    if (size(A, 3) == 1)
        clear S;
        S(:,:,1) = A;
        S(:,:,2) = A;
        S(:,:,3) = A;
        A = S;
    end

    % Compute matrix of currents
    I_A = functions_script.computeCurrentPerColour(A, 15);
    k = 1;

    % Using different values of Vdd (below 10 the image will be completely
    % black)
    for Vdd = 14:-1:10
        
        % Image with only voltage scaled without image processing
        A_dvs = functions_script.displayed_image(I_A, Vdd, 1);
        
        % Efficiency and distortion without image processing
        distortion_dvs(k, i) = functions_script.distortion(A, uint8(A_dvs));
        efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(A_dvs), Vdd);
        k=k+1;

        % Histogram equalization
        Ah = functions_script.histogram_eq_dvs(A, Vdd);
        I_Ah = functions_script.computeCurrentPerColour(Ah, 15);
        Ah_dvs = functions_script.displayed_image(I_Ah, Vdd, 1);
        distortion_dvs(k, i) = functions_script.distortion(A, uint8(Ah_dvs));
        efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(Ah_dvs), Vdd);
        k=k+1;

        for kx = 0.1:0.1:0.5

            % Brightness scaling
            Ab = functions_script.brightness_scale_dvs(A, Vdd, kx);
            I_Ab = functions_script.computeCurrentPerColour(Ab, 15);
            Ab_dvs = functions_script.displayed_image(I_Ab, Vdd, 1);
            distortion_dvs(k, i) = functions_script.distortion(A, uint8(Ab_dvs));
            efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(Ab_dvs), Vdd);
            k=k+1;

            % Third transformation
            Abc = functions_script.brightness_contrast_combine_dvs(A, Vdd, kx);
            I_Abc = functions_script.computeCurrentPerColour(Abc, 15);
            Abc_dvs = functions_script.displayed_image(I_Abc, Vdd, 1);
            distortion_dvs(k, i) = functions_script.distortion(A, uint8(Abc_dvs));
            efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(Abc_dvs), Vdd);
            k=k+1;

            % Fourth transformation
            Ac = functions_script.contrast_enhance_dvs(A, Vdd, kx/2);
            I_Ac = functions_script.computeCurrentPerColour(Abc, 15);
            Ac_dvs = functions_script.displayed_image(I_Ac, Vdd, 1);
            distortion_dvs(k, i) = functions_script.distortion(A, uint8(Ac_dvs));
            efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(Ac_dvs), Vdd);
            k=k+1;

        end
    end
end

save('result_dvs', 'efficiency_dvs', 'distortion_dvs');
