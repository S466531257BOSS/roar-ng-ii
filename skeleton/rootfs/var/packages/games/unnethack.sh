PKG_NAME="unnethack"
PKG_VER="4.0.0"
PKG_REV="1"
PKG_DESC="A variant of the roguelike game NetHack"
PKG_CAT="Games"
PKG_DEPS="ncurses"
PKG_LICENSE="custom"

# the source package release date
PKG_DATE="20120401"

# the package source files
PKG_SRC="http://downloads.sourceforge.net/project/unnethack/unnethack/$PKG_VER/$PKG_NAME-$PKG_VER-$PKG_DATE.tar.gz"

build() {
	# extract the sources tarball
	extract_tarball $PKG_NAME-$PKG_VER-$PKG_DATE.tar.gz
	[ 0 -ne $? ] && return 1

	cd $PKG_NAME-$PKG_VER-$PKG_DATE

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --docdir=/$DOC_DIR \
	            --disable-dummy-graphics \
	            --enable-curses-graphics \
	            --disable-tty-graphics \
	            --disable-mswin-graphics \
	            --enable-wizmode=root \
	            --with-compression="$(which xz)" \
	            --with-owner=root \
	            --with-group=root \
	            --with-gamesdir=/$SHARE_DIR/$PKG_NAME \
	            --with-bonesdir=/$VAR_DIR/$PKG_NAME/bones \
	            --with-savesdir=/$VAR_DIR/$PKG_NAME/saves \
	            --with-leveldir=/$VAR_DIR/$PKG_NAME/level
	[ 0 -ne $? ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ 0 -ne $? ] && return 1
	make -j $BUILD_THREADS manpages
	[ 0 -ne $? ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ 0 -ne $? ] && return 1

	# install the man pages
	for i in doc/*.6
	do
		install -D -m 644 $i $INSTALL_DIR/$MAN_DIR/man6/$(basename $i)
		[ 0 -ne $? ] && return 1
	done

	# install the license
	install -D -m 644 dat/license $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/license
	[ 0 -ne $? ] && return 1

	return 0
}