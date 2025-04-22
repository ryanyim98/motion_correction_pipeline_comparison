# dump out ROI timeseries
# based on preprocessed functional file in standard space

# run from the scripts directory

MAIN_DIR=$(pwd)
DATA_DIR=$MAIN_DIR/mc_all
ROI_DIR=$MAIN_DIR/ROIs
XFS_DIR=$DATA_DIR/xfs

VOIs='nacc8mm anteriorinsula8mmkg mpfc8mm'

ANAT_TEMPLATE=$MAIN_DIR/ROIs/mni_ns.nii.gz
ANAT_TEMPLATE_FUNC=$MAIN_DIR/ROIs/mni_ns_func.nii.gz


for SUB in bn230418 cw231123
do
  ### skull-stip T1
  #3dSkullStrip -overwrite -prefix mc_all/T1/${SUB}_T1_ns.nii.gz -input mc_all/T1/${SUB}_T1.nii.gz -push_to_edge

  # ### # register t1 to mni:
  # flirt -ref $ANAT_TEMPLATE -in T1/${SUB}_T1_ns.nii.gz -out ${SUB}_t1_mni -omat ${SUB}_t12mni.mat \
  #     -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear

  for METHOD in freesurfer
  do
      cd $DATA_DIR/$METHOD
      #
      # ##################step 1: preprocessing
      # if [ ! -d "preprocessed" ]; then
      #     mkdir preprocessed
      # fi
      #
      # for KERNEL in 0 2 4
      # do
      #   for RUN in run-01 run-02
      #   do
      #     ### apply different smoothing kernels
      #     ### spatial smoothing
      #     3dmerge -overwrite -prefix preprocessed/${SUB}_mid_${RUN}_b${KERNEL}.nii.gz -1blur_fwhm $KERNEL -doall ${SUB}_mid_${RUN}.nii.gz
      #
      #     cd preprocessed
      #     ### convert to percent signal change
      #     3dTstat -overwrite -prefix ${SUB}_mid_${RUN}_avg_b${KERNEL}.nii.gz ${SUB}_mid_${RUN}_b${KERNEL}.nii.gz
      #     3drefit -overwrite -abuc ${SUB}_mid_${RUN}_avg_b${KERNEL}.nii.gz
      #     3dcalc -overwrite -datum float -a ${SUB}_mid_${RUN}_b${KERNEL}.nii.gz -b ${SUB}_mid_${RUN}_avg_b${KERNEL}.nii.gz -expr "((a-b)/b)*100" -prefix ${SUB}_mid_${RUN}_psc_b${KERNEL}.nii.gz
      #
      #     ### high-pass filtering
      #     # 3dFourier -prefix pp_mid_${RUN}_b${KERNEL}.nii.gz -highpass .011 mid_${RUN}_psc_b${KERNEL}.nii.gz
      #     3dBandpass -overwrite -prefix ${SUB}_pp_mid_${RUN}_b${KERNEL}.nii.gz .011 9999 ${SUB}_mid_${RUN}_psc_b${KERNEL}.nii.gz
      #     cd ..
      #   done
      #   3dTcat -overwrite -prefix ${SUB}_pp_mid_b${KERNEL}_orig.nii.gz preprocessed/${SUB}_pp_mid_run-01_b${KERNEL}.nii.gz preprocessed/${SUB}_pp_mid_run-02_b${KERNEL}.nii.gz
      # done

      # # # #################step 2: apply coregistration
      # for KERNEL in 0 2 4
    	# do
      #
    	# 	### apply the part2mni transformation
    	# 	flirt -in ${SUB}_pp_mid_b${KERNEL}_orig.nii.gz -applyxfm -init ${XFS_DIR}/${SUB}_part2mni.mat -out ${SUB}_pp_mid_b${KERNEL}_mni.nii.gz -paddingsize 0.0 -interp trilinear	-ref $ANAT_TEMPLATE_FUNC
    	# done

      #################step 3: dump ROI tc

      if [ ! -d "roi_ts" ]; then
          mkdir roi_ts
      fi

      for mask in $VOIs
      #for mask in csf wm
      do

        for KERNEL in 0 2 4
        do
            echo
            echo -------$mask---------
            echo

            PP_FILE=${SUB}_pp_mid_b${KERNEL}_mni.nii.gz #pp_mid_b0_mni.nii.gz
            #cp $PP_FILE $ROI_DIR
            3dmaskave -overwrite -mask ${ROI_DIR}/${mask}_func.nii.gz -quiet $PP_FILE > roi_ts/${SUB}_mid_b${KERNEL}_${mask}.1D
          done # kernel loop
      done # mask loop
  done #method loop
done #subject loop

# ## fmriprep works differently
# for SUB in cw231123 bn230418
# do
#   for METHOD in fmriprep
#   do
#       cd $DATA_DIR/$METHOD
#       # cp ~/Desktop/midmvpa/mid_data/derivatives/sub-${SUB}/func/sub-${SUB}_task-mid_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz ${SUB}_mid_run-01.nii.gz
#       # cp ~/Desktop/midmvpa/mid_data/derivatives/sub-${SUB}/func/sub-${SUB}_task-mid_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz ${SUB}_mid_run-02.nii.gz
#       #
#       # for KERNEL in 0 2 4
#       # do
#       #   for RUN in run-01 run-02
#       #   do
#       #     #align the spatial extent to the same dimension as MNI
#       #     3dresample -overwrite -master mni_ns_func.nii.gz  -input ${SUB}_mid_${RUN}.nii.gz  -prefix ${SUB}_mid_${RUN}_resampled.nii.gz
#       #     #apply smoothing
#       #     3dmerge -overwrite -prefix preprocessed/${SUB}_pp_mid_${RUN}_b${KERNEL}.nii.gz -1blur_fwhm $KERNEL -doall ${SUB}_mid_${RUN}_resampled.nii.gz
#       #     ### convert to percent signal change
#       #     3dTstat -overwrite -prefix preprocessed/${SUB}_mid_${RUN}_avg_b${KERNEL}.nii.gz preprocessed/${SUB}_pp_mid_${RUN}_b${KERNEL}.nii.gz
#       #     3drefit -overwrite -abuc preprocessed/${SUB}_mid_${RUN}_avg_b${KERNEL}.nii.gz
#       #     3dcalc -overwrite -datum float -a preprocessed/${SUB}_pp_mid_${RUN}_b${KERNEL}.nii.gz -b preprocessed/${SUB}_mid_${RUN}_avg_b${KERNEL}.nii.gz -expr "((a-b)/b)*100" -prefix preprocessed/${SUB}_pp_mid_${RUN}_b${KERNEL}_psc.nii.gz
#       #     ## high-pass filtering
#       #     3dBandpass -overwrite -prefix preprocessed/${SUB}_pp_mid_${RUN}_b${KERNEL}_filt.nii.gz .011 9999 preprocessed/${SUB}_pp_mid_${RUN}_b${KERNEL}_psc.nii.gz
#       #   done
#       #   #concatenate the already preprocessed files
#       #     3dTcat -overwrite -prefix ${SUB}_pp_mid_b${KERNEL}_mni.nii.gz preprocessed/${SUB}_pp_mid_run-01_b${KERNEL}_filt.nii.gz preprocessed/${SUB}_pp_mid_run-02_b${KERNEL}_filt.nii.gz
#       # done # kernel loop
#       # ################# dump ROI tc
#       #
#       # if [ ! -d "roi_ts" ]; then
#       #     mkdir roi_ts
#       # fi
#
#       for mask in $VOIs
#       #for mask in csf wm
#       do
#
#         for KERNEL in 0 2 4
#         do
#             echo
#             echo -------$mask---------
#             echo
#
#             PP_FILE=${SUB}_pp_mid_b${KERNEL}_mni.nii.gz #pp_mid_b0_mni.nii.gz
#             cp $PP_FILE $ROI_DIR
#             3dmaskave -overwrite -mask ${ROI_DIR}/${mask}_func.nii.gz -quiet $PP_FILE > roi_ts/${SUB}_mid_b${KERNEL}_${mask}.1D
#             #  3dmaskave -overwrite -mask ../../ROIs/nacc8mm_func_part.nii.gz -quiet ${SUB}_pp_mid_b${KERNEL}_mni.nii.gz > roi_ts/test.1D
#         done # kernel loop
#       done # mask loop
#   done #method loop
#
# done #subject loop
