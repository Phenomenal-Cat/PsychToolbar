
%=========================== SCNI_CheckKeys.m =============================
% Check the experimenter's keyboard input for whether any of the shortcut 
% keys assigned during 'SCNI_InitKeyboard.m' have been pressed, and apply
% the corresponding actions.
%==========================================================================

function [Params] = SCNI_CheckKeys(Params)

    Params.Run.EndRun = 0;
    [keyIsDown,secs,keyCode] = KbCheck([], Params.Keys.List);              	% Check keyboard for relevant key presses 
    if keyIsDown && secs > Params.Keys.LastPress+Params.Keys.Interval     	% If key is pressed and it's more than the minimum interval since last key press...
        Params.Keys.LastPress   = secs;                                    	% Log time of current key press
        if keyCode(Params.Keys.Stop) == 1                                  	% Experimenter pressed quit key
            SCNI_SendEventCode('ExpAborted', Params);                     	% Inform neurophys. system
            Params.Run.EndRun = 1;
        elseif keyCode(Params.Keys.Reward) == 1                           	% Experimenter pressed manual reward key
            Params = SCNI_GiveReward(Params);                            	% Deliver manual reward
        elseif keyCode(Params.Keys.Audio) == 1                              % Experimenter pressed play sound key
            Params = SCNI_PlaySound(Params);                                        
        elseif keyCode(Params.Keys.Center) == 1                             % Experimenter pressed 'center' key
            Params = SCNI_UpdateCenter(Params);
        elseif keyCode(Params.Eye.Keys.ChangeEye) == 1                      % Experimenter pressed 'next eye' key
            if Params.Eye.CalMode > 1
                Params.Eye.EyeToUse = Params.Eye.EyeToUse + 1;
                if Params.Eye.EyeToUse > 3
                    Params.Eye.EyeToUse = 1;
                end
            end
        elseif keyCode(Params.Eye.Keys.GainInc) == 1                        % Increase gain      
            Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected) = Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected)+Params.Eye.GainIncrement;
            
        elseif keyCode(Params.Eye.Keys.GainDec) == 1                        % Decrease gain
            Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected) = Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected)-Params.Eye.GainIncrement;
            
        elseif keyCode(Params.Eye.Keys.ChangeXY) == 1                       % Select XY toggle
            Params.Eye.XYselected = Params.Eye.XYselected + 1;
          	if Params.Eye.XYselected > 2
                Params.Eye.XYselected = 1;
            end
        elseif keyCode(Params.Eye.Keys.Invert) == 1                         % Invert eye XY
            Params.Eye.Cal.Sign{Params.Eye.EyeToUse}(Params.Eye.XYselected) = -Params.Eye.Cal.Sign{Params.Eye.EyeToUse}(Params.Eye.XYselected);
      	elseif keyCode(Params.Eye.Keys.Save) == 1 
            %Params = SaveCal(Params);
    	elseif keyCode(Params.Eye.Keys.Mouse) == 1                          % Update center based on mouse cursor
            Params = SCNI_UpdateCenterFromMouse(Params);                    
        end

    end


    %=============== UPDATE CENTER GAZE POSITION
    function Params = SCNI_UpdateCenter(Params)
        Eye         = SCNI_GetEyePos(Params);                                   % Get screen coordinates of current gaze position (pixels)
      	if Params.Eye.EyeToUse == 3
            for e = 1:2
                Params.Eye.Cal.Offset{e}  =  -Eye(e).Volts;
            end
        end
    end

    %=============== UPDATE CENTER GAZE POSITION BASED ON MOUSE CURSOR
    function Params = SCNI_UpdateCenterFromMouse(Params)
        [EyeX, EyeY, buttons] = GetMouse(Params.Display.win);                                   % Get mouse cursor position (relative to top left)
        if EyeX > 0 && EyeY > 0
            Eye.Pixels  = [EyeX, EyeY];                                                        	% 
            Eye.PixCntr = Eye.Pixels-Params.Display.Rect([3,4])/2;                           	% Center coordinates
            Eye.Degrees = Eye.PixCntr./Params.Display.PixPerDeg;                              	% Convert pixels to degrees
            Eye.Volts   = (Eye.Degrees./Params.Eye.Cal.Gain{Params.Eye.EyeToUse})+Params.Eye.Cal.Offset{Params.Eye.EyeToUse};	% Convert degrees to volts
            Eye.Volts
            Params.Eye.Cal.Offset{Params.Eye.EyeToUse}  =  -Eye.Volts;                          % Update voltage offset
        end
    end


end