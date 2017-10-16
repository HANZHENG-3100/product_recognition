data = slidingWindow(data, param)

	for i = 1:data.numImages
		im = imread(fullfile(data.resizePath, [data.imageTitles{i} '.jpg']));
		[height, width, ~] = size(im);

		% count total number of bounding boxes in this image
		numbb = 0;
		for j=1:length(param.sw.width)
			swWidth = param.sw.width(j);
			swHeight = param.sw.height(j);
			numbb = numbb + floor((width-swWidth+1)/param.sw.stride_x) * floor((height-swHeight+1)/param.sw.stride_y);
		end
		% pre-allocate bb matrix
		bb = zeros(numbb, 4);

		% store coordinates of bounding boxes
		count = 0;
		for j=1:length(param.sw.width)
			swWidth = param.sw.width(j);
			swHeight = param.sw.height(j);
			xStart = 1:param.sw.stride_x:width-swWidth+1;
			yStart = 1:param.sw.stride_y:height-swHeight+1;
			bb(count, :) = [xStart xStart+swWidth-1 yStart yStart+swHeight-1];
		end
		
		data.bb{i} = bb;
	end

end