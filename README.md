# General Purpose Makefile (GPM)

A general purpose makefile for C and C++ projects using the gcc compiler (linux).

## Synopsis
Tired of writing a makefile for every project? This makefile compiles C/C++ projects and creates libraries for you, by simply putting your code files in the proper directory hierarchy. Customizations are optional and can be made in Makefile.user, in order to include external libraries, add an install prefix, set the name of your executable, etc.

## Setup
The idea is to use one makefile for all projects. The makefile dynamically detects source/header files, and compiles the project without changing editing the makefile. This is done by using the following directory hierarchy:

    project
    |-- Makefile
    |-- include
        |-- *.h
    |-- src
        |-- main.[c|cc]
        |-- *.cc
        |-- *.c
    |-- obj
        |-- *.o
        |-- *.d
    |-- lib
        |-- libproject.a
        |-- libproject.so*
    |-- tar
        |-- project*.tar.xz


## Usage
    > make [option]

| Option | Description |
| --- |--- |
| build\*   | compile to binary (*alias* of $(PROJECT) and all)|
| rebuild   | recompile                                     |
| build-x86 | Explicitly compile for 32bit architecture     |
| build-x64 | Explicitly compile for 64bit architecture     |
| debug     | compile with debug symbols                    |
| strip     | remove stl library symbols from binary        |
| profile   | compile with profiling capabilities           |
| assembly  | print assembly                                |
| lines     | print #lines in source files                  |
| static    | create static library                         |
| dynamic   | create dynamic library                        |
| install   | compile and install project to prefix         |
| setup     | create directory hierarchy and main.cc        |
| config    | create Makefile.user for user customizations  |
| clean     | remove object files, libraries and binary     |
| cleandist | remove object files                           |
| dist      | create tarball of source files                |
| help      | print this help                               |

\* = default.

Do not edit the makefile. To customize, type `make config` and edit `Makefile.user`.

