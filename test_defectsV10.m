%% ʶ���ƿ��������һ�������
gOrg=dicomread('��-002-003-004-005-006-01-015-02-1.dcm');
nOrgH=size(gOrg,1);
nOrgW=size(gOrg,2);
bOrg=imbinarize(gOrg);%ȫ����ֵ�ָ�
bOrgcomplement=imcomplement(bOrg);
cLabelOrg=bwconncomp(bOrgcomplement);%ȡ��ͨ��
sLabelStats= regionprops(cLabelOrg,'BoundingBox');%������������С����

idxBottle=1;

for idxLabel=1:numel(cLabelOrg.PixelIdxList)
idxSumLabel=numel(cLabelOrg.PixelIdxList{idxLabel}(:,1));
if(idxSumLabel==0)%%û�����idx˵����ͷ�ˣ����Խ���ѭ��
   break;
elseif(idxSumLabel<70000)%%̫С˵������ҩƿ
   continue;
else%%˵����ҩƿ�����濪ʼ�������
   nCoordinateVector(idxBottle,:)=uint16(...
       sLabelStats(idxLabel).BoundingBox);
   idxBottle=idxBottle+1;
end

end

nCoordinateVector(:,3)=uint16(ones(idxBottle-1,1))*max(nCoordinateVector(:,3));
nCoordinateVector(:,4)=uint16(ones(idxBottle-1,1))*max(nCoordinateVector(:,4));

%% �����ָ�
for i=1:idxBottle-1
    
uLineBottom=314;%����֪ʶ��ƿ��λ��
%��ȡԭͼ�и�ƿ�ӣ�����Ӧ��ֵ�˲�
gSingle=createsamples(gOrg,nCoordinateVector(i,:));
% figure,imshow(gSingle),title('ԭͼ');
gSingle=adpmedian(gSingle,3);
% figure,imshow(gSingle);

%�и�ƿ�ǣ���ǿͼƬ
gCap=gSingle(1:135,:);
% figure,imshow(gCap);
% gCapAdj=imadjust(gCap,[2000/65535,11073/65535],[0,1],1);
gCapAdj=imadjust(gCap,stretchlim(gCap,[0,0.6]),[0,1],1);
% figure,imshow(gCapAdj);

%�и�ƿ����ǿͼƬ
gBottle=gSingle(136:size(gSingle,1),:);
% figure,imshow(gBottle);
% gBottleAdj=imadjust(gBottle,[6000/65535,8700/65535],[0,1],5);
gBottleAdj=imadjust(gBottle,stretchlim(gBottle,[0.07,0.38]),[0,1],1);
% figure,imshow(gBottleAdj);

%�ָ�ƿ���п�����ȷ��Һ�����
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


%�иҺ�岿�ֲ���ǿ
gLiqInOut=gBottle(uLine:size(gBottle,1),:);
% figure,imshow(gLiq);
% gLiqInOutAdj=imadjust(gLiqInOut,[6000/65535,7700/65535],[0,1],5);
gLiqInOutAdj=imadjust(gLiqInOut,stretchlim(gLiqInOut,[0.13,0.27]),[0,1],5);
% figure,imshow(gLiqInOutAdj);

%�и�Һ��
bLiqInOut=imbinarize(gLiqInOutAdj);
% figure,imshow(bLiq);
idxLiqInOut=bwlabel(bLiqInOut);
bLiq=idxLiqInOut>=2;
gLiq{i}=uint16(bLiq).*gLiqInOut;
% figure,imshow(gLiq{i});
gLiqAdj=imadjust(gLiq{i},stretchlim(gLiq{i},[0.4,0.75]),[0,1],20);
% figure,imshow(gLiqAdj);

%�ָ�����
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