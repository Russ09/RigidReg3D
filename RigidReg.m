function [ Transformation, OutputImage ] = RigidReg( SourceImage, TargetImage )
%Performs rigid registration of SourceImage to TargetImage using Mutual
%Information similarity measure.
%   Inputs   - SourceImage - Nifti Struct - Image to register
%            - TargetImage - Nifti Struct - Image to be registered to
%
%   Outputs  - DeformationField
%            - OutputImage

bMakeMovie = 0;

%Initial Transformation -  Rough rotation/translation for overlap
SMax = max(SourceImage.img(:)); 
TMax = max(TargetImage.img(:));

TransformVector = [0,0,0]; %Rotate, X-translate, Y-translate;

SourceImage.img = SourceImage.img.*(SourceImage.img > SMax/4);

TargetImage.img = TargetImage.img.*(TargetImage.img > SMax/4);

[SourceImage] = InitialTransform(SourceImage, TargetImage);

[SourceImage] = ImageRotate(SourceImage,10);

% [SourceImage] = ImageRotate(SourceImage,pi/2);
subplot(2,2,3);
imagesc(SourceImage.img + TargetImage.img);
pause(0.1);

Transformation = [1,0,0,0;...
                  0,1,0,0;...
                  0,0,1,0];
              
              Similarity = 0;
              Threshold = 100;

Similarity = ComputeSimilarity(SourceImage,TargetImage,TransformVector)
iter = 0;
              
while(Similarity < Threshold)
    
    [TransformVector] = OptimizeSimilarity(SourceImage, TargetImage, TransformVector);
    
    Similarity = ComputeSimilarity(SourceImage,TargetImage,TransformVector)
    iter = iter + 1 ;
    fprintf('Iteration %d completed',iter);
    
    [TestImage] = UpdateSourceImage(SourceImage, TransformVector);    
    subplot(2,2,4);
    imagesc(TestImage.img + TargetImage.img);
    pause(0.1);
    
    if(bMakeMovie)
        
      
      if iter == 1;
          writerObj = VideoWriter('regmovie.avi');
          open(writerObj);
          frame = getframe(1);
          writeVideo(writerObj,frame);
      else
          frame = getframe(1);
          writeVideo(writerObj,frame);
      end
        
        
    end

end
close(writerObj)

end


function [Similarity] = ComputeSimilarity(SourceImage,TargetImage,TransformVector)
%   Mutual Information Similarity Metric
bSelfImplementation = 0;

SourceImage = ImageTranslate(SourceImage,TransformVector(2:3));
SourceImage = ImageRotate(SourceImage,TransformVector(1));

Source = double(floor(SourceImage.img));
Target = double(floor(TargetImage.img));

Source = Source - min(Source(:)) + 1;
Target = Target - min(Target(:)) + 1;

if(bSelfImplementation)


Images(:,1) = Source(:);
Images(:,2) = Target(:);

HJoint = accumarray(Images,1);

HJointNorm = HJoint./sum(HJoint(:));

SourceMarginal = sum(HJointNorm,2);
TargetMarginal = sum(HJointNorm,1);

SourceEntropy = -sum(SourceMarginal.*log2(SourceMarginal + (SourceMarginal == 0)));
TargetEntropy = -sum(TargetMarginal.*log2(TargetMarginal + (TargetMarginal == 0)));

JointArg = HJointNorm.*log2(HJointNorm + (HJointNorm == 0));
JointEntropy = -sum(JointArg(:));

% Similarity = SourceEntropy + TargetEntropy - JointEntropy; %Mutual Information

Similarity = (SourceEntropy + TargetEntropy)/JointEntropy; %Normalised Mutual Information
else
    Target = ceil((126/max(Target(:)).*Target));
    Source = ceil((126/max(Source(:)).*Source));
    
    Similarity = ent(Source,Target,size(Source))
end

end

function [TransformVector] = OptimizeSimilarity(SourceImage, TargetImage,TransformVector)
%Gradient Descent for optimizing the Mutual Information Similarity Metric
xDelta = 5;
yDelta = 5;
thetaDelta = 5;

Deltas = [thetaDelta;xDelta;yDelta];

TVec = TransformVector;
SimRotPlus  = ComputeSimilarity(SourceImage,TargetImage,TransformVector + [thetaDelta,0,0]);
SimRotMinus = ComputeSimilarity(SourceImage,TargetImage,TransformVector + [-thetaDelta,0,0]);

SimXPlus    = ComputeSimilarity(SourceImage,TargetImage,TransformVector + [0,xDelta,0]);
SimXMinus    = ComputeSimilarity(SourceImage,TargetImage,TransformVector + [0,-xDelta,0]);

SimYPlus    = ComputeSimilarity(SourceImage,TargetImage,TransformVector + [0,0,yDelta]);
SimYMinus    = ComputeSimilarity(SourceImage,TargetImage,TransformVector + [0,0,-yDelta]);

Weight = [20;50;50];
Grad = [SimRotPlus - SimRotMinus; SimXPlus - SimXMinus; SimYPlus - SimYMinus]./(2*Deltas);

TransformVector = TransformVector + Weight'.*Grad';

end

function [ReturnImage] = ImageTranslate(InputImage,Vector)

bSelfImplement = 0;


if (bSelfImplement)
    ResampleImage = zeros(size(InputImage.img));

    for iX = 1:size(ResampleImage,1)

        for iY = 1:size(ResampleImage,2)
            InRange     = iX + Vector(1) < size(InputImage.img,1)&&...
                        iX + Vector(1) >= 1&&...
                        iY + Vector(2) < size(InputImage.img,2)&&...
                        iY + Vector(2) >= 1;
            if (InRange)
                ResampleImage(iX,iY) = interpn(InputImage.img,iX+Vector(1),iY + Vector(2));
            end

        end
    end

    ReturnImage = InputImage;
    ReturnImage.img = ResampleImage;
else
    ReturnImage = InputImage;
    tform = maketform('affine',[1,0,0;0,1,0;Vector(1),Vector(2),1]);
    A = ReturnImage.img;
    ReturnImage.img = imtransform(A,tform,'XData',[1 size(A,2)],'YData',[1 size(A,1)]);
end

end

function [ReturnImage] = ImageRotate(InputImage, Theta)

bSelfImplement = 0;

if(bSelfImplement)
    Sizes = size(InputImage.img);

    MidShift = -Sizes./2;
    ResampleImage = zeros(size(InputImage.img));

    RotationMatrix = [cos(Theta),-sin(Theta);sin(Theta),cos(Theta)];

    for iX = 1:size(ResampleImage,1)

        for iY = 1:size(ResampleImage,2)

            Coords = [iX,iY] + MidShift;
            Coords = RotationMatrix\Coords';
            Coords = Coords' - MidShift;

            InRange     = Coords(1) < size(InputImage.img,1)&&...
                          Coords(1) >= 1.0&&...
                          Coords(2) < size(InputImage.img,2)&&...
                          Coords(2) >= 1.0;
            if (InRange)
                ResampleImage(iX,iY) = interpn(InputImage.img,Coords(1),Coords(2));
            end

        end
    end

    ReturnImage = InputImage;

    ReturnImage.img = ResampleImage;
else
    ReturnImage = InputImage;

    ReturnImage.img = imrotate(InputImage.img,Theta,'crop');
end

end

function ReturnImage = UpdateSourceImage(SourceImage,TransformVector)

ReturnImage = ImageTranslate(SourceImage,TransformVector(2:3));
ReturnImage = ImageRotate(ReturnImage,TransformVector(1));

end

function [SourceImage] = InitialTransform(SourceImage,TargetImage)

close all

subplot(2,2,1)
imagesc(TargetImage.img);
[x,y] = ginput(1);
subplot(2,2,2)
imagesc(SourceImage.img);
[x2,y2] = ginput(1);

Vector = [x-x2,y-y2];
Vector = floor(Vector);

% ResampleImage = zeros(size(TargetImage.img));
% 
% for iX = 1:size(ResampleImage,1)
%     
%     for iY = 1:size(ResampleImage,2)
%         InRange     = iX + Vector(1) < size(SourceImage.img,1)&&...
%                     iX + Vector(1) > 0&&...
%                     iY + Vector(2) < size(SourceImage.img,2)&&...
%                     iY + Vector(2) > 0;
%         if (InRange)
%             ResampleImage(iX,iY) = SourceImage.img(iX+Vector(1),iY + Vector(2));
%         end
%         
%     end
% end

    tform = maketform('affine',[1,0,0;0,1,0;Vector(1),Vector(2),1]);
    A = SourceImage.img;
    ResampleImage = imtransform(A,tform,'XData',[1 size(A,2)],'YData',[1 size(A,1)]);

subplot(2,2,3)
imagesc(ResampleImage);

SourceImage.img = ResampleImage;

end