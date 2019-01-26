# Predictive-Modelling-to-target-donors

## Project Definition
* The goal of the project is to help DSC (Non Profit organisation) target the customers that are more likely to donate during their next reactivation campaign.The target would be only those customers who are likely to donate more than 35 euro’s.

* We would be using forward-stepwise selection model to predict the number of customer for the next reactivation campaign

* Data used for prediction:
  * Donors.csv – general information about donors
  * Gifts.csv – past reactivation campaign data
  * Campaign20130411.csv – Train dataset
  * Campaign20140115.csv – Test dataset
  
  # Data Preparation
  
**Training dataset:**
* To start with the Donors data set and Campaign201304 dataset was merged together with the DonorId which is the unique key
* Then the gift dataset was filtered with the data of dates before 20130411 and then the statistical variables such as mean_donation,max_donation,min_donation,frequency and Recency were calculated.
* This data was then merged with the overall donor and campaign dataset.
* All the Donor's with the NA values for amount were removed.
* Variables such as language and region were removed.
* Dummy variables were created for gender and for the Zipcode

**Test dataset:**
* The test data set was prepared in the same way as training, only difference being gift dataset was filtered with the data of dates before 20140115.




