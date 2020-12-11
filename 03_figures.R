# Joy Kumagai (joy.kumagai@senckenberg.de ; jkumagai@ucsd.edu.com)
# Date: Dec 10th 2020
# Purpose of Script: Create stacked bar graph figure of habitat protection
# Dive Atlas Protection Plan 

#### Load Packages ####
library(tidyverse)
library(cowplot)

#### Load Data ####
data <- read.csv("data/results/protection_table.csv")
data$habitat <- c("Cold Corals", "Coral Reefs", "Mangroves", "Saltmarshes", "Seagrasses")

all <- data[, 1:3]
no_take <- data[,c(1, 4, 5)]
colnames(all) <- c("habitat", "Proposed", "Current")
colnames(no_take) <- c("habitat", "Proposed", "Current")

all <- all %>% 
pivot_longer(Proposed:Current, names_to = "mpa_type", values_to = "percent_protected") %>% 
  mutate(no_take = FALSE)

no_take <- no_take %>% 
  pivot_longer(Proposed:Current, names_to = "mpa_type", values_to = "percent_protected") %>% 
  mutate(no_take = TRUE)


p1 <- all %>% 
  ggplot(aes(x = habitat, y = percent_protected, fill = mpa_type)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_manual(values = c("#D9F0D3", "#5AAE61"), name = "All MPAs") +
  theme_minimal() +
  theme(legend.position = "bottom", 
        axis.line = element_line(color="lightgrey")) +
  ylim(0, 80) + 
  labs(x = "Habitat", y = "Perecent Protected")

p2 <- no_take %>% 
  ggplot(aes(x = habitat, y = percent_protected, fill = mpa_type)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_manual(values = c("#F4A582", "#D6604D"), name = "No-take MPAs") +
  theme_minimal() +
  theme(legend.position = "bottom", 
        axis.line = element_line(color="lightgrey")) +
  ylim(0, 80) +
  labs(x = "Habitat", y = "Perecent Protected")

p3 <- plot_grid(p1, p2, labels = "AUTO")
ggsave2("data/results/figure01.png", p3, device = "png", width = 12, height = 6, units = "in", dpi = 600)
