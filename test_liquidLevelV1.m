clear
imageOrig=imread('test_total1_mod.bmp');
imageGray=rgb2gray(imageOrig(261:740,803:1031,:));%%选取该瓶所在区域并灰度转换
imageGray=imgaussfilt(imageGray);%%滤波
% figure
% imshow(imageGray);

%%假设瓶子是竖直放置的
imageCapGray=imageGray(1:138,:);%截取瓶盖
% figure
% imshow(imageCapGray);
imageBodyGray=imageGray(139:480,:);%截取瓶身
[imageBodyH,imageBodyW]=size(imageBodyGray);
% figure
% imshow(imageBodyGray);
imageBodyThreshold=40;%选择阈值分割瓶身的玻璃
imageGlass=imageBodyGray>=imageBodyThreshold;
% figure
% imshow(imageGlass);
imageGlassCC=bwconncomp(imageGlass);%去掉外面一层空白
for idx=1:length(imageGlassCC.PixelIdxList)
    if(imageGlassCC.PixelIdxList{idx}(1)==1)
        break;
    end
end
imageGlass(imageGlassCC.PixelIdxList{idx})=0;
% figure
% imshow(imageGlass);
idx=find(imageGlass==0);%取瓶身内部装液体的部分
imageBodyGray(idx)=0;
imageROI=imageBodyGray;
% figure
% imshow(imageROI);
% imageROI=imgaussfilt(imageROI);
figure
imshow(imageROI);
title('瓶内部分');
imageGasThreshold=145;%取出瓶内空气部分（部分）
imageROIGas=imageROI>=145;
imageROIGasCC=bwconncomp(imageROIGas);
numPixelsROI=cellfun(@numel,imageROIGasCC.PixelIdxList);
[~,idx]=max(numPixelsROI);
for i=1:length(imageROIGasCC.PixelIdxList)
    if (i~=idx)
        imageROIGas(imageROIGasCC.PixelIdxList{i}) = 0;
    end
end
% figure
% imshow(imageROIGas);

%%找到液气交界线
%%根据所取的空气部分的下边界拟合一条近似于液面的直线
imageROIGasBoundaries=bwboundaries(imageROIGas);
% imageGasBoundaries=zeros(imageBodyH,imageBodyW);
% for i=1:length(imageROIGasBoundaries{1})
%     imageGasBoundaries(imageROIGasBoundaries{1}(i,1),imageROIGasBoundaries{1}(i,2))=255;
% end
% figure
% imshow(imageGasBoundaries);
numBottomPixels=0;
numBottom=max(imageROIGasBoundaries{1}(:,1));
while (numBottomPixels<0.1*length(imageROIGasBoundaries{1}))
    numBottom=numBottom-2;
    numBottomPixels=sum(imageROIGasBoundaries{1}(:,1)>numBottom);
end
sumH=0;
sumHTimes=0;
for i=1:length(imageROIGasBoundaries{1})
    if(imageROIGasBoundaries{1}(i,1)>=numBottom)
        sumH=sumH+imageROIGasBoundaries{1}(i,1);
        sumHTimes=sumHTimes+1;
    end
end
heightLiquid=round(sumH/sumHTimes);
imageGray(heightLiquid+138,:)=255;
% figure
% imshow(imageGray);

%%根据所取的液体部分的下边界拟合一条近似于液面的直线
sumPixels=0;
heightBottom=342;
while(sumPixels<0.5*229)
   sumPixels=sumPixels+sum(imageROI(heightBottom,:)~=0);
   heightBottom=heightBottom-1;
end
imageGray(heightBottom+138,:)=255;
figure
imshow(imageGray);
title('液体上界面和下界面');

height=heightBottom-heightLiquid;

% numBottomPixels=0;
% numBottom=max(imageBodyROI);
% while (numBottomPixels<imageBodyW)
%     numBottom=numBottom+1;
%     numBottomPixels=sum(imageBodyROI>numBottom);
% end
% heightLiquidBottom=numBottom;
% imageGray(heightLiquidBottom+138,:)=255;