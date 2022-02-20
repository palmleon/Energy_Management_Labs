
classdef functions_script
    methods (Static)
        
        function S = computePower(A)
            gamma = 0.7755;
            Wr = 2.13636845*10^-7;
            Red = (double(A(:,:,1)) .^ gamma) .* Wr;
            Wg = 1.77746705*10^-7;
            Green = (double(A(:,:,2)) .^ gamma) .* Wg;
            Wb = 2.14348309*10^-7;
            Blue = (double(A(:,:,3)) .^ gamma) .* Wb;
            W0 = 1.48169521*10^-6;
            S = W0 + sum(sum(Red+Green+Blue));
        end
        
        function d = abs_distance(A, B)
            Diff = (A - B) .^ 2;
            Diff = Diff(:,:,1) + Diff(:,:,2) + Diff(:,:,3);
            d = sum(sum(sqrt(double(Diff))));
        end
        
        function d = rel_distance(A, B) % not percentage value
            C = functions_script.abs_distance(A, B);
            d = C/(size(A(:,:,1),1)*size(A(:,:,1),2)*sqrt(100^2+(255^2)*2));
        end
        
        % Function to compute efficiency,
        % where A is the original image and B the modified one
        function e = efficiency(A, B)
            e = 1 - functions_script.computePower(B)/functions_script.computePower(A);
        end
        
        function d = distortion(A, B)
            d = functions_script.rel_distance(rgb2lab(A), rgb2lab(B));
        end
        
        % HUNGRY BLUE, reduces the value of blue from 100% to 0%
        function [dist, eff] = hungryblue(A)
            S = A;
            power_saved = zeros(11,1);
            distance = zeros(11,1);
            Apower = functions_script.computePower(A);
            g = 1;
            for c = 1.0:-0.1:0.0
                S(:,:,3) = uint8(A(:,:,3) .* c);
                power_saved(g) = 1 - (functions_script.computePower(S)/Apower);
                distance(g) = functions_script.distortion(A, S);
                g = g+1;
            end
            dist = distance;
            eff = power_saved;
        end
        
        % HISTOGRAM EQUALISATION
        function [dist, eff] = histogram_eq(A)
            S = histeq(A);
            eff = functions_script.efficiency(A, S);
            dist = functions_script.distortion(A, S);
        end

        % HUNGRY VALUE
        function [dist, eff] = hungryvalue(A)
            efficiency = zeros(10,1);
            distortion = zeros(10,1);
            Apower = functions_script.computePower(A);
            A_hsv = rgb2hsv(A);
            g = 1;
            for c = 0.9:-0.1:0.0
                S_hsv = A_hsv;
                S_hsv(:,:,3) = (A_hsv(:,:,3) .* c);
                S_final = uint8(hsv2rgb(S_hsv).*256);
                efficiency(g) = 1 - (functions_script.computePower(S_final)/Apower);
                distortion(g) = functions_script.distortion(A, S_final);
                g = g+1;
            end
            dist = distortion;
            eff = efficiency;
        end

        % HUNGRY LUMINANCE
        function [dist, eff] = hungryluminance(A)
            efficiency = zeros(10,1);
            distortion = zeros(10,1);
            Apower = functions_script.computePower(A);
            A_lab = rgb2lab(A);
            g = 1;
            for c = 0.9:-0.1:0.0
                S_lab = A_lab;
                S_lab(:,:,1) = (S_lab(:,:,1) .* c);
                S_final = lab2rgb(S_lab,'OutputType','uint8');
                efficiency(g) = 1 - (functions_script.computePower(S_final)/Apower);
                distortion(g) = functions_script.distortion(A, S_final);
                g = g+1;
            end
            dist = distortion;
            eff = efficiency;
        end 

        % HUNGRY BLUE AND VALUE
         function [dist, eff] = hungrybluevalue(A)
            efficiency = zeros(10,1);
            distortion = zeros(10,1);
            Apower = functions_script.computePower(A);
            g = 1;
            for c = 0.95:-0.05:0.5
                S = A;
                S(:,:,3) = uint8(S(:,:,3) .* c);
                S_hsv = rgb2hsv(S);
                S_hsv(:,:,3) = S_hsv(:,:,3) .* c;
                S_final = uint8(hsv2rgb(S_hsv).*256);
                efficiency(g) = 1 - (functions_script.computePower(S_final)/Apower);
                distortion(g) = functions_script.distortion(A, S_final);
                g = g+1;
            end
            dist = distortion;
            eff = efficiency;
        end            

        % HUNGRY LUMINANCE AND VALUE
        function [dist, eff] = hungryluminancevalue(A)
            efficiency = zeros(10,1);
            distortion = zeros(10,1);
            Apower = functions_script.computePower(A);
            g = 1;
            for c = 0.95:-0.05:0.5
                S_lab = rgb2lab(A);
                S_lab(:,:,1) = S_lab(:,:,1) .* c;
                S_hsv = rgb2hsv(lab2rgb(S_lab,'OutputType','uint8'));
                S_hsv(:,:,3) = S_hsv(:,:,3) .* c;
                S_final = uint8(hsv2rgb(S_hsv).*256);
                efficiency(g) = 1 - (functions_script.computePower(S_final)/Apower);
                distortion(g) = functions_script.distortion(A, S_final);
                g = g+1;
            end
            dist = distortion;
            eff = efficiency;
        end 

        % HUNGRY BLUE AND LUMINANCE
        function [dist, eff] = hungryblueluminance(A)
            efficiency = zeros(10,1);
            distortion = zeros(10,1);
            Apower = functions_script.computePower(A);
            g = 1;
            for c = 0.95:-0.05:0.5
                S = A;
                S(:,:,3) = uint8(S(:,:,3) .* c);
                S_lab = rgb2lab(S);
                S_lab(:,:,1) = S_lab(:,:,1) .* c;
                S_final = lab2rgb(S_lab,'OutputType','uint8');
                efficiency(g) = 1 - (functions_script.computePower(S_final)/Apower);
                distortion(g) = functions_script.distortion(A, S_final);
                g = g+1;
            end
            dist = distortion;
            eff = efficiency;
        end 

        % HUNGRY ALL
        function [dist, eff] = hungryall(A)
           efficiency = zeros(10,1);
            distortion = zeros(10,1);
            Apower = functions_script.computePower(A);
            g = 1;
            for c = 0.95:-0.05:0.5
                S = A;
                S(:,:,3) = uint8(S(:,:,3) .* c);
                S_lab = rgb2lab(S);
                S_lab(:,:,1) = S_lab(:,:,1) .* c;
                S_hsv = rgb2hsv(lab2rgb(S_lab,'OutputType','uint8'));
                S_hsv(:,:,3) = S_hsv(:,:,3) .* c;
                S_final = uint8(hsv2rgb(S_hsv).*256);
                efficiency(g) = 1 - (functions_script.computePower(S_final)/Apower);
                distortion(g) = functions_script.distortion(A, S_final);
                g = g+1;
            end
            dist = distortion;
            eff = efficiency; 
        end
       
        %%%%%%%%%% Second day functions %%%%%%%%%%

        function S = computeCurrentPerColour(A, Vdd)
            p1 =   4.251e-05;
            p2 =  -3.029e-04;
            p3 =   3.024e-05;
        
            S = ((p1 * Vdd * double(A))/255) + ((p2 * double(A))/255) + p3;
        end

        function S = computePowerPanel(A, Vdd)
            % Matrix with currents instead of colours
            M_currents = functions_script.computeCurrentPerColour(A, Vdd);

            S = Vdd * sum(sum(sum(M_currents)));
        end

        % BRIGHTNESS SCALING
        function S = brightness_scale_dvs(A, Vdd)
            p1 =   4.251e-05;
            p2 =  -3.029e-04;
            p3 =   3.024e-05;
            Vdd_org = 15;
            I_cell_max = (p1 * Vdd * 1) + (p2 * 1) + p3;
            image_RGB_max = (I_cell_max - p3)/(p1*Vdd_org+p2) * 255;
            n_pixel = size(A,1)*size(A,2)*3;
            n_pixel_sat = size(A(A > image_RGB_max), 1);

            % Need to estimate loss in brightness
            A_hsv = rgb2hsv(A);
            A_mean_v = mean(A(:,:,3), 'all');
            A_hsv(:,:,3) = A_hsv(:,:,3)+0.1;
            
            A_scaled = 255*hsv2rgb(A_hsv);
            S = uint8(A_scaled);
        end

        % HISTOGRAM EQUALISATION
        function S = histogram_eq_dvs(A, Vdd)
            p1 =   4.251e-05;
            p2 =  -3.029e-04;
            p3 =   3.024e-05;
            Vdd_org = 15;
            I_cell_max = (p1 * Vdd * 1) + (p2 * 1) + p3;
            image_RGB_max = (I_cell_max - p3)/(p1*Vdd_org+p2) * 255;
         
            H = histeq(A);
            S = uint8((double(H)/255.0)*image_RGB_max);
        end

        % Function given by the professor
        function out = displayed_image(I_cell, Vdd, mode)
            SATURATED = 1;
            DISTORTED = 2;
            
            p1 =   4.251e-05;
            p2 =  -3.029e-04;
            p3 =   3.024e-05;
            Vdd_org = 15;
            
            I_cell_max = (p1 * Vdd * 1) + (p2 * 1) + p3;
            image_RGB_max = (I_cell_max - p3)/(p1*Vdd_org+p2) * 255;
            
            out = round((I_cell - p3)/(p1*Vdd_org+p2) * 255);
            
            if (mode == SATURATED)
                out(find(I_cell > I_cell_max)) = image_RGB_max;
            else if (mode == DISTORTED)
                    out(find(I_cell > I_cell_max)) = round(255 - out(find(I_cell > I_cell_max)));
                end
            end
        end
        
        %%%%%%%%%% File handling functions %%%%%%%%%%
        
        % Retrives names of the files located in the directory "path"
        function files = files_name(path)
            files = dir(path);
        
            % Removing "." and ".."
            files = files(3:end);
        
            files = {files(:).name};
            path = strcat(path, "/");
            files = strcat(path, files);
        end
        
        % Collects all the images paths from banchmark
        function relative_paths = all_images_banchmark()
            path = "./images/BSDS500/train";
            relative_paths = functions_script.files_name(path);
            path = "./images/BSDS500/test";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
            path = "./images/BSDS500/val";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
            path = "./images/USC-SIPI";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
            path = "./images/Screenshots";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
        end
    end
end


