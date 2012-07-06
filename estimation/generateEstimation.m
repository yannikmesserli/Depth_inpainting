function [Iest Mask Disp] = generateEstimation(cfg,Iref,Idep,camParam)
% performs the estimation of the frame at view v of time t using the
% reference view number vref
% Mask is 1 when there is an occlusion
%
%
% dec 2010 - Copyright - Thomas Maugey - thomas.maugey@epfl.ch





IntrRef = camParam.IntrRef; 
ExtrRef = camParam.ExtrRef;

IntrTar = camParam.IntrTar; 
ExtrTar = camParam.ExtrTar;


Iest = zeros(size(Iref));
Ifil = zeros(size(Idep));
Disp = zeros(size(Iref,1),size(Iref,2),2);


MinZ = camParam.MinZ;
MaxZ = camParam.MaxZ;


% for breakdancer and ballet
if cfg.videoType == 1
    IdepZ = 1.0./((double(Idep)/255.0)*(1.0/MinZ - 1.0/MaxZ) + 1.0/MaxZ);
else
    fprintf('generateEstimation(...) - no formula determined for the depth image conversion\n')
end

[N,M]=size(IdepZ);


for r = 1:N
    for c=1:M
       
  
        if cfg.videoType == 1
            x_real = c;
            y_real = N - r; % if seq are break or ballet
        else
            fprintf('generateEstimation(...) - check if the conversion of row/column to x/x\n')
        end
        
       % project the depth image to the reference camera coordinate 
       Vref = IntrRef\[x_real ; y_real ; 1]; 
       Vref(1:3) = Vref(1:3)*IdepZ(r,c);
       
       % project the reference camera param to the world coord
       Vwor = ExtrRef(:,1:3)\(Vref - ExtrRef(:,4));
       
       Vwor2 = [Vwor;1];
        
       Vtar_temp = ExtrTar * Vwor2;       
       Vtar = IntrTar*Vtar_temp;
       
       y_target =  round(Vtar(2)/Vtar(3)); 
       x_target =  round(Vtar(1)/Vtar(3)); 
      
       
       c_target =  x_target;
       r_target =  N - y_target;
              
       
       if c_target > 0 && c_target <= M && r_target > 0 && r_target <= N
           if Ifil(r_target,c_target) == 0
               Iest(r_target,c_target,:)=Iref(r,c,:);
               Ifil(r_target,c_target)=IdepZ(r,c);
               Disp(r,c,1) = r_target-r;
               Disp(r,c,2) = c_target-c;
           elseif IdepZ(r,c)<Ifil(r_target,c_target)
               Iest(r_target,c_target,:)=Iref(r,c,:);
               Ifil(r_target,c_target)=IdepZ(r,c);
               Disp(r,c,1) = r_target-r;
               Disp(r,c,2) = c_target-c;
           end
           
       else
       %    fprintf('out of bounds\n');
       end
        
    end
end

Mask = Ifil == 0;
Iest(Mask==1)=126;




