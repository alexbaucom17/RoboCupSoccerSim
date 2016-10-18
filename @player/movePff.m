function [ obj, nearPos, nearAng ] = movePff( obj,world,ball_global )
%M Summary of this function goes here
%   Detailed explanation goes here

[obj.vel_des, nearPos, nearAng] = posvelPff(obj,world,ball_global);

end

