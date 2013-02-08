#!/bin/sh

PKG_NAME="locale-gen"
PKG_VER="svn$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="A locale generation tool"
PKG_CAT="BuildingBlock"
PKG_DEPS=""
PKG_LICENSE="gpl-2.0.txt"
PKG_ARCH="noarch"

# the package source files
PKG_SRC=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0

	# create a directory for the sources
	mkdir $PKG_NAME-$PKG_VER
	[ 0 -ne $? ] && return 1

	cd $PKG_NAME-$PKG_VER

	# download the sources
	download_file http://projects.archlinux.org/svntogit/packages.git/plain/trunk/locale-gen?h=packages/glibc \
	              locale-gen
	[ 0 -ne $? ] && return 1

	download_file http://projects.archlinux.org/svntogit/packages.git/plain/trunk/locale.gen.txt?h=packages/glibc \
                      locale.gen
        [ 0 -ne $? ] && return 1

	cd ..

	# create a sources tarball
	make_tarball_and_delete $PKG_NAME-$PKG_VER $PKG_NAME-$PKG_VER.tar.xz
	[ 0 -ne $? ] && return 1

	return 0
}

build() {
	# extract the sources tarball
	extract_tarball $PKG_NAME-$PKG_VER.tar.xz
	[ 0 -ne $? ] && return 1

	cd $PKG_NAME-$PKG_VER

	return 0
}

package() {
	# install locale-gen
	install -D -m 755 locale-gen $INSTALL_DIR/$SBIN_DIR/locale-gen
	[ 0 -ne $? ] && return 1

	# install locale.gen, the configuration file
	install -D -m 644 locale.gen $INSTALL_DIR/$CONF_DIR/locale.gen
	[ 0 -ne $? ] && return 1

	# add English to the default configuration
	cat << EOF >> $INSTALL_DIR/$CONF_DIR/locale.gen

en_US.UTF-8 UTF-8
EOF
	[ 0 -ne $? ] && return 1

	return 0
}
