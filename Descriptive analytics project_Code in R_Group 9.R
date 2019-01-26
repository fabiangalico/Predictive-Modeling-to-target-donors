############################################################
# DSC PREDICTIVE ANALYTICS MODEL FOR REACTIVATION CAMPAIGN #
############################################################

######################################################################################################################

#INSTALL THE LIBRARIES NEEDED

install.packages("pROC")
library(pROC)
install.packages('dplyr')
library(dplyr)
install.packages("dummies")
library(dummies)
install.packages("rpart")
library(rpart)
install.packages('randomForest')
library(randomForest)
install.packages("ROCR")
library(ROCR)
install.packages("corrplot")
library('corrplot')

#-------------------------------------------DATA PREPARATION-------------------------------------------------------#

#############Training dataset preparation

# Read the data

donordata = read.table("donors.csv",sep=";",header = TRUE, stringsAsFactors = F)

campaign_train = read.table("campaign20130411.csv",sep=";",header = TRUE, stringsAsFactors = F)

gifts = read.table("gifts.csv",sep=";",header = TRUE,stringsAsFactors = FALSE)

#Subsetting gifts dataset with the observations less than "11/04/2013" for the train set

gifts$date = as.Date(gifts$date, format = '%d/%m/%Y')
dummy = which(gifts$date < as.Date("11/04/2013",'%d/%m/%Y'))
gifts1 = gifts[dummy,]
head(gifts1)

#Deriving new variables like 'Max','Min' and 'Mean' amount donated from gift table
gifts2 <- gifts1 %>% group_by(donorID) %>% summarise(mean_donation = round(mean(amount),2), 
                                                    min_donation = round(min(amount),2),
                                                    max_donation = round(max(amount),2),
                                                    Freq_donation = n(),
                                                    Recency_donation = as.numeric(as.Date("11/04/2013",'%d/%m/%Y') - max(date)))


#merge the tables donordata and campaign data
overalltraindata1 = merge(x=donordata,y=campaign_train,by = "donorID",all.x = TRUE)
dim(overalltraindata1)

#Deleting the NA values after merging the campaign and donor data
checkna = which(is.na(overalltraindata1$amount))
overalltraindata1 = overalltraindata1[-checkna,]

#merge the data with gifts data set
overalltraindata2 = merge(x=overalltraindata1,y=gifts2,by = "donorID",all.x = TRUE)
head(overalltraindata2)

#deleting columns 'language' and 'region'
overalltraindata = overalltraindata2[,-c(3,5)]

#converting the target variable to 0 (if amount < 35) and 1 (if amount > 35)

#<35 to 0
overalltraindata$amount[which(overalltraindata$amount < 35)] = 0

#>35 to 1
overalltraindata$amount[which(overalltraindata$amount > 35)] = 1

#change name and position of target variable (Move target variable to the end)
names(overalltraindata)[4] = "Donated"
overalltraindata = overalltraindata[,c(1,2,3,5,6,7,8,9,4)]
dim(overalltraindata)
head(overalltraindata)

#Finding NA values and deleting them

overalltraindata = overalltraindata[-which(is.na(overalltraindata$mean_donation)),]
head(overalltraindata)

#checking the donation outliers
summary(overalltraindata)

plot(overalltraindata$mean_donation)

#deleting the outlier
overalltraindata = overalltraindata[-which(overalltraindata$mean_donation == 12394.68),]


#Creating dummy variables for gender
#Traindata
for(v in "gender"){
  d = dummy(v,data=overalltraindata)
  overalltraindata = cbind(overalltraindata,d)
  overalltraindata[v] = NULL
}

# Grouping Zip codes into three different categories and create dummy variables for them

#Train data
overalltraindata$zipcode[overalltraindata$zipcode < 1300 & overalltraindata$zipcode >= 1000] = 'Brussels'
overalltraindata$zipcode[overalltraindata$zipcode < 4000 & overalltraindata$zipcode >= 1500] = 'North Belgium'
overalltraindata$zipcode[overalltraindata$zipcode <= 9999 & overalltraindata$zipcode >= 9000] = 'North Belgium'
overalltraindata$zipcode[overalltraindata$zipcode < 9000 & overalltraindata$zipcode >= 4000] = 'South Belgium'
overalltraindata$zipcode[overalltraindata$zipcode < 1500 & overalltraindata$zipcode >= 1300] = 'South Belgium'

#Dummy variable creation zip code train
for(v in "zipcode"){
  d = dummy(v,data=overalltraindata)
  overalltraindata = cbind(overalltraindata,d)
  overalltraindata[v] = NULL
}

overalltraindata = overalltraindata[,-c(13,14,18)]

names(overalltraindata)[13] <- "Brussels"
names(overalltraindata)[14] <- "NorthBelgium"
names(overalltraindata)[15] <- "SouthBelgium"

#############Test dataset preparation

campaign_test = read.table("campaign20140115.csv",sep=";",header = TRUE, stringsAsFactors = F)

#merge the donordata and campaign test 
overalltestdata1 = merge(x=donordata,y=campaign_test,by = "donorID",all.x = TRUE)
head(overalltestdata1)

#Remove the rows with NA after merging
overalltestdata1 = overalltestdata1[-which(is.na(overalltestdata1$amount)),]

#Merge the resulting dataset with the gifts dataset
overalltestdata2 = merge(x=overalltestdata1,y=gifts2,by = "donorID",all.x = TRUE)

#deleting columns 'language' and 'region'
overalltestdata = overalltestdata2[,-c(3,5)]

#converting the target variable to 0 (if < 35) and 1 (if > 35)

#<35 to 0
overalltestdata$amount[which(overalltestdata$amount < 35)] = 0

#>35 to 1
overalltestdata$amount[which(overalltestdata$amount > 35)] = 1

#change name and position of our target variable
names(overalltestdata)[4] = "Donated"
overalltestdata = overalltestdata[,c(1,2,3,5,6,7,8,9,4)]
dim(overalltestdata)

#Finding NA values and deleting them

overalltestdata = overalltestdata[-which(is.na(overalltestdata$mean_donation)),]
head(overalltestdata)

#checking the donation outliers
summary(overalltestdata)

#Creating dummy variables for gender
#Testdata
for(v in "gender"){
  d = dummy(v,data=overalltestdata)
  overalltestdata = cbind(overalltestdata,d)
  overalltestdata[v] = NULL
}

# Grouping Zip codes into three different categories and create dummy variables for them

#Test data
overalltestdata$zipcode[overalltestdata$zipcode < 1300 & overalltestdata$zipcode >= 1000] = 'Brussels'
overalltestdata$zipcode[overalltestdata$zipcode < 4000 & overalltestdata$zipcode >= 1500] = 'North Belgium'
overalltestdata$zipcode[overalltestdata$zipcode <= 9999 & overalltestdata$zipcode >= 9000] = 'North Belgium'
overalltestdata$zipcode[overalltestdata$zipcode < 9000 & overalltestdata$zipcode >= 4000] = 'South Belgium'
overalltestdata$zipcode[overalltestdata$zipcode < 1500 & overalltestdata$zipcode >= 1300] = 'South Belgium'


#Dummy variable creation zip code test
for(v in "zipcode"){
  d = dummy(v,data=overalltestdata)
  overalltestdata = cbind(overalltestdata,d)
  overalltestdata[v] = NULL
}

overalltestdata = overalltestdata[,-c(13)]

names(overalltestdata)[13] <- "Brussels"
names(overalltestdata)[14] <- "NorthBelgium"
names(overalltestdata)[15] <- "SouthBelgium"
head(overalltestdata)


#Rearrange the columns of train and test to get target(Donated) at the end 
train = overalltraindata[,c(1,2,3,4,5,6,8,9,10,11,12,13,14,15,7)]
test = overalltestdata[,c(1,2,3,4,5,6,8,9,10,11,12,13,14,15,7)]
head(train)
head(test)
table(overalltraindata$Donated)
table(overalltestdata$Donated)

#Export basetable
write.csv(train,file="basetable.csv")

#------------------------------------------------Model Building-------------------------------------------------------------#

# Custom function to calculate AUC: 
auc = function(trueval, predval){
  df = as.data.frame(cbind(trueval,predval))
  names(df) = c("trueval","predval")
  auc = roc(trueval~predval,basetable=df)$auc
  return(auc)
}

#check correlation between variables and delete the ones which show multicolinearity (min_donatin,max_donation,GenderM and SouthBelgium were deleted)

t <- cor(train)
corrplot(t)

#Removed the variables on the basis of correlation
train <- train[, -c(3,4,9,14)]
test <- test[, -c(3,4,9,14)]

###### FORWARD STEPWISE LOGISTIC REGRESSION to find the number of variables

# All possible variables except DonorId and Targetvariable:
variables = names(train)[-c(1,11)]
variablesorder = c()

# Construct a logistic regression model with no variables
model = glm(Donated ~ 1,data=train,family=binomial)

# Construct a formula with all the variables
formula<-formula(paste("Donated","~",paste(variables,collapse="+")))

#Loop over the steps
for(i in c(1:length(variables))){
  #calculate AIC of each model
  info = add1(model,scope=formula,data=train)
  #get variable with highest AIC
  orderedvariables = rownames(info[order(info$AIC),])
  v = orderedvariables[orderedvariables!="<none>"][1]
  #add variable to formula
  variablesorder = append(variablesorder,v)
  formulanew = formula(paste("Donated","~",paste(variablesorder,collapse = "+")))
  model = glm(formulanew,data=train,family=binomial)
  print(v)
}

auctrain = rep(0,length(variablesorder)-1)
auctest = rep(0,length(variablesorder)-1)
for(i in c(1:(length(variablesorder)-1))){
  vars = variablesorder[0:i+1]
  print(vars)
  formula<-paste("Donated","~",paste(vars,collapse="+"))
  model<-glm(formula,data=train,family="binomial")	
  predicttrain<-predict(model,newdata=train,type="response")
  predicttest<-predict(model,newdata=test,type="response")
  auctrain[i] = auc(train$Donated,predicttrain)
  auctest[i] = auc(test$Donated,predicttest)
}

#Plot AUC Curve based on the variables
plot(auctrain, col="red", type = "l", xlab="variables",ylab="auc value",
     main = "AUC Curves", lwd = 2, ylim=c(0.5,0.59))
par(new=TRUE)
plot(auctest,col="blue", type = "l", lwd = 2,ylim=c(0.5,0.59))

legend("bottom", legend=c("train","test"), ncol=2,bty="n",
       col=c("red", "blue"), lwd = 2)
grid (NULL,NULL, lty = 6) 

#Select the model with optimal number of variables (5 variables were chosen based on the AUC):
finalvariables = variablesorder[c(1:6)]
formula<-paste("Donated","~",paste(finalvariables,collapse="+"))
model<-glm(formula,data=train,family="binomial")	
predicttrain<-predict(model,newdata=train,type="response")
predicttest<-predict(model,newdata=test,type="response")

#Finding AUC with the optimised number of variables
auctrain = auc(train$Donated,predicttrain)
auctest = auc(test$Donated,predicttest)
auctrain
auctest

#------------------------------------------------------Evaluation-------------------------------------------------------------#

#Cumulative gains curve

pred <- prediction(predicttrain,train$Donated)
perf <- performance(pred,"tpr","fpr")
plot(perf, main="cumulative gains", col="red", lwd = 2)
pred1 <- prediction(predicttest,test$Donated)
par(new = TRUE)
perf <- performance(pred1,"tpr","fpr")
plot(perf, main="cumulative gains", col="blue", lwd = 2)
lines(x = c(0,100), y = c(0,100), col = "black")
grid (NULL,NULL, lty = 6)
legend("bottom", legend=c("train","test"), ncol=2,bty="n",
       col=c("red", "blue"), lwd = 2)

#Lift Curve

pred1 <- prediction(predicttest,test$Donated)
perflift <- performance(pred1,"lift","rpp")
plot(perflift, main="lift curve", col="blue", lwd = 2,ylim = c(0,4))
pred <- prediction(predicttrain,train$Donated)
perflift1 <- performance(pred,"lift","rpp")
par(new = TRUE)
plot(perflift1, main="lift curve", col="red", lwd = 2,ylim = c(0,4))
abline(h = 1, color = "black")
grid (NULL,NULL, lty = 6)
legend("bottom", legend=c("train","test"), ncol=2,bty="n",
       col=c("red", "blue"), lwd = 2)

#----------------------------------------USING ANOTHER MODEL(RANDOM FOREST)-------------------------------------------#

#Creating a model using random forest and finding AUC

train$Donated = as.factor(train$Donated)
test$Donated = as.factor(test$Donated)
mistrytrain<- tuneRF(train,train$Donated,stepFactor = 1.2,improve = 0.01,trace = T,plot = T)
modelrf<-randomForest(Donated~Recency_donation+genderU+genderS+mean_donation+genderF,data=train,ntree=2000,maxnodes=100)
predictions_train = predict(modelrf,newdata=train,type="prob")[,2]
predictions_test = predict(modelrf,newdata = test,type="prob")[,2]
importance(modelrf)
plot(modelrf)
auc(train$Donated,predictions_train)
auc(test$Donated,predictions_test)
u <- union(predictions_test, test$Donated)
t <- table(factor(predictions_test, u), factor(test$Donated, u))
confusionMatrix(t)


#-------------------------------------------------------BUSINESS CASE-----------------------------------------------#

Population = 44686
Target_Inc = 0.01
Reward = 46.5
Cost_Camp = 0.5
Percentage = 0.1
Lift = 2

profit <- function(Population, Target_Inc, Reward, Cost_Camp, Percentage, Lift) {
  Benefits = Reward * Percentage * (Lift * Target_Inc) * Population
  Costs = Cost_Camp * Percentage * Population
  Profit = Benefits - Costs
  return(Profit)
}

profit(44686, 0.01, 46.5, 0.5, 0.1, 2)
