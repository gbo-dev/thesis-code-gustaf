%AlgV2: parallel paths instead of parallel nodes


function v = AlgV2(v, m)
    paths = struct('notOk', {}, 'ok', {}, 'pathOk', {});
    longestM = 0;
    badGuys = [];
    badGuysPath = [];
    %'algv2'
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
    
    %new addition with the paths
    for x = 1: length(badGuys)
    
        H = subPaths(v, paths, badGuys(x));
        
        [pat, pathNumber] = computeNumbPaths(H, paths(badGuys(x)).ok);
        
        
        if pathNumber + 1 > m
            badGuysPath = [badGuysPath badGuys(x)];
        end
    end
%     badGuys
%     badGuysPath


    
    %if length(badGuysPath) 
    if isempty(badGuysPath)
        
        %disp('isempty');
        
        return 
   
        %disp(badGuys);
    else 
        %'add PC'
        vB = badNode(badGuysPath,paths,v);
        %vB
%         vB = badNode(badGuys, paths); %maybe make badguys global instead of input
%         vB = badNode(badGuys, v);
        %H = subPaths(v, paths, vB);
       
%         pathNumber = computeNumbPaths(v,H, paths(vB).ok);
%         if pathnumber < m
%             return
%         end
        %vR = paths(vB).ok(1);
        %vR = badReceiver(vB, paths,v);
        H = subPaths(v, paths, vB);
        vR = goThroughAllPaths(v, paths, vB, H, m);
        %vR
        %predecessor should also be updated
        %disp(vR);
        v(vB).succ = [v(vB).succ vR];
        v(vR).pred = [v(vR).pred vB];
        
        %recursive call, same function

       
        %printTask(newV);
        v = AlgV2(v, m);
        
            
    end
end






