set -e
if [ ! -d scripts ]; then
  echo "this script should be executed from the repository root directory"
  exit 111
fi
CURLDIR=${CURLDIR-$PWD/depends/libcurl}
WD=`pwd`
# lets build aquachain-miner (static linked for greatest portability)
get_curl(){
  mkdir -p deps
  if [ -d deps/curl-7.69.1 ]; then
    rm -rvf deps/curl-7.69.1
  fi
  cd deps && wget -O libcurl.tar.gz https://curl.haxx.se/download/curl-7.69.1.tar.gz && \
  tar xaf libcurl.tar.gz
}

build_curl(){
if [ -d "$CURLDIR" ]; then
  rm -rf "$CURLDIR"
fi
# curl config ultralite (no ssl)
cd ${WD}/deps/curl-7.69.1 && \
  ./configure --disable-shared --enable-static --prefix=$CURLDIR --disable-ldap --disable-gopher --disable-ftp --disable-pop3 --disable-imap --disable-rtsp --disable-smtp --disable-telnet --disable-tftp --without-ssl --disable-dict --disable-file --without-nghttp2 --disable-netrc --disable-brotli --disable-idn --disable-psl --without-libidn2 --without-brotli --without-libpsl #--enable-ares

make -j 4
make install # installs to CURLDIR
}


if [ ! -d "$CURLDIR" ]; then
  echo "Fetching curl"
  get_curl
  echo "Building curl"
  time build_curl
else
  echo "libcurl exists at \"$CURLDIR\", if this is a mistake remove it and re-run this script"
fi

pkg-config --exists jsoncpp || echo "Please install libjsoncpp-dev"

echo "All libraries are ready to go. Now run:"
echo ""
echo "mkdir build && cmake .."
echo "make -j 2"


