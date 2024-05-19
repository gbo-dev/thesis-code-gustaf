
% Author: 2024 Gustaf Bodin

function [cmaxs, lens, paths] = findPathsRec(v, path, sink, paths, cmax, cmaxs, len, lens)
    % findPathsRec: Recursive function to find all paths from source to sink

    global print;

    % Get the last node in the path
    last = path.list(end);

    wcet = v(last).C;
    len = len + wcet;

    if wcet > cmax
        cmax = wcet;
    end

    % If the last node is the sink, add the path to the list of paths
    if last == sink
        paths = [paths, path];
        cmaxs = [cmaxs, cmax];
        lens = [lens, len];
        return;
    end

    % If the last node is not the sink, continue the search
    for i = 1:length(v(last).succ)

        new_path = path;
        new_path.list = [new_path.list, v(last).succ(i)];
        
        % if print == 1
        %     fprintf('New path: ');
        %     for j = 1:length(new_path.list)
        %         fprintf('%d ', new_path.list(j));
        %     end
        % end
        
        [cmaxs, lens, paths] = findPathsRec(v, new_path, sink, paths, cmax, cmaxs, len, lens);
    end
end
