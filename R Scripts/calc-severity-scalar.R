# fire multipliers for hi-severity increase over time

require(tidyverse)

# Setup

fire_severity = read.csv("R Inputs/Data/mtbs/severity_by_ecoregion_2001_2014.csv")
fire_severity_base = fire_severity %>% mutate(Timestep=2002)
fire_severity = fire_severity %>% 
  mutate(TransitionGroupID=recode(TransitionGroupID, 
                                  'Fire: High Severity [Type]' = 'high', 
                                  'Fire: Medium Severity [Type]' = 'medium', 
                                  'Fire: Low Severity [Type]' = 'low'))
         


sl=0.0035
sh=0.0082
ts=rep(seq(2016,2100,1),12)
ts=sort(ts)

fs_high = fire_severity %>% filter(TransitionGroupID=="high")
fs = fire_severity %>% spread(TransitionGroupID, Amount)

d = data.frame(Timestep=ts,
               StratumID=rep(fs$StratumID,85),
               high=rep(fs$high,85),
               medium=rep(fs$medium,85),
               low=rep(fs$low,85))

# High Severity Increase based on full MTBS record

d1 = as_tibble(d) %>% mutate(HighMult=sl) %>% group_by(StratumID) %>% mutate(HighMult=1+cumsum(HighMult)) %>% mutate(newHigh=high*HighMult) %>%
  mutate(newMed=medium/(low+medium) * (1-newHigh), newLow=low/(low+medium) * (1-newHigh)) %>%
  mutate(MedMult=newMed/medium, LowMult=newLow/low) 
tail(d1)

d1_low = d1 %>% select(Timestep,StratumID,newHigh,newMed,newLow) %>% 
  gather(TransitionGroupID,Amount,3:5) %>%
  mutate(TransitionGroupID = replace(TransitionGroupID, TransitionGroupID=="newHigh", "Fire: High Severity [Type]")) %>%
  mutate(TransitionGroupID = replace(TransitionGroupID, TransitionGroupID=="newMed", "Fire: Medium Severity [Type]")) %>%
  mutate(TransitionGroupID = replace(TransitionGroupID, TransitionGroupID=="newLow", "Fire: Low Severity [Type]")) %>%
  bind_rows(fire_severity_base) %>% arrange(Timestep) %>%
  write_csv("R Inputs/Data/mtbs/fire-temporal-severity-multipliers-low.csv")
head(d1_low)
tail(d1_low)




# High Severity Increase based on past 20 years

d2 = as_tibble(d) %>% mutate(HighMult=sh) %>% group_by(StratumID) %>% mutate(HighMult=1+cumsum(HighMult)) %>% mutate(newHigh=high*HighMult) %>%
  mutate(newMed=medium/(low+medium) * (1-newHigh), newLow=low/(low+medium) * (1-newHigh)) %>%
  mutate(MedMult=newMed/medium, LowMult=newLow/low) 
tail(d2)

d2_high = d2 %>% select(Timestep,StratumID,newHigh,newMed,newLow) %>% 
  gather(TransitionGroupID,Amount,3:5) %>%
  mutate(TransitionGroupID = replace(TransitionGroupID, TransitionGroupID=="newHigh", "Fire: High Severity [Type]")) %>%
  mutate(TransitionGroupID = replace(TransitionGroupID, TransitionGroupID=="newMed", "Fire: Medium Severity [Type]")) %>%
  mutate(TransitionGroupID = replace(TransitionGroupID, TransitionGroupID=="newLow", "Fire: Low Severity [Type]")) %>%
  bind_rows(fire_severity_base) %>% arrange(Timestep)  %>%
  write_csv("R Inputs/Data/mtbs/fire-temporal-severity-multipliers-high.csv")
tail(d2_high)






ggplot(d2, aes(x=Timestep, y=newHigh, color=StratumID)) +
  geom_line()



























