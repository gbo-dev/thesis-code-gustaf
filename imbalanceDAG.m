

function dag = imbalanceDAG(dag, probability) 
    
    % for i = 3:length(dag.v)
    %     if rand < probability
    %         dag.v(i).C = 0;
    %     end
    % end

    % [dag.cmaxs, dag.lengths, dag.paths] = getAllPaths(dag.v);
    
    nullify = 0.9; 
    for i = 1:length(dag.paths)
        if rand < probability
            for j = 3:length(dag.paths(1,i).list)
                if rand < nullify 
                    if (dag.paths(1,i).list(j) == 1) || (dag.paths(1,i).list(j) == 2)
                        continue;
                    else
                        dag.v(dag.paths(1,i).list(j)).C = 0;
                    end
                 end
             end
         end
     end
end


