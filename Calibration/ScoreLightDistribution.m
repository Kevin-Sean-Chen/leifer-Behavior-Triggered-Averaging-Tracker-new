[filename,pathname] = uigetfile('*.png','Load Image');

image = imread([pathname,'\',filename]);

imagesc(image)
colorbar

filename
score = std(double(image(:)))

saveas(gcf, [pathname,'\colormap_',filename])