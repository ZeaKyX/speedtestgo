#
# Copyright (C) 2021 ZeakyX
#

include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest-go
PKG_VERSION:=1.1.5
PKG_RELEASE:=$(AUTORELESE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ZeaKyX/speedtest-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=40b83031c916fbadd99ca8850a1e8b3af44746342ab0070a88ad929b4a80c480

PKG_LICENSE:=LGPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_SPEEDTEST_GO_COMPRESS_GOPROXY \
	CONFIG_SPEEDTEST_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/librespeed/speedtest
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.VersionString=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/speedtest-go/config
config SPEEDTEST_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config SPEEDTEST_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

ifeq ($(CONFIG_SPEEDTEST_GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/speedtest-go
  SECTION:=net
  CATEGORY:=Network
  TITLE:=speedtest-go is a Go backend for LibreSpeed
  URL:=https://github.com/librespeed/speedtest-go
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/speedtest-go/description
	speedtest-go is a Go backend for LibreSpeed
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_SPEEDTEST_GO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/speedtest
endif
endef

define Package/speedtest-go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/speedtest $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call GoBinPackage,speedtest-go))
$(eval $(call BuildPackage,speedtest-go))
