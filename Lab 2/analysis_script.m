% echo off all
% images = all_images_banchmark;
% n_images = size(images, 2);
% dist = zeros(n_images,1);
% eff = zeros(n_images,1);
% for i = 1:n_images
%     S = imread(images(i));
%     if (size(S, 3) == 1)
%         clear A;
%         A(:,:,1) = S;
%         A(:,:,2) = S;
%         A(:,:,3) = S;
%         S = A;
%     end
%     disp( (i/n_images) * 100);
%     [dist(i,1),eff(i,1)] = histogram_eq(S);
% end
% save('result_histeq', 'images', 'dist', 'eff');

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

% statistical analysis on the efficiency and distorsion of images
% ...

% metric = eff ./ (1+(dist).^2);
% metric2 = eff ./ dist;
% plot(0.1:0.1:1.0, mean(matric1(2:11,:),2), 'bx-', 0.1:0.1:1.0, mean(matric2(2:11,:), 2), 'kx-');

% errorbar(0.0:0.1:1.0, mean(dist,2), std(dist, 0, 2), 'kx-');
% hold on;
% plot(0.0:0.1:1.0, max(dist,[], 2), 'bl-',0.0:0.1:1.0, min(dist,[], 2), 'r-')
% title('Distance');
% hold off;
% figure, errorbar(0.0:0.1:1.0, mean(eff,2), std(eff, 0, 2), 'kx-');
% hold on;
% plot(0.0:0.1:1.0, max(eff,[], 2), 'bl-',0.0:0.1:1.0, min(eff,[], 2), 'r-')
% title('Efficiency');
% hold off;
% figure, errorbar(0.1:0.1:1.0, mean(metric,2), std(metric, 0, 2), 'kx-');
% hold on;
% plot(0.1:0.1:1.0, max(metric,[], 2), 'bl-',0.1:0.1:1.0, min(metric,[], 2), 'r-')
% title('Our metric');
% boxplot(transpose(metric));
% title('Our metric');