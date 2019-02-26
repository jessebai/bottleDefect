%% 识别出瓶子数量和一个特殊点
gOrg=dicomread('铁-002-003-004-005-006-01-015-02-1.dcm');
nOrgH=size(gOrg,1);
nOrgW=size(gOrg,2);
bOrg=imbinarize(gOrg);%全局阈值分割
bOrgcomplement=imcomplement(bOrg);
cLabelOrg=bwconncomp(bOrgcomplement);%取连通域
sLabelStats= regionprops(cLabelOrg,'BoundingBox');%算包含区域的最小矩形

idxBottle=1;

for idxLabel=1:numel(cLabelOrg.PixelIdxList)
idxSumLabel=numel(cLabelOrg.PixelIdxList{idxLabel}(:,1));
if(idxSumLabel==0)%%没有这个idx说明到头了，可以结束循环
   break;
elseif(idxSumLabel<70000)%%太小说明不是药瓶
   continue;
else%%说明是药瓶，下面开始找特殊点
   nCoordinateVector(idxBottle,:)=uint16(...
       sLabelStats(idxLabel).BoundingBox);
   idxBottle=idxBottle+1;
end

end

nCoordinateVector(:,3)=uint16(ones(idxBottle-1,1))*max(nCoordinateVector(:,3));
nCoordinateVector(:,4)=uint16(ones(idxBottle-1,1))*max(nCoordinateVector(:,4));

%% 单个分割
for i=1:idxBottle-1
    
uLineBottom=314;%先验知识，瓶底位置
%读取原图切割瓶子，自适应中值滤波
gSingle=createsamples(gOrg,nCoordinateVector(i,:));
% figure,imshow(gSingle),title('原图');
gSingle=adpmedian(gSingle,3);
% figure,imshow(gSingle);

%切割瓶盖，增强图片
gCap=gSingle(1:135,:);
% figure,imshow(gCap);
% gCapAdj=imadjust(gCap,[2000/65535,11073/65535],[0,1],1);
gCapAdj=imadjust(gCap,stretchlim(gCap,[0,0.6]),[0,1],1);
% figure,imshow(gCapAdj);

%切割瓶身，增强图片
gBottle=gSingle(136:size(gSingle,1),:);
% figure,imshow(gBottle);
% gBottleAdj=imadjust(gBottle,[6000/65535,8700/65535],[0,1],5);
gBottleAdj=imadjust(gBottle,stretchlim(gBottle,[0.07,0.38]),[0,1],1);
% figure,imshow(gBottleAdj);

%分割瓶身中空气，确定液面界限
bGasInOut=gBottleAdj>63338;

bGasInOut=bwlabel(bGasInOut);
bGas=bGasInOut==2;
% figure,imshow(bGas);
uGasCount=sum(bGas,2);
for uLine=size(bGas,1):-1:1
   if(uGasCount(uLine)>=2)
       break;
   end
end


%切割含液体部分并增强
gLiqInOut=gBottle(uLine:size(gBottle,1),:);
% figure,imshow(gLiq);
% gLiqInOutAdj=imadjust(gLiqInOut,[6000/65535,7700/65535],[0,1],5);
gLiqInOutAdj=imadjust(gLiqInOut,stretchlim(gLiqInOut,[0.13,0.27]),[0,1],5);
% figure,imshow(gLiqInOutAdj);

%切割液体
bLiqInOut=imbinarize(gLiqInOutAdj);
% figure,imshow(bLiq);
idxLiqInOut=bwlabel(bLiqInOut);
bLiq=idxLiqInOut>=2;
gLiq{i}=uint16(bLiq).*gLiqInOut;
% figure,imshow(gLiq{i});
gLiqAdj=imadjust(gLiq{i},stretchlim(gLiq{i},[0.4,0.75]),[0,1],20);
% figure,imshow(gLiqAdj);

%分割杂质
bLiqDefects{i}=edge(gLiq{i},'canny');
figure,imshow(bLiqDefects{i});



end

% dLiq=double(gLiq{2});
% dSx=fspecial('sobel');
% dSy=dSx';
% gGx=imfilter(dLiq,dSx);
% gGy=imfilter(dLiq,dSy);
% gGrad=sqrt(gGx.*gGx+gGy.*gGy);
% 
% 
% % bGrad=gGrad>30000;
% % figure,imshow(bGrad);
% 
% bGrad=dLiq~=0;
% bGradOpen=bwmorph(bGrad,'open',1);
% bGradClose=bwmorph(bGradOpen,'close',1);
% bGradFill=imfill(bGradClose,'holes');
% bGradDilate=bwmorph(bGradFill,'erode',10);
% figure,imshow(bGradDilate);
% gGradAdj=bGradDilate.*gGrad;
% figure,imshow(gGradAdj>200);
% 
% se=strel('disk',3);
% bGradDilate=imdilate(bGrade,se);
% % bGradDilate=imdilate(bGradDilate,se);
% % bGradDilate=bwmorph(bGrad,'dilate',3);
% % figure,imshow(bGradDilate);
% 
% bGradDilateComplement=imcomplement(bGradDilate);
% gGradmiddle=bGradDilateComplement.*gGrad;
% 
% % figure,imshow(gGradmiddle/500);
% 
% 
% gLiqEdge=uint16(bGrad.*dLiq);
% % figure,imshow(gLiqEdge);


% for i=1:7
% gDifference(:,:,i)=gLiqAdj(:,:,i+1)-gLiqAdj(:,:,i);
% figure,imshow(gDifference(:,:,i));
% end