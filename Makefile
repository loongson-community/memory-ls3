# Makefile for memory
 
PP=cpp
CC=cc
CCFLAGS=-O3 -fPIC -Werror -Wall
LDFLAGS=-shared
 
SRCDIR=src
BINDIR=bin
BUILDDIR=build
 
TARGET=$(BINDIR)/libmem.so
CCOBJSFILE=$(BUILDDIR)/ccobjs
-include $(CCOBJSFILE)
LDOBJS=$(patsubst $(SRCDIR)%.S,$(BUILDDIR)%.o,$(CCOBJS))
 
DEPEND=$(LDOBJS:.o=.dep)
 
all : $(CCOBJSFILE) $(TARGET)
	@$(RM) $(CCOBJSFILE)
 
clean : 
	@echo -n "Clean ... " && $(RM) $(BINDIR)/* $(BUILDDIR)/* && echo "OK"
 
$(CCOBJSFILE) : 
	@echo CCOBJS=`ls $(SRCDIR)/*.S` > $(CCOBJSFILE)
 
$(TARGET) : $(LDOBJS)
	@echo -n "Linking $^ to $@ ... " && $(CC) -o $@ $^ $(LDFLAGS) && echo "OK"
 
$(BUILDDIR)/%.dep : $(SRCDIR)/%.S
	@$(PP) $(CCFLAGS) -MM -MT $(@:.dep=.o) -o $@ $<
 
$(BUILDDIR)/%.o : $(SRCDIR)/%.S
	@echo -n "Building $< ... " && $(CC) $(CCFLAGS) -c -o $@ $< && echo "OK"
 
-include $(DEPEND)

