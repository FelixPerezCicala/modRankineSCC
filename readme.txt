Copyright (c) 2017, Félix Pérez Cicala

----------------------------------------------------------------------------

This program was developed as a Master’s degree final project. The
project's name was:

Modelizacion de ciclos Rankine mediante el método de Spencer, Cotton y
Cannon

Modelling of Rankine cycles using the Spencer, Cotton and Cannon method

The project report in spanish is available for download at: 

https://1drv.ms/b/s!AnnkWxpEdUygpp4kikoO0-Yg2weFqQ 

https://drive.google.com/file/d/16rJ7Wo-DsLmNHMW-5g9d_yY1ZySvrP6-/view?usp=sharing

The supervisor of this project was Domingo Santana Santana (Universidad Carlos
III de Madrid)

This program has been tested in R2016a. It is not guaranteed it will work
in any version preceding R2016a, and it will not work in any version
preceding R2014

----------------------------------------------------------------------------

Description: This program uses the Spencer, Cotton and Cannon method to predict
 the partial load performance of Rankine cycles, using as input data the 
pre-design characteristics of the cycle's components. 

Demonstration video: 
https://www.youtube.com/watch?v=T0ejEwOzZEo 

The process to solve the cycle performance is iterative. The components modelled 
are the steam turbines, feedwater heaters, pumps, and condenser. The steam 
generator and the electrical generator are not modelled. 

The program comes with a GUI to aide the data input and results visualization 
process. To launch the program, execute the "run.m" file in the path. An example 
solution file (default.sol) has been included as well, which can be loaded 
using the first window of the interface. 

This program uses the following libraries and functions:
International association for the properties of water and steam (IAPWS) Matlab functions, 
XSteam, available at: 
https://es.mathworks.com/matlabcentral/fileexchange/9817-x-steam--thermodynamic-properties-of-water-and-steam 
polyvaln function, available at http://soliton.vm.bytemark.co.uk/pub/jjg/src/polyvaln.m 
ParforProgMon, available at https://github.com/DylanMuir/ParforProgMon