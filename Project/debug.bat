@echo off
title run
set fileName=%1
md %fileName%
c:\TASM\RunAsm\tasm.exe /zi %fileName%
c:\TASM\RunAsm\tlink.exe /v %fileName%

copy %fileName%.map %fileName%
copy %fileName%.obj %fileName%

copy %fileName%.exe %fileName% 
IF ERRORLEVEL 1 GOTO FAILED

copy %fileName%.asm %fileName%


del %fileName%.obj

c:\TASM\RunAsm\td.exe %fileName%.exe
del %fileName%.exe 


:FAILED
del %fileName%.map
