# General Purpose Makefile (GPM)

A general purpose makefile for C and C++ projects using the gcc compiler (linux).

## Synopsis
Tired of writing a makefile for every project? This makefile compiles source projects and creates libraries for you, by simply putting your code files in the proper directory hierarchy and running this makefile. Customizations are optional and can be make in Makefile.user, in order to include external libraries, add an install prefix, set the name of your executable, etc.

## Requirement
The only requirement is to put your C (extension \*.c) or C++ (extension \*.cc) files into the 'src' directory, and the header files into to the 'include' directory. The directory hierarchy relative to the makefile is as follows:

| Directory | Contents |
| --- |--- |
|src      | source files (\*.[c\|cc])|
|include  | header files (\*.h)|
|obj      | object and dependency files|
|lib      | static/shared libraries|
|bin      | executable binary|
|tar      | tarballs|

## Usage
    > make [option]

| Option | Description |
| --- |--- |
|build *or* all\* | compile to binary                       |
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

\* = default.

Do not edit the makefile. To customize, type `make config` and edit `Makefile.user`.

