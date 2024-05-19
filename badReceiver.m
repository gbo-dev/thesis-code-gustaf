% receiver node from the badguy


%the first node in the ok  list
% function vR= badReceiver(vB, paths)
%     vR = paths(vB).ok(1);
%     %disp(vR);
% end



%the node the furthest away from the vB, closes to the sink
%this assumes the current structure, probably needs to change if the DAG is
%generated in a different way 
% function vR= badReceiver(vB, paths,v)
%     lastnode = length(paths(vB).ok);
%     vR = paths(vB).ok(lastnode);
%     disp(vR);
% end



%smallest workload
function vR = badReceiver(vB, paths,v)
    smallestW = 100; %change to the max workload if that is a globar variable
    for  i = 1:length(paths(vB).ok)
        if v(paths(vB).ok(i)).C < smallestW
            smallestW = v(paths(vB).ok(i)).C; 
            vR = paths(vB).ok(i);
            %disp(paths(vB).ok(i));
        end
    end
    %disp(smallestW);
end


%biggest workload
% function vR = badReceiver(vB, paths,v)
%     smallestW = 0; %change to the max workload if that is a globar variable
%     for  i = 1:length(paths(vB).ok)
%         if v(paths(vB).ok(i)).C > smallestW
%             smallestW = v(paths(vB).ok(i)).C; 
%             vR = paths(vB).ok(i);
%             disp(paths(vB).ok(i));
%         end
%     end
%     disp(smallestW);
% end















