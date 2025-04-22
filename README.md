# motion_correction_comparison
 Comparing different motion correction (MC) pipelines for a high res dataset

The dataset includes 60 participants who completed the MID task while undergoing high resolution partial coverage fMRI (isotropic 1.5mm).
There are two participants: cw231123 and bn230418, who were hand-selected from 60 participants. 
cw231123 was a mover that was originally removed from the analysis. bn230418 was a non-mover.

The goal of this project is to compare different motion correction tools. The tools that were compared include:
AFNI (using 3dvolreg)
Freesurfer (using AFNI 3dvolreg)
FSL (normcorr and mutualinfo, respectively)
fmriprep (also differs in coreg and other preprocessing steps)

MC were compared based on (1) similarity of the estimated motion, and (2) amplitude of the time course signal of NAcc.

The current findings are that all MC tools yield visually similar motion estimates; however, fmriprep yielded significantly different NAcc time course than other tools.
The reason why fmriprep was so different may be due to field distortion correction, and aligning to an average image rather than the first image.