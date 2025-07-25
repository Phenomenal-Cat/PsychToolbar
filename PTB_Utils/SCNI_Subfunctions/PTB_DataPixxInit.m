function Params = PTB_DataPixxInit(Params)

%======================= PTB_DataPixxInit.m ==============================
% Initialize DataPixx2 for analog and digital IO.
%


%====================== Error handling
if nargin == 0 || isempty('Params') || ~isprop(Params,'DPx')
    Params = PTB_DatapixxSettings([], []);       	% Load DataPixx parameters for this system
end
if ~isfield(Params.DPx,'Installed')
    Params = PTB_DatapixxSettings([], Params);
end
if Params.DPx.Installed == 0 || Params.DPx.Connected == 0
   error('Matlab does not have access to DataPixx functions!');
end
if Params.DPx.Connected == 0
    error('No DataPixx box detected! Check that it is powered on and connected.');
end

%================== General DataPixx settings
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('DisableDinDebounce');
Datapixx('SetDinLog');
Datapixx('StartDinLog');
Datapixx('SetDoutValues',0);
Datapixx('RegWrRd');
Datapixx('DisableDacAdcLoopback');
Datapixx('DisableAdcFreeRunning');                  % For microsecond-precise sample windows
Datapixx('RegWrRd');                                % Synchronize Datapixx registers to local register cache

%================== Prepare ADC for recording analog signals                                            
UnusedIndx                      = find(~cellfun(@isempty, strfind(Params.DPx.AnalogIn.Labels,'None')));     % Find ADC channels not assigned to inputs
Params.DPx.ADCchannelsUsed 	    = find(Params.DPx.AnalogIn.Assign ~= UnusedIndx);                           % Find ADC channels assigned to inputs 
Params.DPx.nAdcLocalBuffSpls    = round(Params.DPx.AnalogIn.Rate*Params.Run.MaxTrialDur);              	    % Preallocate a local buffer
Params.DPx.adcBuffBaseAddr      = 4e6;                                                                      % Set DataPixx internal buffer address
Params.DPx.ScannerChannel       = find(ismember(Params.DPx.AnalogIn.Assign, find(~cellfun(@isempty, strfind(Params.DPx.AnalogIn.Labels,'Scanner')))));   % Find ADC channels recording 


%================== Prepare DAC schedule for reward delivery
Params.DPx.AnalogReward      = ~isempty(find(~cellfun(@isempty,strfind(Params.DPx.AnalogOut.Labels,'Reward'))));
if Params.DPx.AnalogReward == 1
    Reward_pad      	= 0.01;                                                                   	% Pad pulse on either side with zeros (seconds)
    Wave_time       	= Params.Reward.TTLDur+Reward_pad;                                        	% Calculate wave duration (seconds)
    Params.DPx.reward_Voltages	= [zeros(1,round(Params.DPx.AnalogOut.Rate*Reward_pad/2)), 5*ones(1,int16(Params.DPx.AnalogOut.Rate*Params.Reward.TTLDur)), zeros(1,round(Params.DPx.AnalogOut.Rate*Reward_pad/2))];
    Params.DPx.ndacsamples      = floor(Params.DPx.AnalogOut.Rate*Wave_time);                   
    Params.DPx.dacBuffAddr      = 8e6;
    Params.DPx.RewardChnl    	= find(~cellfun(@isempty, strfind(Params.DPx.AnalogOut.Labels,'Reward')))-1;	% Find DAC channel to send reward TTL on                                                                         % Which DAC channel to 
    %Datapixx('SetDacSchedule', Delay, Params.DPx.AnalogOutRate, Params.DPx.ndacsamples, Params.DPx.RewardChnl, Params.DPx.dacBuffAddr, Params.DPx.ndacsamples);
    Datapixx('RegWrRd');
    Datapixx('WriteDacBuffer', Params.DPx.reward_Voltages, Params.DPx.dacBuffAddr, Params.DPx.RewardChnl);
%     nChannels = Datapixx('GetDacNumChannels');
%     Datapixx('SetDacVoltages', [0:nChannels-1; zeros(1, nChannels)]);                                   % Set all DAC channels to 0V
end


%================== Prepare digital outputs for serial communciation with TDT?
if Params.DPx.TDTonDOUT == 1                                                                
    
    
end  