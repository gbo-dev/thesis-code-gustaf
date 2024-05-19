%making a specific DAG for testing
%used instead of expandTaskSeriesParallel
close all;
clear all;

nTasks = 1;
task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

global m;
m = 4;

for i = 1 : nTasks

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});

        %v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        
        v = testDAG1(v);
        task(i).v = v;
        %task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        task(i).v = mod_assignWCETs(task(i).v);
        %task(i).v = makeItDAG(task(i).v, addProb);
        
        originalDag = task(i).v;
        %printTask(task(i).v);
        
        
        %s = superSucc(task(i).v,1);
        %s = superPred(task(i).v, 10);
        %disp(s);

        %disp(v(7).succ);
        %disp(v(7).pred);
       
        %set = algOk(task(i).v, 9);
        %set = algNotOk(task(i).v, 9);
        %disp(set);

        %fprintf('result from sueprSucc: %d \n',v(6).succ);
        %disp(task(i).v);
        newPrintTask(originalDag);
    
        task(i).v = AlgV2(task(i).v, m);
        
        %disp(a(1).notOk);
        %disp(paths(5).ok);
        %disp(a(5).pathOk);
        newPrintTask(task(i).v);
        %disp(computePaths(originalDag).succ);
       
       %H = subgraph(originalDag, [3 6 7 9]);
%        G  = digraph([1 3], [3 2]);
%         plot(G);
%         G = addedge(G, 2,3);
%         plot(G);
        task(i).v = computeAccWorkload(task(i).v);
        [~, q] = max([task(i).v.accWorkload]);
        cp = getCP(q, task(i).v);
        task(i).len = task(i).v(q).accWorkload;

        [~, task(i).Z] = computeZk(task(i).v); %makespan longest path 
        y = [num2str(task(i).len), ' is the longest path for the modified'];
         disp(y);

        [~, a] = computeZk(originalDag);
        x = [num2str(a), ' is the makespan for the original'];
        disp(x);
        [~, task(i).Z] = computeZk(originalDag);

     
        %printTask(task(i).v);

       


        
end

function v = testDAG1(v)
%input is an empty DAG 
%v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});

%source v1
v(1).pred = [];
v(1).succ = [2,3];
v(1).width = 2;
v(1).depth = 3;
v(1).cond = 0;
v(1).C = 15;


%v2
v(2).pred = [1];
v(2).succ = [4,5];
v(2).width = 1;
v(2).depth = 2;
v(2).cond = 0;

%v3
v(3).succ = [6,7];
v(3).pred = [1];
v(3).width = 3;
v(3).depth = 2;
v(3).cond = 0;

%v4
v(4).succ = [10];
v(4).pred = [2];
v(4).width = 0.5;
v(4).depth = 1;
v(4).cond = 0;

%v5
v(5).succ = [10];
v(5).pred = [2];
v(5).width = 1.5;
v(5).depth = 1;
v(5).cond = 0;

%v6
v(6).succ = [8, 9];
v(6).pred = 3;
v(6).width = 2.5;
v(6).depth = 1;
v(6).cond = 0;

%v7
v(7).succ = [9];
v(7).pred = [3];
v(7).width = 3.5;
v(7).depth = 1;
v(7).cond = 0;

%v8
v(8).succ = [10];
v(8).pred = [6];
v(8).width = 2.25;
v(8).depth = 0;
v(8).cond = 0;

%v9
v(9).succ = [10];
v(9).pred = [6,7];
v(9).width = 3;
v(9).depth = 0;
v(9).cond = 0;

%v10
v(10).succ = [];
v(10).pred = [4, 5, 8, 9];
v(10).width = 2;
v(10).depth = -1;
v(10).cond = 0;

%disp(v(10));

end


