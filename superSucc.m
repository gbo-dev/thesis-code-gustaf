

function result = superSucc(v, i) %where v is the DAG and i is the node
    result = [];
    if(isempty(v(i).succ))
        return;
    end
    for x = v(i).succ
        result = union(result,x);
        result = union(result, superSucc(v,x));
    end
    return;
end