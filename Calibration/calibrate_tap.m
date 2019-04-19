% z_indecies = 1:10;
% y_indecies = 11:20;
% x_indecies = 21:30;
z_indecies = 31:40;
y_indecies = 41:50;
x_indecies = 51:60;

root_folder_name = uigetdir
folders = {};
cd(root_folder_name) %open the date directory
allFiles = dir(); %get all the subfolders
folder_count = 0;
for file_index = 1:length(allFiles)
    if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
        folder_count = folder_count + 1;
        folders{folder_count} = [root_folder_name, '\', allFiles(file_index).name];
    end
end

%assume time is all the same

% get results one axis at a time
[ time, voltages, original_trigger_point ] = read_oscilloscope_folder( folders{x_indecies(1)} );
x_voltages = zeros(length(voltages), length(x_indecies));
for index = 1:length(x_indecies)
    x_folder_index = x_indecies(index);
    [ ~, voltages, trigger_point ] = read_oscilloscope_folder( folders{x_folder_index} );
    trigger_point_diff = original_trigger_point - trigger_point;
    x_voltages(:,index) = circshift(voltages, trigger_point_diff);
end
x_mean_voltage = mean(x_voltages,2);
x_std_voltage = std(x_voltages,0,2);
% figure
% hold on
% for index = 1:length(x_indecies)
%     plot(time, x_voltages(:,index))
% end
% figure
% shadedErrorBar(time,x_mean_voltage,std(x_voltages,0,2))
% xlabel('Time (s)')
% ylabel('Voltage (V)')

y_voltages = zeros(length(voltages), length(y_indecies));
for index = 1:length(y_indecies)
    y_folder_index = y_indecies(index);
    [ ~, voltages, trigger_point ] = read_oscilloscope_folder( folders{y_folder_index} );
    trigger_point_diff = original_trigger_point - trigger_point;
    y_voltages(:,index) = circshift(voltages, trigger_point_diff);
end
y_mean_voltage = mean(y_voltages,2);
y_std_voltage = std(y_voltages,0,2);
% figure
% shadedErrorBar(time,mean(y_voltages,2),std(y_voltages,0,2))
% xlabel('Time (s)')
% ylabel('Voltage (V)')
% 
z_voltages = zeros(length(voltages), length(z_indecies));
for index = 1:length(z_indecies)
    z_folder_index = z_indecies(index);
    [ ~, voltages, trigger_point ] = read_oscilloscope_folder( folders{z_folder_index} );
    trigger_point_diff = original_trigger_point - trigger_point;
    z_voltages(:,index) = circshift(voltages, trigger_point_diff);
end
z_mean_voltage = mean(z_voltages,2);
z_std_voltage = std(z_voltages,0,2);
% figure
% shadedErrorBar(time,mean(z_voltages,2),std(z_voltages,0,2))
% xlabel('Time (s)')
% ylabel('Voltage (V)')

%get magnitude
xyz_voltage = [x_mean_voltage, y_mean_voltage, z_mean_voltage];
xyz_magnitutde_voltage = sqrt((x_mean_voltage.^2) + (y_mean_voltage.^2) + (z_mean_voltage.^2));
xyz_magnitutde_g = xyz_magnitutde_voltage / 0.057;
xyz_magnitutde_voltage_std = sqrt((x_std_voltage.^2) + (y_std_voltage.^2) + (z_std_voltage.^2));
xyz_magnitutde_std_g = xyz_magnitutde_voltage_std / 0.057;

figure
shadedErrorBar(time,xyz_magnitutde_g,xyz_magnitutde_std_g)
title(['Max = ', num2str(max(xyz_magnitutde_g)), ' g'])
xlabel('Time (s)')
ylabel('Acceleration Magnitude (g)')