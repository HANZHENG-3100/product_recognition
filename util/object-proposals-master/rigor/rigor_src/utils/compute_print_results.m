function compute_print_results(masks, seg_obj, gt_fldr)
% You can use this function to compute accuracy scores for the segment 
% proposals generated against some GT. This function computes the overlap 
% for each segment to all GTs. Then prints the results and stores them. The 
% results are stored at the path defined by scores_dirpath defined in 
% internal_params.m. The file stores some collated scores including 
% overlap, and covering (collated_scores). It also stores the number of 
% segments generated by parametric min-cut, and the number remaining after 
% filtration (init_num_segs and final_num_segs). Also overlaps of all 
% segments against the GT is stored (Q). The function finally displays the 
% results in a pretty table :)
%
% For instance, if you are working with PASCAL VOC (e.g. stored at 
%  ~/pascalvoc12), you can do the following:
%       [masks, seg_obj, total_time] = ...
%           rigor_obj_segments('~/pascalvoc12/JPEGImages/2007_000033.jpg');
%       compute_print_results(masks, seg_obj, ...
%           '~/pascalvoc12/SegmentationObject');
%
% You can also run compute_print_results.m by loading the data saved to 
% disk by rigor_obj_segments.m, and supplying masks, and seg_obj to the 
% function.
%
% @authors:     Ahmad Humayun
% @contact:     ahumayun@cc.gatech.edu
% @affiliation: Georgia Institute of Technology
% @date:        Fall 2013 - Summer 2014

    img_name = seg_obj.input_info.img_name;
    
    % compute the quality of each segment given the GT
    [Q, collated_scores] = SvmSegm_segment_quality(img_name, gt_fldr, ...
                                                   masks, 'overlap');
    
    % collect scores for all segments
    overlap_scores = [Q.q];
    tp = cell2mat(arrayfun(@(q) q.extra_info.tp, Q, 'UniformOutput',false));
    fp = cell2mat(arrayfun(@(q) q.extra_info.fp, Q, 'UniformOutput',false));
    fn = cell2mat(arrayfun(@(q) q.extra_info.fn, Q, 'UniformOutput',false));
    
    num_gt = numel(Q);
    num_sgmntrs = numel(seg_obj.segm_params.graph_methods);
    
    % # of segments returned by each segmenter and the remaining number
    % after the filteration step
    init_num_segs = seg_obj.num_segs.init_segs;
    final_num_segs = seg_obj.num_segs.after_clustering_FINAL;
    
    % get the name of each segmenter
    sgmntr_names = seg_obj.segm_params.graph_methods;
    sgmntr_names = cellfun(@(s) s(1:strfind(s, 'Graph')-1), ...
                           sgmntr_names, 'UniformOutput',false);
                        
    % compute the scores over different segmenters individually
    start_idx = 1;
    avg_best_overlap_segmenters = zeros(1, num_sgmntrs);
    collective_overlap_segmenters = zeros(1, num_sgmntrs);
    best_seg_overlap_segmenters = zeros(num_gt, num_sgmntrs);
    best_seg_idx_segmenters = zeros(num_gt, num_sgmntrs);
    % iterate over each segmenter
    for sgmntr_idx = 1:num_sgmntrs
        % get the scores for just the current segmenter
        segmenter_overlap = ...
            overlap_scores(start_idx:start_idx + ...
                                     final_num_segs(sgmntr_idx)-1,:);
        % compute the best scores for each GT for the current segmenter
        [best_seg_overlap, best_seg_idx] = max(segmenter_overlap);
        avg_best_overlap_segmenters(sgmntr_idx) = mean(best_seg_overlap);
        best_seg_overlap_segmenters(:,sgmntr_idx) = best_seg_overlap;
        best_seg_idx_segmenters(:,sgmntr_idx) = ...
                                            start_idx + best_seg_idx - 1;
        
        % compute the collective overlap for all GT's for the current
        % segmenter
        best_ind = sub2ind(size(tp), ...
                           best_seg_idx_segmenters(:,sgmntr_idx)', ...
                           1:num_gt);
        total_tp = tp(best_ind);
        total_union = fp(best_ind) + fn(best_ind) + tp(best_ind);
        collective_overlap_segmenters(sgmntr_idx) = ...
            sum(total_tp) / sum(total_union);
        
        start_idx = start_idx + final_num_segs(sgmntr_idx);
    end
    
    % store the scores computed
    collated_scores.collective_overlap_segmenters = ...
                                            collective_overlap_segmenters;
    collated_scores.avg_best_overlap_segmenters = ...
                                            avg_best_overlap_segmenters;
    collated_scores.best_seg_overlap_segmenters = ...
                                            best_seg_overlap_segmenters;
    collated_scores.best_seg_idx_segmenters = best_seg_idx_segmenters;
    
    % print the table of scores
    print_scores_table([Q.gt_seg_szs], sgmntr_names, init_num_segs, ...
                       final_num_segs, collated_scores);
    
    % save the scores
    scores_filepath = seg_obj.return_scores_filepath();
    
    dir_name = fileparts(scores_filepath);
    if(~exist(dir_name, 'dir'))
        mkdir(dir_name);
    end
    save(scores_filepath, 'Q', 'sgmntr_names', 'init_num_segs', ...
                          'final_num_segs', 'collated_scores');

    % print a summary line, useful for noting down results/performance
    print_summary(seg_obj, collated_scores);
end


function print_scores_table(gt_seg_szs, sgmntr_names, init_num_segs, ...
                            final_num_segs, cscores)
    % get the row headers
    row_txts = arrayfun(@(i,gt_sz) sprintf('GT %2d (%5d)', i, gt_sz), ...
                        1:length(gt_seg_szs), gt_seg_szs, ...
                        'UniformOutput', false);
    row_txts = [{'', 'Init. # Segs', 'Final # Segs', 'Avg. Best Overlap', ...
                'Collective Overlap'}, row_txts];
    
    % get the column headers
    col_txts = [{''}, sgmntr_names, {'Overall'}];
    
    % compute the width based on the header lengths
    first_col_width = max(cellfun(@length, row_txts)) + 1;
    other_col_width = max(cellfun(@length, col_txts)) + 1;
    
    % create a divider line
    total_width = 2 + first_col_width + ...
                  (length(col_txts) - 1)*(other_col_width + 1);
    divider_line = [repmat('-', 1, total_width), '\n'];
    
    fprintf(divider_line);
    
    % printf first column
    print_line(row_txts{1}, col_txts(2:end), 's', ...
               first_col_width, other_col_width, length(sgmntr_names)+1);
    
    fprintf(divider_line);
    
    % print initial number of segments
    print_line(row_txts{2}, [init_num_segs, sum(init_num_segs)], 'd', ...
               first_col_width, other_col_width);
    
    % print final number of segments
    print_line(row_txts{3}, [final_num_segs, sum(final_num_segs)], 'd', ...
               first_col_width, other_col_width, length(sgmntr_names)+1);
    
    fprintf(divider_line);
    
    % print average best overlap
    print_line(row_txts{4}, [cscores.avg_best_overlap_segmenters, ...
                             cscores.avg_best_overlap], '.4f', ...
               first_col_width, other_col_width, length(sgmntr_names)+1);
    
    % print collective best overlap
    print_line(row_txts{5}, [cscores.collective_overlap_segmenters, ...
                             cscores.collective_overlap], '.4f', ...
               first_col_width, other_col_width);
    
    fprintf(divider_line);
    
    % print stats for each GT
    for idx = 1:size(cscores.best_seg_overlap_segmenters,1)
        [best_val, best_idx] = ...
            max(cscores.best_seg_overlap_segmenters(idx,:));
        print_line(row_txts{5+idx}, ...
                   [cscores.best_seg_overlap_segmenters(idx,:), ...
                    best_val], '.4f', ...
                   first_col_width, other_col_width, best_idx);
    end
    
    fprintf(divider_line);
end


function print_line(header, vals, spec, first_col_width, ...
                    other_col_width, strong_idx)
    % controls whether a certain value is going to be bold
    strong = false(1, length(vals));
    if exist('strong_idx','var')
        strong(strong_idx) = true;
    end
    strong_o = repmat({'<strong>'}, 1, length(vals));
    strong_e = repmat({'</strong>'}, 1, length(vals));
    strong_o(~strong) = {''};
    strong_e(~strong) = {''};
    
    % print header
    eval(['fprintf(''|%-', num2str(first_col_width), 's'', header)']);
    
    if spec == 's'
        % in case of string
        temp = [strong_o; vals; strong_e];
    else
        temp = [strong_o; num2cell(vals); strong_e];
    end
    eval(['fprintf(''|%s%-', num2str(other_col_width), spec '%s'', temp{:})']);
    
    fprintf('|\n');
end


function print_summary(seg_obj, cscores)
    for idx = 1:numel(seg_obj.segm_params.graph_methods)
        fprintf(1, '% 4d (% 4d)', ...
                seg_obj.num_segs.init_segs(idx), ...
                seg_obj.num_segs.after_clustering_FINAL(idx));
        if idx < numel(seg_obj.segm_params.graph_methods)
            fprintf(1, ', ');
        else
            fprintf(1, ' - ');
        end
    end
    best_gt_scores = max(cscores.best_seg_overlap_segmenters,[],2);
    for idx = 1:length(best_gt_scores)
        fprintf(1, '%.4f', best_gt_scores(idx));
        if idx < length(best_gt_scores)
            fprintf(1, ' + ');
        else
            fprintf(1, ' => ');
        end
    end
    for idx = 1:length(cscores.avg_best_overlap_segmenters)
        fprintf(1, '%.4f', cscores.avg_best_overlap_segmenters(idx));
        if idx < length(cscores.avg_best_overlap_segmenters)
            fprintf(1, ' + ');
        else
            fprintf(1, ' => ');
        end
    end
    fprintf('%.4f\n', cscores.avg_best_overlap);
end
