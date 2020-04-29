# Intraday solar forecasting
This is my co-writing senior project about solar forecasting with @sararut.

## Abstract
Intraday solar power forecasting is crucial to ensuring power continuity and economical dispatch in PV systems. This study is 
focused in solar power forecasting 4h ahead every 30 min. We presents the solar power forecasting methods which are directly 
applying statistical approaches to PV measurements and indirectly calculating PV output from predicted solar irradiance via PV 
simulation model. Moreover, we also consider splitting models based on times of the day: morning model, midday model, and 
evening model. In this work, we develop SVR and RF models and compare the performance to baseline models which are linear 
regression, MARs and ANN models. Every models are designed to produce intraday solar power forecasts using ground data which 
were collected from two measurement stations in  central region of Thailand from 2017-2018. The result shows that the direct 
method yielded better performance, achieving NRMSE of 7.14 and 6.93\%, comparing to indirect method which achieve NRMSE of 
6.40 and 6.02\% on SVR and RF model respectively. The best model in term of forecast accuracy is achieved by random forest 
model, directly predicting the solar power.
