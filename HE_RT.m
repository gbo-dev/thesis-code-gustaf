% Author: 2024 Gustaf Bodin

function R_min = HE_RT(dag, f, m)
    % He et al.-like response time estimate by removing paths and processors

    global print;
    global task;

    R_min = realmax;
    
    [Lfmax, index] = longestFaultyPath(dag, f);
    Wfmax = dag.Wfmax;

    % Can't remove more than m-1 processors or number of paths
    k = min(length(dag.lengths), m - 1);

    [desc_path_lens, desc_path_indices] = sort(dag.lengths, 'descend');

    % Nodes no longer considered in next iteration (contained in prev. path)
    removed_nodes = [];

    for j = 0:k
        [path_len_sum, r_nodes] = sumPathLengths(dag, index, desc_path_lens, desc_path_indices, j, removed_nodes);
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

function [path_len_sum, removed_nodes] = sumPathLengths(dag, index, desc_path_lens, desc_path_indices, j, removed_nodes)

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

        for i = 1:length(dag.paths(desc_path_indices(p)).list)
            if ~ismember(dag.paths(desc_path_indices(p)).list(i), removed_nodes)
                path_len_sum = path_len_sum + dag.v(dag.paths(desc_path_indices(p)).list(i)).C;
                %removed_nodes = [removed_nodes, dag.paths(desc_path_indices(p)).list(i)];
                removed_nodes = [removed_nodes, dag.paths(desc_path_indices(p)).list];
            end
        end
    end
end

