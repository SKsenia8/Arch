#!/bin/bash

# Путь к базовому скрипту
BASE_SCRIPT="/home/kstarshova/folder.sh"
LOG_DIR="/home/kstarshova/log"
BACKUP_DIR="/home/kstarshova/backup"
TEST_FILE_PREFIX="test_file"

# Создание тестовой директории и заполнение ее файлами
setup_test_environment() {
    mkdir -p $LOG_DIR #-p создает промежуточнве каталоги
    mkdir -p $BACKUP_DIR #-p создает промежуточнве каталоги

    # Генерация файлов размером 100 MB каждый
    for i in {1..6}; do
        dd if=/dev/zero of="$LOG_DIR/${TEST_FILE_PREFIX}${i}.txt" bs=100M count=1
    done
}

# Тест 1: Проверка сжатия 5 файлов при заполнении 10%
test_compress_five_files_80_percent() {
    echo "Test 1:X = 10%, N = 5 files"
    $BASE_SCRIPT -n 5 -m 1 -p 0.1 -b $BACKUP_DIR $LOG_DIR
}

# Очищаем директории log и backup
    rm -f $LOG_DIR/* #-f не запрашивает подтверждение удаления
    rm -f $BACKUP_DIR/* #-f не запрашивает подтверждение удаления

# Генерация файлов размером 100 MB каждый
    for i in {1..6}; do
        dd if=/dev/zero of="$LOG_DIR/${TEST_FILE_PREFIX}${i}.txt" bs=100M count=1
    done

# Тест 2: Проверка сжатия 3 файлов при заполнении 60%
test_compress_three_files_60_percent() {
    echo "Test 2: X = 60%, N = 3 files"
    $BASE_SCRIPT -n 3 -m 1 -p 0.6 -b $BACKUP_DIR $LOG_DIR
}

# Очищаем директории log и backup
    rm -f $LOG_DIR/*
    rm -f $BACKUP_DIR/*

# Генерация файлов размером 100 MB каждый
    for i in {1..6}; do
        dd if=/dev/zero of="$LOG_DIR/${TEST_FILE_PREFIX}${i}.txt" bs=100M count=1
    done

# Тест 3: Проверка на сжатие 3 файлов при заполнении 100%
test_no_compression_40_percent() {
    echo "Test 3: X = 100%, N = 5"
    $BASE_SCRIPT -n 3 -m 1 -p 1.0 -b $BACKUP_DIR $LOG_DIR
}

# Очищаем директории log и backup
    rm -f $LOG_DIR/*
    rm -f $BACKUP_DIR/*

# Генерация файлов размером 100 MB каждый
    for i in {1..6}; do
        dd if=/dev/zero of="$LOG_DIR/${TEST_FILE_PREFIX}${i}.txt" bs=100M count=1
    done

# Тест 4: Проверка на пустую директории
test_invalid_backup_directory() {
    echo "Test 4: empty directory"
    $BASE_SCRIPT -n 5 -m 1 -p 0.5 -b $BACKUP_DIR $LOG_DIR
}

# Основной блок выполнения
setup_test_environment
test_compress_five_files_80_percent
test_compress_three_files_60_percent
test_no_compression_40_percent
test_invalid_backup_directory

# Очистка тестовой директории
rm -rf $LOG_DIR/* #-rf удаление файлов и каталогов
rm -rf $BACKUP_DIR/* #-rf удаление файлов и каталогов
