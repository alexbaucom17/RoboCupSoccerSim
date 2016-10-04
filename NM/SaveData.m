function [] = SaveData( S,cfg,n,bh_list )
%SAVEDATA Save data to file with unique name

s1 = 'data/NM_Runs/NM_';
fmt = 'yyyy-mm-dd-HH-MM-SS';
s2 = datestr(now,fmt);    
fname = strcat(s1,s2);
save(fname, 'S','cfg','n','bh_list');

end

