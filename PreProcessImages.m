function [SourceImage,TargetImage,NoModSource,NoModTarget,Status] = PreProcessImages(SourceImage,TargetImage,Status)


if(ndims(TargetImage.img)==4)
    
    TargetImage.img = (TargetImage.img(:,:,:,1)+TargetImage.img(:,:,:,2)+TargetImage.img(:,:,:,3))/3;
    TargetImage.hdr.dime.dim(5) = 1;
    TargetImage.hdr.dime.pixdim(5) = 1;
    TargetImage.hdr.dime.dim(1) = 3;
    SourceImage.hdr.dime.dim(1) = 3;
    SourceImage.hdr.dime.pixdim(5:8) = [1,1,1,1];
    TargetImage.hdr.dime.pixdim(1) = 0;
end

if(ndims(SourceImage.img)==4)
    
    SourceImage.img = (SourceImage.img(:,:,:,1)+SourceImage.img(:,:,:,2)+SourceImage.img(:,:,:,3))/3;
    SourceImage.hdr.dime.dim(5) = 1;
    SourceImage.hdr.dime.pixdim(5) = 1;
end

NoModSource = SourceImage;
NoModTarget = TargetImage;

while (prod(size(SourceImage.img)) > 500^3)
    
    SourceTmp = SubSampleImage(SourceImage,[2,2,2]);
    SourceImage = SourceTmp{1};
    clear SourceTmp;
end

while (prod(size(TargetImage.img)) > 500^3)
    
    SourceTmp = SubSampleImage(TargetImage,[2,2,2]);
    TargetImage = SourceTmp{1};
    clear SourceTmp;
end


SourceImage.img = single(SourceImage.img);
TargetImage.img = single(TargetImage.img);

SourceImage = RenormImage(SourceImage);
TargetImage = RenormImage(TargetImage);

[Isovalue, MinThresh, MaxThresh, Crop] = PreProcessGui(SourceImage,8);
Mask = (SourceImage.img > MinThresh).*(SourceImage.img < MaxThresh);
SourceImage.img = SourceImage.img.*Mask;
CropTrue = Crop./SourceImage.hdr.dime.pixdim(2:4);
CropX = round(CropTrue(1));
CropY = round(CropTrue(2));
CropZ = round(CropTrue(3));

SourceImage.img = SourceImage.img((1+CropX):(end-CropX),(1+CropY):(end-CropY),(CropZ+1):(end-CropZ));

CropTrue = Crop./NoModSource.hdr.dime.pixdim(2:4);
CropX = round(CropTrue(1));
CropY = round(CropTrue(2));
CropZ = round(CropTrue(3));

NoModSource.img = NoModSource.img((1+CropX):(end-CropX),(1+CropY):(end-CropY),(CropZ+1):(end-CropZ));
SourceImage.hdr.iso = Isovalue;
SourceImage.hdr.dime.dim(2:4) = size(SourceImage.img);
NoModSource.hdr.dime.dim(2:4) = size(NoModSource.img);

Status.SourceCrop = Crop;

[Isovalue MinThresh MaxThresh, Crop] = PreProcessGui(TargetImage,1);
TargetImage.img = TargetImage.img.*(TargetImage.img > MinThresh).*(TargetImage.img < MaxThresh);
CropTrue = Crop./TargetImage.hdr.dime.pixdim(2:4);
CropX = round(CropTrue(1));
CropY = round(CropTrue(2));
CropZ = round(CropTrue(3));

TargetImage.img = TargetImage.img((1+CropX):(end-CropX),(1+CropY):(end-CropY),(CropZ+1):(end-CropZ));

CropTrue = Crop./NoModTarget.hdr.dime.pixdim(2:4);
CropX = round(CropTrue(1));
CropY = round(CropTrue(2));
CropZ = round(CropTrue(3));

NoModTarget.img = NoModTarget.img((1+CropX):(end-CropX),(1+CropY):(end-CropY),(CropZ+1):(end-CropZ));
TargetImage.hdr.iso = Isovalue;
TargetImage.hdr.dime.dim(2:4) = size(TargetImage.img);
NoModTarget.hdr.dime.dim(2:4) = size(NoModTarget.img);

Status.TargetCrop = Crop;

SourceImage = RenormImage(SourceImage);
TargetImage = RenormImage(TargetImage);

end