@echo off
SetLocal EnableDelayedExpansion
rem Получаем путь до папки, обозначаем константы 
set path=%1
set /a proc=10
set /a n = 5

rem Проверяем существует ли такой путь, если нет заканчиваем выполнение
if not exist "%path%" echo Wrong path & exit /b

rem Достаем размер папки и оставшееся место на диске
for /F "tokens=3" %%a in ('dir %path%') do echo %%a >> data.txt #/F означает обработка вывода, %%а - переменная

for /f "usebackq delims=" %%a in ("data.txt") do set "size_folder=!free_size!" & set "free_size=%%a" #/f - для обработки текстовых данных
del data.txt

for %%I in (%size_folder%) do set size_f=!size_f!%%I #%%I - итерация по элементам
for %%I in (%free_size%) do set size_d=!size_d!%%I #%%I - итерация по элементам

rem Ищем длину строк, которые содержат размер папки и оставшеся место на диске
set /a len_f=0
set /a len_d=0
for /L %%A IN (0,1,8100) do if not "!size_f:~%%A,1!"=="" set /a len_f = %%A + 1 #/L - создание цикла с числовыми значениями, %%А - переменная цикла
for /L %%A IN (0,1,8100) do if not "!size_d:~%%A,1!"=="" set /a len_d = %%A + 1

rem Преобразуем строки в числа, если число больше 32 байт записываем самое большое возможное число для этого ограничения
if %len_d% GTR 10 set /a disk =2147483647
if %len_d% == 10 if %size_d% GTR '2147483647' set /a disk =2147483647
if %len_d% == 10 if %size_d% LEQ '2147483647' set /a disk =%size_d%
if %len_d% LSS 10 set /a disk =%size_d%

if %len_f% GTR 10 set /a folder =2147483647
if %len_f% == 10 if %size_f% GTR '2147483647' set /a folder =2147483647
if %len_f% == 10 if %size_f% LEQ '2147483647' set /a folder =%size_f%
if %len_f% LSS 10 set /a folder =%size_f%

rem Находим процент заполненности
set /a pr = (%folder% * 100) / (%disk% + %folder%)

rem Если процент меньше целевого выходим и пишем об этом пользователю
if %pr% LEQ %proc% echo No archiving required & exit /b

rem Проверяем наличие архиватора
if not exist "C:\Program Files\7-Zip\7z.exe" echo The archiver program 7-zip is not installed at the address: C:\Program Files & exit /b

rem  ищем n самых старых файлов
for /f "tokens=*" %%a in ('dir %path% /a-d /o-d /b') do echo %%a >> data.txt #/f - для обработки текстовых данных

set /a count_file = 0
for /f "usebackq delims=" %%a in ("data.txt") do set /a count_file = !count_file! + 1 #/f - для обработки текстовых данных

if %count_file% == 1 echo folder is empty & exit /b

set /a dif = %count_file% - %n%
if  %dif% LSS 1 echo folder don't have enough files to archive & exit /b

rem Создаем \backup и переносим туда самые старые файлы
md %path%\backup
for /f "usebackq delims=" %%a in ("data.txt") do set /a count_file = !count_file! - 1 & if !count_file! LSS %n% move "%path%\%%a" "%path%\backup"
del data.txt

rem Архивация файлов
"C:\Program Files\7-Zip\7z.exe" a -mx9 %path%\archive.7z %path%\backup

rem Удаление файлов, которые были заархивированы
del /f /s /q %path%\backup
move "%path%\archive.7z" "%path%\backup"
