classdef visfun
    methods(Static)
        
        function [VisNum] = numvis(VisSymb, Offset);
            % Converts VisName obtained with READTRAC into a numeric array:
            % nREM sleep stages < 0,
            % REM Sleep 0
            % Wake 1
            % Movement 2
            % others 3
            
            VisNum=zeros(1,size(VisSymb,2)-Offset);
            VisNum=VisNum+3;
            Index=find(VisSymb=='1')-Offset;
            VisNum(Index)=-1;
            Index=find(VisSymb=='2')-Offset;
            VisNum(Index)=-2;
            Index=find(VisSymb=='3')-Offset;
            VisNum(Index)=-3;
            Index=find(VisSymb=='4')-Offset;
            VisNum(Index)=-4;
            Index=find(VisSymb=='r')-Offset;
            VisNum(Index)=0;
            Index=find(VisSymb=='0')-Offset;
            VisNum(Index)=1;
            Index=find(VisSymb=='m')-Offset;
            VisNum(Index)=2;
        end
        
        % -----------------------------------------------------------------
        function [Vis]=plotvis(VisNum,density);
            
            %  function [Vis]=PlotVis(VisNum,density);
            %  Creates array from VisNum array which can be used to plot sleep stages as a line plot.
            %  density indicates the desired number of vertical lines per epoch (default 1)
            %
            %  obtain VisNum e.g. with
            %  [vistrack vissymb offset]=readtrac(FileName,1);
            %
            %  VisNum=numvis(vissymb,offset)';
            %
            %  Plot results with plot(Vis(:,1),Vis(:,2))
            %
            %  Th.G. 5.8.99
            
            if nargin<2
                density=1;
            end;
            
            tempNdx=(1:1:length(VisNum))';
            if VisNum(length(VisNum))==3
                VisNum(length(VisNum))=VisNum(length(VisNum)-1);
            end;
            
            if density==1
                Vis1=zeros(length(VisNum)*3,1);
                Ndx=zeros(length(tempNdx)*3,1);
                for i=1:length(VisNum)
                    x=(tempNdx(i)-0.5)/3/60;
                    Ndx(3*(i-1)+1)=x;
                    Ndx(3*(i-1)+2)=x;
                    Ndx(3*(i-1)+3)=NaN;
                    Vis1(3*(i-1)+1)=VisNum(i);
                    Vis1(3*(i-1)+2)=VisNum(i)+1;
                    Vis1(3*(i-1)+3)=NaN;
                end;
            else
                Vis1=zeros(length(VisNum)*density*2+length(VisNum)-1,1);
                Ndx=zeros(length(tempNdx)*density*2+length(tempNdx)-1,1);
                for i=1:length(VisNum)
                    Delta=1/density;
                    for j=1:density
                        x=(tempNdx(i)-1+Delta/2+Delta*(j-1))/3/60;
                        Ndx(2*(i-1)*density+(i-1)+2*(j-1)+1)=x;
                        Ndx(2*(i-1)*density+(i-1)+2*(j-1)+2)=x;
                        Vis1(2*(i-1)*density+(i-1)+2*(j-1)+1)=VisNum(i);
                        Vis1(2*(i-1)*density+(i-1)+2*(j-1)+2)=VisNum(i)+1;
                    end
                    Ndx(2*(i-1)*density+(i-1)+2*density+1)=NaN;
                    Vis1(2*(i-1)*density+(i-1)+2*density+1)=NaN;
                end;
            end;
            Vis=[Ndx,Vis1];
            %plot(Vis(:,1),Vis(:,2))
        end
        
        % -----------------------------------------------------------------
        function [vistrack, vissymb, offs] = readtrac(visfilename,track);
            % VIS file operations
            %___________________________________________________________________
            % Luca Finelli - 02.05.1997
            % Institute of Pharmacology - UNI Zürich - Switzerland
            %
            % READTRAC returns a matrix of binary numbers,  VISTRACK,  where the
            %          j-th element of the i-th  column (=i-th 20-s epoch) is 0,
            %          if the  corresponding 4-sepoch is included, 1  if  it  is
            %          discarded. This selection refers to  the  selected  TRACK
            %          (default: track 1) in  the VISFILENAME file.
            %
            %          See also: READVIS
            %
            % Input Parameters:
            %
            %   visfilename =  string: disc path and file name for VIS file (*.vis)
            %
            % Optional Input Parameters (0 -> default):
            %
            %   track       =  integer: selected track (default = 1)
            %
            % Output:
            %
            %   vistrack    = binary matrix
            %   vissymb     = char vector: sleep stage scoring for 20-s epochs
            %
            % Optional Output:
            %
            %   offs        = number of epochs to be discarded at the beginning
            %
            % Synopsis:
            %
            %   [vistrack,vissymb,offs] = READTRAC(visfilename,track);
            %
            % Last Update:   08.05.1997 lf - Added track choice parameter
            % Last Update:   24.03.1999 tg - Added offs as optional output
            % Last Update:   14.04.1999 tg - Modifications to allow vis files with missing sleep stages
            % Last Update:   24.07.1999 lf - Help edited and indexing of vistrack tested: ok
            
            if nargin < 2
                track = 1;
            end
            
            % READ OFFSET (reads offset from file *.vis )
            fid  = fopen(visfilename,'r');
            line = fgets(fid);
            offs = sscanf(line,'%d');
            fclose(fid);
            
            % READ SCORING FILE INFORMATION TO "visdata" (epochs+stages+tracks up to TRACK)
            fidvis=fopen(visfilename,'r');
            fgetl(fidvis);
            formatcode='%d%*c%c%*c';        % C format code to sscanf for 0 tracks
            for j=1:track
                formatcode=[formatcode '%c']; % changing C format code to read tracks
            end                             % up to selected value (TRACK parameter)
            
            i=1;
            Finished=0;
            while Finished==0
                visline=fgetl(fidvis);
                if ~ischar(visline)
                    Finished=1;
                else
                    [buffer,count]=sscanf(visline,formatcode,2+track);
                    if count>0
                        if i>1 & buffer(1)<visdata(1,i-1)
                            Finished=1;
                        else
                            if count==1
                                buffer=[buffer;32];
                                count=count+1;
                            end;
                            if count<2+track
                                for j=count+1:2+track
                                    buffer=[buffer;10];
                                end
                            end
                            visdata(:,i)=buffer;
                            i=i+1;
                        end;
                    end
                end
            end;
            fclose(fidvis);
            
            % DECOMPRESSING SLEEP STAGES INFORMATION TO "vissymb"
            [m n]=size(visdata);
            for i=1:n-1
                lower=visdata(1,i);
                higher=visdata(1,i+1);
                for k=lower:higher-1
                    vissymb(k)=char(visdata(2,i));
                end;
            end;
            vissymb(visdata(1,n))=setstr(visdata(2,n));
            if offs~=0
                vissymb=[linspace('x','x',offs) vissymb]; % shifting epoch count from lights off
            end                                           % to beginning of file
            
            % EXTRACTING 20-s EPOCHS WITH SOME EXCLUDED 4-s EPOCHS TO "excluded"
            indexc=find(visdata(2+track,:)>=64 & visdata(2+track,:)<=95); % ASCII codes for exclusion is
            % between 64 (none) and 95 (all)
            excluded=visdata(1,indexc);
            
            % CREATING MATRIX "vistrack" WITH 0 FOR INCLUDED 4-S EPOCH, 1 FOR EXCLUDED
            %                 To row number corresponds 20-s epoch number in vis file
            vistrack=zeros(length(vissymb),5);
            for i=1:length(indexc)
                epochcode=dec2bin(visdata(2+track,indexc(i))-64); % HUMAN SCORING track code:
                %   epochcode=dec2binlf(visdata(2+track,indexc(i))-64); % HUMAN SCORING track code:
                % visdata(2+track,indexc(i))
                % Example: ASCII code value of X in "283 m X"
                % -> 88
                while length(epochcode)<5
                    epochcode=[0,epochcode];                        % bringing binary version of track code
                end;                                              % to five bit length
                
                vistrack(excluded(i)+offs,:)=epochcode(5:-1:1);   % REVERSED! binary vector is 4-s excl.code
            end
        end
        
%         % -------------------------------------------------------------
%         function binary = dec2binlf(decimal);
%             
%             % DEC2BIN returns a vector with the binary  notation  of
%             %         the given integer decimal  number.  The  first
%             %         vector element is the lowest bit.  A  negative
%             %         integer is made into positive.
%             %________________________________________________________
%             % Luca Finelli - 02.05.1997
%             
%             % Last Update:   00.00.0000 lf - changes ...
%             
%             
%             if decimal==0
%                 nobit=1;
%             else
%                 nobit=1+floor(log(round(decimal))/log(2));
%             end;
%             binary=zeros(1,nobit);
%             
%             if sign(decimal)==-1
%                 fprintf('DEC2BIN: warning, %d is a negative number.\n',decimal);
%             end
%             
%             if isint(decimal)~=1
%                 fprintf('DEC2BIN: cannot put %d in binary form.\n',decimal);
%             else
%                 for i=nobit-1:-1:0
%                     if abs(decimal)>=2^(i)
%                         binary(i+1)=1;
%                         decimal=decimal-2^(i)*sign(decimal);
%                     end;
%                 end;
%             end;
%             
%             binary=binary(length(binary):-1:1);
%         end
%         
%         % -------------------------------------------------------------

    end
end







