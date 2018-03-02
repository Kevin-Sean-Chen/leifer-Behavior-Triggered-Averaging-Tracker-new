%not used in paper

save_folder = uigetdir();
myfigure = gcf;
subplots=get(myfigure,'children');

for subplot_index = 1:length(subplots)
    if isa(subplots(subplot_index),'matlab.graphics.axis.Axes')
        hfig = figure;
        current_colormap = colormap(subplots(subplot_index));
        hax_new = copyobj(subplots(subplot_index), hfig);
        set(hax_new, 'Position', get(0, 'DefaultAxesPosition'));
        colormap(current_colormap);
        saveas(hfig,[save_folder, filesep, num2str(subplot_index), '.pdf'],'pdf');
        close(hfig)
    end
end