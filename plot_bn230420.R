library(readr)
library(dplyr)
library(ggplot2)
library(patchwork)

## AFNI approach

r1 <- read.delim("~/Downloads/comp/3dmotion_run-01.1D", header = F, sep = "") %>% 
  mutate(run = "run-01")
r2 <- read.delim("~/Downloads/comp/3dmotion_run-02.1D", header = F, sep = "")%>% 
  mutate(run = "run-02")
# The output is in 9 ASCII formatted columns:
#   n  roll  pitch  yaw  dS  dL  dP  rmsold rmsnew

r_afni<- rbind(r1,r2) %>% 
  group_by(run) %>% 
  mutate(euc_dist = sqrt(V2^2+V3^2+V4^2+V5^2+V6^2+V7^2),
         tr = row_number())


ggplot(r_afni, aes(x = tr, y = euc_dist, color = run))+
  geom_point()

r_afni <- r_afni%>% 
  group_by(run) %>% 
  mutate(euc_dist = sqrt(V2^2+V3^2+V4^2+V5^2+V6^2+V7^2),
         tr = row_number()) %>% 
  mutate_at(vars(V2:V7),~ .x - lag(.x))%>%
  rename_with(~ paste0(.x, "_derivative"), matches("V")) %>% 
  mutate(enorm = sqrt(V2_derivative^2+V3_derivative^2+V4_derivative^2+
                        V5_derivative^2+V6_derivative^2+V7_derivative^2))



print(paste("the mean Euclidean distance of run 1 using afni is: ",mean(r_afni$enorm[r_afni$run == "run-01"],na.rm = T)))
print(paste("the mean Euclidean distance of run 2 using afni is: ",mean(r_afni$enorm[r_afni$run == "run-02"],na.rm = T)))


## FreeSurfer approach

r1 <- read.delim("/Users/yanyan/Downloads/freesurfer_justin/functional/bn-run01/bold/003/fmcpr.mcdat", header = F, sep = "") %>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-01")
r2 <- read.delim("/Users/yanyan/Downloads/freesurfer_justin/functional/bn-run02/bold/004/fmcpr.mcdat", header = F, sep = "")%>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-02")

r_fs<- rbind(r1,r2) %>% 
  group_by(run) %>% 
  mutate(euc_dist = sqrt(V2^2+V3^2+V4^2+V5^2+V6^2+V7^2),
         tr = row_number()) %>% 
  mutate(euc_dist = euc_dist-min(euc_dist))%>% 
  mutate_at(vars(V2:V7),~ .x - lag(.x))%>%
  rename_with(~ paste0(.x, "_derivative"), matches("V")) %>% 
  mutate(enorm = sqrt(V2_derivative^2+V3_derivative^2+V4_derivative^2+
                        V5_derivative^2+V6_derivative^2+V7_derivative^2))

print(paste("the mean Euclidean norm of run 1 using Freesurfer is: ",mean(r_fs$enorm[r_fs$run == "run-01"],na.rm = T)))
print(paste("the mean Euclidean norm of run 2 using Freesurfer is: ",mean(r_fs$enorm[r_fs$run == "run-02"],na.rm = T)))


#FSL-mutual info
r1 <- read.delim("/Users/yanyan/Desktop/MVPA/for_justin/pilot_bn230418/run-01/mid_run-01_mc_mutualinfo.nii.gz.par", header = F, sep = "") %>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-01") %>% 
  mutate(rowid = row_number())
r2 <- read.delim("/Users/yanyan/Desktop/MVPA/for_justin/pilot_bn230418/run-02/mid_run-02_mc_mutualinfo.nii.gz.par", header = F, sep = "") %>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-02") %>% 
  mutate(rowid = row_number())

r_fsl_mi <- rbind(r1,r2) %>% 
  group_by(run) %>% 
  mutate(euc_dist = sqrt(V1^2+V2^2+V3^2+V4^2+V5^2+V6^2),
         tr = row_number()) %>% 
  mutate(euc_dist = euc_dist-min(euc_dist))%>% 
  mutate_at(vars(V1:V6),~ .x - lag(.x))%>%
  rename_with(~ paste0(.x, "_derivative"), matches("V")) %>% 
  mutate(enorm = sqrt(V1_derivative^2+V2_derivative^2+V3_derivative^2+V4_derivative^2+
                        V5_derivative^2+V6_derivative^2))

#FSL-norm corr
r1 <- read.delim("/Users/yanyan/Desktop/MVPA/for_justin/pilot_bn230418/run-01/mid_run-01_mc_normcorr.nii.gz.par", header = F, sep = "") %>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-01") %>% 
  mutate(rowid = row_number())
r2 <- read.delim("/Users/yanyan/Desktop/MVPA/for_justin/pilot_bn230418/run-02/mid_run-02_mc_normcorr.nii.gz.par", header = F, sep = "") %>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-02") %>% 
  mutate(rowid = row_number())

r_fsl_nc <- rbind(r1,r2) %>% 
  group_by(run) %>% 
  mutate(euc_dist = sqrt(V1^2+V2^2+V3^2+V4^2+V5^2+V6^2),
         tr = row_number()) %>% 
  mutate(euc_dist = euc_dist-min(euc_dist))%>% 
  mutate_at(vars(V1:V6),~ .x - lag(.x))%>%
  rename_with(~ paste0(.x, "_derivative"), matches("V")) %>% 
  mutate(enorm = sqrt(V1_derivative^2+V2_derivative^2+V3_derivative^2+V4_derivative^2+
                        V5_derivative^2+V6_derivative^2))





#fmriprep
r1 <- read.delim("~/Desktop/midmvpa/mid_data/derivatives/sub-01/func/sub-01_task-mid_run-1_desc-confounds_timeseries.tsv", header = T, sep = "\t") %>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-01")%>% 
  rowwise() %>% 
  mutate(motion_censor = ifelse(sum(motion_outlier00:motion_outlier67) > 0, 1, 0)) %>% 
  select(global_signal:rmsd,trans_x:rot_z_power2,run:motion_censor)

r2 <- read.delim("~/Desktop/midmvpa/mid_data/derivatives/sub-01/func/sub-01_task-mid_run-2_desc-confounds_timeseries.tsv", header = T, sep = "\t")%>% 
  mutate_all(~as.numeric(.x)) %>% 
  mutate(run = "run-02")%>% 
  rowwise() %>% 
  mutate(motion_censor = ifelse(sum(motion_outlier00:motion_outlier87) > 0, 1, 0))%>% 
  select(global_signal:rmsd,trans_x:rot_z_power2,run:motion_censor)

r_fp<- rbind(r1,r2) %>% 
  group_by(run) %>% 
  mutate(#enorm = framewise_displacement,  
         tr = row_number()) %>% 
  rename(V1=trans_x,V2=trans_y,V3=trans_z, V4=rot_x,V5=rot_y,V6=rot_z) %>% 
  group_by(run) %>% 
  mutate(euc_dist = sqrt(V1^2+V2^2+V3^2+V4^2+V5^2+V6^2),
         tr = row_number()) %>% 
  mutate(euc_dist = euc_dist-min(euc_dist))%>% 
  mutate_at(vars(V1:V6),~ .x - lag(.x))%>%
  rename_with(~ paste0(.x, "_derivative"), matches("V")) %>% 
  mutate(enorm = sqrt(V1_derivative^2+V2_derivative^2+V3_derivative^2+V4_derivative^2+
                        V5_derivative^2+V6_derivative^2))

ggplot(r_fp, aes(x = framewise_displacement, y = enorm, color = run))+
  geom_point()

ggplot(r_fp, aes(x = tr, y = euc_dist, color = run))+
  geom_line()

ggplot(r_fp, aes(x = tr, y = enorm, color = run))+
  geom_line()

print(paste("the mean Euclidean norm of run 1 using Freesurfer is: ",mean(r_fp$enorm[r_fp$run == "run-01"],na.rm = T)))
print(paste("the mean Euclidean norm of run 2 using Freesurfer is: ",mean(r_fp$enorm[r_fp$run == "run-02"],na.rm = T)))


ggplot(r_afni, aes(x = tr, y = euc_dist, color = run))+
  geom_line()+
  ylim(0,1)+
  labs(title = "AFNI")+
  
  ggplot(r_afni, aes(x = tr, y = enorm, color = run))+
  geom_line()+
  ylim(0,0.4)+
  
  ggplot(r_fsl_mi, aes(x = tr, y = euc_dist, color = run))+
  labs(title = "FSL coreg - mutualinfo")+
  geom_line()+
  ggplot(r_fsl_mi, aes(x = tr, y = enorm, color = run))+
  geom_line()+
  ylim(0,0.4)+
  
  ggplot(r_fsl_nc, aes(x = tr, y = euc_dist, color = run))+
  labs(title = "FSL coreg - normcorr")+
  geom_line()+
  ggplot(r_fsl_nc, aes(x = tr, y = enorm, color = run))+
  geom_line()+
  ylim(0,0.4)+
  
  ggplot(r_fsl, aes(x = tr, y = euc_dist, color = run))+
  labs(title = "FreeSurfer coreg")+
  geom_line()+
  ggplot(r_fsl, aes(x = tr, y = enorm, color = run))+
  geom_line()+
  ylim(0,0.4)+
  
  ggplot(r_fp, aes(x = tr, y = euc_dist, color = run))+
  labs(title = "fmriPrep coreg")+
  geom_line()+
  ggplot(r_fp, aes(x = tr, y = enorm, color = run))+
  geom_line()+
  ylim(0,0.4)+
  plot_layout(nrow = 5)

r <- cbind(r_fs %>%  ungroup() %>% select(enorm) %>% rename(enorm_fs = enorm),
           r_afni %>%  ungroup()%>% select(enorm) %>% rename(enorm_afni = enorm),
           r_fsl_mi %>%  ungroup()%>% select(enorm) %>% rename(enorm_fsl_mi = enorm),
           r_fsl_nc %>%  ungroup()%>% select(enorm) %>% rename(enorm_fsl_nc = enorm),
           r_fp %>%  ungroup()%>% select(enorm) %>% rename(enorm_fp = enorm)) %>% 
  mutate(tr = row_number())


(ggplot(r)+
    geom_line(aes(x = tr, y = enorm_afni), color = 'orange')+
    geom_line(aes(x = tr, y = enorm_fs), color = 'skyblue')+
    geom_line(aes(x = tr, y = enorm_fsl_mi), color = 'blue4')+
    geom_line(aes(x = tr, y = enorm_fsl_nc), color = 'purple')+
    geom_line(aes(x = tr, y = enorm_fp), color = 'salmon')+
    annotate("text",x = 0, y = 0.3, color = 'orange', label = "AFNI")+
    annotate("text",x = 0, y = 0.33, color = 'skyblue', label = "FreeSurfer")+
    annotate("text",x = 0, y = 0.27, color = 'blue4', label = "FSL-mutual")+
    annotate("text",x = 0, y = 0.24, color = 'purple', label = "FSL-normcorr")+
    annotate("text",x = 0, y = 0.21, color = 'salmon', label = "fmriPrep")+
    labs(y = "eucl. norm",
         title = "bn230418"))/
  
  (  ggplot(r, aes(x = enorm_afni, y = enorm_fs))+
       geom_point(size = 0.1)+
       geom_smooth(method = "lm")|
       
       ggplot(r, aes(x = enorm_afni, y = enorm_fsl_mi))+
       geom_point(size = 0.1)+
       geom_smooth(method = "lm")|
       
       ggplot(r, aes(x = enorm_fs, y = enorm_fsl_mi))+
       geom_point(size = 0.1)+
       geom_smooth(method = "lm")|
       
       ggplot(r, aes(x = enorm_afni, y = enorm_fp))+
       geom_point(size = 0.1)+
       geom_smooth(method = "lm"))

lm.beta::lm.beta(lm(enorm_afni~enorm_fs,r))
lm.beta::lm.beta(lm(enorm_afni~enorm_fsl_mi,r))
lm.beta::lm.beta(lm(enorm_fsl_mi~enorm_fsl_nc,r))
lm.beta::lm.beta(lm(enorm_fsl_mi~enorm_fs,r))
lm.beta::lm.beta(lm(enorm_fsl_nc~enorm_fs,r))
lm.beta::lm.beta(lm(enorm_afni~enorm_fsl_nc,r))
lm.beta::lm.beta(lm(enorm_afni~enorm_fp,r))
