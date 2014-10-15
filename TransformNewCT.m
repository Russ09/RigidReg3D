function [ OutputImage InitImage ] = TransformNewCT( InputImage,SaveName )
%TRANSFORMNEWCT Summary of this function goes here
%   Detailed explanation goes here

OutputImage = InputImage;

if(exist('FitData.mat','file'))
    RegistrationStruct = load('FitData.mat');
else
    fprintf('Struct containing registration information (FitData.mat) is not present in the current folder');
end

Status                  = RegistrationStruct.Status;
InitialTransformation   = Status.InitialTransformation;
TransformVector         = Status.TransformVector;
Dims                    = Status.PixAdjust.NoModDims;

ImageSize = Status.PixAdjust.NMPixDims.*Dims;

Crop        = Status.SourceCrop;
CropTrue    = Crop./InputImage.hdr.dime.pixdim(2:4);

CropX = round(CropTrue(1));
CropY = round(CropTrue(2));
CropZ = round(CropTrue(3));

OutputImage.img = OutputImage.img((1+CropX):(end-CropX),(1+CropY):(end-CropY),(CropZ+1):(end-CropZ));

NewDims = ImageSize./OutputImage.hdr.dime.pixdim(2:4);
NewDims = round(NewDims);

TmpOutputImage = zeros(NewDims);
TmpOutputImage(1:size(OutputImage.img,1),1:size(OutputImage.img,2),1:size(OutputImage.img,3)) = OutputImage.img;
OutputImage.img = TmpOutputImage;
clear TmpOutputImage;

OutputImage.hdr.dime.dim(2:4)       = size(OutputImage.img);
OutputImage.hdr.dime.dim(1)         = 3;
OutputImage.hdr.dime.pixdim(1)      = 0;
OutputImage.hdr.dime.pixdim(5:8)    = [1,1,1,1];

InitialTransformation(4,1:3) = InitialTransformation(4,1:3)./InputImage.hdr.dime.pixdim(2:4);
RegTransformation = BuildAffineMatrix(TransformVector,OutputImage);
Transformation = InitialTransformation*RegTransformation;

InitImage = OutputImage;

tform           = affine3d(Transformation);
R               = imref3d(size(OutputImage.img));
OutputImage.img = imwarp(OutputImage.img,tform,'OutputView',R);

tform           = affine3d(InitialTransformation);
R               = imref3d(size(InitImage.img));
InitImage.img = imwarp(InitImage.img,tform,'OutputView',R);


if(nargin == 2)
    save_untouch_nii(OutputImage,SaveName)
end

end

