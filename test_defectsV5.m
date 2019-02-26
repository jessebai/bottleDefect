%%
uLineBottom=314;%����֪ʶ��ƿ��λ��
%��ȡԭͼ����������֪ʶ�и���ڶ���ƿ�ӣ�������Ӧ��ֵ�˲�
gOrg=dicomread('��-002-003-004-005-006-01-015-02-1.dcm');
nCoordinateVector=[626 1804;862 1804;1077 1804;1300 1804;...
    1507 1804;1725 1804;1923 1804;2121 1804];
gSingle=createsamples(gOrg,nCoordinateVector(1,:));
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
gLiq=uint16(bLiq).*gLiqInOut;
% figure,imshow(gLiq);
gLiqAdj=imadjust(gLiq,stretchlim(gLiq,[0.4,0.8]),[0,1],30);
% figure,imshow(gLiqAdj);

%����Ӧ�ָ����ʲ���̬ѧ����
bLiqDef=imbinarize(gLiqAdj,'adaptive','Sensitivity',1);
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


%�Դ���ͼ�������Ӻ���ʾ
gBottleAdj(uLine,:)=65535;
gBottleAdj(uLineBottom,:)=65535;
gTotal=cat(1,gCapAdj,gBottleAdj);
figure,imshow(gTotal),title('�任������ͼ');

bDefTotal=cat(1,zeros(size(gCap,1)+uLine-1,size(gBottleAdj,2)),bDef);
gDefTotal=uint16(double(gTotal).*bDefTotal);
figure,imshow(gDefTotal),title('ȱ��ͼ');
bDefTotalComplement=imcomplement(bDefTotal);
gDefTotalComplement=gTotal.*uint16(bDefTotalComplement);
figure,imshow(gDefTotalComplement),title('ȥ��ȱ�ݺ��ͼ');