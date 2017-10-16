[data, param] = imageReader(param)

	imageFiles = dir(data.imagePath);
	imageFiles = fileNames(3:end);
	numImages = length(imageFiles);
	data.numImages = numImages;
	for i = 1:numImages
	   currentImageName = imageFiles(i).name;
	   currentImage = imread(currentImageName);
	   data.imageNames{i} = currentImageName;
	   [~, data.imageTitles{i}, ~] = fileparts(currentImageName);
	   data.image{i} = currentImage;
	end

end