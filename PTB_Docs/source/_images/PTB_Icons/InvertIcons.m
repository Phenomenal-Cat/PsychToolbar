

IconDir = '/Volumes/Seagate Backup 3/NIH_Code/NIF_Toolbar/NTB_Docs/source/_images/NTB_Icons/';
cd(IconDir);
ImFiles = dir('*.png');

OutputRes   = [200,200];
ImWhite     = ones([OutputRes, 3]);

for n = 1:numel(ImFiles)
    [im, c, alp] = imread(ImFiles(n).name);
    ImSize = size(im);
    if ImSize(1) == ImSize(2)
        try
            alp = imresize(alp, OutputRes);
            Filename = fullfile(IconDir, ['W_', ImFiles(n).name]);
            imwrite(ImWhite, Filename, 'alpha', alp);
        end
    else
        fprintf('%s has a non square aspect ratio!\n', ImFiles(n).name);
    end
end