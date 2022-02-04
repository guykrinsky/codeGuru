@echo off
set group_name=%1
set first_file_name=%group_name:.asm=1.asm%
set second_file_name=%first_file_name:1=2%
copy %group_name% %first_file_name%
copy %group_name% %second_file_name%
..\nasm.exe %first_file_name%
..\nasm.exe %second_file_name%
del %first_file_name% %second_file_name%
echo %first_file_name%