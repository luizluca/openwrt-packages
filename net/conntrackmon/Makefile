# SPDX-License-Identifier: GPL-3.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=conntrackmon
PKG_VERSION:=1.2.1
PKG_RELEASE:=$(AUTORELEASE)
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later

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
	Config file is a direct map to all 'conntrack -E' options, except
	for sed_filter, which modifies conntrack output before going to
	syslog.
endef

define Package/conntrackmon/conffiles
/etc/config/conntrackmon
endef

Build/Compile=

define Package/conntrackmon/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/conntrackmon.config $(1)/etc/config/conntrackmon
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/conntrackmon.init $(1)/etc/init.d/conntrackmon
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/conntrackmon.sbin $(1)/usr/sbin/conntrackmon
endef

$(eval $(call BuildPackage,conntrackmon))
