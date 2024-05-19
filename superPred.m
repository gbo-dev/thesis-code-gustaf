
%superPred, returns ALL the predecessors of the i node in v

function result = superPred(v, i)
 result = [];
    if(isempty(v(i).pred))
        return;
    end
    for x = v(i).pred
        result = union(x, result);
        result = union(superPred(v,x), result);
    end
    return;
end