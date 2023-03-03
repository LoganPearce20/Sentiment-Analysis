library(tidyverse)
library(ggplot2)
library(lubridate)
library(sentimentr)
library(wordcloud)
library(dplyr)
library(tidytext)
library(DT)

rm(list = ls())

rds_data <- read_rds("data/clean data/clean_rds_data.rds")

get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")

#for time series by month
rds_data <- rds_data %>%
  mutate(month = substr(dateRecieved, 0, regexpr("", dateRecieved)+1))

#sentiment analysis on severity of issues based on company and using log scale to compare larger institutions to smaller ones
sentiment_analysis <- rds_data %>%
  unnest_tokens(word, consumerComplaintNarrative)

sentiment_company <- sentiment_analysis %>%
  inner_join(get_sentiments("afinn"))

sentiment_company_scores <- sentiment_company %>%
  group_by(company) %>%
  summarize(sentiment_score = sum(value))

any(duplicated(sentiment_company_scores$company)) #test if all company entries are unique

sentiment_company_scores$log_company_score <- log(abs(sentiment_company_scores$sentiment_score))

sentiment_month <- sentiment_analysis %>%
  inner_join(get_sentiments("afinn"))

sentiment_month_scores <- sentiment_month %>%
  group_by(month) %>%
  summarize(sentiment_score = sum(value))

sentiment_month_scores$log_month_score <- log(abs(sentiment_month_scores$sentiment_score))

#nrc and bing
nrc_anger <- get_sentiments("nrc") %>% 
  filter(sentiment == "anger")

sentiment_analysis %>%
  inner_join(nrc_anger) %>%
  count(word, sort = TRUE)

consumer_sentiment <- sentiment_analysis %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>% 
  mutate(sentiment = negative)

ggplot(consumer_sentiment, aes(word, sentiment, fill = word)) +
  geom_col(show.legend = FALSE) +
  labs(x = "Word", y = "Use of Word", title = "Angry Sentiments")

#Time-series for company performance by month
issues_by_month <- rds_data %>%
  select(month) %>%
  mutate(month = if_else(month == "01", "Jan",month)) %>%
  mutate(month = if_else(month == "02", "Feb",month)) %>%
  mutate(month = if_else(month == "03", "Mar",month)) %>%
  mutate(month = if_else(month == "04", "Apr",month)) %>%
  mutate(month = if_else(month == "05", "May",month)) %>%
  mutate(month = if_else(month == "06", "Jun",month)) %>%
  mutate(month = if_else(month == "07", "Jul",month)) %>%
  mutate(month = if_else(month == "08", "Aug",month)) %>%
  mutate(month = if_else(month == "09", "Sep",month)) %>%
  mutate(month = if_else(month == "10", "Oct",month)) %>%
  mutate(month = if_else(month == "11", "Nov",month)) %>%
  mutate(month = if_else(month == "12", "Dec",month)) %>%
  group_by(month) %>%
  summarise(numIssues = length(month))

ggplot(issues_by_month) +
  geom_point(mapping = aes(x = month, y = numIssues, color = sentiment_month_scores$log_month_score)) +
  scale_x_discrete(limits = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
  labs(y = "Number of Issues", x = "Month", color = "Log Sentiment Score", title = "Log Sentiment Scores by Month")

#Word cloud analysis
sentiment_analysis %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 50))

# Company performance by state for shiny app
sentiment_analysis <- rds_data %>%
  unnest_tokens(word, issue)

sentiment_company_by_state <- sentiment_analysis %>%
  inner_join(get_sentiments("afinn"))

sentiment_company_by_state_scores <- sentiment_company %>%
  group_by(state, company, month) %>%
  summarize(sentimentScore = sum(value)) %>%
  mutate(month = if_else(month == "01", "Jan",month)) %>%
  mutate(month = if_else(month == "02", "Feb",month)) %>%
  mutate(month = if_else(month == "03", "Mar",month)) %>%
  mutate(month = if_else(month == "04", "Apr",month)) %>%
  mutate(month = if_else(month == "05", "May",month)) %>%
  mutate(month = if_else(month == "06", "Jun",month)) %>%
  mutate(month = if_else(month == "07", "Jul",month)) %>%
  mutate(month = if_else(month == "08", "Aug",month)) %>%
  mutate(month = if_else(month == "09", "Sep",month)) %>%
  mutate(month = if_else(month == "10", "Oct",month)) %>%
  mutate(month = if_else(month == "11", "Nov",month)) %>%
  mutate(month = if_else(month == "12", "Dec",month)) 

sentiment_company_by_state_scores$logStateScore <- log(abs(sentiment_company_by_state_scores$sentimentScore))

#shinyApp
column_names<-colnames(sentiment_company_by_state_scores) #for input selections
ui<-fluidPage( 
  
  titlePanel(title = "Sentiment Analysis of Financial Institutions"),
  h4('Financial Institions Performance by State & Month'),
  
  fluidRow(
    column(2,
           selectInput('X', 'Choose State or Month',column_names,column_names[3])),
    column(4,
           selectInput('Y', 'Choose Log Score or Summed Score',column_names,column_names[5])),
    column(6,
           selectInput('Splitby', 'Split By', column_names,column_names[2]))
    ),
    column(12,plotOutput('plot_01')),
    column(12,DT::dataTableOutput("table_01")),
    column(12,plotOutput('plot_02')),
    column(12,plotOutput('plot_03'))
  )
  
  

server<-function(input,output){
  
  output$plot_01 <- renderPlot({
    ggplot(sentiment_company_by_state_scores, aes_string(x = input$X, y = input$Y)) +
      geom_col() +
      geom_smooth() 
  })
  output$plot_02 <- renderPlot({
    sentiment_analysis %>%
      anti_join(stop_words) %>%
      count(word) %>%
      with(wordcloud(word, n, max.words = 50))
  })
  output$plot_03 <- renderPlot ({
    ggplot(issues_by_month) +
      geom_point(mapping = aes(x = month, y = numIssues, color = sentiment_month_scores$log_month_score)) +
      scale_x_discrete(limits = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
      labs(y = "Number of Issues", x = "Month", color = "Log Sentiment Score", title = "Severity of Issues by Month")
  })
  output$table_01<-DT::renderDataTable(sentiment_company_by_state_scores[,c(input$X,input$Y,input$Splitby)],options = list(pageLength = 4))
}

shinyApp(ui=ui, server=server)

