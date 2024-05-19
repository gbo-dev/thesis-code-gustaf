%subgraph
% the parallel graph/paths


function H = subPaths(v, paths,node)
%figure;
%hold on;
%all = superSucc(v,1);
H = paths(node).ok;
%disp(H);
%disp(node);
%from newPrintTask
source_nodes = [];
target_nodes = [];
x = [];
y = [];
nLabel = [];
for i = 1 : length(H)   % plot edges
    x = [x v(paths(node).ok(i)).width];
    y = [y v(paths(node).ok(i)).depth];
    %disp(v(paths(node).ok(i)).width);
    nodeName = strcat('v', num2str(paths(node).ok(i)), ' C: ', num2str(v(paths(node).ok(i)).C));
    nLabel = [nLabel {nodeName}];
end
for i = 1 : length(v)   % plot edges

    for j = 1 : length(v(i).succ)

        %disp(v(paths(node).ok(i)).succ);
        target_nodes = [target_nodes v(i).succ(j)];
        source_nodes = [source_nodes i];


    end
end

G = digraph(source_nodes, target_nodes);
%disp(computePaths(H));
H = subgraph(G, H);
% p = plot(H);
% p.XData = x;
% p.YData = y;
% p.Marker = '*';
% p.EdgeColor = 'm';
% p.NodeColor = 'r';
% p.NodeLabel = nLabel;


%G = graph(v);
%plot(H);

%hold off;

end