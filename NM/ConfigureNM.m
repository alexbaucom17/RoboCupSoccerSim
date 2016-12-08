function [ cfg ] = ConfigureNM( cfg )
%CONFIGURENM Re-configure NM parameters

%remove all 0 weights from training set but keep index for easy replacement
%later
cfg.NM_initial = reshape(cfg.pff_weights(:,cfg.training_role),1,[]);
cfg.NM_idx = [];
for i = cfg.training_role
    col = cfg.pff_weights(:,i);
    rows = find(col ~= 0);
    cols = repmat(i,length(rows),1);
    cfg.NM_idx = [cfg.NM_idx; sub2ind(size(cfg.pff_weights),rows,cols)];
end    
cfg.NM_initial(cfg.NM_initial == 0) = []; 
cfg.NM_dim = length(cfg.NM_initial);

%adaptive parameters for NM
%http://www.webpages.uidaho.edu/~fuchang/res/anms.pdf
cfg.NM_alpha = 1;
cfg.NM_beta = 1 + 2/cfg.NM_dim;
cfg.NM_gamma = 0.75-1/(2*cfg.NM_dim);
cfg.NM_delta = 1-1/cfg.NM_dim;

end

