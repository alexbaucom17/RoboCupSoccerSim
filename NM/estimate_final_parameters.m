function [ w ] = estimate_final_parameters( S)
%ESTIMATE_FINAL_PARAMETERS Estimate final weights of simplex
%   final weights are simply a weighted average of the simplex vertices

%This is clearly not the most efficient way to do this, but this
%function will be fast compared to the rest of the program so it really
%doesn't matter

%it might be better to just return the best point instead of averaging
%them.... might need some testing to determine

%initialize
n = length(S)-1;
w = zeros(1,n);

%get min/max to scale scores
S = StructSort(S,'score');
maxScore = S(end).score;
minScore = S(1).score;
diff = maxScore-minScore;
normalize = @(score) (score-minScore)/diff;

%loop through each vertex
for i = 1:n+1
    
    %grab vertex
    v = S(i).vertex;
    
    %normlaize score
    s = normalize(S(i).score);
    
    %add vertex weighted by score to total
    w = w + v*s;
end

%divide by total number of vertices
w = w/(n+1);

end

