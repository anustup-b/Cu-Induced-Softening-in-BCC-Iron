files = {'stress_strain_0.00.txt', 'stress_strain_0.02.txt', 'stress_strain_0.05.txt'};
labels = {'0% Cu', '2% Cu', '5% Cu'};
results = zeros(length(files), 2); 
all_data_list = cell(1, length(files));

fprintf('\n=== MECHANICAL DEGRADATION SUMMARY ===\n'); %[output:053a63f6]

for i = 1:length(files) %[output:group:8e337849]
    % Read data matrix directly
    data = readmatrix(files{i});
    
    % Convert to numeric array if imported as text strings
    if iscell(data) || isstring(data)
        data = str2double(data);
    end
    
    % Strip header rows containing NaNs
    data(any(isnan(data), 2), :) = [];
    
    if isempty(data) || size(data, 2) < 2
        error('Could not extract numeric columns from "%s". Check simulation output.', files{i});
    end
    
    strain = data(:, 1);
    stress = data(:, 2);
    
    % Calculate Ultimate Tensile Strength
    [UTS, peak_idx] = max(stress);
    
    % Auto-detect percentage strain scaling
    if max(strain) > 2.0
        strain_decimal = strain / 100;
    else
        strain_decimal = strain;
    end
    
    % Linear elastic strain region (0.01 to 0.035)
    elastic_indices = find(strain_decimal >= 0.01 & strain_decimal <= 0.035);
    
    % Fallback fitting if region is sparse
    if isempty(elastic_indices)
        safe_end = max(3, min(length(stress), round(peak_idx * 0.3)));
        elastic_indices = 2:safe_end;
    end
    
    % Young's Modulus (Slope)
    p = polyfit(strain_decimal(elastic_indices), stress(elastic_indices), 1);
    Modulus = p(1);
    
    results(i, :) = [Modulus, UTS];
    fprintf('%s -> Young''s Modulus: %.2f GPa | UTS: %.2f GPa\n', labels{i}, Modulus, UTS); %[output:53744986]
    
    all_data_list{i} = [strain, stress];
end %[output:group:8e337849]

% Combine datasets side-by-side for OriginLab export
min_rows = min(cellfun(@(x) size(x, 1), all_data_list));
csv_data = cell2mat(cellfun(@(x) x(1:min_rows, :), all_data_list, 'UniformOutput', false));

writematrix(csv_data, 'Origin_Export.csv');
disp('Data successfully exported to Origin_Export.csv.'); %[output:1466677d]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:053a63f6]
%   data: {"dataType":"text","outputData":{"text":"\n=== MECHANICAL DEGRADATION SUMMARY ===\n","truncated":false}}
%---
%[output:53744986]
%   data: {"dataType":"text","outputData":{"text":"0% Cu -> Young's Modulus: 212.35 GPa | UTS: 13.30 GPa\n2% Cu -> Young's Modulus: 210.57 GPa | UTS: 13.04 GPa\n5% Cu -> Young's Modulus: 206.63 GPa | UTS: 12.72 GPa\n","truncated":false}}
%---
%[output:1466677d]
%   data: {"dataType":"text","outputData":{"text":"Data successfully exported to Origin_Export.csv.\n","truncated":false}}
%---
