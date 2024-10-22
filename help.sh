#!/bin/bash
#программа принимает строки вида -n 1 -m 2 -p 0.3 -b backup_directory
help() { #сообщение вывод основной информации
    echo -e "\e[1mUsage:\e[0m $0 [OPTIONS] [DIRECTORY]" 
    echo
    echo -e "\e[1mArguments:\e[0m"
    echo "[DIRECTORY] [default: .]"
    echo
    echo -e "\e[1mOptions:\e[0m"
    echo -e "\e[1m-n\e[0m\t\tNumber of files to compress"
    echo -e "\e[1m-m\e[0m\t\tMax size of directory in GB"
    echo -e "\e[1m-p\e[0m\t\tPercentage to compress in [0.1 .. 1]"
    echo -e "\e[1m-b\e[0m\t\tBackup directory (default: .)"
    echo -e "\e[1m-h\e[0m\t\tPrint this message"
}

#тут ксюша должна была добавить названия свои директорий
directory=.
backup_directory=.

#цикл. проходится по строке, собирает информацию
while [[ $# -gt 0 ]]; do # $# - количество переданных аргументтов, -gt  - оператор сравнения
    case $1 in
        -n) #-n - оператор проверки, который используется для определения, является ли строка не пустой
            N=$2 #  количество файлов
           
            shift 2;; # сдвиг дальше. след команда
        -m)
            gb=$2 #количество гигабайтов
            maxsize=$(bc <<< "$gb * 1024 * 1024 * 1024")  #перевод в байты, bc для операций с плавающей точкой
            shift 2;;
        -p)
            per=$2 #переменная указанный процент именно в формате дроби
            if [[ $(bc <<< "$per <= 0 || $per > 1.0") -eq 1 ]]; then #-eq оператор сравнения, который означает равно
                echo "-p argument must be in [0.1 .. 1]"
                exit 1
            fi
            shift 2;;
        -b)
            backup_directory=$2 #указание бэкап директории. проверка ее существовани
            if [[ ! -d "$backup_directory" ]]; then
                echo "Backup directory $backup_directory does not exist"
                exit 1
            fi
            shift 2;;
        -h) #вывод сообщения помощи
            help
            exit;;
        -*) 
            echo "Unknown option: $1"
            exit 1;;
        *)
            directory=$1
            shift;;
    esac
done #завершение цикла

total_size=$(du -sb $directory | cut -f 1)  #размер директории

files=$(ls -tr $directory)  #файлы, сортируя их по времени изменения в обратном порядке (самые старые файлы вверху) t - time r обратный порядок

if [[ $(bc -l <<< "($total_size / $maxsize) >= $per") -eq 1 ]]; #проверка, если папка занята больше чем процент 
then
    echo -e "Directory size exceeds \e[1m$per\e[0m of maximum size"
    i=0
    files_to_compress=()
    cd $directory
    for file in $files #процесс сжатия файлов
    do
        files_to_compress+=($file)
        i=$((i+1)) 
        if [[ $i -eq $N ]]; then
            break #когда I в цикле равно n введеное, стоп, нужно сжать n файлов
        fi
    done
    # архивация в бэкап директорию
    echo -e "\e[1mCompressing\e[0m: \e[4m\e[3m${files_to_compress[@]}\e[0m to $backup_directory/out.tar.gz"
    tar czfv out.tar.gz ${files_to_compress[@]} 
    rm ${files_to_compress[@]}
    cd -
    if [[ "$backup_directory" != "." ]]; then
        echo -e "Backing up to $backup_directory/out.tar.gz"
        mv $directory/out.tar.gz $backup_directory/
    fi
else
    echo "Nothing to do"
fi
