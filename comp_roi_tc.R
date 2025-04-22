library(readr)
library(dplyr)
library(ggplot2)
library(patchwork)
library(tidyr)

my.methods = c("nomc","afni","fsl-mi","fsl-nc","freesurfer","fmriprep")
my.subjects = c("cw231123","bn230418")
r_all <- NULL
for (s in my.subjects){
  for (m in my.methods){
  r1 <- read.delim(paste0("~/Downloads/comp/mc_all/",m,"/roi_ts/",s,"_mid_b4_nacc8mm.1D"), header = F, sep = "") %>% 
    mutate(method = m,
           subject = s,
           tr = row_number())
  r_all <- rbind(r_all,r1)
  }
}

r_all <- r_all %>% 
  pivot_wider(names_from = "method", values_from = V1)

PerformanceAnalytics::chart.Correlation(r_all %>% filter(subject =="bn230418") %>% select(-subject,-tr))
PerformanceAnalytics::chart.Correlation(r_all %>% filter(subject =="cw231123") %>% select(-subject,-tr))

ggplot(r_all)+
  geom_line(aes(x = tr, y = nomc), color = 'orange', linewidth = 0.5)+
  geom_line(aes(x = tr, y = afni), color = 'skyblue', linewidth = 0.5)+
  geom_line(aes(x = tr, y = `fsl-mi`), color = 'purple', linewidth = 0.5)+
  geom_line(aes(x = tr, y = `fsl-nc`), color = 'violet', linewidth = 0.5)+
  geom_line(aes(x = tr, y = fmriprep), color = 'red', linewidth = 0.5)+

  annotate("text",x = -1, y = 2.5, color = 'orange', label = "no mc")+
  annotate("text",x = -1, y = 2, color = 'skyblue', label = "AFNI")+
  annotate("text",x = -1, y = 1, color = 'purple', label = "FSL-mutual")+
  annotate("text",x = -1, y = 1.5, color = 'red', label = "fmriprep")+
  annotate("text",x = -1, y = 0.5, color = 'violet', label = "FSL-normcorr")+
  theme_bw()+
  labs(y = "nacc % signal change",
       title = "effect of motion correction on nacc average signal",
       subtitle = "holding preprocessing constant")+
  facet_wrap(~subject,nrow = 2)


ggplot(r_all)+
  geom_line(aes(x = tr, y = nomc), color = 'orange', linewidth = 0.5)+
  geom_line(aes(x = tr, y = afni), color = 'skyblue', linewidth = 0.5)+
  annotate("text",x = -1, y = 2.5, color = 'orange', label = "no mc")+
  annotate("text",x = -1, y = 2, color = 'skyblue', label = "AFNI")+
  theme_bw()+
  facet_wrap(~subject,nrow = 2)

ggplot(r_all)+
  # geom_line(aes(x = tr, y = afni), color = 'skyblue', linewidth = 0.5)+
  geom_line(aes(x = tr, y = `fsl-mi`), color = 'blue4', linewidth = 0.5)+
  geom_line(aes(x = tr, y = nomc), color = 'orange', linewidth = 0.5)+
  annotate("text",x = -1, y = 2.5, color = 'orange', label = "no mc")+
  # annotate("text",x = -1, y = 2, color = 'skyblue', label = "AFNI")+
  annotate("text",x = -1, y = 1.5, color = 'blue4', label = "FreeSurfer")



nacc_tc_b4 <- read_csv("~/Downloads/comp/nacc_tc/timecourses_b4_long.csv") %>% 
  filter(voi %in% c("nacc8mm")) %>%
  mutate(cue_value = factor(trialtype, levels = 1:6, labels = c("-$0","-$1","-$5","+$0","+$1","+$5"))) 

nacc_tc_b4_all <- nacc_tc_b4 %>% 
  group_by(subject,voi,method) %>% 
  mutate(id = row_number())

ggplot(nacc_tc_b4_all %>% filter(voi == "nacc8mm"), aes(x = id, y = BOLD, group = method, 
                               fill = method))+
  geom_line(aes(color = method))+
  facet_wrap(~subject, nrow = 2)+
  theme_bw()+
  scale_fill_brewer(palette = "Paired")+
  scale_color_brewer(palette = "Paired")

nacc_tc_b4_summary <- nacc_tc_b4 %>% 
  filter(cue_value %in% c("+$0","+$5")) %>% 
  group_by(subject,voi,method,tr,cue_value) %>% 
  summarise(mBOLD = mean(BOLD,na.rm = T),
            seBOLD = sd(BOLD,na.rm = T)/ sqrt(n()))

ggplot(nacc_tc_b4_summary, aes(x = tr, y = mBOLD, group = method, 
                               fill = method))+
  geom_line(aes(color = method,linetype = cue_value), linewidth = 1)+
  geom_ribbon(aes(group=method,ymin = mBOLD - seBOLD, ymax = mBOLD + seBOLD),
              alpha = 0.1)+
  facet_wrap(~subject+cue_value, nrow = 1)+
  theme_bw()+
  scale_x_continuous(breaks = 1:10)+
  labs(title = "average time course")

nacc_tc_b4_summary_cueval <- nacc_tc_b4 %>%
  group_by(subject,voi,method,tr,cue_value) %>%
  summarise(mBOLD = mean(BOLD,na.rm = T),
            seBOLD = sd(BOLD,na.rm = T)/ sqrt(n()))

ggplot(nacc_tc_b4_summary_cueval %>% 
         filter(voi == "nacc8mm",
                cue_value %in% c("+$5","+$0")), aes(x = tr, y = mBOLD, group = cue_value, 
                                                    fill = cue_value))+
  geom_line(aes(color = cue_value))+
  geom_ribbon(aes(ymin = mBOLD - seBOLD, ymax = mBOLD + seBOLD),
              alpha = 0.2)+
  facet_wrap(~subject+method, nrow = 2)+
  theme_bw()+
  scale_fill_brewer(palette = "Set2")+
  scale_color_brewer(palette = "Set2")+
  scale_x_continuous(breaks = 1:10)

ggplot(nacc_tc_b4_summary_cueval %>% 
         filter(voi == "nacc8mm",
                cue_value %in% c("+$5","-$5","-$0")), aes(x = tr, y = mBOLD, group = cue_value, 
                                                    fill = cue_value))+
  geom_line(aes(color = cue_value))+
  geom_ribbon(aes(ymin = mBOLD - seBOLD, ymax = mBOLD + seBOLD),
              alpha = 0.2)+
  facet_wrap(~subject+method, nrow = 2)+
  theme_bw()+
  scale_fill_brewer(palette = "Dark2")+
  scale_color_brewer(palette = "Dark2")+
  scale_x_continuous(breaks = 1:10)

View(nacc_tc_b4_summary_cueval %>% filter(tr == 4, cue_value == "+$5",
                                          voi == "nacc8mm"))

View(nacc_tc_b4_summary_cueval %>% filter(tr == 5, cue_value == "+$5",
                                          voi == "nacc8mm"))

nacc_tc_b4_summary_hit <- nacc_tc_b4 %>% 
  group_by(subject,voi,method,tr,hit) %>% 
  summarise(mBOLD = mean(BOLD,na.rm = T),
            seBOLD = sd(BOLD,na.rm = T)/ sqrt(n())) %>% 
  mutate(hit = as.factor(hit))

ggplot(nacc_tc_b4_summary_hit %>% 
         filter(voi == "nacc8mm"), aes(x = tr, y = mBOLD, group = hit, 
                                                    fill = hit))+
  geom_line(aes(color = hit))+
  geom_ribbon(aes(ymin = mBOLD - seBOLD, ymax = mBOLD + seBOLD),
              alpha = 0.2)+
  facet_wrap(~subject+method, nrow = 2)+
  theme_bw()+
  scale_fill_brewer(palette = "Set1")+
  scale_color_brewer(palette = "Set1")+
  scale_x_continuous(breaks = 1:10)

nacc_tc_b4_summary_hit5 <- nacc_tc_b4 %>% 
  filter(cue_value == "+$5") %>% 
  group_by(subject,voi,method,tr,hit) %>% 
  summarise(mBOLD = mean(BOLD,na.rm = T),
            seBOLD = sd(BOLD,na.rm = T)/ sqrt(n())) %>% 
  mutate(hit = as.factor(hit))

ggplot(nacc_tc_b4_summary_hit5 %>% 
         filter(voi == "nacc8mm"), aes(x = tr, y = mBOLD, group = hit, 
                                       fill = hit))+
  geom_line(aes(color = hit))+
  geom_ribbon(aes(ymin = mBOLD - seBOLD, ymax = mBOLD + seBOLD),
              alpha = 0.2)+
  theme_bw()+
  scale_fill_brewer(palette = "Set1")+
  scale_color_brewer(palette = "Set1")+
  scale_x_continuous(breaks = 1:10)+
  facet_wrap(~subject+method,nrow =2)+
  labs(title = "+$5, hit vs .miss")

f1 <- nacc_tc_b4 %>% 
  filter(cue_value == "+$5") %>% 
  mutate(run = ifelse(trial <= 42, "run-01","run-02")) %>% 
  group_by(subject,voi, tr,method, run) %>% 
  summarise(mBOLD = mean(BOLD,na.rm = T),
            seBOLD = sd(BOLD,na.rm = T)/sqrt(n()))

ggplot(f1, aes(x = tr, y = mBOLD, group = method))+
  geom_line(aes(color = method),linewidth = 1)+
  geom_ribbon(aes(ymin = mBOLD-seBOLD,ymax = mBOLD+seBOLD, fill = method),
                width = 0.1, alpha = 0.1)+
  facet_wrap(~subject+run+voi)+
  theme_bw()+
  geom_hline(yintercept = 0, linetype = "dashed")+
  scale_x_continuous(breaks = 1:10)


