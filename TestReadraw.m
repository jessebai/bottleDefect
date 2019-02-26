sDarkFname='raw/dark-avg-int-g6.raw';
sRadFname='raw/rad-avg-int-g6.raw';
uDistance=65536;
uRow=2048;
uCol=2560;
dDark=readraw(sDarkFname,0,uRow,uCol);
uDark=uint16(dDark);
uDarkHistadj=histeq(uDark);
figure,imshow(uDarkHistadj),title('暗场图');

dRad=readraw(sRadFname,0,uRow,uCol);
uRad=uint16(dRad);
uRadHistadj=histeq(uRad);
figure,imshow(uRadHistadj),title('增益图');

uDefect=uRadHistadj-uDarkHistadj;
figure,imshow(uDefect),title('增益减暗场图');