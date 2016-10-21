function [ obj, nearPos, nearAng ] = moveSimplePff( obj,world,ball_global )
%MOVESIMPLEPFF Summary of this function goes here
%   Detailed explanation goes here

obj.pos_des = posSimple(obj,world,ball_global);
[obj.vel_des, nearPos, nearAng] = velPff(obj,world);

end

