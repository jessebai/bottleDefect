clear
imageOrig=imread('test_single1_mod.bmp');
imageGray=rgb2gray(imageOrig);
imageGray=imgaussfilt(imageGray);
figure
imshow(imageGray);
title('原图');
imageBW = imbinarize(imageGray);%%全局阈值
% figure
% imshow(imageBW);
imageCC=bwconncomp(imageBW);%%取连通域

%%
%%下面是取药瓶中间的连通域

numPixels = cellfun(@numel,imageCC.PixelIdxList);
numPixelsSort=sort(numPixels);
maxNum2=numPixelsSort(length(numPixelsSort)-1);
idx=find(numPixels==maxNum2);
for i=1:length(imageCC.PixelIdxList)
    if (i~=idx)
        imageBW(imageCC.PixelIdxList{i}) = 0;
    end
end
% figure
% imshow(imageBW);

%%
%%原图中分割出药瓶中间一块
idx=find(imageBW==0);
imageGrayROI=imageGray;
% imageGrayROI(idx)=130;%注意调整颜色，要让去掉的部分颜色和缺陷颜色不一致 %有问题，所以下面步骤略微麻烦一点
imageGrayROI(idx)=0;
% figure
% imshow(imageGrayROI);

%%
%%分割出缺陷
imageDefectsROI=imbinarize(imageGrayROI,'adaptive','ForegroundPolarity','dark','Sensitivity',0.54);
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
imageGray(imageDefects)=0;
figure
imshow(imageGray);
title('分离缺陷后的药瓶图');

