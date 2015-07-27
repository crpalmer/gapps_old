include $(SRC)/Makefile.config

DEST=$(SRC)/out
D=$(shell pwd)

UPDATER_SCRIPT=META-INF/com/google/android/updater-script
BACKUP_SH=system/addon.d/70-gapps.sh
G_PROP=system/etc/g.prop

CERT=testkey.x509.pem
KEY=testkey.pk8

$(DEST)/$(PACKAGE)-signed.zip: $(DEST)/$(PACKAGE).zip
	java -jar signapk.jar $(CERT) $(KEY) $(DEST)/$(PACKAGE).zip $@

$(DEST)/$(PACKAGE).zip: $(DEST)/$(UPDATER_SCRIPT) $(SRC)/proprietary-files $(SRC)/optional-files \
		$(DEST)/$(BACKUP_SH) $(DEST)/$(G_PROP)
	mkdir -p `dirname $@`
	-rm -rf $(DEST)/system
	cp -r $(SRC)/system $(DEST)/
	(cd $(DEST) && zip -r $@ META-INF \
		$(BACKUP_SH) $(OPTIONAL_BACKUP_SH) $(G_PROP)  \
		`cd $(OUT) && $D/generate-file-list system $(SRC)/proprietary-files`)

$(DEST)/$(UPDATER_SCRIPT): generate-updater-script $(SRC)/deleted-files
	mkdir -p `dirname $@`
	./generate-updater-script $(VERSION) >$@

$(DEST)/$(BACKUP_SH): $(SRC)/proprietary-files generate-backup-sh
	mkdir -p `dirname $@`
	./generate-backup-sh $(SRC)/proprietary-files > $@

.DUMMY: $(G_PROP).build
$(DEST)/$(GPROP).build:

$(DEST)/$(G_PROP): $(DEST)/$(GPROP).build
	mkdir -p `dirname $@`
	./generate-g.prop $(DEST)/$(PACKAGE) $(VERSION) >$@
