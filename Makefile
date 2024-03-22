KMODULE_NAME = ssv6x5x

ARCH ?= arm
KSRC ?= $(HOME)/firmware/output/build/linux-custom
CROSS_COMPILE ?= $(HOME)/firmware/output/per-package/linux/host/opt/ext-toolchain/bin/arm-linux-

KBUILD_TOP ?= $(PWD)
SSV_DRV_PATH ?= $(PWD)

include $(KBUILD_TOP)/config.mak

EXTRA_CFLAGS := -I$(KBUILD_TOP) -I$(KBUILD_TOP)/include

KERN_SRCS := ssvdevice/ssvdevice.c
KERN_SRCS += ssvdevice/ssv_cmd.c

KERN_SRCS += hci/ssv_hci.c

KERN_SRCS += smac/init.c
KERN_SRCS += smac/ssv_skb.c
KERN_SRCS += smac/dev.c
KERN_SRCS += smac/ssv_rc_minstrel.c
KERN_SRCS += smac/ssv_rc_minstrel_ht.c
KERN_SRCS += smac/ap.c
KERN_SRCS += smac/ampdu.c
KERN_SRCS += smac/efuse.c
KERN_SRCS += smac/ssv_pm.c
KERN_SRCS += smac/ssv_skb.c

ifeq ($(findstring -DCONFIG_SSV6XXX_DEBUGFS, $(ccflags-y)), -DCONFIG_SSV6XXX_DEBUGFS)
KERN_SRCS += smac/ssv6xxx_debugfs.c
endif

ifeq ($(findstring -DUSE_LOCAL_CRYPTO, $(ccflags-y)), -DUSE_LOCAL_CRYPTO)
KERN_SRCS += smac/sec_ccmp.c
KERN_SRCS += smac/sec_tkip.c
KERN_SRCS += smac/sec_wep.c
KERN_SRCS += smac/wapi_sms4.c
KERN_SRCS += smac/sec_wpi.c
endif


ifeq ($(findstring -DCONFIG_SMARTLINK, $(ccflags-y)), -DCONFIG_SMARTLINK)
KERN_SRCS += smac/ksmartlink.c
endif
ifeq ($(findstring -DCONFIG_SSV_SMARTLINK, $(ccflags-y)), -DCONFIG_SSV_SMARTLINK)
KERN_SRCS += smac/kssvsmart.c
endif

ifeq ($(findstring -DSSV_SUPPORT_HAL, $(ccflags-y)), -DSSV_SUPPORT_HAL)
KERN_SRCS += smac/hal/hal.c

ifeq ($(findstring -DSSV_SUPPORT_SSV6051, $(ccflags-y)), -DSSV_SUPPORT_SSV6051)
KERN_SRCS += smac/ssv_rc.c
KERN_SRCS += smac/ssv_ht_rc.c
KERN_SRCS += smac/hal/ssv6051/ssv6051_mac.c
KERN_SRCS += smac/hal/ssv6051/ssv6051_phy.c
KERN_SRCS += smac/hal/ssv6051/ssv6051_cabrioA.c
KERN_SRCS += smac/hal/ssv6051/ssv6051_cabrioE.c
endif

ifeq ($(findstring -DSSV_SUPPORT_SSV6006, $(ccflags-y)), -DSSV_SUPPORT_SSV6006)

KERN_SRCS += hwif/usb/usb.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006_common.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006C_mac.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006_phy.c
KERN_SRCS += smac/hal/ssv6006c/ssv6006_turismoC.c
ifeq ($(findstring -DSSV_SUPPORT_SSV6006AB, $(ccflags-y)), -DSSV_SUPPORT_SSV6006AB)
KERN_SRCS += smac/hal/ssv6006/ssv6006_mac.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_cabrioA.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_geminiA.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_turismoA.c
KERN_SRCS += smac/hal/ssv6006/ssv6006_turismoB.c
endif
endif
else
KERN_SRCS += smac/ssv_rc.c
KERN_SRCS += smac/ssv_ht_rc.c
endif

KERN_SRCS += hwif/sdio/sdio.c

ifeq ($(findstring -DCONFIG_SSV_SUPPORT_AES_ASM, $(ccflags-y)), -DCONFIG_SSV_SUPPORT_AES_ASM)
KERN_SRCS += crypto/aes_glue.c
KERN_SRCS += crypto/sha1_glue.c
KERN_SRCS_S := crypto/aes-armv4.S
KERN_SRCS_S += crypto/sha1-armv4-large.S
endif

KERN_SRCS += $(KMODULE_NAME)-generic-wlan.c

$(KMODULE_NAME)-y += $(KERN_SRCS_S:.S=.o)
$(KMODULE_NAME)-y += $(KERN_SRCS:.c=.o)

obj-$(CONFIG_SSV6X5X) += $(KMODULE_NAME).o

#export CONFIG_SSV6X5X=m

.PHONY: all ver modules clean

all: modules

modules:
	$(MAKE) -C $(KSRC) M=$(SSV_DRV_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

strip:
	$(CROSS_COMPILE)strip $(KMODULE_NAME).ko --strip-unneeded

clean:
	$(MAKE) -C $(KSRC) M=$(SSV_DRV_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
