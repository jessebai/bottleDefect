% clear
gOrg=dicomread('铝-005-0063-008-01-0125-016-02-1.dcm');

gSingle=gOrg(1331:1803,1145:1347);
% figure,imshow(gSingle);
gSingle=adpmedian(gSingle,3);
% figure,imshow(gSingle);

gCap=gSingle(1:135,:);
% figure,imshow(gCap);
gCapAdj=imadjust(gCap,[2000/65535,11073/65535],[0,1],1);
% figure,imshow(gCapAdj);

gBottle=gSingle(136:size(gSingle,1),:);
% figure,imshow(gBottle);
gBottleAdj=imadjust(gBottle,[6000/65535,7700/65535],[0,1],1);
% figure,imshow(gBottleAdj);
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

gLiqInOut=gBottle(uLine:size(gBottle,1),:);
% figure,imshow(gLiq);
gLiqInOutAdj=imadjust(gLiqInOut,[6000/65535,7700/65535],[0,1],5);
% figure,imshow(gLiqInOutAdj);

bLiqInOut=gLiqInOutAdj~=65536&gLiqInOutAdj~=0;
% figure,imshow(bLiq);
idxLiqInOut=bwlabel(bLiqInOut);
bLiq=idxLiqInOut==2;
gLiq=uint16(bLiq).*gLiqInOut;
gLiqAdj=uint16(bLiq).*gLiqInOutAdj;
% figure,imshow(gLiq);




lBottle=gBottle>6600&gBottle<7700;
gLiqInOut=uint16(lBottle).*gBottle;
% figure,imshow(gLiqInOut);
% gLiqAdj=histeq(gLiq,256);
gLiqInOutAdj=imadjust(gLiqInOut,[6600/65535,7700/65535],[0,1],4);
figure,imshow(gLiqInOutAdj);





imageBW=maskedImage;
% figure
% imshow(maskedImage);
imageCC=bwconncomp(maskedImage);%%取连通域

%%
%%下面是取药瓶中间的连通域

numPixels = cellfun(@numel,imageCC.PixelIdxList);
numPixelsSort=sort(numPixels);
maxNum2=numPixelsSort(length(numPixelsSort)-1);
idx=find(numPixels==maxNum2);
for i=1:length(imageCC.PixelIdxList)
    if (i~=2)
        imageBW(imageCC.PixelIdxList{i}) = 0;
    end
end
% figure
% imshow(imageBW);

%%
%%原图中分割出药瓶中间一块
idx=find(imageBW==0);
imageGrayROI=gOrg;
% imageGrayROI(idx)=130;%注意调整颜色，要让去掉的部分颜色和缺陷颜色不一致 %有问题，所以下面步骤略微麻烦一点
imageGrayROI(idx)=0;
% figure
% imshow(imageGrayROI);
imageGrayROI=imageGrayROI(83:110,58:82);
%%
%%分割出缺陷
imageDefectsROI=imbinarize(imageGrayROI,23815);
% imageDefects=imbinarize(imageGrayROI,'adaptive','Sensitivity',0.65);
% imageDefects=imbinarize(imageGrayROI,'adaptive','ForegroundPolarity','bright','Sensitivity',0.65);
% figure
% imshow(imageDefectsROI);
imageDefects=~imageDefectsROI;%%需要处理一下，前景后景略有问题
% figure
% imshow(imageDefects);
imageDefectsCC=bwconncomp(imageDefects);%%取连通域
numDefectsPixels = cellfun(@numel,imageDefectsCC.PixelIdxList);
[maxNum,idx]=max(numDefectsPixels);
imageDefects(imageDefectsCC.PixelIdxList{idx})=0;
figure
imshow(imageDefects);
title('缺陷图');

%%
gOrg(imageDefects)=0;
figure
imshow(gOrg);
title('分离缺陷后的药瓶图');

