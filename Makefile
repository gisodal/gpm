PROJECT = progname

SDIR 	= src
ODIR 	= obj
BDIR 	= bin
IDIR 	= include

SHELL	= /bin/bash
CFLAGS 	= -Wall -Wextra
OBJS 	= $(patsubst $(SDIR)/%.cc,$(ODIR)/%.o,$(wildcard $(SDIR)/*.cc))
OBJS   += $(patsubst $(SDIR)/%.c,$(ODIR)/%.o,$(wildcard $(SDIR)/*.c))

RESET 	= \033[0m
make_std_color = \033[3$1m 		# defined for 1 through 7
make_color	   = \033[38;5;$1m	# defined for 1 through 255

WRN_COLOR = $(strip $(call make_std_color,3))
ERR_COLOR = $(strip $(call make_std_color,1))
STD_COLOR = $(strip $(call make_color,8))

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


.PHONY: $(PROJECT) all debug clean

$(PROJECT): $(BDIR)/$(PROJECT)

all: $(PROJECT)

debug: CFLAGS += -g
debug: $(PROJECT)

$(BDIR)/$(PROJECT): $(OBJS)
	@mkdir -p $(BDIR)
	@echo $(CC) -o $@ $(OBJS) -I$(IDIR)
	@g++ -o $@ $(OBJS) -I$(IDIR) $(COLOR_OUTPUT)

$(ODIR)/%.o: $(SDIR)/%.c
	@mkdir -p $(ODIR)
	@echo gcc -o $@ -c $< $(CFLAGS)
	@gcc -o $@ -c $< $(CFLAGS) $(COLOR_OUTPUT)

$(ODIR)/%.o: $(SDIR)/%.cc
	@mkdir -p $(ODIR)
	@echo g++ -o $@ -c $< $(CFLAGS)
	@g++ -o $@ -c $< $(CFLAGS) $(COLOR_OUTPUT)

clean:
	rm -rf $(BDIR) $(ODIR)

