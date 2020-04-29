import numpy as np
from datetime import datetime, timedelta
import pandas as pd
import matplotlib.pyplot as plt
from pylab import rcParams
plt.style.use('seaborn-darkgrid')

def visualize(df, model_col , measure_col ,capacity =1000 , style = 'bar',detail = False, save = False, visualize = True):
    ''' 
    usage : this object use to analysis statistical charasteristic of predicted value
    requirement : for DataFrame in format2 (must include 'Datetime' column !) 
                and shouldn't be more than 6 models (visualization issue)

    example :
	 df = pd.read_csv('data.csv', parse_dates = [0])
 	 y_col = ['PVwatts', 'NCEP', 'pysolar']
	 yhat_col = ['measure']
 	 visualize_error(df, y_col =y_col)
	
    ''' 

    df['time'] = [t.time() for  t in df['Datetime']]
    error_matrix ={}
    rmse_matrix = {}
    mbe_matrix = {}
    for i in model_col:
        df[f'error_{i}'] = df[i]-df[measure_col]
        mbe = df[f'error_{i}'].dropna().values.mean()
        mae = (np.abs(df[f'error_{i}'].dropna().values)).mean()
        rmse = np.sqrt((df[f'error_{i}'].dropna().values**2).mean())
        nrmse = (rmse/capacity)*100
        error_matrix[i] = [mbe, mae, rmse, nrmse]
        groups = df.groupby('time')[f'error_{i}']
        rmse_groups = groups.apply(lambda x : np.sqrt((x.dropna().values**2).mean()))
        mbe_groups = groups.apply(lambda x: x.dropna().values.mean())
        time = rmse_groups.index.values
        rmse_matrix[i] = rmse_groups.values
        mbe_matrix[i] = mbe_groups.values
    error_df = pd.DataFrame(error_matrix, index = ['MBE','MAE','RMSE','NRMSE'])
    rmse_df = pd.DataFrame(rmse_matrix, index = time)
    mbe_df = pd.DataFrame(mbe_matrix, index = time)
    print('error summary')
    print('')
    print(error_df)
    if detail :
        print('-------------------------')
        print('')
        print('RMSE each timepoint')
        print(rmse_df)
        print('-------------------------')
        print('')
        print('MBE each timepoint')
        print(mbe_df)
        
    # visualize RMSE
    if visualize:
        rcParams['figure.figsize'] = 15,12
        fig, axes  = plt.subplots(2,1)
        model = rmse_df.columns.to_list()
        barwidth = 0.2
        n_model = rmse_df.shape[1]
        n_timestep = rmse_df.shape[0]
        r0 = np.arange(n_timestep)
        colors = ['indianred','goldenrod', 'yellowgreen','olivedrab','lightskyblue','royalblue'] 
        if style == 'bar':
            for i in range(n_model):
                r = [x + i*barwidth for x in r0]
                axes[0].bar(r, rmse_df.iloc[:,i],width = barwidth, label = model[i], color = colors[i])
            axes[0].set_xticks([R + (n_model//2-1)*barwidth for R in range(n_timestep)])
            axes[0].set_xticklabels([t[:-3] for t in time.astype('str')])
        elif style == 'line':
            for i in range(n_model):             
                axes[0].plot([t[:-3] for t in time.astype('str')], rmse_df.iloc[:,i].values,'o-', color = colors[i] , label = model[i])
        else:
            raise 'Error: invalid style'


        axes[0].set_xlabel('time of forecasts', fontsize = 13)
        axes[0].set_ylabel('RMSE of solar irradiance(W/m^2)', fontsize = 13)
        axes[0].legend()
        print('')

        #visualize MBE
        for i in range(n_model):
            r = [x + i*barwidth for x in r0]
            axes[1].bar(r, mbe_df.iloc[:,i],width = barwidth, label = model[i], color = colors[i])
        axes[1].set_xticks([R + (n_model//2-1)*barwidth for R in range(n_timestep)])
        axes[1].set_xticklabels([t[:-3] for t in time.astype('str')])
        axes[1].set_xlabel('time of forecasts', fontsize = 13)
        axes[1].set_ylabel('MBE of solar irradiance(W/m^2)', fontsize = 13)
        axes[1].legend()
        if save :
            name = str(input('Enter figure name: '))
            fig.savefig(f'{name}.png')
