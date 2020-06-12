function [f, frac] = basicwaitbar(f,frac,msg,closewin)
                f = waitbar(0,'Please wait...');
                pause(.5)

                waitbar(.33,f,'Loading your data');
                pause(1)

                waitbar(.67,f,'Processing your data');
                pause(1)

                waitbar(1,f,'Finishing');
                pause(1)
                
                if strcmp(closewin,'close')
                    close(f)
                end
end