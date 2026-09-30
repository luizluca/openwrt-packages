#
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2017-2018 Luiz Angelo Daros de Luca <luizluca@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcups
PKG_VERSION:=3.0.3
PKG_RELEASE:=1
PKG_INSTALL:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/OpenPrinting/libcups/releases/download/v$(PKG_VERSION)/
PKG_HASH:=4607ade9ec6f8b250e30c19a7d032219e2ef80d0e76af0bd0e6bd25715243664
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:openprinting:cups

include $(INCLUDE_DIR)/package.mk

define Package/libcups/Default
  URL:=https://www.cups.org/
  SUBMENU:=Printing
endef

define Package/libcups
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib +libpthread +libpng +libjpeg +libusb-1.0 +libavahi-nodbus-support
  TITLE:=Common UNIX Printing System - Core library
  BUILDONLY:=1
endef

define Package/libcups/description
	Common UNIX Printing System - Core library
endef

CONFIGURE_ARGS+=--with-cups-user="nobody" \
		--with-cups-group="nogroup" \
		--with-components="core" \
		--with-pdftops="none" \
		--without-perl \
		--without-python \
		--without-php \
		--enable-shared \
		--enable-image \
		--enable-libusb \
		--disable-acl \
		--disable-dbus \
		--disable-dnssd \
		--disable-launchd \
		--disable-ldap \
		--disable-pam \
		--disable-slp \
		--disable-gnutls \
		--disable-openssl \
		--disable-cdsassl \
		--disable-ssl \
		--disable-gssapi \
		--disable-tiff \
		UNAME="Linux" \
		LIBS="$(TARGET_LDFLAGS) -lz -lpng -ljpeg"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libcups3 $(1)/usr/include/
	
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups*.so* $(1)/usr/lib/
	
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/cups*.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libcups))
