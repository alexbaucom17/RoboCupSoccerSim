function f_total = pffGeneral(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,in7,in8,in9)
%PFFGENERAL

n_players = size(in8,2)+1;

switch n_players 
    case 1
        f_total = pffGeneral1(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,in7,0,in9);
    case 2
        f_total = pffGeneral2(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,in7,in8,in9);
    case 3
        f_total = pffGeneral3(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,in7,in8,in9);
    case 4 
        f_total = pffGeneral4(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,in7,in8,in9);
    case 5
        f_total = pffGeneral5(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,in7,in8,in9);
end