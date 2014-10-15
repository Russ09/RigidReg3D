function [ Transformation, TargetImage, OutputImage, Status ] = RigidReg3D( SourceImage, TargetImage )
%Performs rigid registration of SourceImage to TargetImage using Mutual
%Information similarity measure.
%   Inputs   - SourceImage - Nifti Struct - Image to register
%            - TargetImage - Nifti Struct - Image to be registered to
%
%   Outputs  - DeformationField
%            - OutputImage

if(numel(varargin) < 2)

    [fname, folder1] = uigetfile('*.nii', 'Open Source image (CT)');
    SourceImage = load_untouch_nii([folder1, fname]);

    [fname, folder1] = uigetfile([folder1, '*.nii'], 'Open Target image (DCE)');
    TargetImage = load_untouch_nii([folder1, fname]);

end

bMakeMovie = 0;
bMultiRes = 1;
iter = 1;
MaxRes = 1;
bFitVideo = 1;
bClickInit = 1;
bPreProcess = 1;
bIsoPlot = 1;

%   Number of subsampled images should be used for a multiresolution
%   registration. MaxRes 3 -> Original, subsampled by 2 and subsampled by
%   4.
MaxRes = 2;

%   Number of gradient descent step-sizes to iterate on to convergence
%   before increasing resolution.
MaxStep = 3;



[StepSize Deltas Status] = InitializeParameters(MaxRes,MaxStep);

if(bPreProcess)
    %   Brings up GUI which allows user to crop and threshold the volumes
    %   separately. Also downsamples volumes that are too large for
    %   registration and will turn 4D DCE-MRI volumes into a single 3D
    %   volume for the purpose of registration.
    [SourceImage,TargetImage,NoModSource,NoModTarget,Status] = PreProcessImages(SourceImage,TargetImage,Status);
end

%   Resamples the lower resolution image such that both image volumes have
%   the same pixel dimensions. Volumes are also padded such that both
%   volumes have the same size in world coordinates
[SourceImage, TargetImage, NoModSource, NoModTarget,Status] = PixelAdjust(SourceImage,TargetImage,NoModSource,NoModTarget,Status);

if (bClickInit)
    %   Brings up GUI which allows user to initialise the alignment by
    %   clicking 3 landmarks onto each volume. These landmarks should
    %   correspond between the two volumee.
    [SourceImage,Status] = ClickInitialize(SourceImage,TargetImage,Status);
    
end

if (bMultiRes)
    %   Both volumes are subsampled by powers of two (MaxRes - 1) times.
    Sources = SubSampleImageNew(SourceImage,MaxRes);
    Targets = SubSampleImageNew(TargetImage,MaxRes);
    
end

Source = Sources{Status.Res};
Target = Targets{Status.Res};
   
TransformVector = [0,0,0,0,0,0];

Status.Similarity = ComputeSimilarity(Source,Target,TransformVector,Status)

bStop =0;
              
while(bStop == 0)
       
    %   Increase Image Resolution
    if ((Status.bNoMove == 1 && Status.Res > 1 && Status.StepLevel == 1) || (Status.Res > 1 && Status.bNoGrad == 1))
        Status.Res = Status.Res - 1;
        Status.StepLevel = Status.MaxStep;
        Status.StepSize = StepSize;
        StepDown = 0.5;
        Status.Deltas = Status.Deltas*StepDown;
        Source = Sources{Status.Res};
        Target = Targets{Status.Res};
        Status.Similarity = ComputeSimilarity(Source,Target,TransformVector,Status);
        fprintf('Increasing Resolution\n');
        [TestImage,Status] = UpdateSourceImage(Source, TransformVector,Status);   
        close all
        figure(2)
        IsoPlot(TestImage,Target)
    end
   
    [TransformVector Status] = OptimizeSimilarity(Source, Target, TransformVector,Status);
    
    iter = iter + 1 ;
    
    Status.SimHistory(iter) = Status.Similarity;
    if (Status.SimHistory(iter)> Status.SimHistory(iter-1))
        Status.Increase(iter) = 1;
    else
        Status.Increase(iter) = -1;
    end
    
    fprintf('Iteration %d completed\n',iter);
    
    [TestImage,Status] = UpdateSourceImage(Source, TransformVector,Status);    

    sizeIn = size(TestImage.img);
    pic = double(TestImage.img + Target.img);

    
    if (bIsoPlot)        
        IsoPlot(TestImage,Target)
    end
    
    if(bMakeMovie)

        if iter == 2;
              writerObj = VideoWriter('FitMovie3.avi');
              open(writerObj);
              frame = getframe(2);
              writeVideo(writerObj,frame);
          else
              frame = getframe(2);
              writeVideo(writerObj,frame);
          end

    end
    
    if(Status.Res ==1 && Status.StepLevel == 1&& Status.bNoMove == 1)
        bStop = 1
    end
    
    if(Status.bConverged == 1 && Status.Res == 1);
        bStop = 1;
    end
    
end

Transformation1 = Status.InitialTransformation;
Transformation1(4,1:3) = Transformation1(4,1:3)./NoModSource.hdr.dime.pixdim(2:4);
Transformation2 = BuildAffineMatrix(TransformVector,NoModSource);
Status.RegTransformation = Transformation2;

Transformation = Transformation1*Transformation2;

OutputImage = NoModSource;
tform = affine3d(Transformation);
R = imref3d(size(NoModSource.img));
OutputImage.img = imwarp(NoModSource.img,tform,'OutputView',R);
TargetImage = NoModTarget;
Status.TotalTransformation = Transformation;
Status.TransformVector = TransformVector;

% SaveImagesNii(OutputImage,TargetImage);

FileName = 'FitDataBadInit.mat'

if(exist(FileName,'file'))
    delete(FileName);
end
save(FileName,'Transformation','OutputImage','TargetImage','Status');

% if(bFitVideo)
%     MakeFitMovie(Source,Target,TransformVector,'FitMovie');
% end
    

end


function [Similarity] = ComputeSimilarity(SourceImage,TargetImage,TransformVector,Status)
%   Mutual Information Similarity Metric
bSelfImplementation = 1;
bLargeVolume = Status.bLargeVolume;

SourceImage = ImageTransform(SourceImage,TransformVector);

Source = double(floor(SourceImage.img));
Target = double(floor(TargetImage.img));

Source = Source - min(Source(:)) + 1;
Target = Target - min(Target(:)) + 1;


Method = 'MIND';

switch Method
    
    case 'SSD'
    
    Source = Source > 8;
    Target = Target > 8;
    Similarity = -sum((Source(:) - Target(:)).^2);
    
    case 'MI'

        if(bSelfImplementation)

        %         Pix = size(Target,1);

                Pix = 100;

            Target = ceil(((Pix-2)/max(Target(:)).*Target));
            Source = ceil(((Pix-2)/max(Source(:)).*Source));

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

        Similarity = SourceEntropy + TargetEntropy - JointEntropy; %Mutual Information

    %     Similarity = (SourceEntropy + TargetEntropy)/JointEntropy; %Normalised Mutual Information

        else
            Pix = size(Target,1);

            Target = ceil(((Pix-2)/max(Target(:)).*Target));
            Source = ceil(((Pix-2)/max(Source(:)).*Source));

            Similarity = ent(Source,Target,size(Source));
        end
    
    case 'MIND'
        
        mind1 = MIND_descriptor(Target,0,2);
        mind2 = MIND_descriptor(Source,0,2);
        
        if(~bLargeVolume)
            Similarity = -sum((mind1(:) - mind2(:)).^2);
            if(Similarity == -Inf)
                bLargeVolume = 1;
            end
        end
        
        if(bLargeVolume)
            
            for iD = 1:size(mind1,4)
                mindv1 = mind1(:,:,:,iD);
                mindv2 = mind2(:,:,:,iD);
                Similarity = -sum((mindv1(:) - mindv2(:)).^2);
            end
        
        end
        
        Status.bLargeVolume = bLargeVolume
        



end

Similarity = double(Similarity);
end


function [TransformVector Status] = OptimizeSimilarity(SourceImage, TargetImage,TransformVector,Status)
%Gradient Descent for optimizing the Mutual Information Similarity Metric

thetaDelta = Status.Deltas(1);
phiDelta = Status.Deltas(2);
psiDelta = Status.Deltas(3);
xDelta = Status.Deltas(4);
yDelta = Status.Deltas(5);
zDelta = Status.Deltas(6);


Status.bNoMove = 0;
Status.bNoGrad = 0;
Status.bOscillation = 0;

Status.Iter = Status.Iter + 1;
CurrentSim = Status.Similarity;

Iter = Status.Iter;
if Status.Iter>6
    IncreaseSum = sum(Status.Increase((Iter-4):Iter-1));
    if (IncreaseSum < 2 && Status.StepLevel > 1)
        Status.bNoMove = 1;
        Status.bOscillation = 1;
    end
   
end

if((Status.Iter > 6 && IncreaseSum < 2 && Status.StepLevel > 1)||Status.bNoMove)
    Status.StepLevel = Status.StepLevel - 1;
    Status.Increase(1:Iter-1) = ones(1,Iter-1);
    Status.StepSize = Status.StepSize*0.5;
    if(Status.bOscillation)
        fprintf('Dropping step size due to oscillation\n');
    else
        fprintf('Dropping step size due to no movement\n');
    end
end

Deltas = [thetaDelta;phiDelta;psiDelta;xDelta;yDelta;zDelta];
StepSize = Status.StepSize;


bGradDescent = 0;


if (0)
    Status.bNoMove = 1;
    TempSimilarity = 0;
    Move = zeros(1,6);
    Status.bNoGrad = 1;
else
    if(bGradDescent)
        Move = StepSize'.*(Grad/norm(Grad))';
    else
%         Hessian = Hessian;
%         InvHessGrad = inv(Hessian)*Gradient'
%         Move = StepSize'.*InvHessGrad'
            Move = ComputeGaussNewtonMove(SourceImage,TargetImage,TransformVector,Deltas);
            Move = Move.*StepSize'
    end
    [TempSimilarity] = ComputeSimilarity(SourceImage,TargetImage,TransformVector + Move,Status)
    Status.Similarity
end


if (TempSimilarity > Status.Similarity)
    
        TransformVector = TransformVector + Move;
        Status.Transform = TransformVector;
        Status.Similarity = TempSimilarity;
        TempSimilarity;
else
        Status.bNoMove = 1;
end



%   Oscillation Diagnostics
Status.Move(Iter,:) = Move;
Status.MoveNorm(Iter) = norm(Move);
Status.Angle(Iter) = abs(dot(Move,Status.Move(Iter-1,:))/(norm(Move)*norm(Status.MoveNorm(Iter-1))));
Status.StepNorm(Iter) = norm(Move - Status.Move(Iter-1,:));

TransformVector

if(norm(Move) < 0.005)
    if(Status.Res == 1)
        Status.bConverged = 1;
    end
    Status.bNoMove = 1;
end

end


function [ReturnImage,Status] = UpdateSourceImage(SourceImage,TransformVector,Status)

ReturnImage = ImageTransform(SourceImage,TransformVector);

TransformMatrix = BuildAffineMatrix(TransformVector,SourceImage);
TransformMatrix(4,1:3) = TransformMatrix(4,1:3).*SourceImage.hdr.dime.pixdim(2:4);

% Status.Transformation = Status.Transformation*TransformMatrix;

end


function [Move] = ComputeGaussNewtonMove(SourceImage,TargetImage,TransformVector,Deltas)

DiagD = diag(Deltas);
Transformed1 = ImageTransform(SourceImage,TransformVector);
mind1 = MIND_descriptor(single(TargetImage.img),0,2);
mind2 = MIND_descriptor(single(Transformed1.img),0,2);
Similarity1 = (mind1(:) - mind2(:));


    for iI = 1:6
            Transformed2 = ImageTransform(SourceImage,TransformVector + DiagD(iI,:));
            mind3 = MIND_descriptor(single(Transformed2.img),0,2);
            
            Similarity2 = (mind1(:) - mind3(:)).^2;

            Jacobian(:,iI) = (mind3(:) - mind2(:))./Deltas(iI);
    end
    A = 2*(Jacobian'*Jacobian);
    b = Jacobian'*Similarity1;
    
    Step = A\b;
    
    Move = Step';

end