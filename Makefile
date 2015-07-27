include $(SRC)/Makefile.config

DEST=$(SRC)/out
D=$(shell pwd)

UPDATER_SCRIPT=META-INF/com/google/android/updater-script
BACKUP_SH=system/addon.d/70-gapps.sh
G_PROP=system/etc/g.prop

CERT=testkey.x509.pem
KEY=testkey.pk8

all:
	-rm -rf $(DEST)/system
	-rm -rf $(DEST)/META-INF
	cp -r $(SRC)/system $(DEST)
	cp -r $D/$(PLATFORM)/META-INF $(DEST)
	$(MAKE) $(DEST)/$(PACKAGE)-signed.zip

$(DEST)/$(PACKAGE)-signed.zip: $(DEST)/$(PACKAGE).zip
	java -jar signapk.jar $(CERT) $(KEY) $(DEST)/$(PACKAGE).zip $@

$(DEST)/$(PACKAGE).zip: $(DEST)/$(UPDATER_SCRIPT) $(DEST)/$(BACKUP_SH) $(DEST)/$(G_PROP) \
	$(DEST)/proprietary-files
	mkdir -p `dirname $@`
	(cd $(DEST) && zip -r $@ META-INF $(BACKUP_SH))
	(cd $(SRC) && zip -r $@ `cat $(DEST)/proprietary-files` )

.DUMMY: $(DEST)/proprietary-files.build
$(DEST)/proprietary-files.build:

$(DEST)/proprietary-files: $(DEST)/proprietary-files.build
	cd $(SRC) && find system -type f | sed 's@^\./@@' | sort > $@

$(DEST)/$(UPDATER_SCRIPT): generate-updater-script $(SRC)/deleted-files
	mkdir -p `dirname $@`
	( \
	  if [ -e $(SRC)/banner.updater-script ]; then \
	    cat $(SRC)/banner.updater-script; \
	  fi; \
	  ./generate-updater-script $(VERSION) $(SRC)/deleted-files; \
	) >$@

$(DEST)/$(BACKUP_SH): $(DEST)/proprietary-files generate-backup-sh
	mkdir -p `dirname $@`
	./generate-backup-sh $(DEST)/proprietary-files > $@

.DUMMY: $(DEST)/$(G_PROP).build
$(DEST)/$(GPROP).build:

$(DEST)/$(G_PROP): $(DEST)/$(GPROP).build
	mkdir -p `dirname $@`
	./generate-g.prop $(DEST)/$(PACKAGE) $(VERSION) >$@
