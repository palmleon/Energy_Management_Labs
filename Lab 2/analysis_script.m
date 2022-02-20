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

% Histogram equalization
subplot(1,2,1);
boxplot(transpose(distortion(12,:)), 'symbol', '');
hold on; ylabel('Distortion');
subplot(1,2,2);
boxplot(transpose(efficiency(12,:)), 'symbol', '');
ylabel('Efficiency');brightness_scale_dvs

                    %%%%%%%%%% Second day %%%%%%%%%%
                    
images = functions_script.all_images_banchmark;
n_images = size(images, 2);
n_transf = 5*4 ; %only dvs + 4 transformation for 4 differen values of vdd
efficiency_dvs = zeors(n_transf, n_images);
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

        % Brightness scaling
        Ab = functions_script.brightness_scale_dvs(A, Vdd);
        I_Ab = functions_script.computeCurrentPerColour(Ab, 15);
        Ab_dvs = functions_script.displayed_image(I_Ab, Vdd, 1);
        distortion_dvs(k, i) = functions_script.distortion(A, uint8(Ab_dvs));
        efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(Ab_dvs), Vdd);
        k=k+1;

        % Histogram equalization
        Ah = functions_script.histogram_eq_dvs(A, Vdd);
        I_Ah = functions_script.computeCurrentPerColour(Ah, 15);
        Ah_dvs = functions_script.displayed_image(I_Ah, Vdd, 1);
        distortion_dvs(k, i) = functions_script.distortion(A, uint8(Ah_dvs));
        efficiency_dvs(k, i) = functions_script.efficiency_dvs(A, uint8(Ah_dvs), Vdd);
        k=k+1;

        % Third transofrmation

        % Fourth transformation

    end
end

save('result_dvs', 'efficiency_dvs', 'distortion_dvs');