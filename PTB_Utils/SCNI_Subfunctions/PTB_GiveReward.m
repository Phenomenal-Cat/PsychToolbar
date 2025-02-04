function [Params] = SCNI_GiveReward(Params)

%============================ SCNI_GiveReward.m ===========================
% Sends the pre-loaded reward delivery square wave out to the solenoid via
% the specified DAC / Digital OUT channel of the DataPixx2.


if ~isfield(Params.DPx, 'AnalogReward')
    if ~isfield(Params, 'Run')
        Params.Run.MaxTrialDur = Params.DPx.AnalogOutRate;
    end
    Params = SCNI_DataPixxInit(Params);
end

if Params.DPx.AnalogReward == 1 %=========== USE ANALOG OUT
    Delay = 0;
    Datapixx('SetDacSchedule', Delay, Params.DPx.AnalogOutRate, Params.DPx.ndacsamples, Params.DPx.RewardChnl, Params.DPx.dacBuffAddr, Params.DPx.ndacsamples);
    Datapixx('StartDacSchedule');
    Datapixx('RegWrRd');
    disp(Datapixx('GetDacStatus'));
    Params.Reward.RunCount = Params.Reward.RunCount + 1;
    
%     Datapixx('RegWrRd');
%     nChannels = Datapixx('GetDacNumChannels');
%     dacRanges = Datapixx('GetDacRanges');
%     Datapixx('SetDacVoltages', [0; 10]);
%     WaitSecs(3);
%     Datapixx('RegWrRd');
%     Datapixx('SetDacVoltages', [0 ; 0]);
    
elseif Params.DPx.AnalogReward == 0 %=========== USE DIGITAL OUT
    bitValues           = 1;
    DecValues           = bi2de(bitValues);                         % Re-convert binary to decimal
    doutWaveform        = [0, 0, 0, 0, 0, 0, 1, 1];                
    doutBufferBaseAddr  = 0;
    Datapixx('WriteDoutBuffer', doutWaveform, doutBufferBaseAddr + 4096*(Params.DPx.RewardChnl+1));
    Datapixx('SetDoutSchedule', 0, 1000, 9, doutBufferBaseAddr);
    Datapixx('EnableDoutButtonSchedules');                          % This starts the schedules
    Datapixx('RegWrRd');                                            % Synchronize DATAPixx registers to local register cache

end