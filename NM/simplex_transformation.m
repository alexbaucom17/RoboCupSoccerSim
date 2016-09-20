function [S_sorted] = simplex_transformation(S,cfg,ConfigConstant,default_behavior,test_behavior,batch_size)
%SIMPLEX_TRANSFORMATION Performs Nelder Mead simplex transformations
%   Detailed explanation goes here

%sort simplex scores
S_sorted = sortStruct(S,'score');

%useful indeces
h = length(S_sorted); %worst
s = h-1; %second worst
l = 1; %best
n = cfg.NM_dim; %number of dimensions

%Get vertices
Xh = S_sorted(h).vertex;
Xs = S_sorted(s).vertex;
Xl = S_sorted(l).vertex;

%get scores
Fh = S_sorted(h).score;
Fs = S_sorted(s).score;
Fl = S_sorted(l).score;

%pull out verteces for easy calculations
%this is clearly slow but will still be way faster than running matches
S_mat = zeros(n+1,n);
for i = 1:n+1
    S_mat(i,:) = S_sorted(i).vertex;
end   
    
%caluclate cnetroid of best side
C = 1/n*sum(S_mat(1:s,:),1);

%compute refleciton transformation
Xr = C + cfg.NM_alpha*(C-Xh);

%score new reflection point
Fr = score_vertex(Xr,ConfigConstant,default_behavior,test_behavior,batch_size,cfg);

%check to see if this is a good point
if Fr < Fs && Fr >= Fl    
    %if so just replace the bad point and terminate
    S_sorted(h).vertex = Xr;
    S_sorted(h).score = Fr;
    return
end

%if the reflection point was better than the best, keep expanding in this
%direction
if Fr < Fl
    
    %compute and score expansion point
    Xe = C + cfg.NM_gamma*(Xr - C);
    Fe = score_vertex(Xe,ConfigConstant,default_behavior,test_behavior,batch_size,cfg);
    
    %check to see if the expansion was worth it
    if Fe < Fl
        %keep expansion if the score improved
        S_sorted(h).vertex = Xe;
        S_sorted(h).score = Fe;
    else
        %just keep the reflection if score wasn't better
        S_sorted(h).vertex = Xr;
        S_sorted(h).score = Fr;
    end
    return
end

%if the reflection point was worse than the second worst point do a
%contraction
if Fr >= Fs
    


end

