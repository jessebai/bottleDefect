clear;
gOrg=dicomread('iron_wire\��-002-003-004-005-006-01-015-02-1.dcm');%��ȡͼƬ
% gOrg=dicomread('��˿-ҩҺ-12.dcm');%��ȡͼƬ
se=strel('square',5);%�����ṹԪ
% gOrg=adpmedian(gOrg,3);%����Ӧ�˲�
gFilter=imbothat(gOrg,se);%��ñ�任
% gFilter=adpmedian(gFilter,3);%����Ӧ�˲�

bOrg=gOrg>16500;%ȫ����ֵ�ָ� %17000
% figure,imshow(bOrg);
bOrgcomplement=imcomplement(bOrg);
cLabelOrg=bwconncomp(bOrgcomplement);%ȡ��ͨ��
sLabelStats=regionprops(cLabelOrg,'BoundingBox');%������������С����

idxBottle=1;%ƿ������

for idxLabel=2:numel(cLabelOrg.PixelIdxList)   %0
    idxSumLabel=numel(cLabelOrg.PixelIdxList{idxLabel}(:,1));
    if(idxSumLabel==0)%%û�����idx˵����ͷ�ˣ����Խ���ѭ��
       break;
    elseif(idxSumLabel<69000)%%̫С˵������ҩƿ  %70000
       continue;
    else%%˵����ҩƿ�����濪ʼ�������
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

%% �����ָ�(filterͼ��
for i=1:idxBottle-1

%��ȡԭͼ�и�ƿ�ӣ�����Ӧ��ֵ�˲�
gSingleFilter{i}=createsamples(gFilter,nCoordinateVector(i,:));
% figure,imshow(gSingleFilter{i}),title('ԭͼ');

% gSingleFilter{i}=adpmedian(gSingleFilter{i},3);
% gSingleFilter{i}=imfilter(gSingleFilter{i},fspecial('gaussian',[3 3],1),'replicate');
gSingleFilter{i}=medfilt2(gSingleFilter{i},[3,3]);
% figure,imshow(gSingleFilter{i});

gSingleFilterAdj{i}=imadjust(gSingleFilter{i},...
    stretchlim(gSingleFilter{i},[0.75,0.96]),[0,1],1);  %0.91�������������
% gSingleFilterAdj{i}=imadjust(gSingleFilter{i},...
%     stretchlim(gSingleFilter{i},[0,1]),[0,1],1);  %0.91
% figure,imshow(gSingleFilterAdj{i});

%�������ĵ�Ѱ�ҷָ�ľ�������
%����Ѱ������
%��ȡԭͼ�и�ƿ�ӣ�����Ӧ��ֵ�˲�
gSingle=createsamples(gOrg,nCoordinateVector(i,:));
% figure,imshow(gSingle),title('ԭͼ');
gSingle=adpmedian(gSingle,3);
% figure,imshow(gSingle);

uCapLine=135;
%�и�ƿ�ǣ���ǿͼƬ
gCap=gSingle(1:uCapLine,:);
% figure,imshow(gCap);
gCapAdj=imadjust(gCap,stretchlim(gCap,[0,0.6]),[0,1],1);
% figure,imshow(gCapAdj);

%�и�ƿ����ǿͼƬ
gBottle=gSingle(uCapLine+1:size(gSingle,1),:);
% figure,imshow(gBottle);
gBottleAdj=imadjust(gBottle,stretchlim(gBottle,[0.07,0.38]),[0,1],1);
% figure,imshow(gBottleAdj);

%�ָ�ƿ���п�����ȷ��Һ�����
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

%% �ָ�����
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
% figure,imshow(bDefTotal{i}),title('ȱ��ͼ');

%% ͼ���������
uLineBottom=322;
gBottleAdj(uLineUp,:)=65535;
gBottleAdj(uLineBottom,:)=65535;

gBottleDown=gBottleAdj(uLineUp+1:size(gBottleAdj,1),:);
gBottleUp=gBottle(1:uLineUp,:);
gBottleUpAdj=imadjust(gBottleUp,stretchlim(gBottleUp,[0.1,0.6]),[0,1],1);

gTotal=cat(1,gCapAdj,gBottleUpAdj);
gTotal=cat(1,gTotal,gBottleDown);
% figure,imshow(gTotal),title('�任������ͼ');
% figure,imshow(bDefTotal{i}),title('ȱ��ͼ');

gBottleNoDef{i}=gTotal.*uint16(imcomplement(bDefTotal{i}));
% figure,imshow(gBottleNoDef{i}),title('ȥ��ȱ�ݺ��ͼ');

figure,subplot(1,3,1),imshow(gTotal),title('�任������ͼ');
subplot(1,3,2),imshow(bDefTotal{i}),title('ȱ��ͼ');
subplot(1,3,3),imshow(gBottleNoDef{i}),title('ȥ��ȱ�ݺ��ͼ');

end

% figure
% for i=1:8
%     subplot(2,12,i*3-2),imshow(gTotal),title('�任������ͼ');
%     subplot(2,12,i*3-1),imshow(bDefTotal{i}),title('ȱ��ͼ');
%     subplot(2,12,i*3),imshow(gBottleNoDef{i}),title('ȥ��ȱ�ݺ��ͼ');
% end