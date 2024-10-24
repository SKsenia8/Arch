@echo off
setlocal EnableDelayedExpansion

rem Установка пути к тестовой директории
set test_path=C:\test
set log_path=%test_path%\logtest

rem Создаем тестовую директорию и поддиректорию log
mkdir %log_path%

rem Генерируем файлы в папке log для достижения размера 0.5 GB
echo Generation tests
for /L %%i in (1,1,60) do ( #/L - для создания цикла с числовым диапозоном, %%i переменная 
    fsutil file createnew %log_path%\file_%%i.txt 10485760 #создание файлов по 10мб
)

echo Test 1: X = 50%, N = 5 files
set /a proc=50
set /a n=5
call "C:\test.bat" "%log_path%" %proc% %n% #call для выполнения другого пакетного файла
if exist "%log_path%\backup\archive.7z" (
    echo Test 1 passed
) else (
    echo Test 1 failed: archive was not created
)

rem Очищаем log_path после теста 1
del /q "%log_path%\*" #/q файл удаляется без запроса

rem Опять генерируем файлы в папке log для достижения размера 0.5 GB
for /L %%i in (1,1,60) do (
    fsutil file createnew %log_path%\file_%%i.txt 10485760
)

echo Test 2: X = 75%, N = 2 files
set /a proc=75
set /a n=2
call "C:\test.bat" "%log_path%" %proc% %n%
if exist "%log_path%\backup\archive.7z" (
    echo Test 2 passed
) else (
    echo Test 2 failed: archive was not created
)

rem Очищаем log_path после теста 2
del /q "%log_path%\*"

rem Опять генерируем файлы в папке log для достижения размера 0.5 GB
for /L %%i in (1,1,60) do (
    fsutil file createnew %log_path%\file_%%i.txt 10485760
)

echo Test 3: X = 90%, N = 15 files
set /a proc=90
set /a n=15
call "C:\test.bat" "%log_path%" %proc% %n%
if exist "%log_path%\backup\archive.7z" (
    echo Test 3 passed
) else (
    echo Test 3 failed: archive was not created
)

rem Очищаем log_path после теста 3
del /q "%log_path%\*"

rem Опять генерируем файлы в папке log для достижения размера 0.5 GB
for /L %%i in (1,1,60) do (
    fsutil file createnew %log_path%\file_%%i.txt 10485760
)

echo Test 4: X = 10%, N = 1 files
set /a proc=10
set /a n=1
call "C:\test.bat" "%log_path%" %proc% %n%
if exist "%log_path%\backup\archive.7z" (
    echo Test 4 passed
) else (
    echo Test 4 failed: archive was not created
)

rem Завершаем скрипт
exit /b 0
