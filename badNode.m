
%choosing the 'bad' node by taking the first in the badGuys list
% function vB = badNode(badGuys)
% 
% %add functionality on how to pick the "bad node", the firsy heuristic
% vB = badGuys(1);
% %disp('test vB')
% return;
% 
% end


%pick a random node in the badGuys list
% function vB = badNode(badGuys)
% %disp(badGuys);
% max = randi(length(badGuys));
% vB = badGuys(max);
% %disp(vB);
% end


% the bad guy is the last in the badGuys list
% function vB = badNode(badGuys)
%     last = length(badGuys);
%     vB = badGuys(last);
%     disp(vB);
% end


% the bad guy is the ones with biggest workload
%need to add the v in the input in AlgV1 for this one
function vB = badNode(badGuys, paths,v)
    bWorload = v(badGuys(1)).C;
    vB = badGuys(1);
    for i = 1:length(badGuys)
        if v(badGuys(i)).C < bWorload
            bWorload = v(badGuys(i)).C ;
            vB = badGuys(i);
            %disp(vB);
        end
    end
end

%look at the number of paralle paths and pick the bad guy with the shortest
%number
%need to add paths in AlgV1 for this one
% function vB = badNode(badGuys, paths)
%     shortestP = 100;
%     for i = 1:length(badGuys)
%         if paths(badGuys(i)).pathOk < shortestP
%             shortestP = paths(badGuys(i)).pathOk;
%             vB = badGuys(i);
%            
%         end
%     end
%      %disp(vB);
% end





