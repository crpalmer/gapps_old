PACKAGE=gapps-$(shell date +%Y%m%d)
UPDATER_SCRIPT=META-INF/com/google/android/updater-script
BACKUP_SH=system/addon.d/70-gapps.sh
OPTIONAL_BACKUP_SH=optional/face/addon.d/71-gapps-faceunlock.sh

CERT=testkey.x509.pem
KEY=testkey.pk8

$(PACKAGE)-signed.zip: $(PACKAGE).zip
	java -jar signapk.jar $(CERT) $(KEY) $(PACKAGE).zip $@

$(PACKAGE).zip: $(UPDATER_SCRIPT) proprietary-files optional-files \
		$(BACKUP_SH) $(OPTIONAL_BACKUP_SH)
	zip -r $@ META-INF install-optional.sh \
		$(BACKUP_SH) $(OPTIONAL_BACKUP_SH) \
		`./scripts/generate-file-list system proprietary-files` \
		`./scripts/generate-file-list optional optional-files`

$(UPDATER_SCRIPT): scripts/generate-updater-script deleted-files
	./scripts/generate-updater-script >$@

$(BACKUP_SH): proprietary-files scripts/generate-backup-sh
	mkdir -p `dirname $@`
	./scripts/generate-backup-sh proprietary-files > $@

$(OPTIONAL_BACKUP_SH): optional-files scripts/generate-backup-sh
	mkdir -p `dirname $@`
	./scripts/generate-backup-sh optional-files > $@
