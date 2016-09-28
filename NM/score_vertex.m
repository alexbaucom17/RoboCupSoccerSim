function [score] = score_vertex(w_in,C,behavior_list,batch_size,cfg)
%SCORE_VERTEX Scores a test vertex using the game controlelr simulation

%check size of default weight list
w_size_defualt = size(cfg.pff_weights);

%re-format weights and pad with 0s if needed
w_test = reshape(w_in,w_size_defualt(1),[]);
w_size = size(w_test);
if w_size(2) < 5
    w = zeros(w_size_defualt);
    w(:,cfg.training_role) = w_test;
end

%run batch
scores = zeros(1,batch_size);
%switch behavior list for second half
l = length(behavior_list);
behavior_list2 = cat(1,behavior_list(l/2+1:end),behavior_list(1:l/2));
parfor j = 1:batch_size
    [~,score1] = GameController(C,behavior_list,w);
    [~,score2] = GameController(C,behavior_list2,w);
    scores(j) = score1.total(2)+score2.total(1);
end

%average batch scores (negative since we need minimzation for NM)
%add score penalty to encourage lower weights
score = -sum(scores)/batch_size + cfg.NM_weight_penalty*norm(w_in)^2;

