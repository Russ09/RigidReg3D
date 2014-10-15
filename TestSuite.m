% 
% % 
% clear A B
% tmp1 = SubSampleImage(ctinput,[4,4,4]);
% tmp2 = SubSampleImage(dceinput,[2,2,2]);
% [A{1},B{1}] = PixelAdjust(tmp1{1},tmp2{1});
% 
% 
% % 
% % close
% 
% FinalVec = [-1.6449,    1.7984-2*pi/10,    0.1854,  -15.0553+6,    4.8133-3,   14.9795]
% 
% % Source1 = ImageTransform(A{1},[-pi/2,5*pi/8,0,-15,3,15]);
% Source1 = ImageTransform(A{1},FinalVec);
% 
% 
%     
%     
% SMin = min(B{1}.img(:));
% TMin = min(Source1.img(:));
% 
% SMax = max(B{1}.img(:));
% TMax = max(Source1.img(:));
% 
% B{1}.img = (B{1}.img - SMin+1)*(100/(SMax-SMin));
% Source1.img = (Source1.img - TMin+1)*(100/(TMax-TMin));
% tmp = zeros(size(Source1.img));
% tmp(35:end-34,35:end-34,35:end-34) = Source1.img(35:end-34,35:end-34,35:end-34);
% Source1.img = tmp;
% 
% Source1.img = Source1.img.*(Source1.img > 40).*(Source1.img < 60);  
% dims = size(Source1.img);
% 
% close
% subplot(131);
% h2 = patch(isosurface(B{1}.img,40));
% lighting none
% set(h2,'EdgeColor','none','FaceColor',[0,1,0]);
% alpha(h2,0.1);
% axis([1,dims(1),1,dims(2),1,dims(3)]);
% axis equal
% camlight;
%     xlabel('xaxis');
%     ylabel('yaxis');
%     zlabel('zaxis');
% view(135,27);
% subplot(132);
% h = patch(isosurface(Source1.img,40));
% set(h,'EdgeColor','none','FaceColor',[1,0,0]);
% alpha(h,0.1);
% lighting none
% axis([1,dims(1),1,dims(2),1,dims(3)]);
% axis equal
% camlight;
%     xlabel('xaxis');
%     ylabel('yaxis');
%     zlabel('zaxis');
% view(135,27);
% 
% subplot(133);
% h = patch(isosurface(Source1.img,50));
% h2 = patch(isosurface(B{1}.img,50));
% set(h,'EdgeColor',[0,0,1],'FaceColor',[0,0,1]);
% set(h2,'EdgeColor',[1,0,0],'FaceColor',[1,0,0]);
% alpha(h2,0.1);
% alpha(h,0.1);
% lighting none
% axis([1,dims(1),1,dims(2),1,dims(3)]);
% axis equal
% 
% camlight;
%     xlabel('xaxis');
%     ylabel('yaxis');
%     zlabel('zaxis');
% view(135,27);


% Make Rotating model
% 
tmp1 = SubSampleImage(ctinput,[8,8,8]);
tmp2 = SubSampleImage(dceinput,[2,2,2]);

    SourceImage = tmp1{1}
    TargetImage = tmp2{1}
    %Transform = [-1.7571    2.0698    0.2078  -17.2738    5.0313   14.2256]; Good Fit1
    Transform = [-1.6917    2.0750    0.2038  -17.8003    5.4200   14.1356];
    
    
    SMin = min(SourceImage.img(:));
    TMin = min(TargetImage.img(:));

    SMax = max(SourceImage.img(:));
    TMax = max(TargetImage.img(:));

    SourceImage.img = (SourceImage.img - SMin+1)*(100/(SMax-SMin));
    TargetImage.img = (TargetImage.img - TMin+1)*(100/(TMax-TMin));

    SourceImage.img = SourceImage.img.*(SourceImage.img > 50);
    
    tmp = zeros(size(SourceImage.img));
    tmp(20:end-20,20:end-20,5:end-5) = SourceImage.img(20:end-20,20:end-20,5:end-5);
    SourceImage.img = tmp;
    
    [SourceImage, TargetImage] = PixelAdjust(SourceImage,TargetImage);
    
    Test = ImageTransform(SourceImage,Transform);
    Target = TargetImage;
    

for iR = 1:5:360
    
close all
figure(1)
set(1, 'Position', [100, 100, 1049, 895]);
dims = size(Test.img);
h2 = patch(isosurface(permute(Test.img,[2,3,1]),30));
pause(0.1);
% waitfor(h2)
h = patch(isosurface(permute(Target.img,[2,3,1]),10));
pause(0.1)
% waitfor(h)
set(h2,'EdgeColor','none','FaceColor',[0,1,0]);
set(h,'EdgeColor','none','FaceColor',[1,0,0]);
alpha(h,0.1);
alpha(h2,0.1);
lighting gouraud;
axis equal
camlight;
    xlabel('xaxis');
    ylabel('yaxis');
    zlabel('zaxis');
view(iR,15);
pause(1);


     if iR == 1;
              writerObj = VideoWriter('FitRotate2.avi');
              open(writerObj);
              frame = getframe(1);
              writeVideo(writerObj,frame);
      else
              frame = getframe(1);
              writeVideo(writerObj,frame);
     end
      
     
end

close(writerObj);

TV = [-1.7926235   2.2304897   0.3716238 -19.1878052   7.0699005  13.2041578];
IsoPlot(tmp1{1},ImageTransform(tmp2{1},TV));

for iR = 1:1:360
    h = figure
    h2 = axes
    set(h,'Position', [100, 100, 1049, 895]);
%     set(1, 'view',[iR,15])
    view(h2,iR,15);
         if iR == 1;
              writerObj = VideoWriter('FitRotate3.avi');
              open(writerObj);
              frame = getframe(h);
              writeVideo(writerObj,frame);
        else
              frame = getframe(h);
              writeVideo(writerObj,frame);
        end
    
    
    
end

close(writerObj);




