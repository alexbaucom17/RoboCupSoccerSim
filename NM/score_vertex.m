function [score] = score_vertex(w_test,C,default_behavior,test_behavior,batch_size,cfg)
%SCORE_VERTEX Scores a test vertex using the game controlelr simulation

%check size of default weight list
w_size_defualt = size(cfg.pff_weights);

%re-format weights and pad with 0s if needed
w = w_test;
w = reshape(w,w_size_defualt(1),[]);
w_size = size(w);
if w_size(2) < 5
    w = [w, zeros(w_size(1),5-w_size(2))];
end

%run batch
scores = zeros(1,batch_size);
parfor j = 1:batch_size
    [~,score1] = ParGameController(C,default_behavior,test_behavior,w);
    [~,score2] = ParGameController(C,test_behavior,default_behavior,w);
    scores(j) = score1.total(2)+score2.total(1);
end

%add up batch scores (negative since we need minimzation)
score = -sum(scores);

