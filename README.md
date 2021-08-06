# IPN Summer School on Extracellular recordings


- Understand the origin of extracellular fields and currents 
- Familiarize with different acquisition systems and recording methods, hardware (e.g. electrode types and the impact on the extracellular recordings) 
- Be able to visualize the raw signal and apply pre-processing techniques (e.g. noise, signal processing, filtering)
- Understand the theory of ‘spike sorting’ and use a state-of-the-art package for this purpose (Kilosort)
- Understand and be able to do LFP analysis (Brainstorm)
- Exploratory data analysis and visualization, and relationships between spikes and LFPs (e.g. Brainstorm - CellExplorer and scripting)

## Dataset
Here is the shared [*dataset*](https://utoronto-my.sharepoint.com/:f:/g/personal/sara_mahallati_mail_utoronto_ca/EtxU7ooHfqNKuPZ3lpbE7O8BtZkkMn1k2vf9D5grUUM4IA?e=AHPRMW). for now only shared between the instructors. 

## Installation instructions
You have two options: 
#### 1) Virtual Machine
 
#### 2) Your machine
You will need MATLAB2019 upwards and Python. University students have a MATLAB license through their universities and can log in to Mathworks and download latest version of Matlab. We recommend installing Python through Anaconda distribution. 
 
Please download CellExplorer toolbox from [here](https://github.com/petersenpeter/CellExplorer/archive/master.zip) and add it to the MATLAB path. 

Install Phy in your intended environment with the following commands: 
```
conda create -n EPhysWorkshop python=3.7 pip numpy matplotlib scipy scikit-learn h5py pyqt cython pillow -y
conda activate EPhysWorkshop
pip install phy --pre --upgrade
```







### INSTRUCTORS: 
  - Sara Mahallati, PhD, 
  - Konstantinos Nasiotis, PhD
  - Guillaume Viejo, PhD

### SCHEDULE: 

August 9-13, 2021

---

## Resources 

1. [Neuroscope](neuroscope.md)
2. [Kluster](kluster.md)
3. [CellExplorer](https://cellexplorer.org/)
4. [Brainstorm](ipn_brainstorm.md)
