LIBDIR := lib
plantuml_marker ?= .check-plantuml-installed.txt
DEPS_FILES += $(plantuml_marker)
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif

$(plantuml_marker):
	@if $(CI); then apk add --no-cache plantuml msttcorefonts-installer fontconfig; update-ms-fonts; elif ! hash plantuml 2>/dev/null; then ! echo "plantuml is not installed"; fi
	@touch $@
