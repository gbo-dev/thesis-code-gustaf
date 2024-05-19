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

function [v] = computeAperiodicJobsNonCP(v, R, D)
% returns an upper-bound to the Z value of the task graph represented as v
% (Algorithm 2 in the paper)
%v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});    
    global m;

    order = computeTopologicalOrder(v);
    
    v(order(end)).Lpath= v(order(end)).C;
    
    
    for z = length(order) : -1 : 1 
        i = order(z);
        if isempty(v(i).succ)
            v(i).Lpath=v(i).C;
            v(i).RevRel=0;
        else
            max=0;
             for j = 1 : length(v(i).succ)
                 if(max<v(v(i).succ(j)).Lpath)
                     max=v(v(i).succ(j)).Lpath;
                 end
             end
             v(i).Lpath=v(i).C+max;
             v(i).RevRel=v(i).Lpath-v(i).C;
        end        
    end
    
    for z = 1:length(order) 
        i = order(z);
      
        if isempty(v(i).pred)
            v(i).Offset=0;
        %    v(i).RevRel=0;
        else
             max=0;
             delay=0;
%              disp('target')
%              disp(i);
%              disp('preds')
             
             for j = 1 : length(v(i).pred)
%                  disp(v(i).pred(j));
                 delay=v(v(i).pred(j)).Offset+ (v(v(i).pred(j)).C);
%                  disp('delay');
%                  disp(delay);
                 if(max<delay)
                     max=delay;
                 end
             end
%                  disp('max');
%                  disp(max);
             
             v(i).Offset=max;
             %v(i).RevRel=v(i).Lpath-v(i).C;
        end        
    end
    
    if(0)
        for(K=1: length(v))
          %v(K)
          i=order(K);
           disp('ind');
    disp(i)
     disp('pre');
    disp(v(i).pred)
    disp('off');
    disp(v(i).Offset);
        end
    end
    
    
    
    
   % for z = length(order) : -1 : 1 
   %     i=order(z);
   %     str = sprintf('v %d L=%d',i, v(i).RevRel);
   %     disp(str);
   %  end
    v=v;
   
end