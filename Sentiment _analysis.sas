/*loading Dataset*/

proc import datafile='/home/u63493410/Social_Media.csv update.csv'
    out=MyData
    dbms=csv
    replace;
    getnames=yes;
run;

/********************************************************************
Category-Based Sentiment Analysis*/

proc sql;
   create table CategorySentiment as
   select Category, Sentiment, count(*) as SentimentCount
   from MyData
   group by Category, Sentiment;
quit;

/*Summarize or Visualize the Data*/

proc sgplot data=CategorySentiment;
  vbar Category / response=SentimentCount group=Sentiment;
   keylegend / location=inside position=topright;
run;

/***********************************************************************
/***********************************************************************

Emotion Analysis/Sentiment Analysis using Emotional Lexicon approach*/

/* Isolate the relevant columns */
data EmotionAnalysisData;
   set MyData(keep=Type_y Sentiment);
run;

/* Calculating the emotion distribution by sentiment */
proc freq data=EmotionAnalysisData;
   tables Sentiment*Type_y / out=EmotionSummary;
run;

/* Sort both datasets by Sentiment variable */
proc sort data=EmotionAnalysisData;
   by Sentiment;
run;

proc sort data=MyData;
   by Sentiment;
run;

/* Merge the Score column from MyData into EmotionAnalysisData */
data EmotionAnalysisDataWithScore;
   merge EmotionAnalysisData(in=InEmotionData) MyData(keep=Sentiment Score in=InMyData);
   by Sentiment;
   if InEmotionData and InMyData;
run;

/* Calculating the mean emotion scores for each emotion within each sentiment category */
proc means data=EmotionAnalysisDataWithScore mean;
   class Sentiment Type_y;
   var Score;
   output out=MeanEmotionScores mean=Mean_Score;
run;

/*---------------------------------------------------------------------------------*
//*visualizations based on mean emotion scores by sentiment*/

/* Create a bar chart of mean emotion scores by sentiment */
proc sgplot data=MeanEmotionScores;
   vbar Type_y / response=Mean_Score group=Sentiment;
   xaxis discreteorder=data;
   yaxis grid;
   title "Mean Emotion Scores by Sentiment";
run;

/* Create a box plot of emotion scores by sentiment */
proc sgplot data=MeanEmotionScores;
   vbox Mean_Score / category=Sentiment;
   xaxis grid;
   yaxis label="Mean Score" grid;
   title "Box Plot of Emotion Scores by Sentiment";
run;

/* Create a scatter plot of mean emotion scores by sentiment and emotion */
proc sgplot data=MeanEmotionScores;
   scatter x=Sentiment y=Mean_Score / group=Type_y datalabel=Type_y;
   xaxis grid;
   yaxis label="Mean Score" grid;
   title "Scatter Plot of Mean Emotion Scores by Sentiment and Emotion";
run;

/*-------------------------------------------------------------------------------*/

/*Sentiment distribution for content type or Type_x column along with score*/

/* Calculating summary statistics (mean, median, etc.) for Score by Type_x*/
proc means data=MyData mean median std min max;
   class Type_x;
   var Score;
run;

/* Creating a bar chart of mean scores by Type_x and Sentiment */
proc sgplot data=MyData;
   vbar Type_x / response=Score group=Sentiment;
   xaxis discreteorder=data;
   yaxis grid;
   title "Mean Score Distribution by Type_x and Sentiment";
run;

/* Create a box plot of sentiment scores by Type_x */
proc sgplot data=MyData;
   hbox Score / category=Type_x group=Sentiment;
   xaxis grid;
   yaxis label="Content Type" grid;
   title "Box Plot of Sentiment Scores by Content Type";
run;

/*---------------------------------------------------------------------------------*/

/*Exporting the csv file*/

proc export data=Mydata
outfile='path of the file'
dbms=csv replace;
putnames=yes;
run;





























































