
% Author: 2024 Gustaf Bodin

function [cmaxs, lens, paths] = getAllPaths(v)
    % getAllPaths: Find all paths and their lengths and the cmax in each path in a DAG

    sources = getSources(v);
    sinks = getSinks(v);

    % From all sources, find all paths to all sinks
    paths = [];
    cmaxs = [];
    lens = [];
    for i = 1:length(sources)
        for j = 1:length(sinks)
            [new_cmaxs, new_lengths, new_paths] = findPaths(v, sources(i), sinks(j));
            paths = [paths, new_paths];
            cmaxs = [cmaxs, new_cmaxs];
            lens = [lens, new_lengths];       
        end
    end
end
