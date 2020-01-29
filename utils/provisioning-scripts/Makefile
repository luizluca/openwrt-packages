#
# Copyright (C) 2018-2020 Luiz Angelo Daros de Luca <luizluca@gmail.com>
#
include $(TOPDIR)/rules.mk

PKG_NAME:=provisioning-scripts
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Luiz Angelo Daros de Luca <luizluca@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Build/Compile
endef

define Package/provisioning-scripts
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Provisioning scripts
#  URL:=
  DEPENDS:=+gnupg
  PKGARCH:=all
endef

define Package/provisioning-scripts/description
Provides mecanism for provisioning devices

endef


define Package/provisioning-scripts-usb
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Provisioning scripts using USB Storage
#  URL:=
  DEPENDS:=provisioning-scripts +block-mount +e2fsprogs +kmod-fs-ext4 +kmod-usb3 +kmod-usb2 +kmod-usb-storage +kmod-fs-vfat +kmod-fs-ntfs +kmod-nls-iso8859-1 +kmod-nls-cp850 +kmod-nls-utf8 
  PKGARCH:=all
endef

define Package/provisioning-scripts-web
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Provisioning scripts using WEB interface
#  URL:=
  DEPENDS:=provisioning-scripts +uhttpd 
  PKGARCH:=all
endef

define Package/provisioning-scripts-publisher
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Provisioning scripts publisher script
#  URL:=
  DEPENDS:=provisioning-scripts +getopt
  PKGARCH:=all
endef

define Package/provisioning-scripts/description
Script to generate a new .prov file from a config.tgz.
It can also be use to generate device and publisher GPG keypairs

endef

define Package/provisioning-scripts/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/provisioning-scripts-provision.sh $(1)/sbin/provision
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/provisioning-scripts-provision.init $(1)/etc/init.d/provision
	$(INSTALL_DIR) $(1)/etc/provisioning-scripts
endef

define Package/provisioning-scripts-usb/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_BIN) ./files/provisioning-scripts-usb.hotplug $(1)/etc/hotplug.d/block/01-provisioning-scripts-usb
endef

define Package/provisioning-scripts-web/install
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./files/provisioning-scripts-web.html $(1)/www/provision.html
	$(INSTALL_BIN) ./files/provisioning-scripts-web.cgi $(1)/www/cgi-bin/provision
endef

define Package/provisioning-scripts-publisher/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/provisioning-scripts-publisher.sh $(1)/usr/bin
endef

$(eval $(call BuildPackage,provisioning-scripts))
$(eval $(call BuildPackage,provisioning-scripts-usb))
$(eval $(call BuildPackage,provisioning-scripts-web))
$(eval $(call BuildPackage,provisioning-scripts-publisher))
