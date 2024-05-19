
%ALGv1(v){
%compute ok and not ok
%while(ok for any node has more than m nodes)
    %Bad guy: heuristic 1
    %from ok set of vx select Ve subheuristic 2
    %add APC vx --> ve
    %compute ok and notok
%find the longest path....
%}

function v = AlgV1(v, m)
    paths = struct('notOk', {}, 'ok', {}, 'pathOk', {});
    longestM = 0;
    badGuys = [];
    
    for i = 1 : length(v)
        paths(i).notOk = algNotOk(v,i);
        ok = algOk(v,i);
        paths(i).ok = ok;
        paths(i).pathOk = length(ok);
        %fprintf('ok path length for node %d : %d \n',i, paths(i).pathOk);
        if length(ok) + 1 > longestM
            longestM = length(ok);
            %disp(longestM);
        end
        if length(ok) + 1 > m % add self
            badGuys = [badGuys  i];
            
        end
        
    end
  

    if length(badGuys) < m
        
        %disp('isempty');
        
        return
   
        %disp(badGuys);
    else
        vB = badNode(badGuys,paths,v);
%         vB = badNode(badGuys, paths); %maybe make badguys global instead of input
%         vB = badNode(badGuys, v);
      
       
        %vR = paths(vB).ok(1);
        vR = badReceiver(vB, paths,v);
        %predecessor should also be updated
        %disp(vR);
        v(vB).succ = [v(vB).succ vR];
        v(vR).pred = [v(vR).pred vB];
        
        %recursive call, same function

       
        %printTask(newV);
        v = AlgV1(v, m);
        
            
    end
end






