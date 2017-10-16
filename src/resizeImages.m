data = resizeImages(data, param)

	for i = 1:data.numImages
		im = imread(fullfile(param.imagePath, data.imageNames{i}));
		imResized = imresize(im, param.height, param.width);
		imwrite(imResized, fullfile(param.resize, data.imageNames{i}));
	end
end