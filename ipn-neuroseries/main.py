#!/usr/bin/env python


import numpy as np
import pandas as pd
import neuroseries as nts
from pylab import *
from wrappers import *
import sys


data_directory = '/home/guillaume/Dropbox (Peyrache Lab)/SummerSchool/A2926-200311'

episodes = ['sleep', 'wake']
events = ['1']


spikes, shank = loadSpikeData(data_directory)



position = loadPosition(data_directory, events, episodes)


wake_ep = loadEpoch(data_directory, 'wake', episodes)
sleep_ep = loadEpoch(data_directory, 'sleep')					


# We can look at the position of the animal in 2d with a figure
figure()
plot(position['x'], position['z'])
show()


# Now we are going to compute the tuning curve for all neurons during exploration
# The process of making a tuning curve has been covered in main3_tuningcurves.py
# So here we are gonna use the function computeAngularTuningCurves from functions.py 
from functions import computeAngularTuningCurves
tuning_curves = computeAngularTuningCurves(spikes, position['ry'], wake_ep, 60)

	
# And let's plot all the tuning curves in a polar plot
from pylab import *
figure()
for i, n in enumerate(tuning_curves.columns):
	subplot(10,10,i+1, projection = 'polar')
	plot(tuning_curves[n])	
show()


# It's a bit dirty. Let's smooth the tuning curves ...
from functions import smoothAngularTuningCurves
tuning_curves = smoothAngularTuningCurves(tuning_curves, 10, 2)

# and plot it again
figure()
for i, n in enumerate(tuning_curves.columns):
	subplot(10,10,i+1, projection = 'polar')
	plot(tuning_curves[n])	
show()
