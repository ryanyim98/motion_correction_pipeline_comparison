% Step 1: Read NIfTI files
nifti_files = {
               % '/Users/yanyan/Desktop/MVPA/for_justin/cw231123/run-01/mid_run-01_ts.nii.gz';
               % '/Users/yanyan/Desktop/MVPA/for_justin/cw231123/run-02/mid_run-02_ts.nii.gz';
               '~/Desktop/MVPA/for_justin/cw231123/afni/mid_run-01_m.nii.gz';
               '~/Desktop/MVPA/for_justin/cw231123/afni/mid_run-02_m.nii.gz';
               '/Users/yanyan/Desktop/MVPA/for_justin/cw231123/run-01/mid_run-01_mc_normcorr.nii.gz';
               '/Users/yanyan/Desktop/MVPA/for_justin/cw231123/run-02/mid_run-02_mc_normcorr.nii.gz';
               '/Users/yanyan/Desktop/MVPA/for_justin/cw231123/run-01/mid_run-01_mc_mutualinfo.nii.gz';
               '/Users/yanyan/Desktop/MVPA/for_justin/cw231123/run-02/mid_run-02_mc_mutualinfo.nii.gz';
               % '~/Desktop/midmvpa/mid_data/derivatives/sub-02/func/sub-02_task-mid_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz';
               % '~/Desktop/midmvpa/mid_data/derivatives/sub-02/func/sub-02_task-mid_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz';
               % '~/Downloads/freesurfer_justin/functional/cw-run01/bold/001/fmcpr.nii.gz';
               % '~/Downloads/freesurfer_justin/functional/cw-run02/bold/002/fmcpr.nii.gz';
               % '~/Downloads/freesurfer_justin/functional/bn-run01/bold/003/f.nii.gz';
               % '~/Downloads/freesurfer_justin/functional/bn-run02/bold/004/f.nii.gz';
               % '~/Downloads/freesurfer_justin/functional/bn-run01/bold/003/fmcpr.nii.gz';
               % '~/Downloads/freesurfer_justin/functional/bn-run02/bold/004/fmcpr.nii.gz';
               % '/Users/yanyan/Desktop/MVPA/for_justin/pilot_bn230418/run-01/mid_run-01_mc_normcorr.nii.gz';
               % '/Users/yanyan/Desktop/MVPA/for_justin/pilot_bn230418/run-02/mid_run-02_mc_normcorr.nii.gz';
               }; % Assuming NIfTI files are in the current directory
num_files = height(nifti_files);
out_names = {
    % 'cw-raw-run01';'cw-raw-run02'; 
    'cw-afni-run01';'cw-afni-run02';
    'cw-fsl-nc-run01';'cw-fsl-nc-run02';
    'cw-fsl-mi-run01';'cw-fsl-mi-run02';
    % 'cw-fmriprep-run01';'cw-fmriprep-run02'; 
    % 'cw-fs-run01';'cw-fs-run02';
    % 'bn-raw-run01';'bn-raw-run02';
    % 'bn-raw-run01';'bn-raw-run02';
    % 'bn-fs-run01';'bn-fs-run02';
    % 'bn-fsl-nc-run01';'bn-fsl-nc-run02'
    };

% Define a grayscale colormap
cmap = gray(256); % You can adjust the number of colormap entries if needed

% Step 2: Extract image data
for f = 1:num_files
    nii = load_nii(char(nifti_files(f))); % Use appropriate function to load NIfTI files
    % Extract dimensions
    [x, y, z, t] = size(nii.img);
    % Preallocate a movie matrix
    mov(1:t) = struct('cdata', [], 'colormap', []);

    vidObj = VideoWriter(['~/Desktop/MVPA/motion/' char(out_names(f)) '.mp4'], 'MPEG-4');
    vidObj.Quality = 100; % Set video quality (0-100, higher is better)
    vidObj.FrameRate = 15; % Set frame rate
    open(vidObj);

    for i = 1:t
        % Extract 3D volume
        volume = rot90(squeeze(nii.img(:, :, 5, i)));%nii.img(:, :, 15, i); nii.img(50, :, :, i);nii.img(:, 75, :, i)
        
           % Convert to an indexed image frame
        frame = uint8(255 * mat2gray(squeeze(volume))); % Convert to uint8 for colormap indexing
        frame = ind2rgb(frame, cmap);
        
        % Display the frame (optional)
        imshow(frame);
        
    % Add the frame to the movie matrix
        mov(i).cdata = frame;
        mov(i).colormap = [];
        currFrame = getframe(gcf);
       writeVideo(vidObj,currFrame);
    end

    % Close the file.
    close(vidObj);
end
