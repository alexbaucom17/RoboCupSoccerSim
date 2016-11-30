
%% Initialization
close all
clear
addpath game pff
disp('Initializing...')

%set up configuration variables
batch_size = 4; %ideally this should be a multiple of however many workers are in the parallel pool

%list team behaviors to test
bh_list = {'moveSimple', ...
           'movePff'};
       
%override some config values for parallel testing
cfg = Config();
cfg.drawgame = false;
cfg.halflength = 300; %run 2 5 minute halves

%uncomment to load weights from data
load data/NM_2016-11-22-19-55-28Supporter
cfg.pff_weights = new_pff_weights;

%setup behavior array and other needed info
num_bh = size(bh_list,2);
batch_combos = nchoosek(1:num_bh,2);
num_batches = size(batch_combos,1);
num_games = num_batches * batch_size;
for i = 1:num_bh
    bh(i).str = bh_list{i};
    bh(i).handle = str2func(bh(i).str);
    bh(i).filename = strcat(bh(i).str,'.m');
    bh(i).games_played = 0;
    bh(i).wins = 0;
    bh(i).loss = 0;
    bh(i).ties = 0;
    bh(i).gf = 0;
    bh(i).ga = 0;
end

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles({bh(:).filename});
else
    p.updateAttachedFiles();
end    

%% Run simulations

%run sim
disp('Starting simulations...')
tic

scores = zeros(batch_size,2);
%run in batches
for i = 1:num_batches
    
    %prep batch
    fprintf('Running batch %i of %i\n',i,num_batches)
    team1 = batch_combos(i,1);
    team2 = batch_combos(i,2);
    handle1 = bh(team1).handle;
    handle2 = bh(team2).handle;
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
    
    %update info
    bh(team1).games_played = bh(team1).games_played + batch_size;
    bh(team1).wins = bh(team1).wins + team1_wins;
    bh(team1).loss = bh(team1).loss + team2_wins;
    bh(team1).ties = bh(team1).ties + ties;
    bh(team1).gf = bh(team1).gf + total_goals(1);
    bh(team1).ga = bh(team1).ga + total_goals(2);
    
    bh(team2).games_played = bh(team2).games_played + batch_size;
    bh(team2).wins = bh(team2).wins + team2_wins;
    bh(team2).loss = bh(team2).loss + team1_wins;
    bh(team2).ties = bh(team2).ties + ties;
    bh(team2).gf = bh(team2).gf + total_goals(2);
    bh(team2).ga = bh(team2).ga + total_goals(1);
    
end
toc
