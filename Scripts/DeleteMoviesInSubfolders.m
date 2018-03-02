%not used in paper

folder_name = uigetdir
cd(folder_name) %open the directory of image sequence\
filesToDelete = rdir('**\processed.avi');
delete(filesToDelete.name);