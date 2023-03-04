# Sentiment-Analysis
## Introduction
I have analyzed a dataset of numerous consumer narratives surrounding various financial institutions in the United States.  The goal is for any company / person in the US to be able to use this analysis to determine which banks are best for them and their banking needs.
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
<img src="Plots/Financial Institutions Number of Complaints by State.png" alt="Financial Institutions Performance by State" width="1600" height="300">

* To chart this I used the afinn sentiment database and summed all of the scores together and applied a log scale to the sum of each companies score in every state
* We can see that the states with the worst sentiment ratings for their financial institutions are CA, IL, TX, NY, FL, GA, AL

2) Companies Performance by Month
<img src="Plots/Severity of Issues by Month.png" alt="Financial Institutions Performance by Month" width="1600" height="300">

* To chart this I took the total amount of complaints received in each month to create the initial bar chart.  To color each bar chart I then used the afinn database to get a sentiment score and colored each bar chart in based on the severity of its sentiment. Lighter shades of blue indicate worse consumer narratives and darker shades of blue indicate less negative consumer narratives
* July, August, September, and October have the most total consumer narratives
* March, May, and June have the most negative consumer narratives
* April, August, September, and October have the least negative consumer narratives

3) Word Cloud
<img src="Plots/Wordcloud.png" alt="Financial Institutions Performance by Month" width="600" height="300">

* The general sentiment surrounding these financial institutions performance is overall negative with words like "haphazard", "craziness","faltered", and "loathing", etc. occuring at a significant rate

4) Best Performing Financial Institutions
<img src="Plots/Best Performing Institutions.png" alt="Best Performing Institutions" width="600" height="300">

* Banco Popular North America, Freedom Mortgage, Great Lakes, Impac Mortgage Holdings Inc., Marlette Founding Inc are the best performing financial institutions

5) Worst Performing Financial Institutions 
<img src="Plots/Worst Performing Institutions.png" alt="Best Performing Institutions" width="1200" height="300">

* Bank of America, Equifax, Experian, Trans Union Intermediate Holdings Inc, and Wells Fargo and Company are the worst performing financial institutions

## Conclusion
1) There is an overall negative sentiment towards these financial institutions
2) CA, TX, FL, AL, IL, GA, NY are the overall worst performing states in terms of consumer sentiment
3) March, May, and June are the worst performing months in terms of consumer sentiment
4) This information can help be a huge help for businesses's and ordinary people alike better plan their financial futures whether it be when or where they make their transactions
