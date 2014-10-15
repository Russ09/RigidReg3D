function FixNiftiHeader( fname, folder1 )
%Opens a NIFTI file and corrects the header for use in IRTK



if(nargin<1)
    
    	[fname, folder1] = uigetfile('*.nii', 'Choose NIFTI file');
        Image = load_untouch_nii([folder1, fname]);
        
else
    cd(folder1)
    Image = load_untouch_nii(fname);
end
    

nDims = ndims(Image.img);
Image.hdr.dime.dim(1) = nDims;
Image.hdr.hist.quatern_b = 0;
Image.hdr.hist.quatern_c = 0;
Image.hdr.hist.quatern_d = 0;

Image.hdr.hist.qoffset_x = 0;
Image.hdr.hist.qoffset_y = 0;
Image.hdr.hist.qoffset_z = 0;

Image.hdr.hist.qform_code = 0;

save_untouch_nii(Image,[folder1,fname]);


end

