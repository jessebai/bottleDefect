%%
%处理最后一个图

%读取原图并根据先验知识切割最后一个瓶子，在自适应中值滤波
gOrg=dicomread('铝-005-0063-008-01-0125-016-02-1.dcm');
gSingle=gOrg(1331:1803,1920:2115);
% figure,imshow(gSingle),title('原图');
gSingle=adpmedian(gSingle,3);
% figure,imshow(gSingle);

%切割瓶盖，增强图片
gCap=gSingle(1:135,:);
% figure,imshow(gCap);
gCapAdj=imadjust(gCap,[2000/65535,11073/65535],[0,1],1);
% figure,imshow(gCapAdj);

%切割瓶身，增强图片
gBottle=gSingle(136:size(gSingle,1),:);
% figure,imshow(gBottle);
gBottleAdj=imadjust(gBottle,[6000/65535,8700/65535],[0,1],5);
% figure,imshow(gBottleAdj);

%分割瓶身中空气，确定液面界限
bGasInOut=gBottleAdj>62338;

bGasInOut=bwlabel(bGasInOut);
bGas=bGasInOut==2;
% figure,imshow(bGas);
uGasCount=sum(bGas,2);
for uLine=size(bGas,1):-1:1
   if(uGasCount(uLine)>=0.5*size(gSingle,2))
       break;
   end
end

%切割含液体部分并增强
gLiqInOut=gBottle(uLine:size(gBottle,1),:);
% figure,imshow(gLiq);
gLiqInOutAdj=imadjust(gLiqInOut,[6000/65535,7700/65535],[0,1],5);
% figure,imshow(gLiqInOutAdj);

%切割液体
bLiqInOut=gLiqInOutAdj>=65500;
% figure,imshow(bLiq);
idxLiqInOut=bwlabel(bLiqInOut);
bLiq=idxLiqInOut==2;
gLiq=uint16(bLiq).*gLiqInOut;
% figure,imshow(gLiq);
gLiqAdj=imadjust(gLiq,[7800/65535,8200/65535],[0,1],1);

%自适应分割杂质并形态学处理
bLiqDef=imbinarize(gLiqAdj,'adaptive','Sensitivity',0.72);
% bDef=bLiq-bLiqDef;
seLiqDef=strel('square',3);
bLiqDefOpen=imopen(bLiqDef,seLiqDef);
bLiqDefClose=imclose(bLiqDef,seLiqDef);
bDefPar=bLiqDefClose-bLiqDefOpen;
cCCDefPar=bwconncomp(bDefPar);
uNumPixels=cellfun(@numel,cCCDefPar.PixelIdxList);
[~,idxDef]=max(uNumPixels);
bDef=zeros(size(bDefPar));
bDef(cCCDefPar.PixelIdxList{idxDef})=1;


uLineBottom=314;%先验知识，瓶底位置

%对处理图进行连接和显示
gBottleAdj(uLine,:)=65535;
gBottleAdj(uLineBottom,:)=65535;
gTotal=cat(1,gCapAdj,gBottleAdj);
figure,imshow(gTotal),title('变换处理后的图');

bDefTotal=cat(1,zeros(size(gCap,1)+uLine-1,size(gBottleAdj,2)),bDef);
gDefTotal=uint16(double(gTotal).*bDefTotal);
% figure,imshow(gDefTotal),title('缺陷图');
bDefTotalComplement=imcomplement(bDefTotal);
gDefTotalComplement=gTotal.*uint16(bDefTotalComplement);
% figure,imshow(gDefTotalComplement),title('去除缺陷后的图');


%%
%生成无异物的液体图
close all;
gLiqAll=gLiq;
for idxDefPixs=1:size(cCCDefPar.PixelIdxList{idxDef})
    idxCurPix=cCCDefPar.PixelIdxList{idxDef}(idxDefPixs);
    for idxNbrPix=idxCurPix-122:122:idxCurPix+122
        gLiqAll(idxNbrPix)=median([...
            gLiqAll(idxNbrPix-122*1),gLiqAll(idxNbrPix-122*2)...
            ,gLiqAll(idxNbrPix--122*3),gLiqAll(idxNbrPix+122*1)...
            ,gLiqAll(idxNbrPix+122*2),gLiqAll(idxNbrPix+122*3)...
            ,gLiqAll(idxNbrPix-122*5),gLiqAll(idxNbrPix-122*4)...
            ,gLiqAll(idxNbrPix-122*1-1),gLiqAll(idxNbrPix-122*2-1)...
            ,gLiqAll(idxNbrPix--122*3-1),gLiqAll(idxNbrPix+122*1-1)...
            ,gLiqAll(idxNbrPix+122*2-1),gLiqAll(idxNbrPix+122*3-1)...
            ,gLiqAll(idxNbrPix-122*--1),gLiqAll(idxNbrPix-122*4-1)...
            ,gLiqAll(idxNbrPix-122*1+1),gLiqAll(idxNbrPix-122*2+1)...
            ,gLiqAll(idxNbrPix--122*3+1),gLiqAll(idxNbrPix+122*1+1)...
            ,gLiqAll(idxNbrPix+122*2+1),gLiqAll(idxNbrPix+122*3+1)...
            ,gLiqAll(idxNbrPix-122*5+1),gLiqAll(idxNbrPix-122*4+1)...
            ]);
    end
end

gLiqAll=imfilter(gLiqAll,fspecial('gaussian',5,1));
gLiqAll=adpmedian(gLiqAll,3);


gLiqAllAdj=imadjust(gLiqAll,[7800/65535,8400/65535],[0,1],1);
% figure,imshow(gLiqAll);

%%
%第四个瓶子的液体部分


gSingle1=gOrg(1331:1803,1145:1347);
% figure,imshow(gSingle);
gSingle1=adpmedian(gSingle1,3);
% figure,imshow(gSingle);

gCap1=gSingle1(1:135,:);
% figure,imshow(gCap);
gCapAdj1=imadjust(gCap1,[2000/65535,11073/65535],[0,1],1);
% figure,imshow(gCapAdj);

gBottle1=gSingle1(136:size(gSingle1,1),:);
% figure,imshow(gBottle);
gBottleAdj1=imadjust(gBottle1,[6000/65535,7700/65535],[0,1],1);
% figure,imshow(gBottleAdj);
bGasInOut1=gBottleAdj1>62338;

bGasInOut1=bwlabel(bGasInOut1);
bGas1=bGasInOut1==2;
% figure,imshow(bGas);
uGasCount=sum(bGas1,2);
for uLine1=size(bGas1,1):-1:1
   if(uGasCount(uLine1)>=0.5*size(gSingle1,2))
       break;
   end
end

gLiqInOut1=gBottle1(uLine1:size(gBottle1,1),:);
% figure,imshow(gLiq);
gLiqInOutAdj1=imadjust(gLiqInOut1,[6000/65535,7700/65535],[0,1],5);
% figure,imshow(gLiqInOutAdj);

bLiqInOut1=gLiqInOutAdj1~=65536&gLiqInOutAdj1~=0;
% figure,imshow(bLiq);
idxLiqInOut1=bwlabel(bLiqInOut1);
bLiq1=idxLiqInOut1==2;
gLiq1=uint16(bLiq1).*gLiqInOut1;
gLiqAdj1=uint16(bLiq1).*gLiqInOutAdj1;
% figure,imshow(gLiqAll);
% figure,imshow(gLiq1);

%%
%使用无异物液体图进行对比处理
gLiqAllCat=cat(2,zeros(122,7),gLiqAll);
gLiqAllCat=cat(1,gLiqAllCat,zeros(7,203));
gSub=gLiqAllCat-gLiq1;
% figure,imshow(gSub);
gSubAdj=imadjust(gSub,[500/65535,1000/65535],[,],1);
figure,imshow(gSubAdj);