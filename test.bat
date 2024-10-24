@echo off
SetLocal EnableDelayedExpansion
set path=%1
set /a proc=-1
set /a n = 5

if not exist "%path%" echo Wrong path & exit /b

for /F "tokens=3" %%a in ('dir %path%') do echo %%a >> data.txt

for /f "usebackq delims=" %%a in ("data.txt") do set "size_folder=!free_size!" & set "free_size=%%a"
del data.txt

for %%I in (%size_folder%) do set size_f=!size_f!%%I
for %%I in (%free_size%) do set size_d=!size_d!%%I

set /a len_f=0
set /a len_d=0
for /L %%A IN (0,1,8100) do if not "!size_f:~%%A,1!"=="" set /a len_f = %%A + 1
for /L %%A IN (0,1,8100) do if not "!size_d:~%%A,1!"=="" set /a len_d = %%A + 1

if %len_d% GTR 10 set /a disk =2147483647
if %len_d% == 10 if %size_d% GTR '2147483647' set /a disk =2147483647
if %len_d% == 10 if %size_d% LEQ '2147483647' set /a disk =%size_d%
if %len_d% LSS 10 set /a disk =%size_d%

if %len_f% GTR 10 set /a folder =2147483647
if %len_f% == 10 if %size_f% GTR '2147483647' set /a folder =2147483647
if %len_f% == 10 if %size_f% LEQ '2147483647' set /a folder =%size_f%
if %len_f% LSS 10 set /a folder =%size_f%

set /a pr = (%folder% * 100) / (%disk% + %folder%)

if %pr% LEQ %proc% echo No archiving required & exit /b

if not exist "C:\Program Files\7-Zip\7z.exe" echo The archiver program 7-zip is not installed at the address: C:\Program Files & exit /b

for /f "tokens=*" %%a in ('dir %path% /a-d /o-d /b') do echo %%a >> data.txt

set /a count_file = 0
for /f "usebackq delims=" %%a in ("data.txt") do set /a count_file = !count_file! + 1

if %count_file% == 1 echo folder is empty & exit /b

set /a dif = %count_file% - %n%
if  %dif% LSS 1 echo folder don't have enough files to archive & exit /b

md %path%\backup
for /f "usebackq delims=" %%a in ("data.txt") do set /a count_file = !count_file! - 1 & if !count_file! LSS %n% move "%path%\%%a" "%path%\backup"
del data.txt

"C:\Program Files\7-Zip\7z.exe" a -mx9 %path%\archive.7z %path%\backup

del /f /s /q %path%\backup
move "%path%\archive.7z" "%path%\backup"
