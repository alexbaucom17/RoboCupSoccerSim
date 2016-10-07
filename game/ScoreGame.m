function [ newscore ] = ScoreGame(world,cfg)
%SCOREGAME Scoring function for soccer simulation
%   Takes in world info and configuration and updates 
%   the score for this step


%scoring metrics
% + goals scored
% - goals against
% - out of bounds
% + attacker close to ball
% + supporter and attacker proper distance range apart
% - defenders + goalie to close
% - searching time

persistent score;

%initialize if needed
if isempty(score)
    score.goalsFor = [world.red_score, world.blue_score];
    score.goalsAgainst = [world.blue_score, world.red_score];
    score.oob = [0,0];
    score.close2ball = [0,0];
    score.own_goals = [0,0];
    score.num_kicks = [0,0];
    %score.supportDist = [0,0];
    %score.defendDist = [0,0];
    %score.searchTime = [0,0];
    
%update properties each step
else
    
    %calculate varios metrics
    attacker_ids = world.get_attacker_ids;
    ball_dist = [world.world_exact.players(attacker_ids).ball_local];
    attacker_dist = [norm(ball_dist(1:2)),norm(ball_dist(3:4))];
    
    
    score.goalsFor = [world.red_score, world.blue_score];
    score.goalsAgainst = [world.blue_score, world.red_score];
    score.own_goals_against = world.own_goals;
    score.own_goals_for = fliplr(world.own_goals);
    score.oob = world.num_oob;
    score.close2ball = score.close2ball + (attacker_dist<cfg.close2ballthresh)./attacker_dist;
    score.num_kicks = world.num_kicks;
    
    %total up everything
    score.total = score.goalsFor*cfg.goalsForPts + ...
         score.goalsAgainst*cfg.goalsAgainstPts + ...
         score.oob*cfg.oobPts + score.close2ball*cfg.close2ballPts+...
         score.own_goals_for*cfg.ownGoalForPts+...
         score.own_goals_against*cfg.ownGoalAgainstPts+...
         score.num_kicks*cfg.kickPts;
end

%report back current score
newscore = score;    


end

