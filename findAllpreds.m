function S= findAllpreds(v, ind)
% computes a topological order of the nodes starting from a DAG structure (linear complexity)

S=[];

if(length(v(ind).pred))==0
   return; 
end

S=[S, v(ind).pred];

for i=1: length(v(ind).pred)
S=[S, findAllpreds(v, v(ind).pred(i))];    
end
end
