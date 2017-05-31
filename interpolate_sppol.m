
%------------ input ---------------

%these three values come form ref_density/g.out file

dfet_n1 = 40;
dfet_n2 = 40;
dfet_n3 = 135; 

nspin = 2;

%these three values come from the NGXF, NGYF, and NGZF from OUTCAR

vasp_n1 = 60;  % NGXF in OUTCAR
vasp_n2 = 60;  % NGYF in OUTCAR
vasp_n3 = 196; % NGZF in OUTCAR


% --------------------------------------------
%
% In general we do not modify codes below 
%
% --------------------------------------------

load  uemb.new
fprintf('uemb.new is loaded\n\n');

tot_mesh_abinit = dfet_n1*dfet_n2*dfet_n3;
embpot = reshape(uemb,[tot_mesh_abinit,nspin]);

fprintf('ABINIT mesh: %d %d %d\n',dfet_n1,dfet_n2,dfet_n3)
fprintf('VASP   mesh: %d %d %d\n\n',vasp_n1,vasp_n2,vasp_n3)

fid = fopen('embpot.vasp','w');

for isp=1:nspin 

  fprintf('interpolating spin: %d ...\n',isp);
  
  aa = embpot(:,isp);

  RS= reshape(aa, [dfet_n1,dfet_n2,dfet_n3]);
  newRS = zeros(dfet_n1+1,dfet_n2+1,dfet_n3+1);

  %========== add boundary ======
  for k=0:dfet_n3
      for j=0:dfet_n2
          for i=0:dfet_n1
              q1 = i;
              q2 = j;
              q3 = k;
              if (k==dfet_n3)
                  q3 = 0;
              end
              if (j==dfet_n2)
                  q2 = 0;
              end
              if (i==dfet_n1)
                  q1 = 0;
              end
              newRS(i+1,j+1,k+1) = RS(q1+1,q2+1,q3+1);
          end
      end
  end

  %========== interpolation ==========

  %abinit's mesh 
  xv = [0:dfet_n1]*(1.0/dfet_n1); 
  yv = [0:dfet_n2]*(1.0/dfet_n2); 
  zv = [0:dfet_n3]*(1.0/dfet_n3); 
  [x,y,z]    = meshgrid(xv,yv,zv);

  %vasp mesh  
  xqv = [0:vasp_n1-1]*(1.0/vasp_n1);
  yqv = [0:vasp_n2-1]*(1.0/vasp_n2);
  zqv = [0:vasp_n3-1]*(1.0/vasp_n3);
  [xq,yq,zq] = meshgrid(xqv,yqv,zqv);

  
  % flip the x and y for the interp3() function 
  % Octave and matlab treats the X and Y in a flipped way 
  % compared to FORTRAN
  
  intp_array = zeros(dfet_n2+1,dfet_n1+1,dfet_n3+1);
  for k=0:dfet_n3
    intp_array(:,:,k+1) = transpose(newRS(:,:,k+1));
  end

  % --------- Octave/ Matlab interps() function -----------
  ssss = interp3(x,y,z,intp_array,xq,yq,zq,'linear');

  % transpose the ssss to the FORTRAN format 
  % note that Octave/Matlab flips the X and Y 

  s = zeros(vasp_n1,vasp_n2,vasp_n3);
  
  for k=1:vasp_n3
    s(:,:,k) = transpose(ssss(:,:,k));
  end 

  fprintf('	INFO: Embpot for spin: %d\n', isp)
  fprintf('	      max: %f \n', max(max(max(s))))
  fprintf('	      min: %f \n\n', min(min(min(s))))
  
  % write the embedding potential on VASP mesh ----------
  for k=1:vasp_n3
    for j=1:vasp_n2
       for i=1:vasp_n1
         fprintf(fid,'%12.4e\n',s(i,j,k));
       end
    end
  end

end % spin loop

fclose(fid);

disp('embpot.vasp is made for VASP_emb program.')
