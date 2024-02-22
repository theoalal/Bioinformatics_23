## Choosing a directory
setwd("C:/Users/Omistaja/Desktop/R_scripts/Bioinformatics_23")

# Checking the content of the directory
list.files()
# Installing tidyverse
install.packages("tidyverse")
 # Loading the package
library(tidyverse)
# Loading a csv data file
var <- read.csv("variants_long_table.csv")
# Checking the first few variables in the data frame
head(var)
# CHecking the dimensions of the data
dim(var)
# Number of rows
nrow(var)
#Number of columns
ncol(var)
#Checking the structure of the R object
str(var)
#Checking the summary statistics of the whole data
summary(var)
#Checking specific non-numerical var
summary(var$SAMPLE)
#Summary for numerical var
summary(var$DP)

#Checking data class
class(var)
class(var$SAMPLE)
class(var$CHROM)
typeof(var$CHROM)

#Preview data in spreadsheet mode
view(var)

#checking column names
colnames(var)

#selecting columns 1, 4 and 5 and all rows
var[, c(1,4,5)]
#Selecting columns with default display
select(var, SAMPLE, REF, ALT)

#select columns 1, 4, and 5 with selected display
select(var, SAMPLE, REF, ALT) %>% head(3)

#select all columns except "CALLER" with selected display
select(var, -CALLER) %>% head(3)
#Transforming the data frame into tibble
var_tb <- as_tibble(var)
select(var_tb, SAMPLE, REF, ALT) %>% head(3)

#Filtering
#select rows with selected display using base R code
var_tb[var_tb$SAMPLE == "SRR13500958",]
#selecting rows with dplyr
filter(var_tb, SAMPLE == "SRR13500958") %>% head(3)

# Select sample type (rows) and variables (columns) with selected display
var_tb %>% filter(SAMPLE == "SRR13500958") %>% select(CHROM, POS, REF, ALT) %>% head(3)

# To select all data related to the sample specified
var_tb %>% filter(SAMPLE == "SRR13500958") %>% select(CHROM, POS, REF, ALT, DP)

# To select only values for which DP>=500 for the same sample
var_tb %>% filter(SAMPLE == "SRR13500958" & DP>=500) %>% select(CHROM, POS, REF, ALT, DP)

# To select only values for which DP>=1000 for the same sample
var_tb %>% filter(SAMPLE == "SRR13500958" & DP>=1000) %>% select(CHROM, POS, REF, ALT, DP)

# Count how many rows are associated with each sample in the data 
var_tb %>% count(SAMPLE)

# Sorting the counts 
var_tb %>% count(SAMPLE, sort = TRUE)

# Distribution of genes per sample and counts 
var_tb %>% count(SAMPLE, GENE, sort = TRUE) %>% head()

##Basic maths ##
# Maximum value of column DP
max(var_tb$DP)
min(var_tb$DP)
mean(var_tb$DP)

# Compute a LOG2 transformation on the DP values in new column
var_tb_log <- var_tb %>% mutate(DP_log2 = log2(DP))
head(var_tb_log)

# View a selected content including the new column
select(var_tb_log, SAMPLE, REF, ALT, DP, DP_log2) %>% head()

# Show the maximum value of DP for each sample
var_tb %>% group_by(SAMPLE) %>% summarize(max(DP))

# Show the minimum value of DP for each sample
var_tb %>% group_by(SAMPLE) %>% summarize(min(DP))


#################################
#Data visualization
# Linking ggplot2 to a specific data frame
ggplot(data = var_tb)

#Linking variable to ggplot2 using aesthetics
ggplot(data = var_tb, aes(x=SAMPLE, y=DP))

##############
#Defining the plot type
# 1. Point plot
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_point()

#2. Boxplot
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_boxplot()


####################################
### Advanced plotting options: axis transformation ##
# xlim() and ylim()
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_point() + ylim(0,10000)
#Boxplot #
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_boxplot() + ylim(0, 10000)

## Other way of doing generating same plot ##
# Points (left-hand plot)
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_point() + scale_y_continuous(name="dp", limits=c(0, 10000))

# Boxplot (right-hand plot)
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_boxplot() + scale_y_continuous(name="dp", limits=c(0, 10000))

#################################
#3 Log transformation ##
# Points (left-hand plot)
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_point() + scale_y_continuous(trans='log10')

ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_point() + scale_y_log10()

# Boxplot (right-hand plot)
ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_boxplot() + scale_y_continuous(trans='log10')

ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) + geom_boxplot() + scale_y_log10()

#############################
## Colors, shapes, legends ##
# Colours of shapes
ggplot(data = var_tb, aes(x=SAMPLE, y=DP, colour = SAMPLE)) + geom_boxplot() + ylim(0,10000)

# Colours for filling options
ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000)


####################################
## changing default colors ##
# Colours for filling options with manual colors
ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_manual(values=c("#cb6015", "#e1ad01", "#6d0016", "#808000", "#4e3524"))

# Colours for filling options with preset palettes
install.packages("RcolorBrewer")
library(RColorBrewer)
ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu")

### Changing legend positions ##
ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu") + theme(legend.position="top")

ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu") + theme(legend.position="none")

### Changing plot and axis title ##
ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu") + theme(legend.position="bottom") + labs(title="DP_per_Sample", x="SampleID", y = "DP")

ggplot(data = var_tb, aes(x=SAMPLE, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu") + theme(legend.position="bottom") + ggtitle("DP per Sample") + xlab("Sample") + ylab("DP")

### Changing point shapes, color and sizes ###

ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) +  geom_point(shape = 21, fill = "#e4dbc1", color = "#b92e17", size = 6) + ylim(0,10000)

ggplot(data = var_tb, aes(x=SAMPLE, y=DP)) +  geom_point(shape = 23, color = "#e4dbc1", fill = "#b92e17", size = 5, alpha=0.5) + ylim(0,10000)

## To see all available point types in R ##

ggpur::show_point_shapes()

########################################
## Advanced variants exploration ##
#To view the data ##
view(var_tb)
## Checking the distribution of DP values per chromosomes and per sample ##
# faceting
ggplot(data = var_tb, aes(x=CHROM, y=DP, fill= SAMPLE)) + geom_boxplot() + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu") + labs(title="DP_per_Chromosome") + facet_grid(. ~ SAMPLE)
# Define a variable with plotting options

p_DP_CHROM <- ggplot(data = var_tb, aes(x=CHROM, y=DP, fill= SAMPLE)) + ylim(0,10000) + scale_fill_brewer(palette="RdYlBu") + labs(title="DP_per_Chromosome") + theme(legend.position="bottom")

# Test boxplots with faceting 

p_DP_CHROM + geom_boxplot() + facet_grid(. ~ SAMPLE)

# Combine violin plots and boxplots with faceting

p_DP_CHROM + geom_violin(trim=FALSE) + facet_grid(. ~ SAMPLE) + geom_boxplot(width=0.1)

## Checking variant effect per sample ##
#1. Plotting the variants effect #
# Count number of different effects per sample
p_EFFECT <- ggplot(data = var_tb, aes(x=EFFECT, fill= SAMPLE)) + scale_fill_brewer(palette="RdBu") + labs(title="Effect_per_Sample") + theme(legend.position="bottom")

p_EFFECT + geom_bar()

# Flip orientation

p_EFFECT_flip <- ggplot(data = var_tb, aes(y=EFFECT, fill= SAMPLE)) + scale_fill_brewer(palette="RdBu") + labs(title="Effect_per_Sample") + theme(legend.position="bottom")

p_EFFECT_flip + geom_bar()

#2. counting variants effects
# Count the number of different effects

var_tb %>% count(EFFECT)
# Count the number of different effects and link them to sample information

var_tb %>% count(EFFECT, SAMPLE, sort = TRUE)

#######################################
#1. counting and extracting the effects for all genes
# Counting the effects per gene

var_tb %>% count(EFFECT, GENE, sort = TRUE)

##2. counting and extracting specific effects for all genes ##
# Filtering option 1 to select for effect on stop

filter(var_tb, EFFECT == "stop_lost" | EFFECT == "stop_gained")

# A tibble: 4 × 16

# Filtering option 2 to select for effect on stop

filter(var_tb, EFFECT %in% c("stop_lost", "stop_gained"))

# A tibble: 4 × 16

# Filtering on effect and selected columns

filter(var_tb, EFFECT %in% c("stop_lost", "stop_gained")) %>% select(SAMPLE, CHROM, GENE, EFFECT)

### Examining read depth per position ###
# Define your variable

p_DP_POS <- ggplot(data = var_tb, aes(x=POS, y=DP, fill= SAMPLE)) + scale_fill_brewer(palette="RdBu") + labs(title="DP_per_Position") + theme(legend.position="bottom")

# Plot

p_DP_POS + geom_point(shape = 21, size = 5)

# Plot with transparency options

p_DP_POS + geom_point(shape = 21, size = 5, alpha = 0.7)