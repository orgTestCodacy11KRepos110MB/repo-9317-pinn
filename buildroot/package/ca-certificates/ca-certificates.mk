################################################################################
#
# ca-certificates
#
################################################################################

CA_CERTIFICATES_VERSION = 20210119
CA_CERTIFICATES_SOURCE = ca-certificates_$(CA_CERTIFICATES_VERSION).tar.xz
CA_CERTIFICATES_SITE = http://snapshot.debian.org/archive/debian/20210119T145122Z/pool/main/c/ca-certificates
CA_CERTIFICATES_DEPENDENCIES = host-openssl host-python
CA_CERTIFICATES_LICENSE = GPLv2+ (script), MPLv2.0 (data)
CA_CERTIFICATES_LICENSE_FILES = debian/copyright

define CA_CERTIFICATES_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) clean all
endef

define CA_CERTIFICATES_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/ca-certificates
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/ssl/certs
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(TARGET_DIR)
	sed -i "s/xMDkzMDE0MDExNVow/0MDkzMDE4MTQwM1ow/g" $(TARGET_DIR)/usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt
	rm -f $(TARGET_DIR)/usr/sbin/update-ca-certificates

	# Remove any existing certificates under /etc/ssl/certs
	rm -f  $(TARGET_DIR)/etc/ssl/certs/*

	# Create symlinks to certificates under /etc/ssl/certs
	# and generate the bundle
	cd $(TARGET_DIR) ;\
	for i in `find usr/share/ca-certificates -name "*.crt" | LC_COLLATE=C sort` ; do \
		ln -sf ../../../$$i etc/ssl/certs/`basename $${i} .crt`.pem ;\
		cat $$i ;\
	done >$(@D)/ca-certificates.crt

	# Create symlinks to the certificates by their hash values
	$(HOST_DIR)/usr/bin/c_rehash $(TARGET_DIR)/etc/ssl/certs

	# Install the certificates bundle
	$(INSTALL) -D -m 644 $(@D)/ca-certificates.crt \
	$(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt

endef

$(eval $(generic-package))
