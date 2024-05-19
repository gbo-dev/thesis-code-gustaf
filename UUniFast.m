%UUnifast


function vectU = UUniFast(n, Ut)
    sumU = Ut;
    for i=1:n-1
        nextSumU = sumU * power(rand, 1/(n-i));
        vectU(i) = sumU - nextSumU;
        sumU = nextSumU;
    end
    vectU(n) = sumU;
end