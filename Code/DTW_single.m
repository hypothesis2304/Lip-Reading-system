% DTW
% X - m point signal on rows
% Y - n point signal on columns
x = h_w_ratio_1{1}(:,1);
y = h_w_ratio_1{2}(:,1);
m = length( x(:,1) );
n = length( y(:,1) );
for i = 1:m
    D(i+1,0+1) = inf ;
end
for j = 1:n
    D(0+1,j+1) = inf ;
end
D(0+1,0+1) = 0;
for i = 1:m
    for j = 1:n
        d(i,j) = abs(x(i) - y(j));
        D(i+1,j+1) = min( [D(i+1,j)+d(i,j) ,
                          D(i,j+1)+ d(i,j) ,
                          D(i,j)+ (2*d(i,j))]);
    end
end
D(m+1,n+1)
% D(m+1,n+1) is the measure of distortion between X and Y
% the input word is compared with all the templates 
% and the one with minimum distortion is selected as the output

        
    
        