function f=createsamples(g,nCoordinate)
%% ����������,����ԭ����ͼ��ĳ��ƿ�����Ͻ�����Ϳ�ȸ߶ȣ����ת��ͼ��

%��ȡԭͼ
gOrg=g;
% figure,imshow(gOrg);

% %����һ��ƿ�����ϽǺ����½������˵�,ͼ�Ĵ�СΪ465*211
% % nCoordinateY1=[625,1796];
% % nCoordinateX1=[415,1332];
% nCoordinateX1=[nCoordinateY1(1)-210,nCoordinateY1(2)-464];
nCoordinateX1=nCoordinate(1:2);
nCoordinateY1(1)=nCoordinateX1(1)+nCoordinate(3);
nCoordinateY1(2)=nCoordinateX1(2)+nCoordinate(4);

%�ָ�һ��ƿ��
f=gOrg(nCoordinateX1(2)-5:nCoordinateY1(2)+5,...
    (nCoordinateX1(1)-5):(nCoordinateY1(1)+5));
% figure,imshow(gOrg1);

% %�ָ�һ��ƿ��
% gOrg1=gOrg(nCoordinateX1(2)-5:nCoordinateY1(2)+5,...
%     (nCoordinateX1(1)-5):(nCoordinateY1(1)+5));
% % figure,imshow(gOrg1);
% 
% %��ֵ����ƿ��
% bBot1=imbinarize(gOrg1);
% bBot1Complement=imcomplement(bBot1);
% % figure,imshow(bBot1Complement);
% 
% %�ҵ�ƿ�ӵ���������
% % bBdrs=bwboundaries(bBot1Complement);
% bBdrsTotal1=bwperim(bBot1Complement);
% %ȷ�������ƿ�ӵı�Ե����
% nHeight1=size(bBot1,1);
% nWidth1=size(bBot1,2);
% % [idxLeftLineX1,idxLeftLineY1]=find(bBdrs{1}(:,1)>nHeight1*0.4&...
% %     bBdrs{1}(:,1)<nHeight1*0.7&bBdrs{1}(:,2)<0.5*nWidth1);
% bBdrsLine1=bBdrsTotal1(uint16(0.3*nHeight1):uint16(0.8*nHeight1),...
%     1:uint16(0.2*nWidth1));
% [houghBdrsLine1,thetaBdrsLine1,rhoBdrsLine1]=hough(bBdrsLine1);
% uPeaks1=houghpeaks(houghBdrsLine1,1);
% sLines1=houghlines(bBdrsLine1,thetaBdrsLine1,rhoBdrsLine1,uPeaks1);
% 
% %���ߵĽǶȽ�����ת
% dTransTheta=affine2d([cos(-sLines1.theta/180*pi) sin(-sLines1.theta/180*pi) 0;
%     -sin(-sLines1.theta/180*pi) cos(-sLines1.theta/180*pi) 0;
%     0 0 1]);
% f=imwarp(gOrg1,dTransTheta,'FillValues',30000);
end