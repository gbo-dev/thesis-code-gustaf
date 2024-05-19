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

function printTask(v)
% prints a conditional DAG task

    figure;
    hold on;
    
    p = 1;

%     if ~isempty(headline)
%         title(headline);
%     end
    for i = 1 : length(v)   % plot vertices
        if v(i).C ~= 0
            plotCircle(v(i).width, v(i).depth, 0.1, i, v);
        end
        p = p + 1;
    end
    
    for i = 1 : length(v)   % plot edges
        for j = 1 : length(v(i).succ)
            if v(i).cond == 0
                plot([v(i).width v(v(i).succ(j)).width],[v(i).depth v(v(i).succ(j)).depth], 'm');            
            elseif v(i).cond == 1
                plot([v(i).width v(v(i).succ(j)).width],[v(i).depth v(v(i).succ(j)).depth], 'm--');
%             elseif v(i).cond == 2 && v(j).cond == 2
%                 plot([v(i).width v(v(i).succ(j)).width],[v(i).depth v(v(i).succ(j)).depth], 'b--');
            end
        end
    end
 
    hold off;
end
