#-----------------------------------------------------------------------------------
# R Scripts used to build a LUCAS Model for the State of California
# Script 1 of 4
# Define SyncroSim project and create Project Definitions

#-----------------------------------------------------------------------------------
# Created by: Benjamin M. Sleeter
# U.S. Geological Survey, Western Geographic Science Center
# bsleeter@usgs.gov
# Date of creation: December 5, 2017

# Load packages
library(raster)
library(rasterVis)
library(tidyverse)
library(rsyncrosim)

#####  ===================================================================================================
# SECTION 1: Setup Model Library and Project =============================================================
#####  ===================================================================================================


# Set the Syncro Sim program directory
programFolder = "C:/Users/bsleeter.GS/Downloads/Applications/SyncroSim/syncrosim-windows-2-1-15" # Set this to location of SyncroSim installation

# Start a SyncroSim session
mySession = session(programFolder) # Start a session with SyncroSim

# Set the current working directory
setwd("E:/california-carbon-futures/build/model_base/ccf_v5/") # Check this is correct for your computer!
getwd() # Show the current working directory

# Create and setup a new Library
myLibrary = ssimLibrary(name = "ccf_v5", session = mySession,)
list.files() # Check that the new library was created on disk

# Display internal names of all the library's datasheets - corresponds to the the 'File-Library Properties' menu in SyncroSim
datasheet(myLibrary, summary = T)

# Get the current values for the Library's Backup Datasheet
sheetData = datasheet(myLibrary, name = "SSim_Backup", empty = T) # Get the current backup settings for the library
sheetData

# Modify the values for the Library's Backup Datasheet
sheetData = addRow(sheetData, data.frame(IncludeInput=TRUE, IncludeOutput=FALSE, BeforeUpdate=TRUE)) # Add a new row to this dataframe
saveDatasheet(myLibrary, data = sheetData, name = "SSim_Backup") # Save the new dataframe back to the library
datasheet(myLibrary, "SSim_Backup")

# Get the current values for the Library's Modules
package(mySession)

# Check if stock flow add-on is enabled for the library
addon(myLibrary)

# Enable stock flow add-on
enableAddon(myLibrary, 'stsim-stockflow') # Enable to Stock and Flow module
#enableAddon(myLibrary, 'stsim-ecodep') # Enable the ecological departure modeule
addon(myLibrary)

# Create or open a new project
myProject = project(myLibrary, project = "ccf_v5") # Also creates a new project (if it doesn't exist already)
project(myLibrary, summary = TRUE)
















#####  ===================================================================================================
# SECTION 2: Project Properties ==========================================================================
#####  ===================================================================================================

# Display internal names of all the project's datasheets - corresponds to the Project Properties in SyncroSim#####
projectSheetNames = datasheet(myProject, summary = T)
projectSheetNames

# Terminology
sheetData = datasheet(myProject, "STSim_Terminology")
sheetData
sheetData$AmountLabel[1] = "Area"
sheetData$AmountUnits[1] = "Square Kilometers"
sheetData$StateLabelX[1] = "LULC Class"
sheetData$StateLabelY[1] = "Subclass"
sheetData$PrimaryStratumLabel[1] = "Ecoregion"
sheetData$SecondaryStratumLabel[1] = "County"
sheetData$TertiaryStratumLabel[1] = "Ownership"
sheetData$TimestepUnits[1] = "Year"
saveDatasheet(myProject, sheetData, "STSim_Terminology")
datasheet(myProject, "STSim_Terminology")































#####  ===================================================================================================
# SECTION 3: Project Definitions =========================================================================
#####  ===================================================================================================

# Strata Project Definitions -----------------------------------------------------------------------------------

# Define Primary Stratum (Ecoregions)
sheetData = datasheet(myProject, "STSim_Stratum", empty = T, optional = T) # Returns empty dataframe with only required column(s)
ecoregions = read.csv("R Inputs/Ecoregion.csv", header = T) # Read in a list of ecoregions and unique ID's
saveDatasheet(myProject, ecoregions, "STSim_Stratum", force = T, append = F)
datasheet(myProject, "STSim_Stratum", optional = T) # Returns entire dataframe, including optional columns

# Define Secondary Stratum (Counties)
sheetData = datasheet(myProject, "STSim_SecondaryStratum", empty = T, optional = T) # Returns empty dataframe with only required column(s)
counties = read.csv("R Inputs/County.csv", header = T) # Read in a list of counties and unique ID's
saveDatasheet(myProject, counties, "STSim_SecondaryStratum", force = T, append = F)
datasheet(myProject, "STSim_SecondaryStratum", optional = T) # Returns entire dataframe, including optional columns

# Define Tertiary Stratum (Ownership)
sheetData = datasheet(myProject, "STSim_TertiaryStratum", empty = T, optional = T) # Returns empty dataframe with only required column(s)
sheetData = addRow(sheetData, data.frame(Name = "Federal", ID = 1))
sheetData = addRow(sheetData, data.frame(Name = "Non Federal", ID = 2))
sheetData = addRow(sheetData, data.frame(Name = "Private", ID = 3))
sheetData = addRow(sheetData, data.frame(Name = "Tribal", ID = 4))
saveDatasheet(myProject, sheetData, "STSim_TertiaryStratum", force = T, append = F)
datasheet(myProject, "STSim_TertiaryStratum", optional = T) # Returns entire dataframe, including optional columns


# State Class Project Definitions-----------------------------------------------------------------------------------

# First State Class Label (LULC Class)
sheetData = datasheet(myProject, "STSim_StateLabelX", empty = T, optional = T)
lulcTypes = c("Water", "Developed", "Barren", "Grassland", "Forest", "Shrubland", "Wetland", "SnowIce", "Agriculture")
saveDatasheet(myProject, data.frame(Name = lulcTypes), "STSim_StateLabelX", force = T, append = F)

# Second State Class Label (Subclass)
sheetData = datasheet(myProject, "STSim_StateLabelY", empty = T, optional = T)
subclassTypes = c("All", "Perennial", "Annual", "Transportation", "Agroforestry", "Covercrop", "PostFire", "Treated (Thinned)", "Treated (Prescribed)", "CFM", "Composted",
                  "Open","Low","Medium","High")
saveDatasheet(myProject, data.frame(Name = subclassTypes), "STSim_StateLabelY", force = T, append = F)

# State Classes
stateClasses = datasheet(myProject, name = "STSim_StateClass", empty = T, optional = T)
stateClasses = addRow(stateClasses, data.frame(Name = "Water:All", StateLabelXID = "Water", StateLabelYID = "All", ID = 1))
stateClasses = addRow(stateClasses, data.frame(Name = "SnowIce:All", StateLabelXID = "SnowIce", StateLabelYID = "All", ID = 11))
stateClasses = addRow(stateClasses, data.frame(Name = "Wetland:All", StateLabelXID = "Wetland", StateLabelYID = "All", ID = 9))
stateClasses = addRow(stateClasses, data.frame(Name = "Barren:All", StateLabelXID = "Barren", StateLabelYID = "All", ID = 5))
stateClasses = addRow(stateClasses, data.frame(Name = "Grassland:All", StateLabelXID = "Grassland", StateLabelYID = "All", ID = 7))
stateClasses = addRow(stateClasses, data.frame(Name = "Shrubland:All", StateLabelXID = "Shrubland", StateLabelYID = "All", ID = 10))
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:All", StateLabelXID = "Forest", StateLabelYID = "All", ID = 6))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:Open", StateLabelXID = "Developed", StateLabelYID = "Open", ID = 21))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:Low", StateLabelXID = "Developed", StateLabelYID = "Low", ID = 22))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:Medium", StateLabelXID = "Developed", StateLabelYID = "Medium", ID = 23))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:High", StateLabelXID = "Developed", StateLabelYID = "High", ID = 24))
stateClasses = addRow(stateClasses, data.frame(Name = "Developed:Transportation", StateLabelXID = "Developed", StateLabelYID = "Transportation", ID = 25))
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Annual", StateLabelXID = "Agriculture", StateLabelYID = "Annual", ID = 8))
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Perennial", StateLabelXID = "Agriculture", StateLabelYID = "Perennial", ID = 12))
stateClasses = addRow(stateClasses, data.frame(Name = "Shrubland:PostFire", StateLabelXID = "Shrubland", StateLabelYID = "PostFire", ID = 15)) # Post-Fire (high severity) class
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:Treated (Thinned)", StateLabelXID = "Forest", StateLabelYID = "Treated (Thinned)", ID = 61)) # Interventions - Thinning from below
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:Treated (Prescribed)", StateLabelXID = "Forest", StateLabelYID = "Treated (Prescribed)", ID = 62)) # Interventions - Prescribed Fire
stateClasses = addRow(stateClasses, data.frame(Name = "Forest:CFM", StateLabelXID = "Forest", StateLabelYID = "CFM", ID = 63)) # Interventions - Changes to Forest Management Class
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Agroforestry", StateLabelXID = "Agriculture", StateLabelYID = "Agroforestry", ID = 13)) # Interventions - Agroforestry
stateClasses = addRow(stateClasses, data.frame(Name = "Agriculture:Covercrop", StateLabelXID = "Agriculture", StateLabelYID = "Covercrop", ID = 14)) # Interventions - Covercrops
stateClasses = addRow(stateClasses, data.frame(Name = "Grassland:Composted", StateLabelXID = "Grassland", StateLabelYID = "Composted", ID = 71)) # Interventions - Grassland compost ammendments
saveDatasheet(myProject, stateClasses, "STSim_StateClass", force = T, append = F)


# Transition Project Definitions-----------------------------------------------------------------------------------

# Transition Types
transitionTypes = datasheet(myProject, name = "STSim_TransitionType", empty = T, optional = T)
# Ag Change
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Change: Annual to Perennial", ID = "1"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Change: Perennial to Annual", ID = "2"))
# Ag Contraction
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Annual to Grassland", ID = "10"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Annual to Shrubland", ID = "11"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Annual to Forest", ID = "12"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Annual to Wetland", ID = "13"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Perennial to Grassland", ID = "15"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Perennial to Shrubland", ID = "16"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Perennial to Forest", ID = "17"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Contraction: Perennial to Wetland", ID = "18"))
# Ag Expansion
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Expansion: Annual", ID = "20"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Ag Expansion: Perennial", ID = "23"))
# Urbanization
transitionTypes = addRow(transitionTypes, data.frame(Name = "Urbanization: Open", ID = "30"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Urbanization: Low", ID = "31"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Urbanization: Medium", ID = "32"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Urbanization: High", ID = "33"))
# Urban Intensification
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intensification: Open to Low", ID = "34"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intensification: Open to Medium", ID = "35"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intensification: Open to High", ID = "36"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intensification: Low to Medium", ID = "37"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intensification: Low to High", ID = "38"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intensification: Medium to High", ID = "39"))
# WildFire and Disturbance
transitionTypes = addRow(transitionTypes, data.frame(Name = "Fire: High Severity", ID = "40"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Fire: Medium Severity", ID = "41"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Fire: Low Severity", ID = "42"))
# Insect and Drought Mortality
transitionTypes = addRow(transitionTypes, data.frame(Name = "Drought: High Severity", ID = "50"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Drought: Medium Severity", ID = "51"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Drought: Low Severity", ID = "52"))
# Management Actions
transitionTypes = addRow(transitionTypes, data.frame(Name = "Management: Forest Clearcut", ID = "60"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Management: Forest Selection", ID = "61"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Management: Orchard Removal", ID = "62"))
# Intervention Activities
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Reforestation", ID = "100")) # Only applied for areas that experience a type converison to shrubland post high severity Fire
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Thinning From Below", ID = "101"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Prescribed Fire", ID = "102"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Woodland Restoration", ID = "103")) # focused on oak woodland restoration
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Agroforestry", ID = "104")) # Pathways added for both perennial and annual, need new NPP rates...
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Covercrop", ID = "105")) # Pathways added for both perennial and annual, change straw removal rates
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Riparian Restoration", ID = "106")) # Pathways added for both perennial and annual, change straw removal rates
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Wetland Restoration", ID = "107")) # Conversion of ag to wetland
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: CFM", ID = "108")) # Conversion to alternative forest management class
transitionTypes = addRow(transitionTypes, data.frame(Name = "Intervention: Compost", ID = "109")) # Conversion to alternative forest management class

# Successional Pathways
transitionTypes = addRow(transitionTypes, data.frame(Name = "Succession: Post Fire Recovery", ID = "120"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Succession: Thinning From Below", ID = "121"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Succession: Prescribed Fire", ID = "122")) # Transition from "Shrubland:PostFire" to "Forest" based on adjacency and recovery rates. Data from Thorne makes some cells "0" which can never recover to forest
transitionTypes = addRow(transitionTypes, data.frame(Name = "Succession: Permanent Shrub Conversion", ID = "123"))
transitionTypes = addRow(transitionTypes, data.frame(Name = "Succession: From CFM", ID = "124")) # Conversion back from alternative forest management class
transitionTypes = addRow(transitionTypes, data.frame(Name = "Succession: From Compost", ID = "125")) # Conversion back from composted grassland class
saveDatasheet(myProject, transitionTypes, "STSim_TransitionType", force = T, append = F)






# Transition Groups
transitionGroups = datasheet(myProject, name = "STSim_TransitionGroup", empty = T, optional = T)

transitionGroups = addRow(transitionGroups, data.frame(Name = "Ag Change"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Ag Expansion"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Ag Contraction"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Urbanization"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Intensification"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Fire"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Drought"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Harvest"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Intervention"))
transitionGroups = addRow(transitionGroups, data.frame(Name = "Succession"))
saveDatasheet(myProject, transitionGroups, "STSim_TransitionGroup", force = T, append = F)



# Transition Types by Groups
transitionTypebyGroup = datasheet(myProject, name = "STSim_TransitionTypeGroup", empty = T, optional = T)

# Ag Change
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Change: Annual to Perennial", TransitionGroupID = "Ag Change"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Change: Perennial to Annual", TransitionGroupID = "Ag Change"))

# Ag Contraction
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Annual to Grassland", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Annual to Shrubland", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Annual to Forest", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Annual to Wetland", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Grassland", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Shrubland", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Forest", TransitionGroupID = "Ag Contraction"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Wetland", TransitionGroupID = "Ag Contraction"))

# Ag Expansion
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Expansion: Annual", TransitionGroupID = "Ag Expansion"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Ag Expansion: Perennial", TransitionGroupID = "Ag Expansion"))

# Urbanization
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Urbanization: Open", TransitionGroupID = "Urbanization"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Urbanization: Low", TransitionGroupID = "Urbanization"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Urbanization: Medium", TransitionGroupID = "Urbanization"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Urbanization: High", TransitionGroupID = "Urbanization"))

# Intensification
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Intensification: Open to Low", TransitionGroupID = "Intensification"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Intensification: Open to Medium", TransitionGroupID = "Intensification"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Intensification: Open to High", TransitionGroupID = "Intensification"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Intensification: Low to Medium", TransitionGroupID = "Intensification"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Intensification: Low to High", TransitionGroupID = "Intensification"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Intensification: Medium to High", TransitionGroupID = "Intensification"))

# Fire
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Fire: High Severity", TransitionGroupID = "Fire"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Fire: Medium Severity", TransitionGroupID = "Fire"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Fire: Low Severity", TransitionGroupID = "Fire"))

# Insects
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Drought: High Severity", TransitionGroupID = "Drought"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Drought: Medium Severity", TransitionGroupID = "Drought"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Drought: Low Severity", TransitionGroupID = "Drought"))

# Forest Harvest
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Management: Forest Clearcut", TransitionGroupID = "Harvest"))
transitionTypebyGroup = addRow(transitionTypebyGroup, data.frame(TransitionTypeID = "Management: Forest Selection", TransitionGroupID = "Harvest"))

saveDatasheet(myProject, transitionTypebyGroup, "STSim_TransitionTypeGroup", append = F)


# Transition Simulation Group
transitionSimulationGroup = datasheet(myProject, name="STSim_TransitionSimulationGroup", empty = F, optional = T)
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "Ag Contraction"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "Ag Expansion"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "Urbanization"))
transitionSimulationGroup = addRow(transitionSimulationGroup, data.frame(TransitionGroupID = "Fire"))
saveDatasheet(myProject, transitionSimulationGroup, "STSim_TransitionSimulationGroup", force = T, append = F)

# Age Project Definitions-----------------------------------------------------------------------------------
# 

# Ages are being turned off here due to increases in ssim output database - un-comment in order to turn on and re-run models 
#ageFrequency = 20
#ageMax = 500
#ageGroups = c(20, 40, 60, 80, 100, 120, 140, 160, 180, 200)
#saveDatasheet(myProject, data.frame(Frequency = ageFrequency, MaximumAge = ageMax), "STSim_AgeType", force = T)
#saveDatasheet(myProject, data.frame(MaximumAge = ageGroups), "STSim_AgeGroup", force = T)




# Attributes Project Definitions-----------------------------------------------------------------------------------
# 

# Attribute Groups
attributeGroup = datasheet(myProject, name = "STSim_AttributeGroup", empty = T, optional = F)
attributeGroup = c("Adjacency", "Albedo", "Carbon Initial Conditions", "Carbon NPP", "Demographic", "Forest Age")
saveDatasheet(myProject, data.frame(Name = attributeGroup), "STSim_AttributeGroup", force = T, append = F)

# Attribute Types
attributeType = datasheet(myProject, name = "STSim_StateAttributeType", empty = T, optional = T)
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Agriculture", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Agroforestry", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Annual", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Covercrop", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Perennial", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Barren", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Developed", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Developed Open", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Developed Low", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Developed Medium", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Developed High", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Transportation", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest Prescribed", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest Thinned", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Forest CFM", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Grassland", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Grassland Composted", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Shrubland", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-ShrubPostFire", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Wetland", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Water", AttributeGroupID = "Adjacency", Units = "km2"))
attributeType = addRow(attributeType, data.frame(Name = "ADJ-Natural", AttributeGroupID = "Adjacency", Units = "km2"))

attributeType = addRow(attributeType, data.frame(Name = "Albedo", AttributeGroupID = "Albedo", Units = "Percent"))
attributeType = addRow(attributeType, data.frame(Name = "Households", AttributeGroupID = "Demographic", Units = "Households"))
attributeType = addRow(attributeType, data.frame(Name = "Population", AttributeGroupID = "Demographic", Units = "Persons"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Living Biomass", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Standing Deadwood", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Down Deadwood", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Litter", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Initial Conditions: Soil", AttributeGroupID = "Carbon Initial Conditions", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "NPP", AttributeGroupID = "Carbon NPP", Units = "kgC/m2"))
attributeType = addRow(attributeType, data.frame(Name = "Compost Addition", AttributeGroupID = "Carbon NPP", Units = "kgC/m2"))
saveDatasheet(myProject, attributeType, "STSim_StateAttributeType", force = T, append = F)





# Distributions and External Variables Project Definitions-----------------------------------------------------------------------------------
# 

# Distributions
distributions = datasheet(myProject, name = "STime_DistributionType", empty = T, optional = T)
distributions = c("Historical Rate: Ag Contraction", "Historical Rate: Ag Expansion", "Historical Rate: Fire", "Historical Rate: Forest Clearcut", "Historical Rate: Forest Selection", "Historical Rate: Forest Harvest",
                  "Historical Rate: Urbanization", "Historical Rate: Drought High Severity", "Historical Rate: Drought Medium Severity", "Historical Rate: Drought Low Severity")
saveDatasheet(myProject, data.frame(Name = distributions), "STime_DistributionType", force = T, append = F)

# External Variables
externalVariables = datasheet(myProject, name = "STime_ExternalVariableType", empty = T, optional = T)
externalVariables = c("Historical Year: Ag Change", "Historical Year: Ag Contraction", "Historical Year: Ag Expansion", "Historical Year: All Change", "Historical Year: Fire",
                      "Historical Year: Forest Harvest", "Historical Year: Land Use Change", "Historical Year: Urbanization", "Historical Year: Drought")
saveDatasheet(myProject, data.frame(Name = externalVariables), "STime_ExternalVariableType", force = T, append = F)





# Stock and Flow Project Definitions-----------------------------------------------------------------------------------
# 

# Stock Flow Terminology
sheetData = datasheet(myProject, name = "SF_Terminology", optional = T)
saveDatasheet(myProject, data.frame(StockUnits = "Kilotons"), "SF_Terminology", force = T)

# Stock Groups
stockGroup = datasheet(myProject, name = "SF_StockGroup", empty = T, optional = T)
stockGroup = c("Harvested Wood Products", "Total Deadwood", "DOM", "Total Ecosystem Carbon")
saveDatasheet(myProject, data.frame(Name = stockGroup), "SF_StockGroup", force = T, append = F)

# Stock Types
stockType = datasheet(myProject, name = "SF_StockType", empty = T, optional = T)
stockType = c("Aquatic", "Atmosphere", "Down Deadwood", "Grain", "HWP (Extracted)", "Litter", "Living Biomass", "Soil", "Standing Deadwood", "Straw", "Compost")
saveDatasheet(myProject, data.frame(Name = stockType), "SF_StockType", force = T, append = F)

# Flow Groups
flowGroup = datasheet(myProject, name = "stsimsf_FlowGroup", empty = T, optional = T)
flowGroup = c("Net Biome Productivity (NBP)", "Net Ecosystem Productivity (NEP)", "Net Primary Productivity (NPP)", "Composting")
saveDatasheet(myProject, data.frame(Name = flowGroup), "stsimsf_FlowGroup", force = T, append = F)

# Flow Types
flowType = datasheet(myProject, name = "SF_FlowType", empty = T, optional = T)
flowType = c("Decay", "Decomposition", "Deadfall", "Emission", "Emission (biomass)", "Emission (grain)", "Emission (litter)", "Emission (soil)", "Emission (straw)", "Growth", "Harvest",
             "Harvest (grain)", "Harvest (straw)", "Leaching", "Litterfall", "Mortality", "Mortality (Drought high)", "Mortality (Drought medium)", "Mortality (Drought low)", "Composting")
saveDatasheet(myProject, data.frame(Name = flowType), "SF_FlowType", force = T, append = F)


# Flow Multiplier Types
flowMultType = datasheet(myProject, name="SF_FlowMultiplierType", empty=T, optional=T)
flowMultType = c("Composting", "CFE", "Q10", "Climate")
saveDatasheet(myProject, data.frame(Name=flowMultType), "SF_FlowMultiplierType", force=T, append=F)

# Display the internal names of all the scenario datasheets
scenarioSheetNames = datasheet(myProject, summary = T)
scenarioSheetNames






















#####  ===================================================================================================
# SECTION 3: Create STSM Sub Scenarios ===================================================================
#####  ===================================================================================================

##### Run Control ##### 

runControl = scenario(myProject, "Run Control [100TS; 100MC]", overwrite=F, create=T)
sheetName = "STSim_RunControl"
sheetData = datasheet(myProject, sheetName, scenario = "Run Control [100TS; 100MC]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(MaximumIteration = 100, MinimumTimestep = 2001, MaximumTimestep = 2101, IsSpatial = T))
saveDatasheet(runControl, sheetData, sheetName, append = F)

runControl = scenario(myProject, "Run Control [100TS; 1MC]", overwrite=F, create=T)
sheetName = "STSim_RunControl"
sheetData = datasheet(myProject, sheetName, scenario = "Run Control [100TS; 1MC]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(MaximumIteration = 1, MinimumTimestep = 2001, MaximumTimestep = 2101, IsSpatial = T))
saveDatasheet(runControl, sheetData, sheetName, append = F)

runControl = scenario(myProject, "Run Control [20TS; 1MC]", overwrite=F, create=T)
sheetName = "STSim_RunControl"
sheetData = datasheet(myProject, sheetName, scenario = "Run Control [20TS; 1MC]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(MaximumIteration = 1, MinimumTimestep = 2001, MaximumTimestep = 2021, IsSpatial = T))
saveDatasheet(runControl, sheetData, sheetName, append = F)




##### Pathway Diagrams ##### 
pathways = scenario(myProject, "Pathways", overwrite=F)

# States
sheetName = "STSim_DeterministicTransition"
sheetData = datasheet(myProject, sheetName, scenario = "Pathways", optional = T, empty = T)

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Open", StateClassIDDest = "Developed:Open", Location = "A1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Low", StateClassIDDest = "Developed:Low", Location = "B1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Medium", StateClassIDDest = "Developed:Medium", Location = "C1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:High", StateClassIDDest = "Developed:High", Location = "D1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Transportation", StateClassIDDest = "Developed:Transportation", Location = "E1"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Annual", Location = "A2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Agriculture:Perennial", Location = "B2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Covercrop", StateClassIDDest = "Agriculture:Covercrop", Location = "C2"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Agroforestry", StateClassIDDest = "Agriculture:Agroforestry", Location = "D2"))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", Location = "A3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Thinned)", Location = "B3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:Treated (Prescribed)", Location = "C3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Shrubland:PostFire", Location = "D3"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", Location = "E3"))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Wetland:All", Location = "A4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", Location = "B4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:Composted", StateClassIDDest = "Grassland:Composted", Location = "C4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", Location = "D4"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Water:All", StateClassIDDest = "Water:All", Location = "A5"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Barren:All", StateClassIDDest = "Barren:All", Location = "B5"))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "SnowIce:All", StateClassIDDest = "SnowIce:All", Location = "C5"))

saveDatasheet(pathways, sheetData, sheetName, append = F)

# Probabilistic Transitions
sheetName = "STSim_Transition"
sheetData = datasheet(myProject, sheetName, scenario = "Pathways", optional = T, empty = T)

# Ag Change
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "Ag Change: Annual to Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "Ag Change: Perennial to Annual", Probability = 1.0, AgeMax = 1, TSTMax = 1))

# Ag Contraction
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Grassland:All", TransitionTypeID = "Ag Contraction: Annual to Grassland", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Shrubland:All", TransitionTypeID = "Ag Contraction: Annual to Shrubland", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Forest:All", TransitionTypeID = "Ag Contraction: Annual to Forest", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Wetland:All", TransitionTypeID = "Ag Contraction: Annual to Wetland", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Grassland:All", TransitionTypeID = "Ag Contraction: Perennial to Grassland", Probability = 1.0, AgeMax = 1, TSTMax = 1))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Shrubland:All", TransitionTypeID = "Ag Contraction: Perennial to Shrubland", Probability = 1.0, AgeMax = 1, TSTMax = 1))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Forest:All", TransitionTypeID = "Ag Contraction: Perennial to Forest", Probability = 1.0, AgeMax = 1, TSTMax = 1))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Wetland:All", TransitionTypeID = "Ag Contraction: Perennial to Wetland", Probability = 1.0, AgeMax = 1, TSTMax = 1))
# Ag Expansion
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "Ag Expansion: Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "Ag Expansion: Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "Ag Expansion: Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Agriculture:Annual", TransitionTypeID = "Ag Expansion: Annual", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "Ag Expansion: Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "Ag Expansion: Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "Ag Expansion: Perennial", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "Ag Expansion: Perennial", Probability = 1.0))
# Urbanization
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Developed:Open", TransitionTypeID = "Urbanization: Open", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Developed:Low", TransitionTypeID = "Urbanization: Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Urbanization: Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Developed:High", TransitionTypeID = "Urbanization: High", Probability = 1.0))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Developed:Open", TransitionTypeID = "Urbanization: Open", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Developed:Low", TransitionTypeID = "Urbanization: Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Urbanization: Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Developed:High", TransitionTypeID = "Urbanization: High", Probability = 1.0))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Developed:Open", TransitionTypeID = "Urbanization: Open", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Developed:Low", TransitionTypeID = "Urbanization: Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Urbanization: Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Developed:High", TransitionTypeID = "Urbanization: High", Probability = 1.0))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Developed:Open", TransitionTypeID = "Urbanization: Open", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Developed:Low", TransitionTypeID = "Urbanization: Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Urbanization: Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Wetland:All", StateClassIDDest = "Developed:High", TransitionTypeID = "Urbanization: High", Probability = 1.0))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Developed:Open", TransitionTypeID = "Urbanization: Open", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Developed:Low", TransitionTypeID = "Urbanization: Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Urbanization: Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Developed:High", TransitionTypeID = "Urbanization: High", Probability = 1.0))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Developed:Open", TransitionTypeID = "Urbanization: Open", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Developed:Low", TransitionTypeID = "Urbanization: Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Urbanization: Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Developed:High", TransitionTypeID = "Urbanization: High", Probability = 1.0))

# Intensification
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Open", StateClassIDDest = "Developed:Low", TransitionTypeID = "Intensification: Open to Low", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Open", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Intensification: Open to Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Open", StateClassIDDest = "Developed:High", TransitionTypeID = "Intensification: Open to High", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Low", StateClassIDDest = "Developed:Medium", TransitionTypeID = "Intensification: Low to Medium", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Low", StateClassIDDest = "Developed:High", TransitionTypeID = "Intensification: Low to High", Probability = 1.0))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Developed:Medium", StateClassIDDest = "Developed:High", TransitionTypeID = "Intensification: Medium to High", Probability = 1.0))

# Fire
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", TransitionTypeID = "Fire: High Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", TransitionTypeID = "Fire: Medium Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:All", TransitionTypeID = "Fire: Low Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", TransitionTypeID = "Fire: High Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", TransitionTypeID = "Fire: Medium Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:All", StateClassIDDest = "Shrubland:All", TransitionTypeID = "Fire: Low Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Shrubland:PostFire", TransitionTypeID = "Fire: High Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Fire: Medium Severity", Probability = 1.0, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Fire: Low Severity", Probability = 1.0, AgeReset = F))

sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Thinned)", TransitionTypeID = "Fire: Medium Severity", Probability = 1.0, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Thinned)", TransitionTypeID = "Fire: Low Severity", Probability = 1.0, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:Treated (Prescribed)", TransitionTypeID = "Fire: Medium Severity", Probability = 1.0, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:Treated (Prescribed)", TransitionTypeID = "Fire: Low Severity", Probability = 1.0, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Shrubland:PostFire", TransitionTypeID = "Fire: High Severity", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Fire: Medium Severity", Probability = 1.0, AgeReset = F))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Fire: Low Severity", Probability = 1.0, AgeReset = F))

# Drought
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Drought: High Severity", Probability = 1.0, AgeReset = T, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Drought: Medium Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Drought: Low Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:All", TransitionTypeID = "Drought: High Severity", Probability = 1.0, AgeReset = T, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Drought: Medium Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Drought: Low Severity", Probability = 1.0, AgeReset = F, AgeMin = 20))

# Harvest
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Management: Forest Clearcut", Probability = 1.0, AgeReset = T, AgeMin = 40))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Management: Forest Selection", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Management: Forest Clearcut", Probability = 1.0, AgeReset = T, AgeMin = 50, AgeMax = 60))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Management: Forest Selection", Probability = 1.0, AgeReset = F, AgeMin = 20))

# Management
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Agriculture:Perennial", TransitionTypeID = "Management: Orchard Removal", Probability = 1.0, AgeReset = T, AgeMin = 20))

# Intervention
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Forest:All", TransitionTypeID = "Intervention: Reforestation", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:Treated (Thinned)", TransitionTypeID = "Intervention: Thinning From Below", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:Treated (Prescribed)", TransitionTypeID = "Intervention: Prescribed Fire", Probability = 1.0, AgeReset = F, TSTMin = 5, TSTMax = 10))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Intervention: Woodland Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Grassland:Composted", TransitionTypeID = "Intervention: Compost", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:Composted", StateClassIDDest = "Grassland:Composted", TransitionTypeID = "Intervention: Compost", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Agroforestry", TransitionTypeID = "Intervention: Agroforestry", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Agriculture:Covercrop", TransitionTypeID = "Intervention: Covercrop", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Forest:All", TransitionTypeID = "Intervention: Riparian Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Perennial", StateClassIDDest = "Forest:All", TransitionTypeID = "Intervention: Riparian Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:All", StateClassIDDest = "Forest:All", TransitionTypeID = "Intervention: Riparian Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Agriculture:Annual", StateClassIDDest = "Wetland:All", TransitionTypeID = "Intervention: Wetland Restoration", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:All", StateClassIDDest = "Forest:CFM", TransitionTypeID = "Intervention: CFM", Probability = 1.0, AgeReset = F, AgeMin = 20))

# Succession 
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Forest:All", TransitionTypeID = "Succession: Post Fire Recovery", Probability = 1.0, AgeReset = T))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Thinned)", StateClassIDDest = "Forest:All", TransitionTypeID = "Succession: Thinning From Below", Probability = 1.0, AgeReset = F, TSTMin = 15))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:Treated (Prescribed)", StateClassIDDest = "Forest:All", TransitionTypeID = "Succession: Prescribed Fire", Probability = 1.0, AgeReset = F, TSTMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Shrubland:PostFire", StateClassIDDest = "Shrubland:All", TransitionTypeID = "Succession: Permanent Shrub Conversion", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Forest:CFM", StateClassIDDest = "Forest:All", TransitionTypeID = "Succession: From CFM", Probability = 1.0, AgeReset = F, AgeMin = 20))
sheetData = addRow(sheetData, data.frame(StateClassIDSource = "Grassland:Composted", StateClassIDDest = "Grassland:All", TransitionTypeID = "Succession: From Compost", Probability = 1.0, AgeReset = F, AgeMin = 80))

saveDatasheet(pathways, sheetData, sheetName, append = F)






##### Initial Conditions ##### 

ic_ecoreg = raster("R Inputs/Data/initial-conditions/old/IC_Ecoregions_1km.tif")
crs(ic_ecoreg)

ic_state = raster("R Inputs/Data/initial-conditions/old/IC_StateClass_Dev_1km.tif")
projectRaster(ic_state, ic_ecoreg, method="ngb")
writeRaster(ic_state, "R Inputs/Data/initial-conditions/IC_StateClass_Dev_1km.tif")

crs(ic_state) = crs(ic_ecoreg)
compareCRS(ic_state, ic_ecoreg)


initialConditions = scenario(myProject, "Initial Conditions", overwrite=F)

sheetName = "stsim_InitialConditionsSpatial"
names(datasheet(myProject, name = sheetName, scenario = "Initial Conditions"))
sheetData = data.frame(StratumFileName = "R Inputs/Data/initial-conditions/IC_Ecoregions_1km.tif",
                       SecondaryStratumFileName = "R Inputs/Data/initial-conditions/IC_Counties_1km.tif",
                       TertiaryStratumFileName = "R Inputs/Data/initial-conditions/IC_Ownership_1km.tif",
                       StateClassFileName = "R Inputs/Data/initial-conditions/IC_StateClass_Dev_1km.tif",
                       AgeFileName = "R Inputs/Data/initial-conditions/IC_Age_1km.tif")
saveDatasheet(initialConditions, sheetData, sheetName, append = F)





##### Output Options ##### 
outputOptions = scenario(myProject, "Output Options", overwrite=F, create=T)

sheetName = "STSim_OutputOptions"
sheetData = datasheet(myProject, name = sheetName, scenario = "Output Options", optional = T, empty = T)
sheetData = data.frame(SummaryOutputSC = T, SummaryOutputSCTimesteps = 1,
                       SummaryOutputTR = T, SummaryOutputTRTimesteps = 1,
                       SummaryOutputTRSC = T, SummaryOutputTRSCTimesteps = 1,
                       SummaryOutputSA = T, SummaryOutputSATimesteps = 1,
                       SummaryOutputTA = F, SummaryOutputTATimesteps = 100,
                       SummaryOutputOmitSS = T,
                       SummaryOutputOmitTS = T, 
                       RasterOutputSC = T, RasterOutputSCTimesteps = 10,
                       RasterOutputTR = F, RasterOutputTRTimesteps = 1,
                       RasterOutputAge = F, RasterOutputAgeTimesteps = 10,
                       RasterOutputTST = F, RasterOutputTSTTimesteps = 100,
                       RasterOutputST = F, RasterOutputSTTimesteps = 100,
                       RasterOutputSA = F, RasterOutputSATimesteps = 100,
                       RasterOutputTA = F, RasterOutputTATimesteps = 100,
                       RasterOutputAATP = T, RasterOutputAATPTimesteps = 100)
saveDatasheet(outputOptions, sheetData, sheetName, append = F)









##### Transition Size Distribution ##### 
transitionSizeDistribution = scenario(myProject, "Transition Size Distribution", overwrite=F)

sheetName = "STSim_TransitionSizeDistribution"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Size Distribution", optional = T, empty = T)
# Drought size distribution
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 1, RelativeAmount = 0.9420))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 5, RelativeAmount = 0.0480))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 10, RelativeAmount = 0.0065))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 20, RelativeAmount = 0.0025))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 50, RelativeAmount = 0.0008))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 100, RelativeAmount = 0.0001))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Low Severity [Type]", MaximumArea = 200, RelativeAmount = 0.0001))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 1, RelativeAmount = 0.9162))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 5, RelativeAmount = 0.0631))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 10, RelativeAmount = 0.0132))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 20, RelativeAmount = 0.0051))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 50, RelativeAmount = 0.0021))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 100, RelativeAmount = 0.0002))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: Medium Severity [Type]", MaximumArea = 200, RelativeAmount = 0.0001))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 1, RelativeAmount = 0.8424))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 5, RelativeAmount = 0.1233))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 10, RelativeAmount = 0.0211))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 20, RelativeAmount = 0.0095))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 50, RelativeAmount = 0.0035))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 100, RelativeAmount = 0.0002))
sheetData = addRow(sheetData, data.frame(Timestep = 2017, TransitionGroupID = "Drought: High Severity [Type]", MaximumArea = 200, RelativeAmount = 0.0000))
saveDatasheet(transitionSizeDistribution, sheetData, sheetName, append = F)

Fire_size_by_ecoregion = read_csv("R Inputs/Data/calFire/Fire_size_by_ecoregion.csv")
saveDatasheet(transitionSizeDistribution, Fire_size_by_ecoregion, sheetName, append = T)

harvest_size_distribution = read_csv("R Inputs/Data/landFire/harvest_size_distribution.csv")
saveDatasheet(transitionSizeDistribution, harvest_size_distribution, sheetName, append = T)

##### Time Since Transition ##### 
tst = scenario(myProject, "Time Since Transition", overwrite = F)

# TST Groups
sheetName = "STSim_TimeSinceTransitionGroup"
sheetData = datasheet(myProject, name = sheetName, scenario = "Time Since Transition", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Ag Change: Perennial to Annual", TransitionGroupID = "Management: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Forest", TransitionGroupID = "Management: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Grassland", TransitionGroupID = "Management: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Shrubland", TransitionGroupID = "Management: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Ag Contraction: Perennial to Wetland", TransitionGroupID = "Management: Orchard Removal [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Intervention: Prescribed Fire", TransitionGroupID = "Intervention: Thinning From Below [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Succession: Thinning From Below", TransitionGroupID = "Intervention: Thinning From Below [Type]"))
sheetData = addRow(sheetData, data.frame(TransitionTypeID = "Succession: Prescribed Fire", TransitionGroupID = "Intervention: Prescribed Fire [Type]"))
saveDatasheet(tst, sheetData, sheetName, append = F)

# TST Randomize
sheetName = "STSim_TimeSinceTransitionRandomize"
sheetData = datasheet(myProject, name = sheetName, scenario = "Time Since Transition", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Management: Orchard Removal [Type]", StateClassID = "Agriculture:Perennial", MinInitialTST = 1, MaxInitialTST = 5))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intervention: Thinning From Below [Type]", StateClassID = "Forest:All", MinInitialTST = 5, MaxInitialTST = 10))
saveDatasheet(tst, sheetData, sheetName, append = F)




##### Adjacency Multipliers ##### 
adjacency = scenario(myProject, "Adjacency Multipliers", overwrite=F)

# Adjacency Settings
radius = 1500
frequency = 5
sheetName = "stsim_TransitionAdjacencySetting"
sheetData = datasheet(myProject, name = sheetName, scenario = "Adjacency Multipliers", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Change: Perennial to Annual [Type]", StateAttributeTypeID = "ADJ-Annual", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Change: Annual to Perennial [Type]", StateAttributeTypeID = "ADJ-Perennial", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Grassland [Type]", StateAttributeTypeID = "ADJ-Grassland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Shrubland [Type]", StateAttributeTypeID = "ADJ-Shrubland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Forest [Type]", StateAttributeTypeID = "ADJ-Forest", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Wetland [Type]", StateAttributeTypeID = "ADJ-Wetland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Grassland [Type]", StateAttributeTypeID = "ADJ-Grassland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Shrubland [Type]", StateAttributeTypeID = "ADJ-Shrubland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Forest [Type]", StateAttributeTypeID = "ADJ-Forest", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Wetland [Type]", StateAttributeTypeID = "ADJ-Wetland", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Expansion", StateAttributeTypeID = "ADJ-Agriculture", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Open [Type]", StateAttributeTypeID = "ADJ-Developed Open", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Low [Type]", StateAttributeTypeID = "ADJ-Developed Low", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Medium [Type]", StateAttributeTypeID = "ADJ-Developed Medium", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: High [Type]", StateAttributeTypeID = "ADJ-Developed High", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to Low [Type]", StateAttributeTypeID = "ADJ-Developed Low", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to Medium [Type]", StateAttributeTypeID = "ADJ-Developed Medium", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to High [Type]", StateAttributeTypeID = "ADJ-Developed High", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Low to Medium [Type]", StateAttributeTypeID = "ADJ-Developed Medium", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Low to High [Type]", StateAttributeTypeID = "ADJ-Developed High", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Medium to High [Type]", StateAttributeTypeID = "ADJ-Developed High", NeighborhoodRadius = radius, UpdateFrequency = frequency))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Succession: Post Fire Recovery [Type]", StateAttributeTypeID = "ADJ-Forest", NeighborhoodRadius = radius, UpdateFrequency = frequency)) # Need to update radius and frequency to represent rate of regeneration
saveDatasheet(adjacency, sheetData, sheetName, append = F)

# Adjacency Transition Multipliers
minValue = 0.0
minAmount = 0.0
maxValue = 0.88
maxAmount = 1.0
sheetName = "stsim_TransitionAdjacencyMultiplier"
sheetData = datasheet(myProject, name = sheetName, scenario = "Adjacency Multipliers", optional = F, empty = T)
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Change: Annual to Perennial [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Change: Annual to Perennial [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Change: Perennial to Annual [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Change: Perennial to Annual [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Grassland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Grassland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Grassland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Grassland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Shrubland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Shrubland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Shrubland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Shrubland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Forest [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Forest [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Forest [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Forest [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Wetland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Annual to Wetland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Wetland [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Contraction: Perennial to Wetland [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Expansion", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Ag Expansion", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Open [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Open [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Low [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Low [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Medium [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: Medium [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: High [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Urbanization: High [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to Low [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to Low [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to Medium [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to Medium [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to High [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Open to High [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Low to Medium [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Low to Medium [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Low to High [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Low to High [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Medium to High [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Intensification: Medium to High [Type]", AttributeValue = maxValue, Amount = maxAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Succession: Post Fire Recovery [Type]", AttributeValue = minValue, Amount = minAmount))
sheetData = addRow(sheetData, data.frame(TransitionGroupID = "Succession: Post Fire Recovery [Type]", AttributeValue = maxValue, Amount = maxAmount))
saveDatasheet(adjacency, sheetData, sheetName, append = F)





##### State Attributes ##### 
stateAttributes = scenario(myProject, "State Attributes", overwrite = F)
sheetName = "STSim_StateAttributeValue"

# Adjacency Values
myScenario = scenario(myProject, "State Attributes [Adjacency]", overwrite = F)
sheetName = "stsim_StateAttributeValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "State Attributes [Adjacency]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Annual", StateAttributeTypeID = "ADJ-Agriculture", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Annual", StateAttributeTypeID = "ADJ-Annual", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Perennial", StateAttributeTypeID = "ADJ-Agriculture", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Perennial", StateAttributeTypeID = "ADJ-Perennial", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Agroforestry", StateAttributeTypeID = "ADJ-Agroforestry", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Agroforestry", StateAttributeTypeID = "ADJ-Annual", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Covercrop", StateAttributeTypeID = "ADJ-Covercrop", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Agriculture:Covercrop", StateAttributeTypeID = "ADJ-Annual", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:Open", StateAttributeTypeID = "ADJ-Developed Open", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:Low", StateAttributeTypeID = "ADJ-Developed Low", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:Medium", StateAttributeTypeID = "ADJ-Developed Medium", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:High", StateAttributeTypeID = "ADJ-Developed High", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:Open", StateAttributeTypeID = "ADJ-Developed", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:Low", StateAttributeTypeID = "ADJ-Developed", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:Medium", StateAttributeTypeID = "ADJ-Developed", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Developed:High", StateAttributeTypeID = "ADJ-Developed", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Forest:All", StateAttributeTypeID = "ADJ-Forest", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Grassland:All", StateAttributeTypeID = "ADJ-Grassland", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Shrubland:All", StateAttributeTypeID = "ADJ-Shrubland", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Wetland:All", StateAttributeTypeID = "ADJ-Wetland", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Forest:All", StateAttributeTypeID = "ADJ-Natural", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Grassland:All", StateAttributeTypeID = "ADJ-Natural", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Shrubland:All", StateAttributeTypeID = "ADJ-Natural", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Wetland:All", StateAttributeTypeID = "ADJ-Natural", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Forest:Treated (Prescribed)", StateAttributeTypeID = "ADJ-Forest Prescribed", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Forest:Treated (Thinned)", StateAttributeTypeID = "ADJ-Forest Thinned", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Forest:CFM", StateAttributeTypeID = "ADJ-Forest CFM", Value=1))
sheetData = addRow(sheetData, data.frame(StateClassID = "Shrubland:PostFire", StateAttributeTypeID = "ADJ-ShrubPostFire", Value=1))
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Albedo
myScenario = scenario(myProject, "State Attributes [Albedo]", overwrite = F)
sheetName = "stsim_StateAttributeValue"
sheetData = read.csv("R Inputs/Data/attributes/Attributes-albedo.csv", header=T)
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Initial Carbon Stocks
myScenario = scenario(myProject, "State Attributes [Initial Carbon Stocks]", overwrite = F)
sheetName = "stsim_StateAttributeValue"
sheetData = read.csv("R Inputs/Data/attributes/Attributes-carbon.csv", header=T)
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Population
myScenario = scenario(myProject, "State Attributes [Population]", overwrite = F)
sheetName = "stsim_StateAttributeValue"
sheetData = read.csv("R Inputs/Data/attributes/Attributes-population.csv", header=T)
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Carbon NPP
myScenario = scenario(myProject, "State Attributes [NPP]", overwrite = F)
sheetName = "stsim_StateAttributeValue"
sheetData = read.csv("R Inputs/Data/attributes/Attributes-npp.csv", header=T)
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Carbon Compost Addition
myScenario = scenario(myProject, "State Attributes [Compost Addition]", overwrite = F)
sheetName = "stsim_StateAttributeValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "State Attributes [Compost Addition]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StateClassID = "Grassland:Composted", StateAttributeTypeID = "Compost Addition", Value=1.42)) # Value derived from Dave Marvin
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Merge State Attributes

myScenario = scenario(myProject, "State Attributes", overwrite = F)
mergeDependencies(myScenario) = T
dependency(myScenario, c("State Attributes [Adjacency]",
                         "State Attributes [Albedo]",
                         "State Attributes [Initial Carbon Stocks]",
                         "State Attributes [Population]",
                         "State Attributes [NPP]",
                         "State Attributes [Compost Addition]"))


##### Distributions ##### 
# Land use changes calculated based historical data from California Farmland Mapping and Monitoring Program located at http://.....
# Forest harvest calculated based historical data from LandFire located at http://.....
# WildFire probabilities calculated from California Fire Perimeters database located at http://.....
# Land use projections based on Sleeter et al., Earth's Future, DOI:.....
# All values assumed to be +/-30%

distributions = scenario(myProject, "Historical Distributions", overwrite = F)

distributionLandUse = read.csv("R Inputs/Data/distributions/Distribution-land-use.csv", header = T)
distributionFire = read.csv("R Inputs/Data/distributions/Distribution-Fire.csv", header = T)
distributionDrought = read.csv("R Inputs/Data/distributions/Distribution-Drought.csv", header = T)
distributionHarvest = read.csv("R Inputs/Data/landFire/forest_harvest_distribution.csv", header = T)
distributionData = bind_rows(distributionLandUse, distributionFire, distributionDrought, distributionHarvest)
sheetName = "STSim_DistributionValue"

sheetData = datasheet(myProject, name = sheetName, scenario = "Historical Distributions", optional = T, empty = T)
sheetData = data.frame(StratumID = distributionData$StratumID,
                       SecondaryStratumID = distributionData$SecondaryStratumID,
                       DistributionTypeID = distributionData$DistributionTypeID,
                       ExternalVariableTypeID = distributionData$ExternalVariableTypeID,
                       ExternalVariableMin = distributionData$ExternalVariableMin,
                       ExternalVariableMax = distributionData$ExternalVariableMax,
                       Value = distributionData$Value,
                       ValueDistributionFrequency = distributionData$ValueDistributionFrequency,
                       ValueDistributionSD = distributionData$ValueDistributionSD)
tail(sheetData)
saveDatasheet(distributions, sheetData, sheetName, append = F)



##### External Variables ##### 

# External Variables (Low Scenarios)
externalVariablesLow = scenario(myProject, "External Variables [Low]", overwrite = F)
sheetName = "STime_ExternalVariableValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "External Variables [Low]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2011, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2011))
sheetData = addRow(sheetData, data.frame(Timestep = 2012, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Land Use Change", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1993, DistributionMax = 1996))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Forest Harvest", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 2010, DistributionMax = 2014))
saveDatasheet(externalVariablesLow, sheetData, sheetName, append = F)

# External Variables (Medium and BAU Scenarios)
externalVariablesMed = scenario(myProject, "External Variables [Medium/BAU]", overwrite = F)
sheetName = "STime_ExternalVariableValue"
sheetData = datasheet(myProject, sheetName, scenario = "External Variables [Medium/BAU]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2011, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2011))
sheetData = addRow(sheetData, data.frame(Timestep = 2012, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Land Use Change", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1993, DistributionMax = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Forest Harvest", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1999, DistributionMax = 2014))
saveDatasheet(externalVariablesMed, sheetData, sheetName, append = F)

# External Variables (High Scenarios)
externalVariablesHigh = scenario(myProject, "External Variables [High]", overwrite = F)
sheetName = "STime_ExternalVariableValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "External Variables [High]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2011, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2011))
sheetData = addRow(sheetData, data.frame(Timestep = 2012, ExternalVariableTypeID = "Historical Year: Land Use Change", ExternalVariableValue = 2012))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Land Use Change", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 1997, DistributionMax = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2002))
sheetData = addRow(sheetData, data.frame(Timestep = 2003, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2003))
sheetData = addRow(sheetData, data.frame(Timestep = 2004, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2004))
sheetData = addRow(sheetData, data.frame(Timestep = 2005, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2005))
sheetData = addRow(sheetData, data.frame(Timestep = 2006, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2006))
sheetData = addRow(sheetData, data.frame(Timestep = 2007, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2007))
sheetData = addRow(sheetData, data.frame(Timestep = 2008, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2008))
sheetData = addRow(sheetData, data.frame(Timestep = 2009, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2009))
sheetData = addRow(sheetData, data.frame(Timestep = 2010, ExternalVariableTypeID = "Historical Year: Forest Harvest", ExternalVariableValue = 2010))
sheetData = addRow(sheetData, data.frame(Timestep = 2013, ExternalVariableTypeID = "Historical Year: Forest Harvest", DistributionTypeID = "Uniform Integer", DistributionFrequency = "Iteration and Timestep", DistributionMin = 2002, DistributionMax = 2009))
saveDatasheet(externalVariablesHigh, sheetData, sheetName, append = F)


##### Slope Multipliers #####
slopeMultiplier = scenario(myProject, "Slope Multiplier", overwrite = F, create=T) # Create the subscenario
sheetName = "STSim_DigitalElevationModel"
sheetData = datasheet(myProject, name = sheetName, scenario = "Slope Multiplier", optional = T, empty = T, lookupsAsFactors = F)
sheetData = addRow(sheetData, data.frame(DigitalElevationModelFileName="R Inputs/Data/ca_dem.tif"))
saveDatasheet(slopeMultiplier, sheetData, sheetName, append = F)

sheetName = "STSim_TransitionSlopeMultiplier" # Define the sheet name
sheetData = datasheet(myProject, name = sheetName, scenario = "Slope Multiplier", optional = T, empty = T, lookupsAsFactors = F) # Fetch an empty datafeed
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope=-90, Amount=5))
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope=-16, Amount=1))
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope= 0, Amount=17)) 
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope= 16, Amount=34))
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope= 25, Amount=100))
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope= 35, Amount=200))
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope= 45, Amount=300))
sheetData = addRow(sheetData, data.frame(TransitionGroupID="Fire", Slope= 55, Amount=400))
saveDatasheet(slopeMultiplier, sheetData, sheetName, append = F)






























#####  ===================================================================================================
# SECTION 4: Create STSM Transition Multipliers ==========================================================
#####  ===================================================================================================

##### Base Transition Multipliers #####
myScenario = scenario(myProject, "Transition Multipliers Base", overwrite=F)
sheetName = "STSim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Base", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Ag Change: Perennial to Annual [Type]", Amount = 0.05, DistributionType = "Uniform", DistributionFrequencyID = "Iteration and Timestep", DistributionMin = 0.025, DistributionMax = 0.075))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Management: Orchard Removal [Type]", Amount = 0.0589, DistributionType = "Uniform", DistributionFrequencyID = "Iteration and Timestep", DistributionMin = 0.0228, DistributionMax = 0.095))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Succession: From CFM [Type]", Amount = 0.01))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Succession: Permanent Shrub Conversion [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Succession: Post Fire Recovery [Type]", Amount = 0.027))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Succession: Prescribed Fire [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Succession: Thinning From Below [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Succession: From Compost [Type]", Amount = 1.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

# Fire Severity Multipliers
severity_df = read_csv("R Inputs/Data/mtbs/severity_by_ecoregion_2001_2014.csv") # WildFire severity by Ecoregion
myScenario = scenario(myProject, "Transition Multipliers Fire Severity [No Change]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
saveDatasheet(myScenario, severity_df, sheetName, append = F)

# Temporal Severity Multipliers (Low)
severity_df = read_csv("R Inputs/Data/mtbs/fire-temporal-severity-multipliers-low.csv") # WildFire severity by Ecoregion
myScenario = scenario(myProject, "Transition Multipliers Fire Severity [Low]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
saveDatasheet(myScenario, severity_df, sheetName, append = F)

# Temporal Severity Multipliers (High)
severity_df = read_csv("R Inputs/Data/mtbs/fire-temporal-severity-multipliers-high.csv") # WildFire severity by Ecoregion
myScenario = scenario(myProject, "Transition Multipliers Fire Severity [High]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
saveDatasheet(myScenario, severity_df, sheetName, append = F)


# Fire relative probabilities
relProb_veg_eco = read_csv("R Inputs/Data/calFire/relative_proportions_state_class.csv") # Relative probability by ecoregion and state class
myScenario = scenario(myProject, "Transition Multipliers Fire Vegetation", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
saveDatasheet(myScenario, relProb_veg_eco, sheetName, append = F)

# Urbanization relative probabilities
urbProb = read_csv("R Inputs/Data/transition-targets/TransitionTargetsRelativeProbabilities.csv")
myScenario = scenario(myProject, "Transition Multipliers Urbanization Probabilities", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
saveDatasheet(myScenario, urbProb, sheetName, append = F)

# Intervention Scenarios (off)
myScenario = scenario(myProject, "Transition Multipliers Intervention [None]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [None]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Non Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Private", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Tribal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Covercrop [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Riparian Restoration [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Non Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Private", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStrataID = "Tribal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Wetland Restoration [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Woodland Restoration [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Compost [Type]", Amount = 0.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)


##### Interventions (turn on/off based on scenario) #####

##### Agroforestry
myScenario = scenario(myProject, "Transition Multipliers Intervention [Agroforestry]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [Agroforestry]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 1.0)) # Turns on the agroforestry intervention
saveDatasheet(myScenario, sheetData, sheetName, append = F)

##### CFM
myScenario = scenario(myProject, "Transition Multipliers Intervention [CFM]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [CFM]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: CFM [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StateClassID = "Forest:All", TransitionGroupID = "Management: Forest Clearcut [Type]", Amount = 0.65))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StateClassID = "Forest:CFM", TransitionGroupID = "Management: Forest Clearcut [Type]", Amount = 0.35))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StateClassID = "Forest:All", TransitionGroupID = "Management: Forest Selection [Type]", Amount = 0.35))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StateClassID = "Forest:CFM", TransitionGroupID = "Management: Forest Selection [Type]", Amount = 0.65))
sheetData = addRow(sheetData, data.frame(Timestep = 2051, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2051, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2051, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2051, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: CFM [Type]", Amount = 0.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

##### Covercrop
myScenario = scenario(myProject, "Transition Multipliers Intervention [Covercrop]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [Covercrop]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Covercrop [Type]", Amount = 1.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

##### Reduced Fire Severity
myScenario = scenario(myProject, "Transition Multipliers Intervention [Reduced Fire Severity]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [Reduced Fire Severity]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

##### Reforestation
myScenario = scenario(myProject, "Transition Multipliers Intervention [Reforestation]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [Reforestation]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 1.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

##### Woodland Restoration
myScenario = scenario(myProject, "Transition Multipliers Intervention [Woodland Restoration]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [Woodland Restoration]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Woodland Restoration [Type]", Amount = 1.0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

##### Composting
myScenario = scenario(myProject, "Transition Multipliers Intervention [Composting]", overwrite=F)
sheetName = "stsim_TransitionMultiplierValue"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Multipliers Intervention [Composting]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="California Chaparral and Oak Woodlands", TransitionGroupID = "Intervention: Compost [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Central California Valley", TransitionGroupID = "Intervention: Compost [Type]", Amount = 1.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Cascades", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Coast Range", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Klamath Mountains", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Sierra Nevada", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Northern Basin and Range", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Central Basin and Range", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Mojave Basin and Range", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Sonoran Basin and Range", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Southern California Mountains", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID="Eastern Cascades Slopes and Foothills", TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)


##### Combine Transition Multipliers Subscenarios  #####
myScenario = scenario(myProject, "Transition Multipliers [No Intervention]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]"))

myScenario = scenario(myProject, "Transition Multipliers [Composting]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]",
                                      "Transition Multipliers Intervention [Composting]"))

myScenario = scenario(myProject, "Transition Multipliers [Reduced Fire Severity]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]",
                                      "Transition Multipliers Intervention [Reduced Fire Severity]"))

myScenario = scenario(myProject, "Transition Multipliers [Reforestation]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]",
                                      "Transition Multipliers Intervention [Reforestation]"))

myScenario = scenario(myProject, "Transition Multipliers [Covercrop]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]",
                                      "Transition Multipliers Intervention [Covercrop]"))

myScenario = scenario(myProject, "Transition Multipliers [Agroforestry]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]",
                                      "Transition Multipliers Intervention [Agroforestry]"))

myScenario = scenario(myProject, "Transition Multipliers [CFM]", overwrite=F)
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c("Transition Multipliers Base",
                                      "Transition Multipliers Urbanization Probabilities",
                                      "Transition Multipliers Fire Severity [High]", 
                                      "Transition Multipliers Fire Vegetation", 
                                      "Transition Multipliers Intervention [None]",
                                      "Transition Multipliers Intervention [CFM]"))








#####  ===================================================================================================
# SECTION 5: Create STSM Transition Targets ==============================================================
#####  ===================================================================================================

##### Directory Setup #####
dir = "R Inputs/Data/transition-targets/"
typeIntensification = "TransitionTargetsIntensification"
typePop = "TransitionTargetsPop"
typeFire = "TransitionTargetsFire"
typeDrought = "TransitionTargetsDrought"
dirDrought = "R Inputs/Data/Drought/"

transitionTargetsIntensification = read_csv("R Inputs/Data/transition-targets/TransitionTargetsIntensification.csv") # Urban Intensification
urbHigh = read_csv("R Inputs/Data/transition-targets/TransitionTargetsPop.High.csv")
urbMedium = read_csv("R Inputs/Data/transition-targets/TransitionTargetsPop.Medium.csv")
urbLow = read_csv("R Inputs/Data/transition-targets/TransitionTargetsPop.Low.csv")

##### LULC Scenarios #####

# BAU LULC Scenario
sheetName = "STSim_TransitionTarget"
myScenario = scenario(myProject, "Transition Targets LULC [BAU]", overwrite=F)
sheetData = datasheet(myProject, sheetName, scenario="Transition Targets LULC [BAU]", optional=T, empty=T)
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Change: Annual to Perennial [Type]", Amount=100, DistributionType="Uniform", DistributionFrequencyID="Iteration and Timestep", DistributionMin=50, DistributionMax=150))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Contraction", DistributionType="Historical Rate: Ag Contraction", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Expansion", DistributionType="Historical Rate: Ag Expansion", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Urbanization", DistributionType="Historical Rate: Urbanization", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Clearcut [Type]", DistributionType="Historical Rate: Forest Clearcut", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Selection [Type]", DistributionType="Historical Rate: Forest Selection", DistributionFrequencyID="Iteration and Timestep"))
sheetData = sheetData %>% bind_rows(transitionTargetsIntensification) # Append Intensification targets
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# High LULC Scenario
myScenario = scenario(myProject, "Transition Targets LULC [High]", overwrite=F)
sheetData = datasheet(myProject, sheetName, scenario="Transition Targets LULC [High]", optional=T, empty=T)
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Change: Annual to Perennial [Type]", Amount=100, DistributionType="Uniform", DistributionFrequencyID="Iteration and Timestep", DistributionMin=50, DistributionMax=150))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Contraction", DistributionType="Historical Rate: Ag Contraction", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Expansion", DistributionType="Historical Rate: Ag Expansion", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Urbanization", DistributionType="Historical Rate: Urbanization", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Clearcut [Type]", DistributionType="Historical Rate: Forest Clearcut", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Selection [Type]", DistributionType="Historical Rate: Forest Selection", DistributionFrequencyID="Iteration and Timestep"))
sheetData = sheetData %>% bind_rows(transitionTargetsIntensification, urbHigh) # Append urbanization and Intensification targets
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Medium LULC Scenario
myScenario = scenario(myProject, "Transition Targets LULC [Medium]", overwrite=F)
sheetData = datasheet(myProject, sheetName, scenario="Transition Targets LULC [Medium]", optional=T, empty=T)
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Change: Annual to Perennial [Type]", Amount=100, DistributionType="Uniform", DistributionFrequencyID="Iteration and Timestep", DistributionMin=50, DistributionMax=150))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Contraction", DistributionType="Historical Rate: Ag Contraction", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Expansion", DistributionType="Historical Rate: Ag Expansion", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Urbanization", DistributionType="Historical Rate: Urbanization", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Clearcut [Type]", DistributionType="Historical Rate: Forest Clearcut", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Selection [Type]", DistributionType="Historical Rate: Forest Selection", DistributionFrequencyID="Iteration and Timestep"))
sheetData = sheetData %>% bind_rows(transitionTargetsIntensification, urbMedium) # Append urbanization and Intensification targets
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Low LULC Scenario
myScenario = scenario(myProject, "Transition Targets LULC [Low]", overwrite=F)
sheetData = datasheet(myProject, sheetName, scenario="Transition Targets LULC [Low]", optional=T, empty=T)
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Change: Annual to Perennial [Type]", Amount=100, DistributionType="Uniform", DistributionFrequencyID="Iteration and Timestep", DistributionMin=50, DistributionMax=150))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Contraction", DistributionType="Historical Rate: Ag Contraction", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Ag Expansion", DistributionType="Historical Rate: Ag Expansion", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2002, TransitionGroupID="Urbanization", DistributionType="Historical Rate: Urbanization", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Clearcut [Type]", DistributionType="Historical Rate: Forest Clearcut", DistributionFrequencyID="Iteration and Timestep"))
sheetData = addRow(sheetData, data.frame(Timestep=2015, TransitionGroupID="Management: Forest Selection [Type]", DistributionType="Historical Rate: Forest Selection", DistributionFrequencyID="Iteration and Timestep"))
sheetData = sheetData %>% bind_rows(transitionTargetsIntensification, urbLow) # Append urbanization and Intensification targets
saveDatasheet(myScenario, sheetData, sheetName, append=F)



##### Fire Scenarios #####
sheetName = "STSim_TransitionTarget"
gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Fire [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
FireData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Fire data based on gcm and rcp
saveDatasheet(myScenario, FireData, name = "STSim_TransitionTarget", append = F)

##### Drought Scenarios #####
sheetName = "STSim_TransitionTarget"
gcm = "CanESM2"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, sheetName, append = F)

gcm = "CanESM2"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)

gcm = "CNRM-CM5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)

gcm = "CNRM-CM5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)

gcm = "MIROC5"
rcp = "rcp45"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeDrought, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)

gcm = "MIROC5"
rcp = "rcp85"
myScenario = scenario(myProject, paste("Transition Targets Drought [",gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T) # Creates a new scenario
mortalityData = read.csv(paste(dir, typeFire, ".", gcm, ".", rcp, ".csv", sep = ""), header = T)# Reads in the Drought data based on gcm and rcp
saveDatasheet(myScenario, mortalityData, name = "STSim_TransitionTarget", append = F)



##### Create master transition target scenarios #####
# BAU Scenario
gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "CanESM2"
rcp = "rcp85"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp45"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp85"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp45"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp85"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "MIROC5"
rcp = "rcp45"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "MIROC5"
rcp = "rcp85"
luc = "BAU"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))



# High Scenario
gcm = "CanESM2"
rcp = "rcp45"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "CanESM2"
rcp = "rcp85"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp45"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "CNRM-CM5"
rcp = "rcp85"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp45"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "HadGEM2-ES"
rcp = "rcp85"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "MIROC5"
rcp = "rcp45"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))

gcm = "MIROC5"
rcp = "rcp85"
luc = "High"
myScenario = scenario(myProject, paste("Transition Targets [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = "")))




# Creat Intervention Transition Targets --------------------------------------------------

# Composting
myScenario = scenario(myProject, "Transition Targets Intervention [Composting]", overwrite=F)
sheetName = "stsim_TransitionTarget"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Targets Intervention [Composting]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Compost [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Compost [Type]", Amount = 55))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

# Reduced Fire Severity
myScenario = scenario(myProject, "Transition Targets Intervention [Reduced Fire Severity]", overwrite=F)
sheetName = "stsim_TransitionTarget"

sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Targets Intervention [Reduced Fire Severity]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0))

sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 1000))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 250))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: Thinning From Below [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Federal", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 500))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Non Federal", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Private", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 250))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TertiaryStratumID = "Tribal", TransitionGroupID = "Intervention: Prescribed Fire [Type]", Amount = 0))

saveDatasheet(myScenario, sheetData, sheetName, append = F)

# Reforestation
myScenario = scenario(myProject, "Transition Targets Intervention [Reforestation]", overwrite=F)
sheetName = "stsim_TransitionTarget"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Targets Intervention [Reforestation]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "California Chaparral and Oak Woodlands", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Cascades", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 2.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Central Basin and Range", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 9.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Central California Valley", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Coast Range", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 21.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Eastern Cascades Slopes and Foothills", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 23.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Klamath Mountains", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 55.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Mojave Basin and Range", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Northern Basin and Range", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 3.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Sierra Nevada", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 82.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Sonoran Basin and Range", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Southern California Mountains", TransitionGroupID = "Intervention: Reforestation [Type]", Amount = 0))
saveDatasheet(myScenario, sheetData, sheetName, append = F)

# Covercrop
myScenario = scenario(myProject, "Transition Targets Intervention [Covercrop]", overwrite=F)
sheetName = "stsim_TransitionTarget"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Targets Intervention [Covercrop]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2002, TransitionGroupID = "Intervention: Covercrop [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: Covercrop [Type]", Amount = 229))
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Agroforestry
myScenario = scenario(myProject, "Transition Targets Intervention [Agroforestry]", overwrite=F)
sheetName = "stsim_TransitionTarget"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Targets Intervention [Agroforestry]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "California Chaparral and Oak Woodlands", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Cascades", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Central Basin and Range", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Central California Valley", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 32.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Coast Range", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Eastern Cascades Slopes and Foothills", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Klamath Mountains", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Mojave Basin and Range", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Northern Basin and Range", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Sierra Nevada", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Sonoran Basin and Range", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, StratumID = "Southern California Mountains", TransitionGroupID = "Intervention: Agroforestry [Type]", Amount = 0))
saveDatasheet(myScenario, sheetData, sheetName, append=F)

# Changes to Forest Management (CFM)
myScenario = scenario(myProject, "Transition Targets Intervention [CFM]", overwrite=F)
sheetName = "stsim_TransitionTarget"
sheetData = datasheet(myProject, name = sheetName, scenario = "Transition Targets Intervention [CFM]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: CFM [Type]", Amount = 400.0))
sheetData = addRow(sheetData, data.frame(Timestep = 2020, TransitionGroupID = "Intervention: CFM [Type]", Amount = 0))
sheetData = addRow(sheetData, data.frame(Timestep = 2050, TransitionGroupID = "Management: Forest Clearcut [Type]", Amount = 365))
sheetData = addRow(sheetData, data.frame(Timestep = 2050, TransitionGroupID = "Management: Forest Selection [Type]", Amount = 446))
saveDatasheet(myScenario, sheetData, sheetName, append=F)





# Creat Intervention Merged Transition Targets --------------------------------------------------

gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
intervention = "Composting"
myScenario = scenario(myProject, paste("Transition Targets ", intervention, " [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = ""),
  "Transition Targets Intervention [Composting]"))

gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
intervention = "Reduced Fire Severity"
myScenario = scenario(myProject, paste("Transition Targets ", intervention, " [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = ""),
  "Transition Targets Intervention [Reduced Fire Severity]"))

gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
intervention = "Reforestation"
myScenario = scenario(myProject, paste("Transition Targets ", intervention, " [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = ""),
  "Transition Targets Intervention [Reforestation]"))

gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
intervention = "Covercrop"
myScenario = scenario(myProject, paste("Transition Targets ", intervention, " [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = ""),
  "Transition Targets Intervention [Covercrop]"))

gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
intervention = "Agroforestry"
myScenario = scenario(myProject, paste("Transition Targets ", intervention, " [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = ""),
  "Transition Targets Intervention [Agroforestry]"))

gcm = "CanESM2"
rcp = "rcp45"
luc = "BAU"
intervention = "CFM"
myScenario = scenario(myProject, paste("Transition Targets ", intervention, " [",luc, ".", gcm, ".", rcp, "]", sep = "")) # Creates a new scenario
mergeDependencies(myScenario) = T
dependency(myScenario, dependency = c( 
  paste("Transition Targets LULC [",luc,"]", sep = ""),
  paste("Transition Targets Fire [",gcm,".",rcp,"]", sep = ""),
  paste("Transition Targets Drought [",gcm,".",rcp,"]", sep = ""),
  "Transition Targets Intervention [CFM]"))





#####  ===================================================================================================
# SECTION 6: Create STSM Spatial Multipliers =============================================================
#####  ===================================================================================================

##### Historical Spatial Multipliers #####
smBase = data.frame(Timestep = 2002,
                    TransitionGroupID = c("Ag Contraction", "Ag Expansion", "Urbanization"),
                    MultiplierFileName = c("R Inputs/Data/spatial-multipliers/SM_AgContraction_1km.tif", 
                                           "R Inputs/Data/spatial-multipliers/SM_AgExpansion_1km.tif", 
                                           "R Inputs/Data/spatial-multipliers/SM_Urbanization_1km.tif"))

smBaseHarvest = data.frame(Timestep=2015,
                           TransitionGroupID=c("Management: Forest Clearcut [Type]", "Management: Forest Selection [Type]"),
                           MultiplierFileName=c("R Inputs/Data/spatial-multipliers/SM_Harvest_v2_Ecomask_1km.tif", "R Inputs/Data/spatial-multipliers/SM_Harvest_v2_Ecomask_1km.tif")) 

smBase = rbind(smBase, smBaseHarvest)

# Historical Clearcut Harvest (2002-2014)
timestepList = seq(2002, 2014, 1)
transitionList = rep("Management: Forest Clearcut [Type]", 13)
fileList = paste("R Inputs/Data/landFire/spatial-multipliers/clearcut/sm_clearcut_X", timestepList, ".tif", sep = "")
smClearcut = data.frame(Timestep = timestepList,
                        TransitionGroupID = transitionList,
                        MultiplierFileName = fileList)

# Historical Selection Harvest (2002-2014)
timestepList = seq(2002, 2014, 1)
transitionList = rep("Management: Forest Selection [Type]", 13)
fileList = paste("R Inputs/Data/landFire/spatial-multipliers/selection/sm_selection_X", timestepList, ".tif", sep = "")
smSelection = data.frame(Timestep = timestepList,
                         TransitionGroupID = transitionList,
                         MultiplierFileName = fileList)

smHarvest = rbind(smClearcut, smSelection)

# Historical Fire (2002-2016)
timestepList = seq(2002, 2017, 1)
transitionList = rep("Fire", 16)
fileList = paste("R Inputs/Data/calFire/spatial-multipliers/SM_Fire_X", timestepList, "_1km.tif", sep = "")
smFire = data.frame(Timestep = timestepList,
                    TransitionGroupID = transitionList,
                    MultiplierFileName = fileList)

# Historical Drought (2002-2016)
timestepList = seq(2002, 2016, 1)
transitionList = rep("Drought: High Severity [Type]", 15)
fileList = paste("R Inputs/Data/spatial-multipliers/SM_insects_high.", timestepList, "_1km.tif", sep = "")
smInsectHigh = data.frame(Timestep = timestepList,
                          TransitionGroupID = transitionList,
                          MultiplierFileName = fileList)

transitionList = rep("Drought: Medium Severity [Type]", 15)
fileList = paste("R Inputs/Data/spatial-multipliers/SM_insects_med.", timestepList, "_1km.tif", sep = "")
smInsectMed = data.frame(Timestep = timestepList,
                         TransitionGroupID = transitionList,
                         MultiplierFileName = fileList)

transitionList = rep("Drought: Low Severity [Type]", 15)
fileList = paste("R Inputs/Data/spatial-multipliers/SM_insects_low.", timestepList, "_1km.tif", sep = "")
smInsectLow = data.frame(Timestep = timestepList,
                         TransitionGroupID = transitionList,
                         MultiplierFileName = fileList)

smInsects = rbind(smInsectHigh, smInsectMed, smInsectLow)

# Merge the base spatial multipliers used over historical period
smBaseAll = rbind(smFire, smInsects, smBase, smHarvest) %>% arrange(Timestep)
head(smBaseAll)



##### Projected Spatial Multipliers (2017-2101) #####

fileseq = seq(1, 84, 1)
fileseqFire = seq(2, 84, 1)
projYears = seq(2017, 2100, 1)
projYearsFire = seq(2018, 2100, 1)
projTrans = rep("Fire", 83)
projInsHigh = rep("Drought: High Severity [Type]", 84)
projInsMed = rep("Drought: Medium Severity [Type]", 84)
projInsLow = rep("Drought: Low Severity [Type]", 84)

gcm = "CanESM2"
rcp = "rcp45"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "CanESM2"
rcp = "rcp85"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "CNRM-CM5"
rcp = "rcp45"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "CNRM-CM5"
rcp = "rcp85"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "HadGEM2-ES"
rcp = "rcp45"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "HadGEM2-ES"
rcp = "rcp85"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)

gcm = "MIROC5"
rcp = "rcp45"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)


gcm = "MIROC5"
rcp = "rcp85"
projFilesFire = paste("R Inputs/Data/westerling/", gcm, ".", rcp, "/Fire_", gcm, ".", rcp, "_", projYearsFire, ".tif", sep = "")
projFilesDroughtHigh = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "high/", "droughtHigh_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtMed = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "med/", "droughtMed_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
projFilesDroughtLow = paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/", "low/", "droughtLow_", gcm, ".", rcp, "_", projYears, ".tif", sep = "")
smFireProj = data.frame(Timestep = projYearsFire, TransitionGroupID = projTrans, MultiplierFileName = projFilesFire)
smDroughtHighProj = data.frame(Timestep = projYears, TransitionGroupID = projInsHigh, MultiplierFileName = projFilesDroughtHigh)
smDroughtMedProj = data.frame(Timestep = projYears, TransitionGroupID = projInsMed, MultiplierFileName = projFilesDroughtMed)
smDroughtLowProj = data.frame(Timestep = projYears, TransitionGroupID = projInsLow, MultiplierFileName = projFilesDroughtLow)
myScenario = scenario(myProject, paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""), overwrite = F, create=T)
sheetData = rbind(smBaseAll, smFireProj, smDroughtHighProj, smDroughtMedProj, smDroughtLowProj)
saveDatasheet(myScenario, sheetData, name = "STSim_TransitionSpatialMultiplier", append = F)










































#####  ===================================================================================================
# SECTION 7: Create Stock-Flow Constant Scenarios ========================================================
#####  ===================================================================================================

# Stocks Diagram-----------------------------------------------------------------------------------

flowPathways = scenario(myProject, "SF Flow Pathways", overwrite = F)

sheetName = "SF_FlowPathwayDiagram"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Pathways", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StockTypeID = "Aquatic", Location = "C4"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Atmosphere", Location = "B1"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", Location = "C3"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Grain", Location = "A2"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "HWP (Extracted)", Location = "A1"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", Location = "B3"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Living Biomass", Location = "B2"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Soil", Location = "B4"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", Location = "C2"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Straw", Location = "A3"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Compost", Location = "C1"))
saveDatasheet(flowPathways, sheetData, sheetName, append = F)

# Flow Pathways-----------------------------------------------------------------------------------

sheetName = "stsimsf_FlowPathway"
sheetData = datasheet(myProject, sheetName, scenario = "SF Flow Pathways", optional = T, empty = T)

# Define Transition triggered flows
# Ag Expansion
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="0.4"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="HWP (Extracted)", TransitionGroupID="Ag Expansion", FlowTypeID="Harvest", Multiplier="0.5"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Down Deadwood", TransitionGroupID="Ag Expansion", FlowTypeID="Mortality", Multiplier="0.1"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Standing Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Down Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Soil", ToStockTypeID="Atmosphere", TransitionGroupID="Ag Expansion", FlowTypeID="Emission", Multiplier="0.3"))
# Urbanization
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="0.4"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="HWP (Extracted)", TransitionGroupID="Urbanization", FlowTypeID="Harvest", Multiplier="0.5"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Down Deadwood", TransitionGroupID="Urbanization", FlowTypeID="Mortality", Multiplier="0.1"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Annual", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Perennial", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Standing Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Down Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Soil", ToStockTypeID="Atmosphere", TransitionGroupID="Urbanization", FlowTypeID="Emission", Multiplier="0.3"))
# Harvest (Clearcut and Selection)
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Management: Forest Clearcut [Type]", FlowTypeID="Emission", Multiplier="0.075"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Down Deadwood", TransitionGroupID="Management: Forest Clearcut [Type]", FlowTypeID="Mortality", Multiplier="0.3"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="HWP (Extracted)", TransitionGroupID="Management: Forest Clearcut [Type]", FlowTypeID="Harvest", Multiplier="0.6"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Standing Deadwood", ToStockTypeID="Down Deadwood", TransitionGroupID="Management: Forest Clearcut [Type]", FlowTypeID="Deadfall", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="HWP (Extracted)", TransitionGroupID="Management: Forest Selection [Type]", FlowTypeID="Harvest", Multiplier="0.2"))
# Orchard Removal
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Perennial", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Management: Orchard Removal [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Perennial", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Management: Orchard Removal [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Perennial", FromStockTypeID="Soil", ToStockTypeID="Atmosphere", TransitionGroupID="Management: Orchard Removal [Type]", FlowTypeID="Emission", Multiplier="0.3"))
# Drought Mortality - note, uses flow multipliers
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Living Biomass", ToStockTypeID="Standing Deadwood", TransitionGroupID="Drought: High Severity [Type]", FlowTypeID="Mortality (Drought high)", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Living Biomass", ToStockTypeID="Standing Deadwood", TransitionGroupID="Drought: Medium Severity [Type]", FlowTypeID="Mortality (Drought medium)", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStockTypeID="Living Biomass", ToStockTypeID="Standing Deadwood", TransitionGroupID="Drought: Low Severity [Type]", FlowTypeID="Mortality (Drought low)", Multiplier="1.0"))
# Fire
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="0.069"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="0.008"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Standing Deadwood", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Mortality", Multiplier="0.813"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Standing Deadwood", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Mortality", Multiplier="0.71"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Standing Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="0.176"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Standing Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="0.1642"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Down Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="0.397"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Down Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="0.611"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Down Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Low Severity [Type]", FlowTypeID="Emission", Multiplier="0.25"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="0.9"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Low Severity [Type]", FlowTypeID="Emission", Multiplier="0.8"))

sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="0.248"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="0.124"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Litter", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Mortality", Multiplier="0.752"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Litter", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Mortality", Multiplier="0.376"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Shrubland:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Low Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))

sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="0.2985"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="0.2985"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Low Severity [Type]", FlowTypeID="Emission", Multiplier="0.2985"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Litter", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Mortality", Multiplier="0.7015"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Litter", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Mortality", Multiplier="0.7015"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Living Biomass", ToStockTypeID="Litter", TransitionGroupID="Fire: Low Severity [Type]", FlowTypeID="Mortality", Multiplier="0.7015"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: High Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Medium Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Grassland:All", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Fire: Low Severity [Type]", FlowTypeID="Emission", Multiplier="1.0"))

# Interventions

# Thinning from Below
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="HWP (Extracted)", TransitionGroupID="Intervention: Thinning From Below [Type]", FlowTypeID="Harvest", Multiplier="0.21"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:All", FromStockTypeID="Living Biomass", ToStockTypeID="Down Deadwood", TransitionGroupID="Intervention: Thinning From Below [Type]", FlowTypeID="Mortality", Multiplier="0.09"))
# Prescribed Fire
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:Treated (Thinned)", FromStockTypeID="Down Deadwood", ToStockTypeID="Atmosphere", TransitionGroupID="Intervention: Prescribed Fire [Type]", FlowTypeID="Emission", Multiplier="0.40"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Forest:Treated (Thinned)", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", TransitionGroupID="Intervention: Prescribed Fire [Type]", FlowTypeID="Emission", Multiplier="0.80"))
# Covercrop
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Litter", ToStockTypeID="Atmosphere", FlowTypeID="Emission (litter)", Multiplier="0.2680"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Litter", ToStockTypeID="Soil", FlowTypeID="Decomposition", Multiplier="0.2887"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Living Biomass", ToStockTypeID="Grain", FlowTypeID="Harvest (grain)", Multiplier="0.2305"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Living Biomass", ToStockTypeID="Litter", FlowTypeID="Litterfall", Multiplier="0.5166"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Living Biomass", ToStockTypeID="Straw", FlowTypeID="Harvest (straw)", Multiplier="0.2500"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Soil", ToStockTypeID="Aquatic", FlowTypeID="Leaching", Multiplier="0.0"))
sheetData = addRow(sheetData, data.frame(FromStateClassID="Agriculture:Covercrop", FromStockTypeID="Soil", ToStockTypeID="Atmosphere", FlowTypeID="Emission (soil)", Multiplier="0.0235"))
# Composted grassland
sheetData = addRow(sheetData, data.frame(FromAgeMin=1,ToAgeMin=1, FromStockTypeID="Compost", ToStockTypeID="Living Biomass", FlowTypeID="Composting", TransitionGroupID="Intervention: Compost [Type]", StateAttributeTypeID="Compost Addition", Multiplier="1.0"))


saveDatasheet(flowPathways, sheetData, sheetName, append = F)

# Append base flows
baseFlows = read_csv("R Inputs/Data/flows/base_flows.csv")
baseFlowsGrassComposted = read_csv("R Inputs/Data/flows/base_flows_grasslandComposted.csv") %>% mutate(FromStateClassID="Grassland:Composted")
flowPathwaysData = bind_rows(baseFlows, baseFlowsGrassComposted)

saveDatasheet(flowPathways, flowPathwaysData, sheetName, append = T)



# Initial Stocks-----------------------------------------------------------------------------------

initialStocks = scenario(myProject, "SF Initial Stocks [Spatial]", overwrite = F)

sheetName = "stsimsf_InitialStockSpatial"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Initial Stocks [Spatial]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", RasterFileName = "R Inputs/Data/initial-stocks/IS_DownDeadwood_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", RasterFileName = "R Inputs/Data/initial-stocks/IS_Litter_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Living Biomass", RasterFileName = "R Inputs/Data/initial-stocks/IS_LivingBiomass_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Soil", RasterFileName = "R Inputs/Data/initial-stocks/IS_Soil_1km.tif"))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", RasterFileName = "R Inputs/Data/initial-stocks/IS_StandingDeadwood_1km.tif"))
saveDatasheet(initialStocks, sheetData, sheetName, append = F)


# Stock Flow Output Options-----------------------------------------------------------------------------------

stockflowOutputOptions = scenario(myProject, "SF Output Options", overwrite = F, create=T)

sheetName = "SF_OutputOptions"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Output Options", optional = T, empty = T)
sheetData = data.frame(SummaryOutputST = T, SummaryOutputSTTimesteps = 1,
                       SummaryOutputFL = T, SummaryOutputFLTimesteps = 1,
                       SpatialOutputST = T, SpatialOutputSTTimesteps = 10,
                       SpatialOutputFL = F, SpatialOutputFLTimesteps = 10)
saveDatasheet(stockflowOutputOptions, sheetData, sheetName, append = F)


# Stock Group Membership-----------------------------------------------------------------------------------
stockGroupMembership = scenario(myProject, "SF Stock Group Membership", overwrite = T, create=T)

sheetName = "SF_StockTypeGroupMembership"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Stock Group Membership", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", StockGroupID = "Total Deadwood", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", StockGroupID = "Total Deadwood", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", StockGroupID = "DOM", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", StockGroupID = "DOM", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", StockGroupID = "DOM", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Down Deadwood", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Standing Deadwood", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Litter", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Living Biomass", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
sheetData = addRow(sheetData, data.frame(StockTypeID = "Soil", StockGroupID = "Total Ecosystem Carbon", Value = 1.0))
saveDatasheet(stockGroupMembership, sheetData, sheetName, append = F)





# Flow Group Membership-----------------------------------------------------------------------------------
# 
flowGroupMembership = scenario(myProject, "SF Flow Group Membership", overwrite = T, create=T)

sheetName = "SF_FlowTypeGroupMembership"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Group Membership", optional = T, empty = T)
# NPP
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Net Primary Productivity (NPP)", Value = 1.0))
# NEP
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Net Ecosystem Productivity (NEP)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Net Ecosystem Productivity (NEP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Net Ecosystem Productivity (NEP)", Value = -1.0))
# NBP
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Net Biome Productivity (NBP)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (grain)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (straw)", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Leaching", FlowGroupID = "Net Biome Productivity (NBP)", Value = -1.0))
# Emissions
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", FlowGroupID = "Emission", Value = 1.0))
# Mortality
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought high)", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought medium)", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought low)", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality", FlowGroupID = "Mortality", Value = 1.0))

# Types as Groups
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality", FlowGroupID = "Mortality", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Litterfall", FlowGroupID = "Litterfall", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought high)", FlowGroupID = "Mortality (Drought high)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought medium)", FlowGroupID = "Mortality (Drought medium)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought low)", FlowGroupID = "Mortality (Drought low)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Leaching", FlowGroupID = "Leaching", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (straw)", FlowGroupID = "Harvest (straw)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (grain)", FlowGroupID = "Harvest (grain)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest", FlowGroupID = "Harvest", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", FlowGroupID = "Growth", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (straw)", FlowGroupID = "Emission (straw)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", FlowGroupID = "Emission (soil)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", FlowGroupID = "Emission (litter)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (grain)", FlowGroupID = "Emission (grain)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", FlowGroupID = "Emission (biomass)", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", FlowGroupID = "Emission", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Decomposition", FlowGroupID = "Decomposition", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Deadfall", FlowGroupID = "Deadfall", Value = 1.0))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Composting", FlowGroupID = "Composting", Value = 1.0))
saveDatasheet(flowGroupMembership, sheetData, sheetName, append = F)


# Flow Order-----------------------------------------------------------------------------------
# 
flowOrder = scenario(myProject, "SF Flow Order", overwrite = T, create=T)

sheetName = "SF_FlowOrder"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Order", optional = T, empty = T, lookupsAsFactors = T)
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Composting", Order = 0.5))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Litterfall", Order = 1))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Growth", Order = 2))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (straw)", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest (grain)", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Harvest", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (biomass)", Order = 3))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Deadfall", Order = 4))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Decay", Order = 5))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (litter)", Order = 6))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Decomposition", Order = 6))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Leaching", Order = 7))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (soil)", Order = 7))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (straw)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Emission (grain)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought high)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought medium)", Order = 10))
sheetData = addRow(sheetData, data.frame(FlowTypeID = "Mortality (Drought low)", Order = 10))
saveDatasheet(flowOrder, sheetData, sheetName, append = F)

# Flow Order Options
sheetName = "SF_FlowOrderOptions"
sheetdata = datasheet(myProject, name = sheetName, scenario = "SF Flow Order", optional = T, empty = T)
sheetData = data.frame(ApplyBeforeTransitions = T, ApplyEquallyRankedSimultaneously = T)
saveDatasheet(flowOrder, sheetData, sheetName, append = F)



# Flow Spatial Multipliers-----------------------------------------------------------------------------------
# 
flowSpatialMultipliers = scenario(myProject, "SF Flow Multipliers [Spatial]", overwrite = T)
sheetName = "stsimsf_FlowSpatialMultiplier"
sheetData = datasheet(myProject, name = sheetName, scenario = "SF Flow Multipliers [Spatial]", optional = T, empty = T)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Growth [Type]", MultiplierFileName = "R Inputs/Data/flows/spatial-multipliers/SM_Growth_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Decay [Type]", MultiplierFileName = "R Inputs/Data/flows/spatial-multipliers/SM_Q10SlowMultiplier_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Decomposition [Type]", MultiplierFileName = "R Inputs/Data/flows/spatial-multipliers/SM_Q10SlowMultiplier_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Emission (litter) [Type]", MultiplierFileName = "R Inputs/Data/flows/spatial-multipliers/SM_Q10FastMultiplier_1km.tif"))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Emission (soil) [Type]", MultiplierFileName = "R Inputs/Data/flows/spatial-multipliers/SM_SoilEmission-Q10SlowMultiplier_1km.tif"))
saveDatasheet(flowSpatialMultipliers, sheetData, sheetName, append = F)













#####  ===================================================================================================
# Section 8: Create Flow Temporal Multipliers ============================================================
#####  ===================================================================================================

# Compositing Multipliers --------------------------------------------------------------------------------
fmCompost = read_csv("R Inputs/Data/flow-multipliers/composting.csv") %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, "SF Flow Multipliers [Compost]", overwrite = F)
sheetData = datasheet(myProject, name = "stsimsf_FlowMultiplier", scenario = "SF Flow Multipliers [Compost]", optional = T, empty = T)
sheetData = rbind(fmCompost)
saveDatasheet(myScenario, sheetData, name="stsimsf_FlowMultiplier")




# CFE Multipliers --------------------------------------------------------------------------------------------
##### RCP 4.5
cfe = "low"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "medlow"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "med"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "medhigh"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "high"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)


##### RCP 8.5
cfe = "low"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "medlow"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "med"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "medhigh"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

cfe = "high"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "cfe", ".", cfe, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers CFE", " [", cfe, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)



# Climate Growth Multipliers -----------------------------------------------------------------------

##### RCP 4.5
gcm = "CanESM2"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "CNRM-CM5"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "MIROC5"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

##### RCP 8.5
gcm = "CanESM2"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "CNRM-CM5"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "MIROC5"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "growth", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID="Growth [Type]")
myScenario = scenario(myProject, paste("SF Flow Multipliers Growth", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)


# Climate Q10 DOM Multipliers -----------------------------------------------------------------------

##### RCP 4.5
gcm = "CanESM2"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "CNRM-CM5"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "MIROC5"
rcp = "rcp45"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

##### RCP 8.5
gcm = "CanESM2"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "CNRM-CM5"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "HadGEM2-ES"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)

gcm = "MIROC5"
rcp = "rcp85"
myData = read_csv(paste("R Inputs/Data/flow-multipliers/", "q10", ".", gcm, ".", rcp, ".csv", sep="")) %>% mutate(FlowGroupID=paste(FlowGroupID," [Type]", sep=""))
myScenario = scenario(myProject, paste("SF Flow Multipliers Q10", " [", gcm, ".", rcp, "]", sep=""), overwrite=F)
saveDatasheet(myScenario, myData, name = "stsimsf_FlowMultiplier", append = F)





# Drought Flow Multipliers ----------------------------------------------------------------------------------
myScenario = scenario(myProject, "SF Flow Multipliers [Drought Mortality]", overwrite=F)
sheetData = datasheet(myProject, name = "stsimsf_FlowMultiplier", scenario = "SF Flow Multipliers [Drought Mortality]", optional = T, empty = F)
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (Drought high) [Type]", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.5, DistributionMax = 1.0))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (Drought medium) [Type]", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.1, DistributionMax = 0.5))
sheetData = addRow(sheetData, data.frame(FlowGroupID = "Mortality (Drought low) [Type]", DistributionType = "Uniform", DistributionFrequencyID = "Always", DistributionMin = 0.01, DistributionMax = 0.1))
saveDatasheet(myScenario, sheetData, name = "stsimsf_FlowMultiplier")








# Merge Flow Multiplier Dependencies  --------------------------------------------------------------------

# CanESM -------------------------------------------------------------------------------------------------
# Rcp45
gcm = "CanESM2"
rcp="rcp45"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
           paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
           paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
           paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
           "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# Rcp85
gcm = "CanESM2"
rcp="rcp85"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# CNRM-CM5 --------------------------------------------------------------------------
# Rcp45
gcm = "CNRM-CM5"
rcp="rcp45"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# Rcp85
gcm = "CNRM-CM5"
rcp="rcp85"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# HadGEM2-ES --------------------------------------------------------------------------
# Rcp45
gcm = "HadGEM2-ES"
rcp="rcp45"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# Rcp85
gcm = "HadGEM2-ES"
rcp="rcp85"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# MIROC5 --------------------------------------------------------------------------
# Rcp45
gcm = "MIROC5"
rcp="rcp45"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# Rcp85
gcm = "MIROC5"
rcp="rcp85"
cfe = "Low"
cfe2 = "low"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedLow"
cfe2 = "medlow"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "Medium"
cfe2 = "med"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "MedHigh"
cfe2 = "medhigh"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

cfe = "High"
cfe2 = "high"
myScenario = scenario(myProject, paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep=""))
mergeDependencies(myScenario) = T
dependency(myScenario, c(
  paste("SF Flow Multipliers CFE [", cfe2, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Growth [", gcm, ".", rcp, "]", sep=""),
  paste("SF Flow Multipliers Q10 [", gcm, ".", rcp, "]", sep=""),
  "SF Flow Multipliers [Compost]", "SF Flow Multipliers [Drought Mortality]"))

# -----------------------------------------------------------------------------------#
# Create Final Scenarios
# -----------------------------------------------------------------------------------#












#####  ===================================================================================================
# Section 9: Create Final Merged Scenarios ===============================================================
#####  ===================================================================================================

# Create STSM and SF Constants ---------------------------------------------------------------------------

myScenario = scenario(myProject, "STSM Constants", overwrite = F)
dependency(myScenario, dependency = c("Pathways", "Initial Conditions", "Output Options", "Transition Size Distribution", "Time Since Transition", "Adjacency Multipliers",
                                         "State Attributes", "Historical Distributions", "Slope Multiplier"))


myScenario = scenario(myProject, "SF Constants", overwrite = F)
dependency(myScenario, dependency = c("SF Flow Pathways", "SF Initial Stocks [Spatial]", "SF Output Options", "SF Stock Group Membership", "SF Flow Group Membership",
                                       "SF Flow Order", "SF Flow Multipliers [Spatial]"))

# Create a Final Scenario ---------------------------------------------------------------------------------

mc = 100
ts = 100
lulc = "BAU"
exvar = "External Variables [Medium/BAU]"
gcm = "CanESM2"
rcp = "rcp45"
cfe = "MedLow"
intervention = "No Intervention"

myScenario = scenario(myProject, paste(lulc, gcm, rcp, cfe, intervention, sep = "."), overwrite = F) # Create the new scenario
dependency(myScenario, 
           dependency = c("STSM Constants", "SF Constants", 
                          paste("Run Control [",ts,"TS; ", mc, "MC]", sep=""),
                          exvar, 
                          paste("SF Flow Multipliers [", gcm, ".", rcp, ".", cfe, "]", sep = ""), 
                          paste("Spatial Multipliers [", gcm, ".", rcp, "]", sep = ""),
                          paste("Transition Multipliers [", intervention, "]", sep=""),
                          paste("Transition Targets [", lulc, ".", gcm, ".", rcp, "]", sep = "")))





# Run Scenarios-----------------------------------------------------------------------------------


# Run test scenario
run(myProject, scenario = 81, summary = F, jobs = 1, forceElements = F)












