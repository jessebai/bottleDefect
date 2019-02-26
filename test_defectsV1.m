% clear
gOrg=dicomread('��-005-0063-008-01-0125-016-02-1.dcm');

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
imageCC=bwconncomp(maskedImage);%%ȡ��ͨ��

%%
%%������ȡҩƿ�м����ͨ��

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
%%ԭͼ�зָ��ҩƿ�м�һ��
idx=find(imageBW==0);
imageGrayROI=gOrg;
% imageGrayROI(idx)=130;%ע�������ɫ��Ҫ��ȥ���Ĳ�����ɫ��ȱ����ɫ��һ�� %�����⣬�������沽����΢�鷳һ��
imageGrayROI(idx)=0;
% figure
% imshow(imageGrayROI);
imageGrayROI=imageGrayROI(83:110,58:82);
%%
%%�ָ��ȱ��
imageDefectsROI=imbinarize(imageGrayROI,23815);
% imageDefects=imbinarize(imageGrayROI,'adaptive','Sensitivity',0.65);
% imageDefects=imbinarize(imageGrayROI,'adaptive','ForegroundPolarity','bright','Sensitivity',0.65);
% figure
% imshow(imageDefectsROI);
imageDefects=~imageDefectsROI;%%��Ҫ����һ�£�ǰ������������
% figure
% imshow(imageDefects);
imageDefectsCC=bwconncomp(imageDefects);%%ȡ��ͨ��
numDefectsPixels = cellfun(@numel,imageDefectsCC.PixelIdxList);
[maxNum,idx]=max(numDefectsPixels);
imageDefects(imageDefectsCC.PixelIdxList{idx})=0;
figure
imshow(imageDefects);
title('ȱ��ͼ');

%%
gOrg(imageDefects)=0;
figure
imshow(gOrg);
title('����ȱ�ݺ��ҩƿͼ');

