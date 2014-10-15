function [ReturnImages] = SubSampleImageNew(InputImage,nSubSamples)

bUseFullRes = 0;

InputDims = size(InputImage.img);
ImageSize = InputImage.hdr.dime.dim(2:4).*InputImage.hdr.dime.pixdim(2:4)

    for iI = 1:nSubSamples

            ReturnImages{iI} = InputImage;
        if(iI == 1)
            
            if(bUseFullRes)
                ReturnImages{iI}.img = InputImage.img;
            else
                ReturnImages{iI}.img = GPReduce(InputImage.img);
            end
        else
            ReturnImages{iI}.img = GPReduce(ReturnImages{iI - 1}.img);
        end
        
        ReturnDims = size(ReturnImages{iI}.img);
        ReturnImages{iI}.hdr.dime.dim(2:4) = ReturnDims;
        
        ReturnImages{iI}.hdr.dime.pixdim(2:4) = ImageSize./ReturnDims;
    end

end
