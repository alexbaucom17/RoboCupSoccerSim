function [score] = score_vertex(w_in,C,behavior_list,batch_size,cfg)
%SCORE_VERTEX Scores a test vertex using the game controlelr simulation

%grab defualt weights and overwrite with the current training weights
w = cfg.pff_weights;
w(cfg.NM_idx) = w_in;

%run batch
scores = zeros(1,batch_size);
%switch behavior list for second half
L = length(behavior_list);
behavior_list2 = cat(1,behavior_list(L/2+1:end),behavior_list(1:L/2));
parfor j = 1:batch_size
    [~,score1] = GameController(C,behavior_list,j,w);
    [~,score2] = GameController(C,behavior_list2,j,w);
    scores(j) = score1.total(1)+score2.total(2);
end

%average batch scores (negative since we need minimzation for NM)
%add score penalty to encourage lower weights
score = -sum(scores)/batch_size + cfg.NM_weight_penalty*norm(w_in);

