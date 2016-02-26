# ------------------------------------------------------------------------------
# Makefile
# ------------------------------------------------------------------------------

# To use this makefile on any source tree, only change the user variables
# below. The directory structure should abide by the following tree:
# 	- directory src      : put source files here (*.[c,cc])
# 	- directory include  : put header files here (*.h)

# ------------------------------------------------------------------------------
# User variables
# ------------------------------------------------------------------------------

include Makefile.user

# ------------------------------------------------------------------------------
# environment variables
# ------------------------------------------------------------------------------

# use bash instead of sh
SHELL=/bin/bash

# directories
BDIR = bin
LDIR = lib
ODIR = obj
SDIR = src
IDIR = include
TDIR = tar
DIR  = $(shell cd "$( dirname "$0" )" && pwd)

ARCH = $(shell getconf LONG_BIT)
CDFLAGS  = -g -Wall -Wextra -D DEBUG -Wno-format -Wno-write-strings -Wno-unused-function -Wno-unused-parameter -Wno-system-headers

# set containting directory is default project name
ifeq ($(PROJECT),)
	PROJECT=$(shell basename $(DIR))
endif

# install dir
ifeq ($(PREFIX),)
	PREFIX=$(HOME)/usr
endif

# set compiler
ifeq ($(wildcard $(SDIR)/*.cc),)
	CC=gcc
else
	CC=g++
endif

# sources, objects and dependecies
SRCS     = $(wildcard $(SDIR)/*.c)
SRCS    += $(wildcard $(SDIR)/*.cc)
OBJS     = $(patsubst $(SDIR)/%.c,$(ODIR)/%.o,$(wildcard $(SDIR)/*.c))
OBJS    += $(patsubst $(SDIR)/%.cc,$(ODIR)/%.o,$(wildcard $(SDIR)/*.cc))
LIBOBJS  = $(filter-out $(ODIR)/main.o, $(OBJS))
DEPS     = $(OBJS:.o=.d)

# library / include paths
INCLUDE_DIR := $(IDIR) $(INCLUDE_DIR)
LIB = $(foreach d, $(LIBRARY_DIR),-L$d)
INC = $(foreach d, $(INCLUDE_DIR),-I$d)

# shared/static libraries to link
STATIC = $(foreach l, $(STATIC_LIBRARIES),-l$l)
SHARED = $(foreach l, $(SHARED_LIBRARIES),-l$l)
SHARED_LIBRARY_DIR = $(foreach l, $(LIBRARY_DIR),-Wl,-R$l)

ifneq ($(STATIC),)
	LIB += -Wl,-Bstatic $(STATIC)
endif

ifneq ($(SHARED),)
	LIB += -Wl,-Bdynamic $(SHARED) $(SHARED_LIBRARY_DIR)
else ifneq ($(STATIC),)
	LIB += -Wl,-Bdynamic
endif

STATICLIB  = lib$(PROJECT).a
DYNAMICLIB = lib$(PROJECT).so.$(VERSION).$(SUBVERSION).$(PATCHLEVEL)

# ------------------------------------------------------------------------------
# Rules
# ------------------------------------------------------------------------------

# rules not representing files
.PHONY: $(PROJECT)  \
	all             \
	build           \
	rebuild         \
	build-x86       \
	build-x64       \
	error           \
	debug           \
	strip			\
	profile         \
	assembly        \
	install-bin     \
	install-static  \
	install-dynamic \
	install-include \
	install         \
	static          \
	debug-static    \
	dynamic         \
	debug-dynamic   \
	setup           \
	tarball         \
	lines           \
	clean           \
	help

# default rule
$(PROJECT): all

# include file dependencies (to recompile when headers change)
-include $(DEPS)

# main compile rules
all: build

build: $(BDIR)/$(PROJECT)

rebuild: clean build

# explicitly compile for x86 architecture
build-x86: ARCH=32
build-x86: CFLAGS += -m32
build-x86: build

# explicitly compile for 64 bit architecture
build-x64: ARCH=64
build-x64: CFLAGS += -m64
build-x64: build

# compile with debug symbols
debug: CFLAGS = $(CDFLAGS)
debug: O = -O0
debug: build

# compile until first error
error: CFLAGS += -Wfatal-errors
error: build

# strip stl library symbols
strip:
	@echo "STRIP $(BDIR)/$(PROJECT)"
	@strip -w -N '_ZNSt*' $(BDIR)/$(PROJECT)

# compile with profile
profile: CFLAGS += -pg
profile: LINK = -pg
profile: build

# compile to assembly
assembly: CFLAGS += -Wa,-a,-ad
assembly: build

# create static library
static: $(LDIR)/$(STATICLIB)

$(LDIR)/$(STATICLIB): $(LIBOBJS) | $(LDIR)
	@echo "LINK $(LDIR)/$(STATICLIB)"
	@ar rcs $(LDIR)/$(STATICLIB) $(LIBOBJS)

debug-static: CFLAGS = $(CDFLAGS)
debug-static: O = -O0
debug-static: static

# create dynamic library
dynamic: $(LDIR)/$(DYNAMICLIB)

$(LDIR)/$(DYNAMICLIB): CFLAGS += -fPIC
$(LDIR)/$(DYNAMICLIB): $(LIBOBJS) | $(LDIR)
	@echo "LINK $(LDIR)/lib$(PROJECT).so"
	@$(CC) -shared -fPIC -Wl,-soname,lib$(PROJECT).so.$(VERSION) -o $(LDIR)/$(DYNAMICLIB) $(LIBOBJS)
	@ln -sf $(DYNAMICLIB) $(LDIR)/lib$(PROJECT).so
	@ln -sf $(DYNAMICLIB) $(LDIR)/lib$(PROJECT).so.$(VERSION)
	@ln -sf $(DYNAMICLIB) $(LDIR)/lib$(PROJECT).so.$(VERSION).$(SUBVERSION)

debug-dynamic: CFLAGS = $(CDFLAGS)
debug-dynamic: O = -O0
debug-dynamic: dynamic

# create object and dependency files
$(ODIR)/%.o: $(SDIR)/%.c | $(ODIR)
	@echo "CC $<"
	@gcc -o $@ -c $< $(O) $(CFLAGS) $(INC) -MMD

$(ODIR)/%.o: $(SDIR)/%.cc | $(ODIR)
	@echo "CXX $<"
	@g++ -o $@ -c $< $(O) $(CFLAGS) $(CXXFLAGS) $(INC) -MMD

# create (link) executable binary
$(BDIR)/$(PROJECT): $(OBJS) | $(BDIR)
	@echo "LINK $@"
	@$(CC) -o $@ $(OBJS) $(LIB) $(LINK)

# install to PREFIX
install-bin: $(PREFIX)/$(BDIR)/$(PROJECT)

$(PREFIX)/$(BDIR)/$(PROJECT): $(BDIR)/$(PROJECT) | $(PREFIX)/$(BDIR)
	@echo "INSTALL $(BDIR)/$(PROJECT)"
	@cp $(BDIR)/$(PROJECT) $(PREFIX)/$(BDIR)/$(PROJECT)

install-static: $(PREFIX)/$(LDIR)$(ARCH)/$(STATICLIB)

$(PREFIX)/$(LDIR)$(ARCH)/$(STATICLIB): $(LDIR)/$(STATICLIB) | $(PREFIX)/$(LDIR)$(ARCH)
	@echo "INSTALL $(LDIR)/$(STATICLIB)"
	@cp $(LDIR)/$(STATICLIB) $(PREFIX)/$(LDIR)$(ARCH)

install-dynamic: $(PREFIX)/$(LDIR)$(ARCH)/$(DYNAMICLIB)

$(PREFIX)/$(LDIR)$(ARCH)/$(DYNAMICLIB): $(LDIR)/$(DYNAMICLIB) | $(PREFIX)/$(LDIR)$(ARCH)
	@echo "INSTALL $(LDIR)/lib$(PROJECT).so"
	@cp $(LDIR)/lib$(PROJECT).so* $(PREFIX)/$(LDIR)$(ARCH)

install-include: $(PREFIX)/$(IDIR)/$(PROJECT) $(patsubst $(IDIR)/%,$(PREFIX)/$(IDIR)/$(PROJECT)/%,$(wildcard $(IDIR)/*.h) $(wildcard $(IDIR)/**/*.h))

$(PREFIX)/$(IDIR)/$(PROJECT)/%.h: $(IDIR)/%.h
	@echo "INSTALL $<"
	@cp $< $@
	@sed -i '/#include .*\.tcc/d' $@

install: install-bin install-include install-static

# create directories
$(SDIR)/main.cc: | $(SDIR)
	@echo -e "int main(int argc, char **argv){\n    return 0;\n}\n" >> $@
	@echo "CREATE $@"

setup: $(IDIR) $(SDIR)/main.cc

$(SDIR):
	@echo "MKDIR $@"
	@mkdir $(SDIR)

$(LDIR):
	@echo "MKDIR $@"
	@mkdir $(LDIR)

$(BDIR):
	@echo "MKDIR $@"
	@mkdir $(BDIR)

$(ODIR):
	@echo "MKDIR $@"
	@mkdir $(ODIR)

$(IDIR):
	@echo "MKDIR $@"
	@mkdir $(IDIR)

$(TDIR):
	@echo "MKDIR $@"
	@mkdir $(TDIR)

$(PREFIX)/$(LDIR)$(ARCH):
	@echo "MKDIR $@"
	@mkdir -p $(PREFIX)/$(LDIR)$(ARCH)

$(PREFIX)/$(BDIR):
	@echo "MKDIR $@"
	@mkdir -p $(PREFIX)/$(BDIR)

$(PREFIX)/$(IDIR)/$(PROJECT):
	@echo "MKDIR $@"
	@mkdir -p $(PREFIX)/$(IDIR)/$(PROJECT)

# create a tarball from source files
tarball: TARFILE = $$(echo $(TDIR)/$(PROJECT)_$$(date +"%Y_%m_%d_%H_%M_%S") | tr -d ' ').tar.xz
tarball: $(TDIR)
	@echo "CREATE TAR $(TARFILE)";
	@XZ_OPT="-9" tar --exclude=".*" -cvJf $(TARFILE) $(IDIR) $(SDIR) Makefile | sed 's:^:    ADD :'

# print how many lines of code to compile
lines:
	@find $(IDIR) $(SDIR) -maxdepth 1 -type f | xargs wc -l

# cleanup
clean:
	@echo "RM $(ODIR) $(BDIR) $(LDIR)"
	@$(RM) -r $(ODIR) $(BDIR) $(LDIR)

# echo make options
help:
	@echo "Usage     :"
	@echo "    make [option]"
	@echo ""
	@echo "Options   :"
	@echo "    build*    : compile to binary"
	@echo "    rebuild   : recompile"
	@echo "    build-x86 : Explicitly compile for 32bit architecture"
	@echo "    build-x64 : Explicitly compile for 64bit architecture"
	@echo "    debug     : compile with debug symbols"
	@echo "    strip     : remove stl library symbols from binary"
	@echo "    profile   : compile with profiling capabilities"
	@echo "    assembly  : print assembly"
	@echo "    lines     : print #lines of code to compile"
	@echo "    static    : create static library"
	@echo "    dynamic   : create dynamic library"
	@echo "    install   : compile and install project to PREFIX"
	@echo "    clean     : remove object files, libraries and binary"
	@echo "    tarball   : create tarball of source files"
	@echo ""
	@echo "    * = default"
	@echo ""
	@echo "Directory hierarchy :"
	@echo "    src      : source files (*.[c|cc])"
	@echo "    include  : header files (*.h)"
	@echo "    obj      : object and dependency files"
	@echo "    lib      : static/shared libraries"
	@echo "    bin      : executable binary"
	@echo "    tar      : tarballs"

