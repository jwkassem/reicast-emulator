#LOCAL_PATH:= 

#MFLAGS	:= -marm -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp
#ASFLAGS	:= -march=armv7-a -mfpu=vfp-d16 -mfloat-abi=softfp
#LDFLAGS	:= -g -Wl,-Map,$(notdir $@).map,--gc-sections -Wl,-O3 -Wl,--sort-common 

RZDCY_SRC_DIR ?= $(call my-dir)

RZDCY_MODULES	:=	cfg/ hw/arm7/ hw/aica/ hw/holly/ hw/ hw/gdrom/ hw/maple/ \
 hw/mem/ hw/pvr/ hw/sh4/ hw/sh4/interpr/ hw/sh4/modules/ plugins/ profiler/ oslib/ \
 hw/extdev/ hw/arm/ imgread/ linux/ ./ deps/coreio/ deps/zlib/ deps/chdr/ deps/crypto/ deps/libelf/ deps/chdpsr/ arm_emitter/ \
 deps/libzip/ deps/libpng/ rend/


ifdef WEBUI
	RZDCY_MODULES += webui/
	RZDCY_MODULES += deps/libwebsocket/

	ifdef FOR_ANDROID
		RZDCY_MODULES += deps/ifaddrs/
	endif
endif

ifndef NO_REC
	RZDCY_MODULES += hw/sh4/dyna/
endif

ifndef NOT_ARM
    RZDCY_MODULES += rec-ARM/
endif

ifndef NO_REND
    RZDCY_MODULES += rend/gles/
else
    RZDCY_MODULES += rend/norend/
endif

ifdef FOR_ANDROID
    RZDCY_MODULES += android/ deps/libandroid/
endif

ifdef FOR_LINUX
	ifdef USE_SDL
		RZDCY_MODULES += sdl/
	else
		RZDCY_MODULES += linux-dist/
	endif
endif

RZDCY_FILES := $(foreach dir,$(addprefix $(RZDCY_SRC_DIR)/,$(RZDCY_MODULES)),$(wildcard $(dir)*.cpp))
RZDCY_FILES += $(foreach dir,$(addprefix $(RZDCY_SRC_DIR)/,$(RZDCY_MODULES)),$(wildcard $(dir)*.c))
RZDCY_FILES += $(foreach dir,$(addprefix $(RZDCY_SRC_DIR)/,$(RZDCY_MODULES)),$(wildcard $(dir)*.S))
	
ifdef FOR_PANDORA
RZDCY_CFLAGS	:= \
	$(CFLAGS) -c -g -O3 -I$(RZDCY_SRC_DIR) -I$(RZDCY_SRC_DIR)/deps \
	-DRELEASE -DPANDORA\
	-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp \
	-frename-registers -fsingle-precision-constant -ffast-math \
	-ftree-vectorize -fomit-frame-pointer
	RZDCY_CFLAGS += -march=armv7-a -mtune=cortex-a8 -mfpu=neon
	RZDCY_CFLAGS += -DTARGET_LINUX_ARMELv7
else
RZDCY_CFLAGS	:= \
	$(CFLAGS) -c -g -O3 -I$(RZDCY_SRC_DIR) -I$(RZDCY_SRC_DIR)/deps \
	-D_ANDROID -DRELEASE\
	-frename-registers -fsingle-precision-constant -ffast-math \
	-ftree-vectorize -fomit-frame-pointer
	
	ifndef NOT_ARM
		RZDCY_CFLAGS += -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3-d16
		RZDCY_CFLAGS += -DTARGET_LINUX_ARMELv7
	else
	  ifndef ISMIPS
      RZDCY_CFLAGS += -DTARGET_LINUX_x86
		else
      RZDCY_CFLAGS += -DTARGET_LINUX_MIPS
		endif
	endif
endif

ifdef NO_REC
  RZDCY_CFLAGS += -DHOST_NO_REC
endif

ifndef DESKTOPGL
  RZDCY_CFLAGS += -DGLES
endif

RZDCY_CXXFLAGS := $(RZDCY_CFLAGS) -fno-exceptions -fno-rtti -std=gnu++11