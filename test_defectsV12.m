clear;
gOrg=dicomread('iron_wire\铁-002-003-004-005-006-01-015-02-1.dcm');%读取图片
% gOrg=dicomread('铁丝-药液-12.dcm');%读取图片
se=strel('square',5);%建立结构元
% gOrg=adpmedian(gOrg,3);%自适应滤波
gFilter=imbothat(gOrg,se);%底帽变换
% gFilter=adpmedian(gFilter,3);%自适应滤波

bOrg=gOrg>16500;%全局阈值分割 %17000
% figure,imshow(bOrg);
bOrgcomplement=imcomplement(bOrg);
cLabelOrg=bwconncomp(bOrgcomplement);%取连通域
sLabelStats=regionprops(cLabelOrg,'BoundingBox');%算包含区域的最小矩形

idxBottle=1;%瓶子数量

for idxLabel=2:numel(cLabelOrg.PixelIdxList)   %0
    idxSumLabel=numel(cLabelOrg.PixelIdxList{idxLabel}(:,1));
    if(idxSumLabel==0)%%没有这个idx说明到头了，可以结束循环
       break;
    elseif(idxSumLabel<69000)%%太小说明不是药瓶  %70000
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

%% 单个分割(filter图）
for i=1:idxBottle-1

%读取原图切割瓶子，自适应中值滤波
gSingleFilter{i}=createsamples(gFilter,nCoordinateVector(i,:));
% figure,imshow(gSingleFilter{i}),title('原图');

% gSingleFilter{i}=adpmedian(gSingleFilter{i},3);
% gSingleFilter{i}=imfilter(gSingleFilter{i},fspecial('gaussian',[3 3],1),'replicate');
gSingleFilter{i}=medfilt2(gSingleFilter{i},[3,3]);
% figure,imshow(gSingleFilter{i});

gSingleFilterAdj{i}=imadjust(gSingleFilter{i},...
    stretchlim(gSingleFilter{i},[0.75,0.96]),[0,1],1);  %0.91，可以提高下限
% gSingleFilterAdj{i}=imadjust(gSingleFilter{i},...
%     stretchlim(gSingleFilter{i},[0,1]),[0,1],1);  %0.91
% figure,imshow(gSingleFilterAdj{i});

%根据中心点寻找分割的具体区域
%不是寻找杂质
%读取原图切割瓶子，自适应中值滤波
gSingle=createsamples(gOrg,nCoordinateVector(i,:));
% figure,imshow(gSingle),title('原图');
gSingle=adpmedian(gSingle,3);
% figure,imshow(gSingle);

uCapLine=135;
%切割瓶盖，增强图片
gCap=gSingle(1:uCapLine,:);
% figure,imshow(gCap);
gCapAdj=imadjust(gCap,stretchlim(gCap,[0,0.6]),[0,1],1);
% figure,imshow(gCapAdj);

%切割瓶身，增强图片
gBottle=gSingle(uCapLine+1:size(gSingle,1),:);
% figure,imshow(gBottle);
gBottleAdj=imadjust(gBottle,stretchlim(gBottle,[0.07,0.38]),[0,1],1);
% figure,imshow(gBottleAdj);

%分割瓶身中空气，确定液面界限
bGasInOut=gBottleAdj>63338;

bGasInOut=bwlabel(bGasInOut);
bGas=bGasInOut==2;
% figure,imshow(bGas);
uGasCount=sum(bGas,2);

for uLineUp=size(bGas,1):-1:1
   if(uGasCount(uLineUp)>=0.6*size(gSingle,2))
       break;
   end
end

if(uLineUp<nMaxHeight-316||uLineUp>nMaxHeight-224)
    uLineUp=203;
end

%% 分割杂质
bSingleFilterAdj{i}=imbinarize(gSingleFilterAdj{i});
bSingleFilterAdj{i}(uCapLine-10,:)=1;
% figure,imshow(gSingleFilterAdj{i});
bSingleFilterAdjFill{i}=imfill(bSingleFilterAdj{i},'holes');
bSingleFilterInside{i}=bSingleFilterAdjFill{i}-bSingleFilterAdj{i};
% figure,imshow(bSingleFilterInside{i});
bSingleFilterInsideComplement{i}=imcomplement(bSingleFilterInside{i});
% figure,imshow(bSingleFilterInsideComplement{i});
bLabelDef{i}=bwlabel(bSingleFilterInsideComplement{i});
bDef{i}=bLabelDef{i}>=2;
% figure,imshow(bDef{i});

bSingleFilterInsideComplementOpen{i}=imopen(bSingleFilterInsideComplement{i},strel('square',3));
bDefAdd{i}=bSingleFilterInsideComplement{i}-bSingleFilterInsideComplementOpen{i};
bDefTotal{i}=bDef{i}+bDefAdd{i};
% figure,imshow(bDefTotal{i}),title('缺陷图');

%% 图像组合连接
uLineBottom=322;
gBottleAdj(uLineUp,:)=65535;
gBottleAdj(uLineBottom,:)=65535;

gBottleDown=gBottleAdj(uLineUp+1:size(gBottleAdj,1),:);
gBottleUp=gBottle(1:uLineUp,:);
gBottleUpAdj=imadjust(gBottleUp,stretchlim(gBottleUp,[0.1,0.6]),[0,1],1);

gTotal=cat(1,gCapAdj,gBottleUpAdj);
gTotal=cat(1,gTotal,gBottleDown);
% figure,imshow(gTotal),title('变换处理后的图');
% figure,imshow(bDefTotal{i}),title('缺陷图');

gBottleNoDef{i}=gTotal.*uint16(imcomplement(bDefTotal{i}));
% figure,imshow(gBottleNoDef{i}),title('去除缺陷后的图');

figure,subplot(1,3,1),imshow(gTotal),title('变换处理后的图');
subplot(1,3,2),imshow(bDefTotal{i}),title('缺陷图');
subplot(1,3,3),imshow(gBottleNoDef{i}),title('去除缺陷后的图');

end

% figure
% for i=1:8
%     subplot(2,12,i*3-2),imshow(gTotal),title('变换处理后的图');
%     subplot(2,12,i*3-1),imshow(bDefTotal{i}),title('缺陷图');
%     subplot(2,12,i*3),imshow(gBottleNoDef{i}),title('去除缺陷后的图');
% end