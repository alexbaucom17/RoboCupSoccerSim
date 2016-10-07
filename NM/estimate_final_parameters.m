function [ w ] = estimate_final_parameters(S,cfg)
%ESTIMATE_FINAL_PARAMETERS Estimate final weights of simplex


%for now I am just returning the best vertex, but we could also do more
%complex processing like a weighted average below
S = sortStruct(S,'score');
w_best = S(1).vertex;

%grab defualt weights and overwrite with the current training weights
w = cfg.pff_weights;
w(cfg.NM_idx) = w_best;



%This is clearly not the most efficient way to do this, but this
%function will be fast compared to the rest of the program so it really
%doesn't matter
% 
% %initialize
% n = length(S)-1;
% w = zeros(1,n);
% 
% %get min/max to scale scores
% S = sortStruct(S,'score');
% maxScore = S(end).score;
% minScore = S(1).score;
% diff = maxScore-minScore;
% normalize = @(score) (score-minScore)/diff;
% 
% 
% 
% %loop through each vertex
% for i = 1:n+1
%     
%     %grab vertex
%     v = S(i).vertex;
%     
%     %normlaize score
%     s = normalize(S(i).score);
%     
%     %add vertex weighted by score to total
%     w = w + v*s;
% end
% 
% %divide by total number of vertices
% w = w/(n+1);

end

