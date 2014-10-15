function [ OutputImage ] = TransformNewMRI( InputImage,SourceImage )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

OutputImage = InputImage;

if(exist('FitData.mat','file'))
    RegistrationStruct = load('FitData.mat');
else
    fprintf('Struct containing registration information (FitData.mat) is not present in the current folder');
end

Status                  = RegistrationStruct.Status;
Transformation          = Status.TotalTransformation;
TargetDims              = SourceImage.hdr.dime.dim(2:4);
SPixDims                = SourceImage.hdr.dime.pixdim(2:4);
TPixDims                = InputImage.hdr.dime.pixdim(2:4);

PixRatio                = SPixDims./TPixDims;

Crop        = Status.TargetCrop;
CropTrue    = Crop./InputImage.hdr.dime.pixdim(2:4);

CropX = round(CropTrue(1));
CropY = round(CropTrue(2));
CropZ = round(CropTrue(3));

TmpImage =  InputImage.img((1+CropX):(end-CropX),(1+CropY):(end-CropY),(CropZ+1):(end-CropZ));

Dims = size(TmpImage);

[x,y,z] = meshgrid(1:Dims(2),1:Dims(1),1:Dims(3));
[x1,y1,z1] = meshgrid(1:PixRatio(2):Dims(2),1:PixRatio(1):Dims(1),1:PixRatio(3):Dims(3));



TmpImage = interp3(x,y,z,TmpImage,x1,y1,z1,'nearest');

Dims = size(TmpImage);
    
% TargetDims = TargetDims - 2*Status.SourceCrop./SourceImage.hdr.dime.pixdim(2:4);    

MaxDims = max([Dims;TargetDims]);

OutputImage.img = zeros(MaxDims);
OutputImage.img(1:Dims(1),1:Dims(2),1:Dims(3)) = TmpImage;
OutputImage.hdr.dime.dim(2:4) = TargetDims;
OutputImage.hdr.dime.pixdim(2:4) = SPixDims;

end

