library(tidyverse)
library(ggplot2)
library(lubridate)
library(sentimentr)
library(wordcloud)
library(dplyr)
library(tidytext)

rm(list = ls())

rds_data <- read_rds("data/sentiment_data.rds")

#Renaming columns to camelcase for consistency
rds_data <- rds_data %>%
  rename(dateRecieved = Date.received) %>%
  rename(dateSentToCompany = Date.sent.to.company) %>%
  rename(subProduct = Sub.product) %>%
  rename(subIssue = Sub.issue) %>%
  rename(submittedVia = Submitted.via) %>%
  rename(consumerComplaintNarrative = Consumer.complaint.narrative) %>%
  rename(companyPublicResponse = Company.public.response) %>%
  rename(zipCode = ZIP.code) %>%
  rename(consumerConsentProvided = Consumer.consent.provided.) %>%
  rename(companyResponseToConsumer = Company.response.to.consumer) %>%
  rename(timelyResponse = Timely.response.) %>%
  rename(consumerDisputed = Consumer.disputed.) %>%
  rename(complaintId = Complaint.ID) %>%
  rename(issue = Issue) %>%
  rename(product = Product) %>%
  rename(company = Company) %>%
  rename(state = State) %>%
  rename(tags = Tags)

#in order to run my querys faster
#df_subset <- tail(rds_data, 50000)

#Replace blanks with NA
rds_data[rds_data == ""] <- NA
#df_subset[df_subset == ""] <- NA

#remove all instances of X
rds_data <- rds_data %>%
  mutate(consumerComplaintNarrative = gsub("X", "", consumerComplaintNarrative))
#df_subset <- df_subset %>%
 # mutate(consumerComplaintNarrative = gsub("X", "", consumerComplaintNarrative))

#select columns for sentiment analysis
clean_rds_data <- rds_data %>%
  select(dateRecieved, product, issue, consumerComplaintNarrative, company, state)

write_rds(clean_rds_data, "data/clean data/clean_rds_data.rds")
