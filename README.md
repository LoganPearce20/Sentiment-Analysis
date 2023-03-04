# Sentiment-Analysis
## Introduction
I have analyzed a dataset of numerous consumer narratives surrounding various financial institutions in the United States.  This sentiment analysis compares these companies performances in the months of the year as well as all states.  It also highlights the top 5 best and worst performing instituions based on this data.
## Dictionary 📖
1) dateRecieved: The date the company received the consumers narrative.
2) product: The specific aspect of the company that the narrative surrounded.
3) issue: Reason for the consumer narrative.
4) consumerComplaintNarrative: Consumers own words on what went wrong.
5) company: Financial institution in question.
6) state: State where consumer narrative was filed.
## Data Cleaning 🧹
1) Reading the file
* Since the file was 255 MB I converted it into an RDS
```r
rds_data <- read_rds("data/sentiment_data.rds")
```
2) Column Names
* I renamed all of the columns into camelCase for consistency
```r
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
```
3) Removing potential skews
* There was a lot of X's in the consumerComplaintNarrative where things were edited for privacy
* Some blank cells were found throughout the dataset so I replaced those with NA
```r
rds_data <- rds_data %>%
  mutate(consumerComplaintNarrative = gsub("X", "", consumerComplaintNarrative))
  
rds_data[rds_data == ""] <- NA
```
4) Clean and export to RDS
```r
clean_rds_data <- rds_data %>%
  select(dateRecieved, product, issue, consumerComplaintNarrative, company, state)

write_rds(clean_rds_data, "data/clean data/clean_rds_data.rds")
```
## Data Analysis
1) Companies Performance by State
* To chart this I used the afinn sentiment database and summed all of the scores together and applied a log scale to the sum of each companies score in every state
<img src="desktop/git/sentiment-analysis/Plots/Financial Institutions Performance by State" alt="Financial Institutions Performance by State" width="600" height="300">
