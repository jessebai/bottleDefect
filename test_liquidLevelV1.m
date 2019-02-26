clear
imageOrig=imread('test_total1_mod.bmp');
imageGray=rgb2gray(imageOrig(261:740,803:1031,:));%%ѡȡ��ƿ�������򲢻Ҷ�ת��
imageGray=imgaussfilt(imageGray);%%�˲�
% figure
% imshow(imageGray);

%%����ƿ������ֱ���õ�
imageCapGray=imageGray(1:138,:);%��ȡƿ��
% figure
% imshow(imageCapGray);
imageBodyGray=imageGray(139:480,:);%��ȡƿ��
[imageBodyH,imageBodyW]=size(imageBodyGray);
% figure
% imshow(imageBodyGray);
imageBodyThreshold=40;%ѡ����ֵ�ָ�ƿ��Ĳ���
imageGlass=imageBodyGray>=imageBodyThreshold;
% figure
% imshow(imageGlass);
imageGlassCC=bwconncomp(imageGlass);%ȥ������һ��հ�
for idx=1:length(imageGlassCC.PixelIdxList)
    if(imageGlassCC.PixelIdxList{idx}(1)==1)
        break;
    end
end
imageGlass(imageGlassCC.PixelIdxList{idx})=0;
% figure
% imshow(imageGlass);
idx=find(imageGlass==0);%ȡƿ���ڲ�װҺ��Ĳ���
imageBodyGray(idx)=0;
imageROI=imageBodyGray;
% figure
% imshow(imageROI);
% imageROI=imgaussfilt(imageROI);
figure
imshow(imageROI);
title('ƿ�ڲ���');
imageGasThreshold=145;%ȡ��ƿ�ڿ������֣����֣�
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

%%�ҵ�Һ��������
%%������ȡ�Ŀ������ֵ��±߽����һ��������Һ���ֱ��
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

%%������ȡ��Һ�岿�ֵ��±߽����һ��������Һ���ֱ��
sumPixels=0;
heightBottom=342;
while(sumPixels<0.5*229)
   sumPixels=sumPixels+sum(imageROI(heightBottom,:)~=0);
   heightBottom=heightBottom-1;
end
imageGray(heightBottom+138,:)=255;
figure
imshow(imageGray);
title('Һ���Ͻ�����½���');

height=heightBottom-heightLiquid;

% numBottomPixels=0;
% numBottom=max(imageBodyROI);
% while (numBottomPixels<imageBodyW)
%     numBottom=numBottom+1;
%     numBottomPixels=sum(imageBodyROI>numBottom);
% end
% heightLiquidBottom=numBottom;
% imageGray(heightLiquidBottom+138,:)=255;