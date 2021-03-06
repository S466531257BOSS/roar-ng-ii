PKG_NAME="aria2"
PKG_VER="1.17.1"
PKG_REV="1"
PKG_DESC="Multi-protoocol download tool"
PKG_CAT="Network"
PKG_DEPS="expat,gnutls"
PKG_LICENSE="gpl-2.0.txt,custom"

# the package source files
PKG_SRC="http://downloads.sourceforge.net/project/aria2/stable/$PKG_NAME-$PKG_VER/$PKG_NAME-$PKG_VER.tar.xz"

build() {
	# extract the sources tarball
	extract_tarball $PKG_NAME-$PKG_VER.tar.xz
	[ 0 -ne $? ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-bittorrent \
	            --enable-metalink \
	            --disable-libaria2 \
	            --without-libuv \
	            --with-gnutls \
	            --without-libnettle \
	            --without-libgmp \
	            --with-libgcrypt \
	            --without-openssl \
	            --without-sqlite3 \
	            --without-libxml2 \
	            --with-libexpat \
	            --without-libcares \
	            --with-libz \
	            --without-tcmalloc \
	            --without-jemalloc \
	            --with-bashcompletiondir=/$CONF_DIR/bash_completion.d
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

	# install the license and the list of authors
	install -D -m 644 LICENSE.OpenSSL \
	                  $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE.OpenSSL
	[ 0 -ne $? ] && return 1
	install -D -m 644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ 0 -ne $? ] && return 1

	return 0
}