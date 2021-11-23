#
# Copyright (C) 2018-2019 Luiz Angelo Daros de Luca
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=swconfig-poller
PKG_VERSION:=1.2.0
PKG_RELEASE:=$(AUTORELEASE)
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/swconfig-poller
   SECTION:=net
   CATEGORY:=Network
   TITLE:=Poll swconfig switch ports to bring CPU ports up/down
   DEPENDS:=+swconfig
   PROVIDES=switchdev-poller
   PKGARCH:=all
endef

define Package/swconfig-poller/description
  This service monitors swconfig ports and brings down CPU ports when
  all related non-CPU vlan ports are also down. Otherwise, it brings
  the port up.
endef

Build/Compile=

define Package/swconfig-poller/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/swconfig-poller.init $(1)/etc/init.d/swconfig-poller
	$(INSTALL_DIR) $(1)/usr/libexec/swconfig-poller
	$(INSTALL_BIN) ./files/swconfig-poller $(1)/usr/libexec/swconfig-poller/swconfig-poller
endef

$(eval $(call BuildPackage,swconfig-poller))
