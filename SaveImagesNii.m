function SaveImagesNii(OutputImage,TargetImage)

OutputImage.img = single(OutputImage.img);
OutputImage.hdr.dime.bitpix = 32;
OutputImage.hdr.dime.datatype = 16;
OutputImage.hdr.dime.dim(1) = 3;


TargetImage.img = single(TargetImage.img);
TargetImage.hdr.dime.bitpix = 32;
TargetImage.hdr.dime.datatype = 16;
TargetImage.hdr.dime.dim(1) = 3;

TargetImage.hdr.dime.glmax = max(TargetImage.img(:));
OutputImage.hdr.dime.glmax = max(OutputImage.img(:));

TargetImage.hdr.dime.glmin = min(TargetImage.img(:));
OutputImage.hdr.dime.glmin = min(OutputImage.img(:));

TargetImage.hdr.hist.quatern_b = 0;
TargetImage.hdr.hist.quatern_c = 0;
TargetImage.hdr.hist.quatern_d = 0;
TargetImage.hdr.hist.qoffset_x = 0;
TargetImage.hdr.hist.qoffset_y = 0;
TargetImage.hdr.hist.qoffset_z = 0;
TargetImage.hdr.hist.qform_code = 0;

OutputImage.hdr.hist.quatern_b = 0;
OutputImage.hdr.hist.quatern_c = 0;
OutputImage.hdr.hist.quatern_d = 0;
OutputImage.hdr.hist.qoffset_x = 0;
OutputImage.hdr.hist.qoffset_y = 0;
OutputImage.hdr.hist.qoffset_z = 0;

if(exist('RegisteredImage.nii','file'))
    delete('RegisteredImage.nii');
end

if(exist('TargetImage.nii','file'))
    delete('TargetImage.nii');
end

save_untouch_nii(OutputImage,'RegisteredImage.nii');
save_untouch_nii(TargetImage,'TargetImage.nii');


end