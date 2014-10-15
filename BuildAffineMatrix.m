function TransformMatrix = BuildAffineMatrix(Vector,InputImage)

Theta   = Vector(1);
Phi     = Vector(2);
Psi     = Vector(3);

X = Vector(4)/InputImage.hdr.dime.pixdim(2);
Y = Vector(5)/InputImage.hdr.dime.pixdim(3);
Z = Vector(6)/InputImage.hdr.dime.pixdim(4);

xDim = InputImage.hdr.dime.dim(2);
yDim = InputImage.hdr.dime.dim(3);
zDim = InputImage.hdr.dime.dim(4);

%Move Centre to origin;
Matrix1 = [1,0,0,0;0,1,0,0;0,0,1,0;-xDim/2,-yDim/2,-zDim/2,1];
Matrix2 = [1,0,0,0;0,1,0,0;0,0,1,0;xDim/2,yDim/2,zDim/2,1];



Rot1 = [1,0,0;0,cos(Theta),-sin(Theta);0,sin(Theta),cos(Theta)];
Rot2 = [cos(Phi),0,sin(Phi);0,1,0;-sin(Phi),0,cos(Phi)];
Rot3 = [cos(Psi),-sin(Psi),0;sin(Psi),cos(Psi),0;0,0,1];

RotMatrix = Rot1*Rot2*Rot3;
PreRot = [RotMatrix,[0;0;0];[0,0,0],1];

RotMatrix = Matrix1*PreRot*Matrix2;
Translate = [1,0,0,0;0,1,0,0;0,0,1,0;X,Y,Z,1];

TransformMatrix = RotMatrix*Translate;

end