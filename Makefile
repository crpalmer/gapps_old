PACKAGE=gapps-$(shell date +%Y%m%d)
UPDATER_SCRIPT=META-INF/com/google/android/updater-script

CERT=testkey.x509.pem
KEY=testkey.pk8

$(PACKAGE)-signed.zip: $(PACKAGE).zip
	java -jar signapk.jar $(CERT) $(KEY) $(PACKAGE).zip $@

$(PACKAGE).zip: $(UPDATER_SCRIPT) proprietary-files optional-files
	zip -r $@ META-INF install-optional.sh \
		`./scripts/generate-file-list system proprietary-files` \
		`./scripts/generate-file-list optional optional-files`

$(UPDATER_SCRIPT): scripts/generate-updater-script deleted-files
	./scripts/generate-updater-script >$@
