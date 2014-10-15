function Image = RenormImage(Image)

Min = min(Image.img(:));

Max = max(Image.img(:));

Range = double(Max - Min);

Image.img = (Image.img - Min)*(100/Range);

if isfield(Image.hdr,'iso')
%     Image.hdr.iso = (Image.hdr.iso-Min)*(100/Range);
end

Image.hdr.dime.glmax = Max;
Image.hdr.dime.glmin = Min;

end