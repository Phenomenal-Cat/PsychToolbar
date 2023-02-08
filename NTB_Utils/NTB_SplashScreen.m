function app = NTB_SplashScreen(app)


SplashLogo      = 'NIF_MagneticField_White.gif';
[im,~, alpha]   = imread(SplashLogo);
im = repmat(im,[1,1,4]);
%im(:,:,4)       = alpha;
app.Run.SplashTex = Screen('MakeTexture', app.Run.Win, im);
SourceRect      = round([1,1,size(im,2),size(im,1)]/2);
ScreenIDtext    = {'Experimenter display', 'Subject display'};
Screen('FillRect', app.Run.Win, [0.5,0.5,0.5]);
Screen('TextSize', app.Run.Win, 60);
Screen('TextFont', app.Run.Win, 'Arial');
for d = 1:2
    Screen('DrawText', app.Run.SplashTex, sprintf('NIF Toolbar V 1.0\n\n%s',ScreenIDtext{d}) , 10, 10, [0,0,0], app.Params.Display.Screen.BackgroundColor);
end
Screen('DrawTexture', app.Run.Win, app.Run.SplashTex, [], CenterRect(SourceRect, ScreenRect));
%Screen('Flip', app.Run.Win);