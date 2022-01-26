# SPDX-License-Identifier: GPL-3.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=neighbormon
PKG_VERSION:=1.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/neighbormon
  SECTION:=net
  CATEGORY:=Network
  URL:=https://humdi.net/vnstat/
  DEPENDS:=+ip
  TITLE:=Log neighbor presence
  PKGARCH:=all
endef

define Package/neighbormon/description
	Monitor neighbor presence (ARP for IPv4, NDP for IPv6) on all interfaces
	and logs them. It will help matching an internet IPv6 address to a MAC
	address, even with privacy extension enabled.
endef

Build/Compile=

define Package/neighbormon/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/neighbormon.init $(1)/etc/init.d/neighbormon
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/neighbormon.sbin $(1)/usr/sbin/neighbormon
endef

$(eval $(call BuildPackage,neighbormon))
