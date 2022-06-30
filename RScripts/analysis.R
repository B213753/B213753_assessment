# Author: B213753
# This script takes the training data set to build a regression model.
# Then it takes the collected data set (.rds) file to use as a 
# test dataset to cross validate the model.
# Outputs are to the console and the plots panel. No outputs are saved
# as files. 


library(tidyverse)
library(here)

# Read in training and collected (test) dataset
LOS_collected<-read_rds(here("RawData","complete_CollectedData.rds"))
LOS_train <- read.csv(here("Data","LOS_train.csv"))

# Explore Age vs Organisation
# Histogram for age
LOS_train %>% 
  ggplot(aes(x=Age))+
  geom_histogram(bins=20)+
  theme_bw()

# Age summary stats
LOS_train %>% 
  summarise(mean_age=mean(Age),median_age=median(Age),IQR=IQR(Age),Min_age=min(Age),Max_age=max(Age))

# Numerical summary of age by organisation
LOS_train %>% 
  group_by(Organisation) %>% 
  summarise(mean_age=mean(Age),median_age=median(Age),IQR=IQR(Age),Min_age=min(Age),Max_age=max(Age))

# Explore LOS
LOS_train %>% 
  ggplot(aes(x=LOS))+
  geom_histogram(bins=15)+
  theme_bw()

# LOS summary stats
LOS_train %>% 
  summarise(mean_LOS=mean(LOS),median_LOS=median(LOS), IQR=IQR(LOS),Min_LOS=min(LOS),Max_LOS=max(LOS))

# Explore LOS vs organisation
LOS_train %>% 
  group_by(Organisation) %>% 
  summarise(mean_LOS=mean(LOS),median_LOS=median(LOS), IQR=IQR(LOS),Min_LOS=min(LOS),Max_LOS=max(LOS))


# Explore Death vs organisation
LOS_table <- LOS_train %>% 
    select(Organisation,Death) %>% 
  table() %>% 
  as_tibble() %>% 
  pivot_wider(names_from=Death,values_from = n) %>% 
  mutate(prop=Alive/(Died+Alive))

# Explore LOS vs Age
LOS_train %>% 
  ggplot(aes(x=Age,y=LOS))+
  geom_point()

# Explore LOS vs Death
LOS_train %>% 
  group_by(Death) %>% 
  summarise(mean_LOS=mean(LOS),median_LOS=median(LOS), IQR=IQR(LOS),Min_LOS=min(LOS),Max_LOS=max(LOS))

# Model LOS
LOS.model <- glm(LOS ~ Age + Death + Age:Death, data=LOS_train, family="poisson" )
summary(LOS.model)

# There is overdispersion - use quasipossion
LOS.model2 <- glm(LOS ~ Age + Death + Age:Death, data=LOS_train, family="quasipoisson" )
summary(LOS.model2)

cbind("Exp(coef)"=LOS.model2$coefficients,confint(LOS.model2)) %>% exp() %>% round(.,digits=3)


# Recode death as factor
LOS_collected <- LOS_collected %>% 
  mutate(Death=factor(Death))

# Predict trained data
predicted <- predict(LOS.model2,newdata = LOS_collected,type="response")

LOS_predicted <- LOS_collected %>% 
  mutate(LOS_predict=predicted)

# Plot predicted vs Actual
LOS_predicted %>% 
  ggplot(aes(x=LOS,y=LOS_predict))+
  geom_point()+
  geom_abline(slope=1,intercept=0, color="red")+
  xlim(0,10)+ylim(0,10)+
  labs(y="Predicted LOS (days)",x="Actual LOS (days)")

# RMSE
error <- LOS_collected$LOS - predicted
RMSE <- sqrt(mean(error^2))

RMSE
