function app = NTB_SplashScreen(app)

SplashLogo      = 'NIF_MagneticField_White.gif';
SplashColor     = [0,0,0.5];
%SplashColor     = app.Params.Display.Screen.BackgroundColor;
im              = imread(SplashLogo);
im              = (max(double(im(:)))*ones(size(im)))-double(im);
im              = im/max(im(:))*255;
im              = repmat(im,[1,1,4]);
app.Run.SplashTex = Screen('MakeTexture', app.Run.Win, im);
SourceRect      = round([1,1,size(im,2),size(im,1)]/2);
ScreenIDtext    = {'Experimenter display', 'Subject display'};
Screen('FillRect', app.Run.Win, SplashColor);
Screen('TextSize', app.Run.Win, 60);
Screen('TextFont', app.Run.Win, 'Arial');

for d = 1:2
    Screen('DrawText', app.Run.SplashTex, sprintf('NIF Toolbar V 1.0\n\n%s', ScreenIDtext{d}) , 10, 10, [1,1,1]*255, SplashColor);
end
Screen('DrawTexture', app.Run.Win, app.Run.SplashTex, [], CenterRect(SourceRect, app.Params.Display.Screen.XScreenRect));
%Screen('Flip', app.Run.Win);