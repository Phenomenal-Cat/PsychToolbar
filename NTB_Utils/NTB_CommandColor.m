function NTB_CommandColor(colorstring)

if ~ischar(colorstring)
    error('Input argument ''colorstring'' must be of type ''char''.');
end
if strcmpi(colorstring, 'reset')
    com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',1);
else
    com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',0);
    com.mathworks.services.Prefs.setColorPref('ColorsBackground', eval(sprintf('java.awt.Color.%s', lower(colorstring))));
end
com.mathworks.services.ColorPrefs.notifyColorListeners('ColorsBackground');