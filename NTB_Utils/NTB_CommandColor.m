function NTB_CommandColor(BkgColor, TextColor)

% Changes the Matlab command window background and text color. Input
% arguments can be either strings for standard colors, or RGB arrays (double). 

if ischar(BkgColor)
    if strcmpi(BkgColor, 'reset')
        com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',1);       % Return to using system colors
    else
        com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',0);       % Don't use system colors
        com.mathworks.services.Prefs.setColorPref('ColorsBackground', eval(sprintf('java.awt.Color.%s', lower(BkgColor))));
        if nargin > 1
            com.mathworks.services.Prefs.setColorPref('ColorsText', eval(sprintf('java.awt.Color.%s', lower(TextColor))));
        end
    end
elseif isa(BkgColor, 'double')
    BkgColor = sprintf('[r=%d,g=%d,b=%d]', BkgColor);
    com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',0);           % Don't use system colors
    com.mathworks.services.Prefs.setRGBColorPref('ColorsBackground', eval(sprintf('java.awt.Color.%s', lower(BkgColor))));
    if nargin > 1
        TextColor = sprintf('[r=%d,g=%d,b=%d]', TextColor);
        com.mathworks.services.Prefs.setRGBColorPref('ColorsText',eval(sprintf('java.awt.Color.%s', lower(TextColor))));
    end
else
    error('Input argument ''colorstring'' must be of type ''char'' or ''double''.');
end
com.mathworks.services.ColorPrefs.notifyColorListeners('ColorsBackground');
com.mathworks.services.ColorPrefs.notifyColorListeners('ColorsText');