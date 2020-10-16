function [center, U, obj_fcn,validity] = fcm_ValidationIndex_kong2015(cluster_data, c, option)
[center, U, obj_fcn] = fcm(cluster_data, c, option);
%[val,cluster_ind]=max(U);
%dist = distfcm(center, cluster_data);       % fill the distance matrix
N=size(cluster_data,1);
m=option(1);
%%  1.partition coefficient (PC)
fm = (U).^2;
PC = 1/N*sum(sum(fm));
%%  2.classification entropy (CE)
fm  = U.*log(U);
PE  = -1/N*sum(sum(fm));
FPI = 1-(c*PC-1)/(c-1);
NCE = PE/log(c);

%%  3.partition Index:SC
ni = sum(U,2);                        %calculate fuzzy cardinality基数
SC=0;
for i=1:c
    d=distfcm(cluster_data, center(i));
    %si = sum(result.data.d.*result.data.f.^(m/2));  %calculate fuzzy variation
    si = sum(U.^2*d.^2);  %calculate fuzzy variation
    SC=si/ni(i)/sum(distfcm(center,center(i)).^2)+SC;
end
%%  4.Separation Index, S
% S_u=0;
% for i=1:c
%     d=distfcm(cluster_data,center(i));
%     %si = sum(result.data.d.*result.data.f.^(m/2));  %calculate fuzzy variation
%     S_u = sum(U.^2*d.^2)+S_u;  %calculate fuzzy variation
% end
num=0;dist=zeros(c*(c-1)/2,1);
for i=1:c-1
    for j=i+1:c
        num=num+1;
        dist(num)=distfcm(center(i,:),center(j,:));
    end
end
dmin=min(dist);
% S=S_u/(N*dmin);
%%  5.Modified Xie and Beni's Index (XB)
XB_u=0;
for i=1:c
    d=distfcm(cluster_data,center(i));
    %si = sum(result.data.d.*result.data.f.^(m/2));  %calculate fuzzy variation
    XB_u = sum(U.^m*d.^2)+XB_u;  %calculate fuzzy variation
end
XB=XB_u/(N*dmin);
validity.PC=PC;
validity.PE=PE;
validity.FPI=FPI;
validity.NCE=NCE;
validity.SC=SC;
validity.XB=XB;
