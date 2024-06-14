% Author: 2024 Gustaf Bodin

function R_min = HE_RT(dag, f, m)
    % He et al.-like response time estimate by removing paths and processors

    global print;

    R_min = realmax;
    
    [Lfmax, index] = longestFaultyPath(dag, f);
    Wfmax = dag.Wfmax;


    k = min(, m - 1);


    % p: path index

    % Order dag.lengths in descending order
    % NOTE: index reordering here!!!!!
    path_lens = sort(dag.lengths, 'descend');

    % skip_longest: avoid removing the length of the longest path twice (already apart of Lfmax)
    skip_longest = 1; 

    for j = 0:k
        path_len_sum = sumPathLengths(dag, index, path_lens, skip_longest, j);

        R = Lfmax + (Wfmax - path_len_sum - Lfmax) / (m-j);

        if R == 0 
            fprintf("ANOMALY, R_He = 0\n");
            continue;
        end
        
        if R < R_min 
            R_min = R;
        end
    end
end 

function path_len_sum = sumPathLengths(dag, index, path_lens, skip_longest, j)

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
end
