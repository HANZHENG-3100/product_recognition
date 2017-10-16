%%%%%%%%%%%% Data pre-prosessing %%%%%%%%%%%%%%%


param = paramSetting();
(data, param) = imageReader(param);
data = resizeImages(data, param);


%%%%%%%%%%%% recognition algorithm %%%%%%%%%%%%%%%

%% ---------- Object region proposal ----------
boundingBoxes = zeroes(1000,4);

switch param.proposalType
	case 'sw'
		data = slidingWindow(data, param);

	case 'ss'
		%%%% TO DO %%%%%

end
		
%% ---------- Feature extraction -------------
switch param.featureType
	case 'ch'
		data = getColorHistogram(data, param);
	
	case 'sift'
		%%%% TO DO %%%%%

	
%% ---------- Classification ----------------
switch param.classifierType
 	case 'svm'
 		%%%% TO DO %%%%%

end


%%%%%%%%%%%% Evaluation %%%%%%%%%%%%%%%




end


%%%%% TO CONSIDER %%%%%%%
% - sliding window size
% - normalization of histogram (not normed yet)