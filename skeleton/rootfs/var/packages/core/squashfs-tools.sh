PKG_NAME="squashfs-tools"
PKG_VER="4.2"
PKG_REV="1"
PKG_DESC="Tools for the Squashfs file system"
PKG_CAT="Core"
PKG_DEPS="zlib,xz,lzo"
PKG_LICENSE="gpl-2.0.txt"

# the package source files
PKG_SRC="http://downloads.sourceforge.net/project/squashfs/squashfs/squashfs$PKG_VER/squashfs$PKG_VER.tar.gz"

# choose the default compression - LZO for ARM, otherwise XZ
case $PKG_ARCH in
	arm*)
		DEFAULT_COMPRESSION="lzo"
		;;
	*)
		DEFAULT_COMPRESSION="xz"
		;;
esac

build() {
	# extract the sources tarball
	extract_tarball squashfs$PKG_VER.tar.gz
	[ 0 -ne $? ] && return 1

	cd squashfs$PKG_VER/squashfs-tools

	# configure the package
	sed -e s~'^#XZ_SUPPORT = 1'~'XZ_SUPPORT = 1'~ \
	    -e s~'^#LZO_SUPPORT = 1'~'LZO_SUPPORT = 1'~ \
	    -e s~'^XATTR_SUPPORT = 1'~'XATTR_SUPPORT = 0'~ \
	    -e s~'^XATTR_DEFAULT = 1'~'XATTR_DEFAULT = 0'~ \
	    -e s~'^COMP_DEFAULT = gzip'~"COMP_DEFAULT = $DEFAULT_COMPRESSION"~ \
	    -i Makefile
	[ 0 -ne $? ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ 0 -ne $? ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m 755 mksquashfs $INSTALL_DIR/$BIN_DIR/mksquashfs
	[ 0 -ne $? ] && return 1
	install -D -m 755 unsquashfs $INSTALL_DIR/$BIN_DIR/unsquashfs
	[ 0 -ne $? ] && return 1

	return 0
}