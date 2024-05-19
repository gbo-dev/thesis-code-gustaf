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