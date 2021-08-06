# IPN Summer School on Extracellular recordings


- Understand the origin of extracellular fields and currents 
- Familiarize with different acquisition systems and recording methods, hardware (e.g. electrode types and the impact on the extracellular recordings) 
- Be able to visualize the raw signal and apply pre-processing techniques (e.g. noise, signal processing, filtering)
- Understand the theory of ‘spike sorting’ and use a state-of-the-art package for this purpose (Kilosort)
- Understand and be able to do LFP analysis (Brainstorm)
- Exploratory data analysis and visualization, and relationships between spikes and LFPs (e.g. Brainstorm - CellExplorer and scripting)

## Dataset
Here is the shared [*dataset*](https://utoronto-my.sharepoint.com/:f:/g/personal/sara_mahallati_mail_utoronto_ca/EtxU7ooHfqNKuPZ3lpbE7O8BtZkkMn1k2vf9D5grUUM4IA?e=AHPRMW). This dataset contains all the processed data in case one step of data processing fails. Still, we highly encourage to process the data on your own machine.

In order to complete the workshop using the tools that will be demonstrated, you can use a virtual machine or install the softwares by yourself. We highly recommand the virtual machine.

#### 1) Virtual Machine

Link for the [virtual machine](https://www.dropbox.com/s/1mun55bg0t88mgj/IPN-Summer-School-Final.zip?dl=1).
Steps to install the virtual machine :

1. Install Oracle VM virtual box
2. Add the machine using the add function (the green cross in the menu bar)
3. Start the machine to test it. The password is ipn
4. If everything works well, you need to activate matlab. For this, open a terminal (using the command ctrl-alt-t or searching in the menu)
5. Type sudo matlab (Password is ipn)
6. Activate matlab using your ​own McGill license.
 
#### 2) Your machine

You will need MATLAB2019 upwards and Python. University students have a MATLAB license through their universities and can log in to Mathworks and download latest version of Matlab. We recommend installing Python through Anaconda distribution. For matlab codes, please add it to the MATLAB path. For python code, please create a conda environnment. The following softwares and code will be needed :

1. [Neuroscope](neuroscope.md)

2. [Kluster](kluster.md)

3. [KiloSort](https://github.com/PeyracheLab/IPN-Workshop-Extracellular-Recordings/tree/main/ipn-kilosort)

4. Phy with the following instructions : 
```
conda create -n EPhysWorkshop python=3.7 pip numpy matplotlib scipy scikit-learn h5py pyqt cython pillow -y
conda activate EPhysWorkshop
pip install phy --pre --upgrade
```
5. [Neuroseries](https://github.com/PeyracheLab/IPN-Workshop-Extracellular-Recordings/tree/main/ipn-neuroseries)
You can create a conda environnment using the following package [list](https://github.com/PeyracheLab/IPN-Workshop-Extracellular-Recordings/blob/main/ipn-neuroseries/ipn_env.yml) :
```
conda create -f ipn_env.yml
conda activate ipn
 ```
 
6. Please download CellExplorer toolbox from [here](https://github.com/petersenpeter/CellExplorer/archive/master.zip) and add it to the MATLAB path. 

7. [Brainstorm](ipn_brainstorm.md)
 









### INSTRUCTORS: 
  - Sara Mahallati, PhD, 
  - Konstantinos Nasiotis, PhD
  - Guillaume Viejo, PhD

### SCHEDULE: 

August 9-13, 2021

---



