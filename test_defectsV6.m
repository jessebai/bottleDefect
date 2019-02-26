dLiq=double(gLiqMidMid{6});
dSx=fspecial('sobel');
dSy=dSx';
gGx=imfilter(dLiq,dSx);
gGy=imfilter(dLiq,dSy);
gGrad=sqrt(gGx.*gGx+gGy.*gGy);
gGrad=gGrad(2:size(gGrad,1)-1,2:size(gGrad,2)-1);
% figure,imshow(gGrad);
bGrad=gGrad>300;
figure,imshow(bGrad);
gGrad=bGrad.*gGrad;
figure,imshow(gGrad);


bGradClose=bwmorph(bGrad,'close',1);
bGradOpen=bwmorph(bGradClose,'open',1);
bGradClose=bwmorph(bGrad,'close',1);
bGradShow=bwmorph(bGradClose,'clean',1);
figure,imshow(bGradShow);
% bGradDilate=bwmorph(bGradFill,'erode',10);
% figure,imshow(bGradDilate);

% gGradShow=gGrad/max(gGrad(:));
% % gGradShow=gGrad/500;
% 
% figure,imshow(gGradShow);