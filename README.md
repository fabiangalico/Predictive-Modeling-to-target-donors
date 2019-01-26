# Predictive-Modelling-to-target-donors

## Project Definition
* The goal of the project is to help DSC (Non Profit organisation) target the customers that are more likely to donate during their next reactivation campaign.The target would be only those customers who are likely to donate more than 35 euro’s.

* We would be using forward-stepwise selection model to predict the number of customer for the next reactivation campaign

* Data used for prediction:
  * Donors.csv – general information about donors
  * Gifts.csv – past reactivation campaign data
  * Campaign20130411.csv – Train dataset
  * Campaign20140115.csv – Test dataset
  
  ## Data Preparation
  
**Training dataset:**
* To start with the Donors data set and Campaign201304 dataset was merged together with the DonorId which is the unique key
* Then the gift dataset was filtered with the data of dates before 20130411 and then the statistical variables such as mean_donation,max_donation,min_donation,frequency and Recency were calculated.
* This data was then merged with the overall donor and campaign dataset.
* All the Donor's with the NA values for amount were removed.
* Variables such as language and region were removed.
* Dummy variables were created for gender and for the Zipcode

**Test dataset:**
* The test data set was prepared in the same way as training, only difference being gift dataset was filtered with the data of dates before 20140115.

**Data Cleaning:**
* Target : Target was updated for train and test as people who donated < EUR 35 to be ‘0’ and those who donated more than EUR 35 as ‘1’ and this variable was named as ‘Donated’.
* Outliers and NA values :There were very few observations with outliers and NA values which were deleted.

**Basetable**
* Was constructed after the data preparation with 15 variables variables including the target. 

**Correlation between variables**
* We checked the correlation bewteen the variables and deleted the ones which are highly correlated to avoid multicolinearity 
* From mean,min and max donation, min and max donation were deleted.
* From gender, gender M was deleted
* From the regions SouthBelgium was deleted

## Model Building

* Forward Stepwise selection model was used to select the variables, and based on the AUC graph the following variables were chosen to determine the AUC 
* Variables chosen : Recency_donation,genderU,genderS,genderF,mean_donation
* Once the variables were selected Logistic Regression model was created and AUC was predicted from the same

## Evaluation and Business Case

 * Population: 44,686
 * Target Incidence: 1%
 * Reward: 46.5 Euros
 * Cost Campaign: 0.5 Euros
 * Percentage selected: 10%
 * Lift: 2

* Benefit = 46.5 * 0.1 * (2 * 0.01) * 44,686 = 4,156
* Cost = 0.5 * 0.1 * 44,686 = 2,234

* Profit = 1,922 Euros
* Profit without the model = -156 Euros

## Predictor Insight Graphs

* Donators that donated more recently are more likely to donate more than 35 Euros in the next reactivation campaign.
* Donators with higher mean amount donated from past donations are more likely to donate more than 35 Euros in the next reactivation campaign.
* Donators with Gender U and Gender S are less likely to donate more than 35 Euros in the next reactivation campaign. This variables represent a small part of the Gender variable, so we assume that they refer to donators whose gender was not collected (maybe they didn't want to give this information).
* Females are slightly more likely to donate more than 35 Euros in the next reactivation campaign.

## Conclusions

* We should target the most recent donators with higher mean amount donated in the past
* Female donators are slightly more likely to donate
* We should avoid donators with unidentified gender
* With our model, we can reach profits even selecting different percentages from our total population (10%, 20%)
* Without the model, the campaign might not yield profits and the target donators would be random



