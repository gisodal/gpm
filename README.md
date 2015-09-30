* General Pupose Makefile (GPM)
A general purpose makefile for C and C++ projects using the gcc compiler.

## Synopsis
This makefile does not have to be changed for general projects.

## Requirement
The only requirement is to put your C (extension \*.c) or C++ (extension \*.cc) files into the 'src' folder and the header file into to the 'include' folder. The directory hierarchy relative to the makefile is as follows:

| Directory | Contents |
| --- |--- |
|src      | source files (\*.[c|cc])|
|include  | header files (\*.h)|
|obj      | object and dependency files|
|lib      | static/shared libraries|
|bin      | executable binary|
|tar      | tarballs|

## Usage
    > make [option]

| Option | Description |
| --- |--- |
|build\*   | compile to binary                         |
|rebuild   | recompile                                 |
|build-x86 | Explicitly compile for 32bit architecture |
|build-x64 | Explicitly compile for 64bit architecture |
|debug     | compile with debug symbols                |
|profile   | compile with profiling capabilities       |
|assembly  | print assembly                            |
|lines     | print #lines of code to compile           |
|library   | create static and dynamic libraries       |
|static    | create static library                     |
|dynamic   | create dynamic library                    |
|install   | install project at PREFIX                 |
|clean     | remove object files, libraries and binary |
|tarball   | create tarball of source files            |

\* = default.

