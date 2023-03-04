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

worst_company_scores <- sentiment_company %>%
  group_by(company) %>%
  summarize(sentiment_score = sum(value)) %>%
  arrange(sentiment_score) %>%
  head(n = 5)

best_company_scores <- sentiment_company %>%
  group_by(company) %>%
  summarize(sentiment_score = sum(value)) %>%
  arrange(sentiment_score) %>%
  tail(n = 5)

any(duplicated(worst_company_scores$company)) #test if all company entries are unique
any(duplicated(best_company_scores$company))  #test if all company entries are unique

#create log score to compare between 5 best and 5 worst performing companies
worst_company_scores$log_company_score <- log(abs(worst_company_scores$sentiment_score))

best_company_scores$log_company_score <- log(abs(best_company_scores$sentiment_score))

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
  h4('Financial Institions Performance'),
  
  fluidRow(
    column(2,
           selectInput('X', 'Choose State or Month',column_names,column_names[3])),
    column(4,
           selectInput('Y', 'Choose Summed Log Score or Summed Regular Score',column_names,column_names[5])),
    column(6,
           selectInput('Splitby', 'Split By', column_names,column_names[2]))
    ),
    column(12,plotOutput('plot_01')),
    column(12,DT::dataTableOutput("table_01")),
    column(12,plotOutput('plot_02')),
    column(12,plotOutput('plot_03')),
    column(6,plotOutput('plot_04')),
    column(6,plotOutput('plot_05'))
  )
  
  

server<-function(input,output){
  
  output$plot_01 <- renderPlot({
    ggplot(sentiment_company_by_state_scores, aes_string(x = input$X, y = input$Y)) +
      geom_col() +
      labs(title = "Financial Institutions Performance by Month")
  })
  output$plot_02 <- renderPlot({
    consumer_sentiment %>%
      anti_join(stop_words) %>%
      count(word) %>%
      with(wordcloud(word, n, max.words = 25, scale = c(1.75, 0.1)))
  })
  output$plot_03 <- renderPlot ({
    ggplot(issues_by_month) +
      geom_col(mapping = aes(x = month, y = numIssues, fill = sentiment_month_scores$log_month_score)) +
      scale_x_discrete(limits = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
      labs(y = "Number of Issues", x = "Month", color = "Log Sentiment Score", title = "Severity of Issues by Month")
  })
  output$plot_04 <- renderPlot ({
    ggplot(worst_company_scores) +
      geom_col(show.legend = FALSE, mapping = aes(x = company, y = log_company_score, fill = company)) +
      labs(y = "Log Sentiment Value", x = "Company", color = "Company", title = "Worst Performing Institutions")
  })
  output$plot_05 <- renderPlot ({
    ggplot(best_company_scores) +
      geom_col(show.legend = FALSE, mapping = aes(x = company, y = log_company_score, fill = company)) +
      labs(y = "Log Sentiment Value", x = "Company", color = "Company", title = "Best Performing Institutions")
  })
  output$table_01<-DT::renderDataTable(sentiment_company_by_state_scores[,c(input$X,input$Y,input$Splitby)],options = list(pageLength = 4))
}

shinyApp(ui=ui, server=server)

