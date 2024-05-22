
% Author: 2024 Gustaf Bodin

function R_min = HE_RT(dag, f, m)
    % He et al.-like response time estimate by removing paths and processors

    global print;

    R_min = realmax;
    % m_max = 0;

    % p: path index
    % k: m - 1
    
    [Lfmax, index] = longestFaultyPath(dag, f);
    Wfmax = dag.Wfmax;

    k = m - 1;

    % Order dag.lengths in descending order
    path_lens = sort(dag.lengths, 'descend');

    for j = 0:k
        % TODO: Ensure this works when j = 0, i.e. "p = 1:0"
        path_len_sum = 0;
        for p = 1:j
            path_len_sum = path_len_sum + path_lens(p);
        end

        R = Lfmax + (Wfmax - path_len_sum - Lfmax) / (m-j);

        if R == 0 
            fprintf("ANOMALY, R_He = 0\n");
            continue;
        end
        % TODO: Add deadline check: Y/N?
        if R < R_min 
            R_min = R;
        end
    end
end 
