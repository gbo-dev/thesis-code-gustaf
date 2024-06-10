
% Author: 2024 Gustaf Bodin

function R_min = HE_RT(dag, f, m)
    % He et al.-like response time estimate by removing paths and processors

    global print;

    R_min = realmax;

    
    [Lfmax, index] = longestFaultyPath(dag, f);
    Wfmax = dag.Wfmax;

    k = m - 1;

    % p: path index

    % Order dag.lengths in descending order
    path_lens = sort(dag.lengths, 'descend');

    % skip_longest: avoid removing the length of the longest path twice (already apart of Lfmax)
    skip_longest = 1; 

    for j = 0:k
        path_len_sum = 0;
        for p = 1:j
            if j == 0
                fprintf("ANOMALY, He: j = 0\n");
            end
            if skip_longest == 1
                if dag.lengths(index) == path_lens(p)
                    skip_longest == 0;
                    continue;
                end
            end 
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
