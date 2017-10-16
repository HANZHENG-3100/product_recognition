param = paramSetting()

	% data paths
	param.datasetPath = '../data/image1';
	param.imagePath = fullfile(param.datasetPath, 'image');
	param.gtPath = fullfile(param.datasetPath, 'gt');
	param.resizePath = fullfile(param.datasetPath, 'resize')

	% image size
	param.width = 600;
	param.height = 400;

	%% object region proposal method:
	% sw - sliding window
	% ss - selective search
	param.proposalType = 'sw';

	%% feature extraction method:
	% ch - color histogram
	% sift - SIFT feature
	param.featureType = 'ch';
	param.nbin = 50;

	%% classification method:
	% svm - support vector machine
	param.classifierType = 'svm';

	% sliding window
	param.sw.width = [5 10 15 20 40 60]; % sw.width and sw.height should be have same sizes; ith entry in width corresponds with ith entry in height
	param.sw.height = [5 10 15 20 40 60];
	param.sw.stride_x = 10;
	param.sw.stride_y = 10;



end