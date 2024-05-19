
% Author: 2024 Gustaf Bodin

function [cmaxs, lens, paths] = findPaths(v, source, sink)
    % findPaths: Find all paths from source to sink

    global print;

    path = struct('list', source);
    
    % Find all paths
    paths = [];
    cmaxs = [];
    lens = [];

    [cmaxs, lens, paths] = findPathsRec(v, path, sink, paths, 0, cmaxs, 0, lens);
    if print == 1
        fprintf('\nNumber of paths: %d\n', length(paths));
    end 
end