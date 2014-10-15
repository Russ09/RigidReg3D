function [ReturnImages] = SubSampleImage(InputImage,SubMatrix)

nImages = size(SubMatrix,1);

InputDims = size(InputImage.img);
Gauss = normpdf(-1:1,0,1);
Gauss2 = convn(Gauss,Gauss');
Gauss3(1,1,:) = Gauss;
Gauss3D = convn(Gauss2,Gauss3);
Gauss3D = Gauss3D./sum(Gauss3D(:));

BlurImage = convn(InputImage.img,Gauss3D,'same');

for iI = 1:nImages
    
    ReturnDims = round(InputDims./SubMatrix(iI,:));

    ReturnImages{iI} = InputImage;
    ReturnImages{iI}.img = zeros(ReturnDims);

    ReturnImages{iI}.hdr.dime.dim(2:4) = ReturnDims';
    ReturnImages{iI}.hdr.dime.pixdim(2:4) = InputImage.hdr.dime.pixdim(2:4).*SubMatrix(iI,:);

    ReturnImages{iI}.img = BlurImage(1:SubMatrix(iI,1):end,1:SubMatrix(iI,2):end,1:SubMatrix(iI,3):end);
    
end

end
