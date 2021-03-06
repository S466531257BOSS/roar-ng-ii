PKG_NAME="screen"
PKG_VER="4.0.3"
PKG_REV="2"
PKG_DESC="Terminal multiplexer"
PKG_CAT="Utilities"
PKG_DEPS="ncurses"
PKG_LICENSE="gpl-2.0.txt"

# the package source files
PKG_SRC="http://ftp.gnu.org/gnu/$PKG_NAME/$PKG_NAME-$PKG_VER.tar.gz
         http://shahor.dimakrasner.com/3/source/screen/screen-4.0.3-longer-TERM.patch"

build() {
	# extract the sources tarball
	extract_tarball $PKG_NAME-$PKG_VER.tar.gz
	[ 0 -ne $? ] && return 1

	cd $PKG_NAME-$PKG_VER

	# patch the sources to allow longer values for TERM; this is required for
	# rxvt-unicode's terminal type (rxvt-unicode-256color)
	patch -p1 < ../screen-4.0.3-longer-TERM.patch
	[ 0 -ne $? ] && return 1

	# generate a new configure script
	autoconf
	[ 0 -ne $? ] && return 1

	# prevent the configure script from finding libelf, so the binary does not
	# link against it, eventually
	sed -i s/'-lelf'/'-lnot_exists'/ configure
	[ 0 -ne $? ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-pam \
	            --disable-telnet \
	            --enable-colors256 \
	            --enable-rxvt_osc \
	            --with-sys-screenrc=/$CONF_DIR/screenrc
	[ 0 -ne $? ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ 0 -ne $? ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ 0 -ne $? ] && return 1

	# keep only one file in the binaries directory
	rm -f $INSTALL_DIR/$BIN_DIR/screen.old \
	      $INSTALL_DIR/$BIN_DIR/screen-$PKG_VER.old \
          $INSTALL_DIR/$BIN_DIR/screen
	[ 0 -ne $? ] && return 1
	mv $INSTALL_DIR/$BIN_DIR/$PKG_NAME-$PKG_VER $INSTALL_DIR/$BIN_DIR/screen
	[ 0 -ne $? ] && return 1

	# install the sample configuration
	install -D -m 644 etc/etcscreenrc $INSTALL_DIR/$CONF_DIR/screenrc
	[ 0 -ne $? ] && return 1

	return 0
}