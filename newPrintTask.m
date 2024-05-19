%new print task



function newPrintTask(v)
% prints a conditional DAG task

    figure;
    hold on;
    
    %p = 1;

%     if ~isempty(headline)
%         title(headline);
%     end
    source_nodes = [];
    target_nodes = [];
    x = [];
    y = [];
    nLabel = [];
    %G = digraph();
%     for i = 1 : length(v)   % plot vertices
%         plotCircle(v(i).width, v(i).depth, 0.1, i, v);
%         p = p + 1;
%     end
    for i = 1 : length(v)   % plot edges
        x = [x v(i).width];
        y = [y v(i).depth];
        nodeName = strcat('v', num2str(i), ' C: ', num2str(v(i).C));
        nLabel = [nLabel {nodeName}];
    end
    %disp(x);
    %disp(y);
    %disp(length(nLabel));
    for i = 1 : length(v)   % plot edges
%         x = [x v(i).width];
%         y = [y v(i).depth];
        %disp();
        for j = 1 : length(v(i).succ)
            if v(i).cond == 0
                %plot([v(i).width v(v(i).succ(j)).width],[v(i).depth v(v(i).succ(j)).depth], 'm');            
                %G = addedge(G, [v(i).width, v(i).depth],[v(v(i).succ(j)).width, v(v(i).succ(j)).depth]);
                %disp(v(i).succ(j));
                target_nodes = [target_nodes v(i).succ(j)];
                source_nodes = [source_nodes i];
                %G = addedge(G,v(i),v(i).succ(j));
                
            elseif v(i).cond == 1
                %plot([v(i).width v(v(i).succ(j)).width],[v(i).depth v(v(i).succ(j)).depth], 'm--');
%             elseif v(i).cond == 2 && v(j).cond == 2
%                 plot([v(i).width v(v(i).succ(j)).width],[v(i).depth v(v(i).succ(j)).depth], 'b--');
            end
        end
    end
    %disp(source_nodes);
    %G = digraph(num2str(source_nodes), num2str(target_nodes));
    %disp(target_nodes);
    G = digraph(source_nodes, target_nodes);
    p = plot(G);
    %disp(source_nodes);
    %disp(target_nodes);
    %H = subgraph(G, [3 6 7 9]);
  
    p.XData = x;
    p.YData = y;
    p.Marker = '*';
    p.EdgeColor = 'm';
    p.NodeColor = 'r';
    p.NodeLabel = nLabel;
    %disp(allpaths(G));
    hold off;
    
end