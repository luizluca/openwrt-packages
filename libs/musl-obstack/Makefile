#
# Copyright (C) 2017 Luiz Angelo Daros de Luca <luizluca@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# updated to work with latest source from abrasive
#

include $(TOPDIR)/rules.mk

PKG_NAME:=musl-obstack
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pullmoll/musl-obstack.git
PKG_SOURCE_VERSION:=d2ad66b0df44a4b784956f7f7f2717131ddc05f4
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=xxx

PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING AUTHORS

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/musl-obstack
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=obstack implementation for musl libc
  URL:=https://github.com/pullmoll/musl-obstack
  DEPENDS:= +libpthread
endef

define Package/musl-obtstack/description
  The musl-obstack package is a copy + paste of the obstack functions and macros found in GNU gcc libiberty library for use with musl libc.
endef


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/obstack.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libobstack.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/musl-obstack.pc $(1)/usr/lib/pkgconfig/
endef

define Package/musl-obstack/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libobstack.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,musl-obstack))
