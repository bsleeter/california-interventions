




scnID = c(243,244)
sheetNames = datasheet(myProject, scenario=scnID)


# State Class Area Output

mySQL = sqlStatement(groupBy=c("Timestep","StateClassID","StateLabelXID"),
                     aggregate=c("Amount"))
statePal = c("Agriculture:Agroforestry"="#AB6C28", "Agriculture:Annual"="#AB6C28", "Agriculture:Covercrop"="#AB6C28", "Agriculture:Perennial"="#804000", "Barren:All"="#b3ac9f", 
             "Developed:High"="#AB0000", "Developed:Low"="#D99282", "Developed:Medium"="#EB0000","Developed:Open"="#DEC5C5","Developed:Transportation"="#000000",
             "Forest:All"="#1C5F2C", "Forest:CFM"="#298940", "Forest:Treated (Prescribed)"="#4f925f", "Forest:Treated (Thinned)"="#42de67", 
             "Grassland:All"="#dfdfc2", "Grassland:Composted"="#bcbc7f", "Shrubland:All"="#ccb879", "Shrubland:PostFire"="#a1893d",
             "SnowIce:All"="#d1def8","Water:All"="#466B9F","Wetland:All"="#b8d9eb")

outputState = datasheet(myProject, scenario=scnID, name="OutputStratumState", sqlStatement=mySQL) %>% arrange(Timestep)
str(outputState)
head(outputState)

ggplot(outputState, aes(x=Timestep, y=Amount, color=StateClassID)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values=statePal) +
  facet_wrap(~StateLabelXID, scales="free_y")

ggplot(outputState, aes(x=Timestep, y=Amount, fill=StateClassID)) +
  geom_area() +
  scale_fill_manual(values=statePal) +
  facet_wrap(~StateLabelXID, scales="free_y")


# Transition Area Output

mySQL = sqlStatement(groupBy=c("Timestep","TransitionTypeID", "StateClassID", "EndStateClassID"), aggregate=c("Amount"))
mySQL = sqlStatement(groupBy=c("ScenarioID", "Timestep","TransitionTypeID", "StateClassID", "EndStateClassID"), aggregate=c("Amount"))

outputTransition = datasheet(myProject, scenario=scnID, name="stsim_OutputStratumTransitionState", sqlStatement=mySQL) %>% arrange(Timestep)
head(outputTransition)
unique(outputTransition$StateClassID)

fireTypes = c("Fire: High Severity", "Fire: Medium Severity", "Fire: Low Severity")
forestTypes = c("Forest:All", "Forest:Treated (Prescribed)", "Forest:Treated (Thinned)")
fireSevPal = c("Fire: High Severity"="#550000", "Fire: Medium Severity"="#ff0000", "Fire: Low Severity"="#ff6666")

fireAreabyState = outputTransition %>% filter(TransitionTypeID %in% fireTypes)
fireArea = outputTransition %>% filter(TransitionTypeID %in% fireTypes, StateClassID %in% forestTypes) %>% group_by(ScenarioID, Timestep, TransitionTypeID) %>% summarise(Amount=sum(Amount))
unique(fireArea$StateClassID)

ggplot(fireArea, aes(x=Timestep,y=Amount, fill=TransitionTypeID)) +
  geom_area() +
  scale_fill_manual(values=fireSevPal) +
  facet_wrap(~ScenarioID)

sevPct = fireArea %>% spread(TransitionTypeID, Amount) %>% rename(High='Fire: High Severity', Low='Fire: Low Severity', Medium='Fire: Medium Severity') %>% 
  mutate(Total=sum(High, Low, Medium)) %>% mutate(HighPct=High/Total, MedPct=Medium/Total, LowPct=Low/Total) %>% select(ScenarioID, Timestep, HighPct, MedPct, LowPct) %>% gather(Severity, Percent, 3:5)
sevPct

ggplot(sevPct, aes(x=Timestep, y=Percent, color=factor(ScenarioID))) +
  geom_line() +
  geom_smooth(method="lm") +
  facet_wrap(~Severity)

