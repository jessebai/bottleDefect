% clear
%% 识别出瓶子数量和一个特殊点
gOrg=dicomread('iron_wire\铁-002-003-004-005-006-01-015-02-1.dcm');
nOrgH=size(gOrg,1);
nOrgW=size(gOrg,2);
bOrg=imbinarize(gOrg);%全局阈值分割
bOrgcomplement=imcomplement(bOrg);
cLabelOrg=bwconncomp(bOrgcomplement);%取连通域
sLabelStats=regionprops(cLabelOrg,'BoundingBox');%算包含区域的最小矩形

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

nMaxWidth=max(nCoordinateVector(:,3));
nMaxHeight=max(nCoordinateVector(:,4));
nWidth=nCoordinateVector(:,3);

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
for uLineDown=size(bGas,1):-1:1
   if(uGasCount(uLineDown)>=2)
       break;
   end
end

for uLineUp=uLineDown:-1:1
   if(uGasCount(uLineUp)>=0.6*size(gSingle,2))
       break;
   end
end

uLineDown=uLineDown+8;

if(uLineUp<nMaxHeight-316||uLineUp>nMaxHeight-224||...
        uLineDown<nMaxHeight-294||uLineDown>nMaxHeight-202)
    uLineUp=203;
    uLineDown=216;
end

%切割含液体部分并增强
gLiqInOut=gBottle(uLineUp:size(gBottle,1),:);
% figure,imshow(gLiq);
% gLiqInOutAdj=imadjust(gLiqInOut,[6000/65535,7700/65535],[0,1],5);
gLiqInOutAdj=imadjust(gLiqInOut,stretchlim(gLiqInOut,[0.13,0.27]),[0,1],5);
% figure,imshow(gLiqInOutAdj);

%切割液体
bLiqInOut=imbinarize(gLiqInOutAdj);
% figure,imshow(bLiq);
idxLiqInOut=bwlabel(bLiqInOut);
bLiq{i}=idxLiqInOut>=2;
gLiq{i}=uint16(bLiq{i}).*gLiqInOut;
% gLiq{i}=imadjust(gLiq{i},stretchlim(gLiq{i},[0.4,0.75]),[0,1],20);%看切割效果去掉注释

uLiqColCount{i}=sum(gLiq{i},1);%每列之和
uLiqRowCount{i}=sum(gLiq{i},2);%每行之和

for uLeftLine=1:size(gLiq{i},2)%液体部分左边边界线
   if(uLiqColCount{i}(uLeftLine)>0.4*size(gLiq{i},1))
       break;
   end
end
uLeftLine=uLeftLine+5;

for uRightLine=size(gLiq{i},2):-1:1%液体部分右边边界线
   if(uLiqColCount{i}(uRightLine)>0.4*size(gLiq{i},1))
       break;
   end
end
uRightLine=uRightLine-5;

for uBottomLine=size(gLiq{i},1):-1:1%液体部分下边边界线
   if(uLiqRowCount{i}(uBottomLine)>0.5*size(gLiq{i},2))
       break;
   end
end
uBottomLine=uBottomLine-5;

gLiqUp{i}=gLiq{i}(1:uLineDown-uLineUp,:);
gLiqMiddle{i}=gLiq{i}(uLineDown-uLineUp+1:size(gLiq{i},1),:);
gLiqBottom{i}=gLiq{i}(uBottomLine:size(gLiq{i},1),:);
gLiqMiddleLeft{i}=gLiqMiddle{i}(:,1:uLeftLine);
gLiqMiddleRight{i}=gLiqMiddle{i}(:,uRightLine:size(gLiq{i},2));
gLiqMidMid{i}=gLiq{i}(uLineDown-uLineUp+1:uBottomLine,uLeftLine+1:uRightLine-1);
% figure,imshow(gLiq{i});
% figure,imshow(gLiqUp{i});
% figure,imshow(gLiqMiddle{i});
% figure,imshow(gLiqBottom{i});
gLiqAdj=imadjust(gLiq{i},stretchlim(gLiq{i},[0.4,0.75]),[0,1],20);
% figure,imshow(gLiqAdj);

%分割杂质
bLiqDefects{i}=edge(gLiqMiddle{i},'canny');
% figure,imshow(bLiqDefects{i});

uLiqDefectsColCount{i}=sum(bLiqDefects{i},1);%每列之和
uLiqDefectsRowCount{i}=sum(bLiqDefects{i},2);%每行之和

for uLeftLineDefects=1:size(bLiqDefects{i},2)%液体部分左边边界线
   if(uLiqDefectsColCount{i}(uLeftLineDefects)>0)
       break;
   end
end
uLeftLineDefects=uLeftLineDefects+5;

for uRightLineDefects=size(bLiqDefects{i},2):-1:1%液体部分右边边界线
   if(uLiqDefectsColCount{i}(uRightLineDefects)>0)
       break;
   end
end
uRightLineDefects=uRightLineDefects-5;

for uBottomLineDefects=size(bLiqDefects{i},1):-1:1%液体部分下边边界线
   if(uLiqDefectsRowCount{i}(uBottomLineDefects)>0)
       break;
   end
end
uBottomLineDefects=uBottomLineDefects-15;

bDefects{i}=bLiqDefects{i}(1:uBottomLineDefects,uLeftLineDefects+1:uRightLineDefects-1);
bDefectsDilate{i}=bwmorph(bDefects{i},'dilate',1);
% bDefectsClose{i}=bwmorph(bDefectsClose{i},'close',1);
% figure,imshow(bDefects{i});
% figure,imshow(bDefectsClose{i});

%连接缺陷图
bDefectsTotal{i}=cat(2,zeros(uBottomLineDefects,uLeftLineDefects),bDefectsDilate{i});
bDefectsTotal{i}=cat(2,bDefectsTotal{i},...
    zeros(uBottomLineDefects,size(gLiqMiddle{i},2)-uRightLineDefects+1));
bDefectsTotal{i}=cat(1,bDefectsTotal{i},...
    zeros(size(gLiqMiddle{i},1)-uBottomLineDefects,size(bDefectsTotal{i},2)));
bDefectsTotal{i}=cat(1,...
    zeros(uLineDown-uLineUp,size(bDefectsTotal{i},2)),bDefectsTotal{i});
% figure,imshow(bDefectsTotal{i});

gDefectsTotal{i}=uint16(bDefectsTotal{i}).*gLiq{i};
% figure,imshow(gDefectsTotal{i});
bDefectsTotalComplement{i}=imcomplement(bDefectsTotal{i});

gBottleAdj(uLineUp,:)=65535;
gBottleAdj(uLineBottom,:)=65535;
gTotal=cat(1,gCapAdj,gBottleAdj);
figure,imshow(gTotal),title('变换处理后的图');

gDefectsTotal{i}=cat(1,...
    zeros(size(gCap,1)+uLineUp-1,size(gBottleAdj,2)),gDefectsTotal{i});
figure,imshow(gDefectsTotal{i}),title('缺陷图');

bBottleNoDef{i}=cat(1,...
    ones(size(gCap,1)+uLineUp-1,size(gBottleAdj,2)),bDefectsTotalComplement{i});
gBottleNoDef{i}=gTotal.*uint16(bBottleNoDef{i});
figure,imshow(gBottleNoDef{i}),title('去除缺陷后的图');
end

n=4;
% figure,imshow(gLiq{n});
% figure,imshow(gLiqUp{n});
% figure,imshow(gLiqMiddle{n});
% figure,imshow(gLiqBottom{n});
% figure,imshow(gLiqMiddleLeft{n});
% figure,imshow(gLiqMiddleRight{n});
% figure,imshow(gLiqMidMid{n});


b7=bDefects{n};
g7=ones(size(b7,1),size(b7,2));
% for i=1:7
% gDifference(:,:,i)=gLiqAdj(:,:,i+1)-gLiqAdj(:,:,i);
% figure,imshow(gDifference(:,:,i));
% end