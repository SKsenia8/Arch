#!/bin/bash
help() {
    echo -e "\e[1mUsage:\e[0m $0 [OPTIONS] [DIRECTORY]" # \e[1m \e[0m
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

directory=/home/kstarshova/log
backup_directory=/home/kstarshova/backup

while [[ $# -gt 0 ]]; do
    case $1 in
        -n)
            N=$2
           
            shift 2;; 
        -m)
            gb=$2 
            maxsize=$(bc <<< "$gb * 1024 * 1024 * 1024") 
            shift 2;;
        -p)
            per=$2
            if [[ $(bc <<< "$per <= 0 || $per > 1.0") -eq 1 ]]; then
                echo "-p argument must be in [0.1 .. 1]"
                exit 1
            fi
            shift 2;;
        -b)
            backup_directory=$2
            if [[ ! -d "$backup_directory" ]]; then
                echo "Backup directory $backup_directory does not exist"
                exit 1
            fi
            shift 2;;
        -h)
            help
            exit;;
        -*)
            echo "Unknown option: $1"
            exit 1;;
        *)
            directory=$1
            shift;;
    esac
done

total_size=$(du -sb $directory | cut -f 1) 

files=$(ls -tr $directory)

if [[ $(bc -l <<< "($total_size / $maxsize) >= $per") -eq 1 ]]; 
then
    echo -e "Directory size exceeds \e[1m$per\e[0m of maximum size"
    i=0
    files_to_compress=()
    cd $directory
    for file in $files 
    do
        files_to_compress+=($file)
        i=$((i+1)) 
        if [[ $i -eq $N ]]; then
            break
        fi
    done
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

