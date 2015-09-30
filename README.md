# General Purpose Makefile (GPM)

A general purpose makefile for C and C++ projects using the gcc compiler (linux).

## Synopsis
Tired of writing a makefile for every project? This makefile compiles and creates libraries for you, by simply putting your code files in the proper directory and running this makefile. No changes to the makefile are required.

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
|rebuild        | recompile                                 |
|build-x86      | Explicitly compile for 32bit architecture |
|build-x64      | Explicitly compile for 64bit architecture |
|debug          | compile with debug symbols                |
|profile        | compile with profiling capabilities       |
|assembly       | print assembly                            |
|lines          | print #lines of code to compile           |
|static         | create static library                     |
|dynamic        | create dynamic library                    |
|install        | compile and install project to PREFIX"    |
|clean          | remove object files, libraries and binary |
|tarball        | create tarball of source files            |

\* = default.

NOTE: when creating a dynamic library, one needs to recompile all source files, due to required '-fPIC' compiler option (on x86\_64 architectures). For this reason, **make install** will only copy the static library.

