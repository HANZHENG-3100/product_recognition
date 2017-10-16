data = getColorHistogramFromImage(data, param)

	for i = 1:data.numImages
		im = imread(fullfile(param.resizePath, [data.imageTitles{i} '.jpg']);
		histR = histogram(im(:,:,1), param.);
		histG = histogram(im(:,:,2));
		histB = histogram(im(:,:,3));
		feat{i} = [histR histG histB];
	end
	data.feat = feat;

end