# Makefile for tuxpaint-fonts

# Tux Paint - A simple drawing program for children.
# This is the macOS fonts installer for Tux Paint.

# Copyright 2004-2022 by various contributors; see CONTRIBUTORS.txt
# http://www.tuxpaint.org/

VER_DATE=$(shell date +"%Y.%m.%d")

.PHONY: all clean

all: tuxpaint-ttf-korean-$(VER_DATE).dmg tuxpaint-ttf-chinese-simplified-$(VER_DATE).dmg tuxpaint-ttf-chinese-traditional-$(VER_DATE).dmg

distclean: clean
	$(RM) *.dmg
	$(RM) -r *.app

clean:
	$(RM) *.tar.gz *.list

tuxpaint-ttf-korean-$(VER_DATE).dmg: Tux\ Paint\ Korean\ Fonts\ Installer.app
	@echo
	@echo "...Creating DMG Distribution File for Korean..."
	@[ -d "$^" ]                                   \
	 && DMG/build-dmg.sh -o "$@" "$^"              \
	 || echo "Please move '$^' to '$(PWD)' first"

tuxpaint-ttf-chinese-simplified-$(VER_DATE).dmg: Tux\ Paint\ Simplified\ Chinese\ Fonts\ Installer.app
	@echo
	@echo "...Creating DMG Distribution File for Simplified Chinese..."
	@[ -d "$^" ]                                   \
	 && DMG/build-dmg.sh -o "$@" "$^"              \
	 || echo "Please move '$^' to '$(PWD)' first"

tuxpaint-ttf-chinese-traditional-$(VER_DATE).dmg: Tux\ Paint\ Traditional\ Chinese\ Fonts\ Installer.app
	@echo
	@echo "...Creating DMG Distribution File for Traditional Chinese..."
	@[ -d "$^" ]                                   \
	 && DMG/build-dmg.sh -o "$@" "$^"              \
	 || echo "Please move '$^' to '$(PWD)' first"

Tux\ Paint\ Korean\ Fonts\ Installer.app: tuxpaint-ttf-korean.tar.gz tuxpaint-ttf-korean.list
	@echo
	@echo "...Creating macOS App Bundle for Korean..."
	@rm -rf "$@"
	@cp -af tuxpaint-ttf-korean.tar.gz tuxpaint-fonts.tar.gz
	@cp -af tuxpaint-ttf-korean.list tuxpaint-fonts.list
	@xcodebuild -project "Tux Paint Fonts Installer.xcodeproj" \
				-scheme "$(shell basename "$@" .app)"          \
				-configuration Release                         \
				CONFIGURATION_BUILD_DIR=build                  \
				MARKETING_VERSION=$(VER_DATE)                  \
				build                                          \
	&& mv "build/$@" .

Tux\ Paint\ Simplified\ Chinese\ Fonts\ Installer.app: tuxpaint-ttf-chinese-simplified.tar.gz tuxpaint-ttf-chinese-simplified.list
	@echo
	@echo "...Creating macOS App Bundle for Simplified Chinese..."
	@rm -rf "$@"
	@cp -af tuxpaint-ttf-chinese-simplified.tar.gz tuxpaint-fonts.tar.gz
	@cp -af tuxpaint-ttf-chinese-simplified.list tuxpaint-fonts.list
	@xcodebuild -project "Tux Paint Fonts Installer.xcodeproj" \
				-scheme "$(shell basename "$@" .app)"          \
				-configuration Release                         \
				CONFIGURATION_BUILD_DIR=build                  \
				MARKETING_VERSION=$(VER_DATE)                  \
				build                                          \
	&& mv "build/$@" .

Tux\ Paint\ Traditional\ Chinese\ Fonts\ Installer.app: tuxpaint-ttf-chinese-traditional.tar.gz tuxpaint-ttf-chinese-traditional.list
	@echo
	@echo "...Creating macOS App Bundle for Traditional Chinese..."
	@rm -rf "$@"
	@cp -af tuxpaint-ttf-chinese-traditional.tar.gz tuxpaint-fonts.tar.gz
	@cp -af tuxpaint-ttf-chinese-traditional.list tuxpaint-fonts.list
	@xcodebuild -project "Tux Paint Fonts Installer.xcodeproj" \
				-scheme "$(shell basename "$@" .app)"          \
				-configuration Release                         \
				CONFIGURATION_BUILD_DIR=build                  \
				MARKETING_VERSION=$(VER_DATE)                  \
				build                                          \
	&& mv "build/$@" .

tuxpaint-ttf-korean.tar.gz:
	@echo
	@echo "...Creating Korean TTF Tarball Required by macOS App Bundle..."
	@tar czvf "$@" -C fonts locale/ko.ttf

tuxpaint-ttf-korean.list:
	@echo
	@echo "...Creating Korean TTF Tarball File List Required by macOS App Bundle..."
	@printf "%s\n" locale/ko.ttf > "$@"

tuxpaint-ttf-chinese-simplified.tar.gz:
	@echo
	@echo "...Creating Simplified Chinese TTF Tarball Required by macOS App Bundle..."
	@tar czvf "$@" -C fonts locale/zh_cn.ttf

tuxpaint-ttf-chinese-simplified.list:
	@echo
	@echo "...Creating Simplified Chinese TTF Tarball File List Required by macOS App Bundle..."
	@printf "%s\n" locale/zh_cn.ttf > "$@"

tuxpaint-ttf-chinese-traditional.tar.gz:
	@echo
	@echo "...Creating Traditional Chinese TTF Tarball Required by macOS App Bundle..."
	@tar czvf "$@" -C fonts locale/zh_tw.ttf

tuxpaint-ttf-chinese-traditional.list:
	@echo
	@echo "...Creating Traditional Chinese TTF Tarball File List Required by macOS App Bundle..."
	@printf "%s\n" locale/zh_tw.ttf > "$@"

# vim:noexpandtab
