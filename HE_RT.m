% Author: 2024 Gustaf Bodin

function R_min = HE_RT(dag, f, m)
    % He et al.-like response time estimate by removing paths and processors

    global print;
    global task;

    R_min = realmax;
    
    [Lfmax, index] = longestFaultyPath(dag, f);
    Wfmax = dag.Wfmax;

    % TODO: Ensure correctness
    k = min(length(dag.lengths), m - 1);

    %dag.v(dag.paths(1).list(end)).C

    %dagParams = struct('lengths', dag.lengths, 'cmaxs', dag.cmaxs, 'paths', dag.paths);
    % dagParams = struct2table(dagParams);
    % dagParams = sortrows(dagParams, 'lengths', 'descend');
    % dagParams = table2struct(dagParams);

    %dagParams = [dag.lengths; dag.cmaxs; dag.paths];
    %dagParams = sortrows(dagParams, 1, 'descend')

    % NOTE: index reordering here!!!!!
    % use indices for paths instead of paths themselves
    [desc_path_lens, desc_path_indices] = sort(dag.lengths, 'descend');

    removed_nodes = [];

    for j = 0:k
        [path_len_sum, r_nodes] = sumPathLengths(dag, index, desc_path_lens, j, removed_nodes);
        removed_nodes = [removed_nodes, r_nodes];

        if (path_len_sum) > Wfmax
            fprintf("ANOMALY, negative interference\n");
            fprintf("path_len_sum: %d, Wfmax: %d\n", (path_len_sum), Wfmax);
            continue;
        end
        
        R = Lfmax + ((Wfmax - path_len_sum) / (m-j));

        if R == 0 
            fprintf("ANOMALY, R_He = 0\n");
            continue;
        end
        
        if R < R_min 
            R_min = R;
        end
    end
end 

function [path_len_sum, removed_nodes] = sumPathLengths(dag, index, desc_path_lens, j, removed_nodes)

    % Use indices for paths instead of paths themselves
    path_len_sum = 0;
    for p = 1:j
        if p == 1
            % This is the longest path so add Lfmax instead
            path_len_sum = path_len_sum + dag.Lfmax;
            % Add the nodes of the longest path to the removed nodes
            removed_nodes = [removed_nodes, dag.paths(index).list];
            removed_nodes = unique(removed_nodes);
            continue;
        end 

        for i = 1:length(dag.paths(p).list)
            if ~ismember(dag.paths(p).list(i), removed_nodes)
                % TODO: Use new indices???
                path_len_sum = path_len_sum + dag.v(dag.paths(p).list(i)).C;
                removed_nodes = [removed_nodes, dag.paths(p).list(i)];
            end
        end
    end
end




% Rewriting path functions 
% Now will save paths as a list/array of nodes
% so that when we order by path length, we can easily 
% consider the nodes of each removed longest path as already removed
