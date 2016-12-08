function [ validation ] = FullRunValidation( new_weights, cfg )
%FULLRUNVALIDATION Summary of this function goes here
%   Detailed explanation goes here

%set up configuration variables
batch_size = cfg.validation_batchSize; %ideally this should be a multiple of however many workers are in the parallel pool

%list team behaviors to test
batch_list = {'moveSimple','movePff';
           'moveSimplePff','movePff'};
       
%uncomment to load weights from data
cfg.pff_weights = new_weights;

%setup behavior array and other needed info
num_batches = size(batch_list,1);
for i = 1:num_batches*2
    filenames{i} = strcat(batch_list{i},'.m');
end

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles(filenames);
else
    p.updateAttachedFiles();
end    

%% Run simulations

%run sim
disp('Beginning validation...')

scores = zeros(batch_size,2);
validation = [];
%run in batches
for i = 1:num_batches
    
    %prep batch
    fprintf('Running batch %i of %i\n',i,num_batches)
    handle1 = str2func(batch_list{i,1});
    handle2 = str2func(batch_list{i,2});
    bh_list =  cat(1,repmat({handle1},cfg.num_players_red,1),...
             repmat({handle2},cfg.num_players_blue,1));
    
    %run batch
    parfor j = 1:batch_size
        stats1 = GameController(C,bh_list,j);
        stats2 = GameController(C,flip(bh_list),j);
        scores(j,:) = [stats1.score(1) + stats2.score(2), stats2.score(2) + stats2.score(1)];
    end
    
    %batch analysis
    total_goals = sum(scores,1);
    team1_wins = sum(scores(:,1)>scores(:,2),1);
    team2_wins = sum(scores(:,1)<scores(:,2),1);
    ties = batch_size - team1_wins - team2_wins;
    if i == 1
        validation.simpleRatio = team2_wins/team1_wins; 
        validation.simpleTies = ties;
        validation.simpleGoals = total_goals;
    else
        validation.pffRatio = team2_wins/team1_wins;
        validation.pffTies = ties;
        validation.pffGoals = total_goals;
    end
end

end

