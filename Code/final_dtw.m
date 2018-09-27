for w = 0:9
    
    minimum = inf;
    
    for q = 1:10
    
        x = hwratio_s9{q,1};
        y = hwratio_s9{w+1,2};
        m = length( x );
        n = length( y );

        for i = 1:m
            D(i+1,0+1) = inf ;
        end

        for j = 1:n
            D(0+1,j+1) = inf ;
        end

        D(0+1,0+1) = 0;
        d = zeros(m,n);
        
        for i = 1:m
            for j = 1:n
                d(i,j) = abs(x(i) - y(j));
                D(i+1,j+1) = min( [D(i+1,j)+d(i,j),
                                   D(i,j+1)+ d(i,j) ,
                                   D(i,j)+ (2*d(i,j))]);
            end
        end


        if (D(m+1,n+1) < minimum)
            minimum = D(m+1,n+1);
            ans = q-1;
        end

    end
    
    input_to_classifier = w
    recognized_as = ans
    
end
    