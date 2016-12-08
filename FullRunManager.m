%Runs series of learning trials and validations for simulation

close all
clear

%add paths if needed (directories won't exist once compiled)
if exist('game','dir')
    addpath game pff NM NM/StructSort
end

%add data directory if needed
if ~exist('FullRunData', 'dir')
  mkdir('FullRunData')
end

n_trials = 10; %max 10
default_config = FullRunConfig();
t_fullrun = tic;

for i = 1:n_trials

%Load configuration for this trial
cfg = FullRunConfig(i);

%error/sanity checks
if ~all(cfg.start_roles_red ==  cfg.start_roles_blue)
    error('Start roles must match for each team')
elseif cfg.num_players_red ~= cfg.num_players_blue
    error('Number of players must match for each team')
end

%Print out useful info
play_names = player.roleNames(cfg.start_roles_red(1:cfg.num_players_red)+1);
play_nameStr = '';
for j = 1:length(play_names)
    play_nameStr = [play_nameStr,play_names{j},' '];
end
train_names = player.roleNames(cfg.training_role);
train_nameStr = '';
for j = 1:length(train_names)
    train_nameStr = [train_nameStr,train_names{j},' '];
end

fprintf('\n========================================\n');
fprintf('Run number: %i\n',i)
fprintf('Playing roles: %s\n',play_nameStr)
fprintf('Training roles: %s\n',train_nameStr)
if ~isempty(cfg.load_fname)
    fprintf('Loading previous weights from: %s\n',cfg.load_fname)
end
fprintf('\n')

%new_weights = cfg.pff_weights;
new_weights = FullRunLearner(cfg);

validation = FullRunValidation(new_weights,default_config);
% validation = 0;

%save everything to file
fname = strcat('FullRunData/Run',num2str(i));
save(fname, 'new_weights','validation');

end

fprintf('\n========================================\n');
fprintf('All runs are completed\n')
fprintf('Data for each run is stored in FullRunData/\n')
fprintf('Total run time: %4.2f\n',toc(t_fullrun))