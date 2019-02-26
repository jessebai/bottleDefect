clear
imageOrig=imread('test_single1_mod.bmp');
imageGray=rgb2gray(imageOrig);
imageGray=imgaussfilt(imageGray);
figure
imshow(imageGray);
title('ԭͼ');
imageBW = imbinarize(imageGray);%%ȫ����ֵ
% figure
% imshow(imageBW);
imageCC=bwconncomp(imageBW);%%ȡ��ͨ��

%%
%%������ȡҩƿ�м����ͨ��

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
%%ԭͼ�зָ��ҩƿ�м�һ��
idx=find(imageBW==0);
imageGrayROI=imageGray;
% imageGrayROI(idx)=130;%ע�������ɫ��Ҫ��ȥ���Ĳ�����ɫ��ȱ����ɫ��һ�� %�����⣬�������沽����΢�鷳һ��
imageGrayROI(idx)=0;
% figure
% imshow(imageGrayROI);

%%
%%�ָ��ȱ��
imageDefectsROI=imbinarize(imageGrayROI,'adaptive','ForegroundPolarity','dark','Sensitivity',0.54);
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
imageGray(imageDefects)=0;
figure
imshow(imageGray);
title('����ȱ�ݺ��ҩƿͼ');

