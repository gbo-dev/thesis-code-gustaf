

function dag = imbalanceDAG(dag, probability) 
    

    for i = 3:length(dag.v)
        if rand < probability
            dag.v(i).C = 0;
        end
    end


    % For the DAG, use probability to decide if we should modify a path
    % For the nodes in the path use the node_nullified proability to 
    % nullify some nodes

    % node_nullified = 1; 

    % % For all paths, set C = 0 with a certain probability
    % for i = 1:length(dag.paths)
    %     if rand < probability
    %         for j = 3:length(dag.paths(1,i).list)
    %             if rand < node_nullified
    %                 % Get node index in the DAG
    %                 % dag.v(paths(i)).C = 0;
    %                 % paths{i}(j)
    %                 if (dag.paths(1,i).list(j) == 1) || (dag.paths(1,i).list(j) == 2)
    %                     continue;
    %                 else
    %                     dag.v(dag.paths(1,i).list(j)).C = 0;
    %                 end
    %             end
    %         end
    %     end
    % end
end


