#
# Copyright (C) 2019 Luiz Angelo Daros de Luca
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=conntrackmon
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=GPLv2
PKG_ARCH:=all

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/package.mk

define Package/conntrackmon
   SECTION:=net
   CATEGORY:=Network
   DEPENDS:=+conntrack
   TITLE:=Logs conntrack events to syslog
   MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
   PKGARCH:=all
endef

define Package/conntrackmon/description
conntrackmon monitor conntrack events and sends changes to syslog.
Config file directly maps to all 'conntrack -E' options

endef

define Package/conntrackmon/conffiles
/etc/config/conntrackmon
endef

define Build/Compile
endef

define Package/conntrackmon/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/conntrackmon.config $(1)/etc/config/conntrackmon
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/conntrackmon.init $(1)/etc/init.d/conntrackmon
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/conntrackmon.sbin $(1)/usr/sbin/conntrackmon
endef

$(eval $(call BuildPackage,conntrackmon))
