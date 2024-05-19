

%want to:
%1. addera ett PC mellan varje node och badguy
%2. räkna om antalet parallel paths (för alla options)



function theChosen1 = goThroughAllPaths(v, paths, vB, H, m)
allPathNumbers = [];
%allPathNumbersBefore = [];
tempv = v;
tempPaths = paths;
theChosenOne = 0;
[pat2, pathNumber2] = computeNumbPaths(H, paths(vB).ok);
% [oldpat, oldpathNumber] = computeNumbPaths(H, paths(vB).ok);
% oldpathNumber;

    for receiver = 1 : length(paths(vB).ok)
        pathNumber = 0;
        
        vR = paths(vB).ok(receiver);
        tempv(vB).succ = [tempv(vB).succ vR];
        tempv(vR).pred = [tempv(vR).pred vB];
%         newPrintTask(tempv);
%         newPrintTask(v);
        %newH = subPaths(tempv, paths, vB); 
        %[pat, pathNumber] = computeNumbPaths(newH, paths(vB).ok);%wrong index for pat
        %pat
        %pathNumber
        %allPathNumbers = [allPathNumbers  pathNumber];

        %--------------------------------------
        longestM = 0;
        %vB
        %paths(vB).notOk
        tempPaths(vB).notOk = algNotOk(tempv,vB);
        %tempPaths(vB).notOk
        ok = algOk(tempv,vB);
        tempPaths(vB).ok = ok;
        tempPaths(vB).pathOk = length(ok);
        %fprintf('ok path length for node %d : %d \n',i, paths(i).pathOk);
%         vB
%         paths(vB).pathOk
%         tempPaths(vB).pathOk
       
        
       

        %---------------------------------------
       
        newH = subPaths(tempv, tempPaths, vB); 

        %plot(newH);
        [pat, pathNumber] = computeNumbPaths(newH, tempPaths(vB).ok);%wrong index for pat
        
        %pat
        %pat2
        %pathNumber
        allPathNumbers = [allPathNumbers  pathNumber];



        tempv = v;
        tempPaths = paths;

    end

    %picking the chosen One
    %picking the node with the most highest number of parallel paths after
    %an added constraint

    for i = 1 : length(allPathNumbers)
        if allPathNumbers(i) > theChosenOne && allPathNumbers(i) < pathNumber2
            theChosenOne = i;
        end

    end

   allPathNumbers;
   theChosenOne;
   theChosen1 = paths(vB).ok(theChosenOne);
   %theChosen1
end



