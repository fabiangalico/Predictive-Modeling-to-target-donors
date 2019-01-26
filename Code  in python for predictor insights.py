# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
# Import libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

# Import basetable from csv file
test = pd.read_csv("C:\\Users\\fgalicojustitz\\Desktop\\Descriptive and Predictive Analytics\\Project Donations\\test.csv") 

# Discretize the variable Recency
test["bins_recency"] = pd.qcut(test["Recency_donation"],5)
print(test.groupby("bins_recency").size())

# Calculating average incidence for rececncy
test_recency = test[["Donated","bins_recency"]]

groups = test_recency.groupby("bins_recency")

incidence = groups['Donated'].agg({"Incidence" : np.mean}).reset_index()
print(incidence)

# Discretize the variable mean
test["bins_mean"] = pd.qcut(test["mean_donation"],5)
print(test.groupby("bins_mean").size())


# Calculating average incidence for mean
test_mean = test[["Donated","bins_mean"]]

groups2 = test_mean.groupby("bins_mean")

incidence2 = groups2['Donated'].agg({"Incidence" : np.mean}).reset_index()
print(incidence2)

# Constructing the predictor insight graph table

def create_pig_table(basetable, target, variable):
    
        groups = basetable[[target,variable]].groupby(variable)
        pig_table = groups[target].agg({'Incidence' : np.mean, 'Size' : np.size}).reset_index()
        return pig_table

#Calculate the predictor insight graph table for the variables
pig_table_genderU = create_pig_table(test, "Donated", "genderU")

pig_table_genderS = create_pig_table(test, "Donated", "genderS")

pig_table_genderF = create_pig_table(test, "Donated", "genderF")

pig_table_recency = create_pig_table(test, "Donated", "bins_recency")

pig_table_mean = create_pig_table(test, "Donated", "bins_mean")

# Create the list of variables for our predictor insight graph tables
variables = ["bins_recency","bins_mean","genderU","genderS", "genderF"]

# Create an empty dictionary
pig_tables = {}

# Loop through the variables
for variable in variables:
     pig_table = create_pig_table(test, "Donated", variable)
     pig_tables[variable] = pig_table
     
print(pig_tables["bins_recency"])

#  Plotting the incidences
# The function to plot a predictor insight graph.
def plot_incidence(pig_table,variable):
    pig_table["Incidence"].plot()
    plt.xticks(np.arange(len(pig_table)), pig_table[variable])
    plt.xlim([-0.5, len(pig_table) - 0.5])
    plt.ylim([0, max(pig_table["Incidence"]*2)])
    plt.ylabel("Incidence", rotation = 0, rotation_mode="anchor", ha = "right")
    plt.xlabel(variable)

    
# Apply the function for the variable "bins_recency".
plot_incidence(pig_table, "bins_recency")

# The function to plot a predictor insight graph
def plot_pig(pig_table,variable):
    plt.ylabel("Size", rotation = 0,rotation_mode="anchor", ha = "right" )
    pig_table["Size"].plot(kind="bar", width = 0.5, color = "lightgray", edgecolor = "none")
    pig_table["Incidence"].plot(secondary_y = True)
    plt.xticks(np.arange(len(pig_table)), pig_table[variable])
    plt.xlim([-0.5, len(pig_table)-0.5])
    plt.ylabel("Incidence", rotation = 0, rotation_mode="anchor", ha = "left")
    plt.show()

# Variables you want to make predictor insight graph tables for
variables = ["bins_recency","bins_mean","genderU","genderS", "genderF"]
# Loop through the variables
for variable in variables: 
    # Create the predictor insight graph table
    pig_table = create_pig_table(test, "Donated", variable)
    # Plot the predictor insight graph
    plot_pig(pig_table, variable)










