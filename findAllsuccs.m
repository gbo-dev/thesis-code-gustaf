function S= findAllsuccs(v, ind)
% computes a topological order of the nodes starting from a DAG structure (linear complexity)

S=[];

if(isempty(v(ind).succ))
   return; 
end

S=[S, v(ind).succ];

for i=1: length(v(ind).succ)
S=[S, findAllsuccs(v, v(ind).succ(i))];    
end

end

