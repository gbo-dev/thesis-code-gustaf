% 
% cptasks - A MATLAB(R) implementation of schedulability tests for
% conditional and parallel tasks
%
% Copyright (C) 2014-2015  
% ReTiS Lab - Scuola Superiore Sant'Anna - Pisa (Italy)
%
% cptasks is free software; you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% version 2 as published by the Free Software Foundation, 
% (with a special exception described below).
%
% Linking this code statically or dynamically with other modules is
% making a combined work based on this code.  Thus, the terms and
% conditions of the GNU General Public License cover the whole
% combination.
%
% cptasks is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License version 2 for more details.
%
% You should have received a copy of the GNU General Public License
% version 2 along with cptasks; if not, write to the
% Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301 USA.
%
%
% Author: 2015 Alessandra Melani
%

% Modified by Gustaf Bodin  

function [dag, W, maxWCET, Wfmax, cmaxs, lengths, paths] = generateSchedParams(i, beta, m, f, cmaxs, lengths, paths)
    
    global task;
    dag = task(i);

    [dag.cmaxs, dag.lengths, dag.paths] = getAllPaths(dag.v);
    dag = imbalanceDAG(dag, 0.5);
    [dag.cmaxs, dag.lengths, dag.paths] = getAllPaths(dag.v);
    
    %max(dag.lengths)

    dag.W = computeVolume(dag.v); % dag.wcw same thing as no cond paths, but to make sure
    Tmin = dag.len; % NOTE: Ensure OK when used
    Tmax = dag.W / beta;
    
    int1 = Tmin;
    int2 = Tmax;
    dag.T = randi([int1, int2]);

    dag.maxWCET = findMaxWCET(dag);
    dag.Wfmax = dag.W + dag.maxWCET * f;
    [Lfmax, ~] = longestFaultyPath(dag, f);

    LowerBoundOnValidDeadline = max(dag.Wfmax/m, Lfmax);
    %dag.D = LowerBoundOnValidDeadline + randi([72,90]);
    dag.D = LowerBoundOnValidDeadline * 1.10;

    % LowerBoundOnValidDeadline
    % dag.D = LowerBoundOnValidDeadline * (1+beta);
    % dag.D = LowerBoundOnValidDeadline * 1.1;
    % dag.D = LowerBoundOnValidDeadline + randi([70,90]); % Somewhere here seems good?
    % A = round(LowerBoundOnValidDeadline * 1.4);
    % B = round(LowerBoundOnValidDeadline * 1.6);
    % dag.D = randi([A, B]);
    % dag.D = randi([Tmin, Lfmax * 2]);
    % % dag.D = max((Wfmax/m), (Lfmax * (1+beta)));
    % fprintf('Wfmax/m: %d\n', Wfmax/m);
    % fprintf('Lfmax: %d\n'w, Lfmax);

    % dag.D = randi([max((Wfmax/m), Lfmax), round(Lfmax * 1.1)]);
end
