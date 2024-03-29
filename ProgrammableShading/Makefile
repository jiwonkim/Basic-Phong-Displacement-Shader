
# the name of the compiled binary
TARGET  := ProgrammableShading

# list files to compile and link together
FILES   := main


#################################################################


# The following Makefile rules should work for Linux or Cygwin

CC		 := g++
LD		 := g++
OBJSUFFIX	 := .o
LIBPREFIX	 := lib
STATIC_LIBSUFFIX := .a
CFLAGS 		 := -O3#-g
CFLAGS_PLATFORM  :=
LDFLAGS		 :=
FRAMEWORKS	 :=
LIBS		 := st png jpeg freetype

ARCH=$(shell uname | sed -e 's/-.*//g')

ifeq ($(ARCH), CYGWIN_NT)

# if we're building in cygwin, we'll need to use the
# win32 versions of gl and glut

EXESUFFIX  := .exe
LIBS  	   += glut32 opengl32
CFLAGS_PLATFORM += `freetype-config --cflags`

else

ifeq ($(ARCH),Darwin)

# we're building on the mac

EXESUFFIX  :=
FRAMEWORKS += OpenGL GLUT AppKit IOKit
CFLAGS_PLATFORM += `freetype-config --cflags`

#
# Mac users need to point to the libjpeg and libpng directories as well as the
# freetype headers.
# 
# The default location of a fink install is given below.
# 
EXTRA_LIB_DIRS := /sw/lib /opt/local/lib
EXTRA_INC_DIRS  := /sw/include /opt/local/include glew/include

else

# building on Linux

EXESUFFIX  :=
LIBS	   += glut GL glew
CFLAGS_PLATFORM += `freetype-config --cflags`

#
# hack for myth machines.  Add /usr/lib as an explicit lib dir so
# it gets picked up instead of /usr/pubsw/lib.
# 

EXTRA_LIB_DIRS := /usr/lib glew/lib
EXTRA_INC_DIRS := /usr/include/freetype2 glew/include

endif
endif


LIBST      :=  st
LIBST_ROOT :=  ../libst
LIBST_DIR  :=  $(LIBST_ROOT)/lib
LIBST_INC  :=  $(LIBST_ROOT)/include

TARGET     := $(addsuffix $(EXESUFFIX), $(TARGET))

INCDIRS    := . $(LIBST_INC) $(EXTRA_INC_DIRS)
LIBDIRS    := $(LIBST_DIR) $(EXTRA_LIB_DIRS)

CFLAGS     += $(addprefix -I, $(INCDIRS))
CFLAGS	   += $(CFLAGS_PLATFORM)
LDFLAGS    += $(addprefix -L, $(LIBDIRS))

LDLIBS	   := $(addprefix -l, $(LIBS))
LDFRAMEWORKS := $(addprefix -framework , $(FRAMEWORKS))

OBJS       :=  $(addsuffix $(OBJSUFFIX), $(FILES))


.SUFFIXES : .cpp $(OBJSUFFIX)

.PHONY : clean release all

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LDLIBS) $(LDFRAMEWORKS)

%.o : %.cpp
	$(CC) $(CFLAGS) -o $@ -c $<


clean:
	rm -rf *$(OBJSUFFIX) $(TARGET) *~ .#* #*

release:
	@make --no-print-directory RELEASE=1


