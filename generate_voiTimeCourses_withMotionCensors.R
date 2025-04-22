library(tidyr)
library(tidyselect)
library(stringr)
library(readr)
library(dplyr)

############### modify these variables based on your dataset ######################
TR_LEN = 2    # in seconds
# how many volumes are in the preprocessed data?
# (1st run, 2nd run)
TRnum = 550
VOIS = c(" mpfc8mm", 
         "nacc8mm",
         "anteriorinsula8mmkg")

KERNEL <- c("b0","b2","b4")
METHODS <- c("nomc","afni","fsl-mi","fsl-nc","freesurfer","fmriprep") #"fmriprep"

# keep "SUB", "RUN", and "VOI" in the paths where subject name or VOI name is 
# to be substituted later in the code
PATH_BEH = "./mc_all/beh/SUB_mid.csv" # behavior files concatenated for all runs
PATH_voiTimeCourses = "./mc_all/METHODS/roi_ts/SUB_mid_KERNEL_VOI.1D"

# if you have a list of subjects saved in a text file, use:
SUBJECTS <- c("cw231123","bn230418")
RUNs = c("01","02")
# the number of TRs you want to extract after onset of each trial
TR_DELAY = 10

# NOTE: must modify line 114 according to a variable in the data (i.e., 'subset(TR == 1)')
# that denotes the beginning of each trial
# Here it is TR (relative to the trial)

################## IMPORT DATA for each subject & COMBINE into a BIG AGGREGATE DATAFRAME ###################
for (ker in KERNEL){
  df.allSubs = NULL
    for (method in METHODS){
    # make an empty dataframe
    
    for(sub in SUBJECTS){
      df.1sub = NULL
      df.1sub <- read_csv(str_replace_all(PATH_BEH, c("SUB" = sub)))%>%
        select(-...1)
      
      # create the 5 TRs at the tail of run 1
      end_run1 <- df.1sub %>%
        subset(trial == 42) %>% 
        .[1:5,] %>% 
        mutate(TR = TR + 6)
      
      # create the 5 TRs at the tail of run 2
      end_run2 <- df.1sub %>%
        subset(trial == 90) %>% 
        .[1:5,] %>% 
        mutate(TR = TR + 5)
      
      df.1sub <- df.1sub %>% 
        # insert 4 rows at the end of each run
        add_row(end_run1, .after = 252) %>% 
        add_row(end_run2, .after = 545) %>% 
        mutate(subject = sub) %>% 
        dplyr::select(subject, everything())
    
    # # import the motion censor file
    # df.censor <- read_delim(str_replace_all(PATH_motionCensor, c("SUB" = sub)),
    #                     "\t", col_names = "censor", escape_double = FALSE, trim_ws = TRUE) 
    
  
    for(voi in VOIS){
      df.voi <- read_delim(str_replace_all(PATH_voiTimeCourses, c("SUB" = sub, "VOI" = voi,
                                                                  "KERNEL" = ker,"METHODS" = method)),
                     "\t", col_names = voi, escape_double = FALSE, trim_ws = TRUE) 
      
      # determine cutoff for outliers
      voi_mean <- mean(df.voi[[1]], na.rm = T) 
      voi_sd <- sd(df.voi[[1]], na.rm = T) 
      thresh_up = voi_mean + (3 * voi_sd)
      thresh_down = voi_mean - (3 * voi_sd)
    
      # remove outliers & then censor based on motion
      df.voi <- df.voi %>%
        # remove outliers if desired
        mutate(!! voi := ifelse(.[[1]] > thresh_up | .[[1]] < thresh_down, yes = NA, no = .[[1]]))
         # bind_cols(df.censor) %>%
        # transmute(!! voi := ifelse(censor == 0, yes = NA, no = .[[1]]))
      
      df.1sub <- bind_cols(df.voi, df.1sub)
    
      for(tr in 1:TR_DELAY){
      
        df.1sub <- df.1sub %>%
          mutate(!! paste0(as.name(voi), "_TR_", as.name(tr)) := lead(.[[1]], tr - 1))
          } # tr loop
    
      # drop the original voi column
      df.1sub <- df.1sub %>% 
        dplyr::select(-1)
    } # voi loop
  
  # based on an appropriate variable in your events file, 
  # subset only the TRs that correspond to the onset of each trial
  df.1sub <- df.1sub %>% 
    subset(TR == 1) %>% 
    mutate(method = method) %>% 
    relocate(method, .after = subject)
  df.allSubs <- bind_rows(df.allSubs, df.1sub)
  } # subject loop
  } #method loop
  ############# save out the data ############
  # path and name of the output dataframe
  # modify the N based on your sample size
  OUTFILE_WIDE = paste0("./nacc_tc/timecourses_",ker,"_wide.csv")
  OUTFILE_LONG = paste0("./nacc_tc/timecourses_",ker,"_long.csv")
  
  # wide format
  write_csv(df.allSubs, file = OUTFILE_WIDE, append = FALSE)
  
  # make it into a long (tidy) format and save that too
  df.allSubs_long <- df.allSubs %>% 
    pivot_longer(cols = contains("_TR_"),
               names_to = c("voi", "tr"),
               names_sep = "_TR_",
               values_to = "BOLD") %>% 
    mutate(tr = as.numeric(tr),
         time = (tr-1)* TR_LEN) %>% 
    subset(time < 20) %>% 
    select(-TR)

  write_csv(df.allSubs_long, file = OUTFILE_LONG, append = FALSE)
} # kernal loop
