# ------------------------------------------------------------------------------
# *************************** DO NOT EDIT THIS FILE ****************************
# ------------------------------------------------------------------------------

# To use this makefile on any source tree, by using the folowing hierarchy:
# 	- directory src      : put source files here (*.[c,cc])
# 	- directory include  : put header files here (*.h)
#
# To customize, type 'make config' and edit Makefile.user

# ------------------------------------------------------------------------------
# Default user variables
# ------------------------------------------------------------------------------

# project name (directory name is used if left blank)
PROJECT =

# project version
VERSION    = 1
SUBVERSION = 0
PATCHLEVEL = 0

# library and include paths (space separated value)
LIBRARY_DIR =
INCLUDE_DIR =

# static and shared libraries to be linked (space separated values)
STATIC_LIBRARIES =
SHARED_LIBRARIES =

# compiler and compiler flags
CXXFLAGS = -w -std=c++11
CFLAGS   = -w
O        = -O3

# ------------------------------------------------------------------------------
# Color Functions
# ------------------------------------------------------------------------------

RESET = \033[0m
BOLD  = \033[1m
make_std_color = \033[3$1m 		# defined for 1 through 7
make_color	   = \033[38;5;$1m	# defined for 1 through 255

RED		= $(call make_std_color,1)
YELLOW	= $(call make_std_color,3)
GREY	= $(call make_color,8)
WRN_COLOR = $(strip $(YELLOW))
ERR_COLOR = $(strip $(RED))
STD_COLOR = $(strip $(GREY))

COLOR_OUTPUT = 2>&1 | \
	while IFS='' read -r line; do 									\
		if 	[[ $$line == *:[\ ]error:* ]] || 						\
			[[ $$line == *:[\ ]undefined* ]] || 					\
			[[ $$line == *:[\ ]fatal\ error:* ]] 					\
			|| [[ $$line == *:[\ ]multiple[\ ]definition* ]]; then 	\
			echo -e "$(ERR_COLOR)$${line}$(RESET)"; 				\
        elif [[ $$line == *:[\ ]warning:* ]]; then   				\
            echo -e "$(WRN_COLOR)$${line}$(RESET)" ; 				\
        else                                           				\
            echo -e "$(STD_COLOR)$${line}$(RESET)"; 				\
        fi;															\
    done; exit $${PIPESTATUS[0]};



# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

recursive_wildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call recursive_wildcard,$d/,$2))
find_staticlibrary=$(firstword $(foreach d, $(LIBRARY_DIR) $(subst :, ,$(LD_LIBRARY_PATH)), $(wildcard $d/lib$1.a)))

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------

# use bash instead of sh
SHELL=/bin/bash

# directories
BDIR := bin
LDIR := lib
ODIR := obj
SDIR := src
TDIR := tar
IDIR := include
ARCH := $(shell getconf LONG_BIT)
DIR  := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ------------------------------------------------------------------------------
# User variables
# ------------------------------------------------------------------------------

MAKEFILE_USER = Makefile.user

-include $(DIR)/$(MAKEFILE_USER)

# ------------------------------------------------------------------------------
# Compilation variables
# ------------------------------------------------------------------------------

CDFLAGS += -g -Wall -Wextra -D DEBUG -Wno-format -Wno-write-strings \
		   -Wno-unused-function -Wno-unused-parameter -Wno-system-headers \
		   -Wno-format-security -Wno-ignored-qualifiers

CXXDFLAGS += $(CDFLAGS)

# set containting directory is default project name
ifeq ($(PROJECT),)
	PROJECT=$(notdir $(DIR))
endif

# default install dir
ifeq ($(PREFIX),)
	PREFIX = $(HOME)/usr
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
INCLUDE     := $(foreach d, $(INCLUDE_DIR),-I$d)
LIBRARY 	:= $(foreach d, $(LIBRARY_DIR),-L$d)

# shared/static libraries to link
STATIC = $(foreach l, $(STATIC_LIBRARIES),-l$l)
SHARED = $(foreach l, $(SHARED_LIBRARIES),-l$l)
SHARED_LIBRARY_DIR = $(foreach l, $(LIBRARY_DIR),-Wl,-R$l)

ifneq ($(STATIC),)
	LIBRARY += -Wl,-Bstatic $(STATIC)
endif

ifneq ($(SHARED),)
	LIBRARY += -Wl,-Bdynamic $(SHARED) $(SHARED_LIBRARY_DIR)
else ifneq ($(STATIC),)
	LIBRARY += -Wl,-Bdynamic
endif

STATICLIB  = lib$(PROJECT).a
DYNAMICLIB = lib$(PROJECT).so.$(VERSION).$(SUBVERSION).$(PATCHLEVEL)
STATICLIBS = $(foreach l, $(STATIC_LIBRARIES), $(foreach d, $(LIBRARY_DIR) $(subst :, ,$(LD_LIBRARY_PATH)), $(wildcard $d/lib$l.a)))

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
	object			\
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
	config			\
	lines           \
	clean           \
 	cleandist		\
	dist         	\
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
build-x86: CXXFLAGS += -m32
build-x86: LDFLAGS += -m32
build-x86: build

# explicitly compile for 64 bit architecture
build-x64: ARCH=64
build-x64: CFLAGS += -m64
build-x64: CXXFLAGS += -m64
build-x64: LDFLAGS += -m64
build-x64: build

# compile with debug symbols
debug: CFLAGS   += $(CDFLAGS)
debug: CXXFLAGS += $(CXXDFLAGS)
debug: O = -O0
debug: build

# compile until first error
error: CFLAGS += -Wfatal-errors
error: CXXFLAGS += -Wfatal-errors
error: build

# strip stl library symbols
# Determine regular expression <regex> that covers (STL) namespace using:
# > nm --debug-syms <binary>
# E.g., STL symbols start with '_ZSt[0-9]'. Use GNU strip to remove them:
# > strip --wildcard --strip-symbol='<regex>' <binary>
# Be aware that [0-9]* does not mean 0 to infinite numbers, but 1 number followed by anything.
strip:
	@echo "STRIP $(BDIR)/$(PROJECT)"
	@strip --wildcard 				\
		--strip-symbol='_ZNKSt*'    \
		--strip-symbol='_ZNSt*' 	\
		--strip-symbol='_ZSt*'      \
		--strip-symbol='_ZNSa*' 	\
		--strip-symbol='*gnu_cxx*'  \
		$(BDIR)/$(PROJECT)

# compile with profile
profile: CFLAGS += -pg
profile: CXXFLAGS += -pg
profile: LDFLAGS = -pg
profile: build

# compile to assembly
assembly: CFLAGS += -Wa,-a,-ad
assembly: CXXFLAGS += -Wa,-a,-ad
assembly: build

# create static library
static: $(LDIR)/$(STATICLIB)

$(LDIR)/$(STATICLIB): $(LIBOBJS) $(STATICLIBS) | $(LDIR)
	@echo "LINK $(LDIR)/$(STATICLIB)"
	@ar rcs $(LDIR)/$(STATICLIB) $(LIBOBJS)

debug-static: CFLAGS   += $(CDFLAGS)
debug-static: CXXFLAGS += $(CXXDFLAGS)
debug-static: O = -O0
debug-static: static

# create dynamic library
dynamic: $(LDIR)/$(DYNAMICLIB)

$(LDIR)/$(DYNAMICLIB): CFLAGS += -fPIC
$(LDIR)/$(DYNAMICLIB): $(LIBOBJS) $(STATICLIBS) | $(LDIR)
	@echo "LINK $(LDIR)/lib$(PROJECT).so"
	@$(CC) -shared -fPIC -Wl,-soname,lib$(PROJECT).so.$(VERSION) -o $(LDIR)/$(DYNAMICLIB) $(LIBOBJS)
	@ln -sf $(DYNAMICLIB) $(LDIR)/lib$(PROJECT).so
	@ln -sf $(DYNAMICLIB) $(LDIR)/lib$(PROJECT).so.$(VERSION)
	@ln -sf $(DYNAMICLIB) $(LDIR)/lib$(PROJECT).so.$(VERSION).$(SUBVERSION)

debug-dynamic: CFLAGS   += $(CDFLAGS)
debug-dynamic: CXXFLAGS += $(CXXDFLAGS)
debug-dynamic: O = -O0
debug-dynamic: dynamic

# create object and dependency files
$(ODIR)/%.o: $(SDIR)/%.c | $(ODIR)
	@echo "CC $<"
	@gcc -o $@ -c $< $(O) $(CFLAGS) $(INCLUDE) -MMD $(COLOR_OUTPUT)

$(ODIR)/%.o: $(SDIR)/%.cc | $(ODIR)
	@echo "CXX $<"
	@g++ -o $@ -c $< $(O) $(CXXFLAGS) $(INCLUDE) -MMD $(COLOR_OUTPUT)

# create (link) executable binary
$(BDIR)/$(PROJECT): $(OBJS) $(STATICLIBS) | $(BDIR)
	@echo "LINK $@"
	@$(CC) -o $@ $(OBJS) $(LIBRARY) $(LDFLAGS) $(COLOR_OUTPUT)

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

install-include: $(PREFIX)/$(IDIR)/$(PROJECT) \
	$(patsubst $(IDIR)/%,$(PREFIX)/$(IDIR)/$(PROJECT)/%,$(call recursive_wildcard,$(IDIR)/,*.h))

$(PREFIX)/$(IDIR)/$(PROJECT)/%.h: $(IDIR)/%.h
	@echo "INSTALL $<"
	@mkdir -p $(dir $@)
	@cp $< $@
	@sed -i '/#include .*\.tcc/d' $@

install: install-bin install-include install-static

# compile object
ifeq ($(firstword $(MAKECMDGOALS)),object)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)
endif

object: BASENAME = $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
object: SRC = $(foreach f,$(BASENAME),$(wildcard $(SDIR)/$f.c) $(wildcard $(SDIR)/$f.cc))
object: OBJ = $(foreach f,$(BASENAME),$(patsubst $(SDIR)/%.c,$(ODIR)/%.o,$(wildcard $(SDIR)/$f.c))) \
			  $(foreach f,$(BASENAME),$(patsubst $(SDIR)/%.cc,$(ODIR)/%.o,$(wildcard $(SDIR)/$f.cc)))
object:
	@if [ -n "$(strip $(OBJ))" ]; then 								\
		$(MAKE) --no-print-directory $(OBJ) | sed 's:\[.*\]::';		\
	else 															\
		echo "No sourcefile found with basename(s):  $(BASENAME)"; 	\
	fi;

# create source tree with main.cc
setup: $(IDIR) $(SDIR)/main.cc

$(SDIR)/main.cc: | $(SDIR)
	@echo "CREATE $@"
	@echo -e "int main(int argc, char **argv){\n    return 0;\n}\n" >> $@

# generate user config file
config: $(MAKEFILE_USER)

$(MAKEFILE_USER):
	@echo "CREATE $(MAKEFILE_USER)"
	@echo "# install prefix" 				>> $(MAKEFILE_USER)
	@echo "PREFIX ?=" 						>> $(MAKEFILE_USER)
	@echo 									>> $(MAKEFILE_USER)
	@cat Makefile | head -34 | tail -20 	>> $(MAKEFILE_USER)

# create directories
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
dist: TARFILE = $$(echo $(TDIR)/$(PROJECT)_$$(date +"%Y_%m_%d_%H_%M_%S") | tr -d ' ').tar.xz
dist: $(TDIR)
	@echo "CREATE TAR $(TARFILE)";
	@XZ_OPT="-9" tar --exclude=".*" -cvJf $(TARFILE) --transform 's,^,$(PROJECT)/,' \
		$(wildcard $(IDIR) $(SDIR) Makefile $(MAKEFILE_USER) INSTALL README README.md) \
		| sed 's:^:    ADD :'

# print how many lines of code to compile
lines:
	@find $(IDIR) $(SDIR) -maxdepth 1 -type f | xargs wc -l

# cleanup
clean:
	@echo "RM $(ODIR) $(BDIR) $(LDIR)"
	@$(RM) -r $(ODIR) $(BDIR) $(LDIR)

cleandist:
	@echo "RM $(ODIR)"
	@$(RM) -r $(ODIR)

# echo make options
help:
	@echo "Usage:"
	@echo "    make [option]"
	@echo ""
	@echo "Options:"
	@echo "    build*    : compile to binary"
	@echo "    rebuild   : recompile"
	@echo "    build-x86 : Explicitly compile for 32bit architecture"
	@echo "    build-x64 : Explicitly compile for 64bit architecture"
	@echo "    debug     : compile with debug symbols"
	@echo "    object    : compile object of provided source basename"
	@echo "    strip     : remove stl library symbols from binary"
	@echo "    profile   : compile with profiling capabilities"
	@echo "    assembly  : print assembly"
	@echo "    lines     : print #lines in source files"
	@echo "    static    : create static library"
	@echo "    dynamic   : create dynamic library"
	@echo "    install   : compile and install project to prefix"
	@echo "    setup     : create directory hierarchy and main.cc"
	@echo "    config    : create Makefile.user for user customizations"
	@echo "    clean     : remove object files, libraries and binary"
	@echo "    cleandist : remove object files"
	@echo "    dist      : create tarball of source files"
	@echo "    help      : print this help"
	@echo ""
	@echo "    * = default"
	@echo ""
	@echo "Directory hierarchy:"
	@echo "    src       : source files (*.[c|cc])"
	@echo "    include   : header files (*.h)"
	@echo "    obj       : object and dependency files"
	@echo "    lib       : static/shared libraries"
	@echo "    bin       : executable binary"
	@echo "    tar       : tarballs"

