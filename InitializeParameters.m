function [StepSize Deltas Status] = InitialiseParameters(MaxRes,MaxStep)

% StepSize = [0.1;0.1;0.1;0.5;0.5;0.5]/2;  Works Well   Similarity 1.0168
StepSize = [1,1,1,1,1,1]'*2; %Similarity = 1.0172
Deltas = [1,1,1,1,1,1]/100;

Status.Iter = 1;
Status.Move(1,:) = [0,0,0,0,0,0];
Status.MoveNorm(1) = 1;
Status.Angle(1) = 0;
Status.FlipCount = 0;
Status.thetaDelta = Deltas(1);
Status.phiDelta = Deltas(2);
Status.psiDelta = Deltas(3);
Status.xDelta = Deltas(4);
Status.yDelta = Deltas(5);
Status.zDelta = Deltas(6);
Status.StepSize = StepSize;
Status.Increase(1) = 1;
Status.SimHistory(1) = 0;
Status.Res = MaxRes;
Status.MaxStep = MaxStep;
Status.StepLevel = MaxStep;
Status.bNoMove = 0;
Status.bNoGrad = 0;
Status.bOscillation = 0;
Status.bLargeVolume = 0;
Status.bConverged = 0;

Status.Deltas = Deltas;
Status.StepSize = StepSize;
end