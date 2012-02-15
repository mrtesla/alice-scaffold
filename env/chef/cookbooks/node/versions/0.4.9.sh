export PREFIX_PATH=%PREFIX%
VERSION="0.4.9"

set -e

rm -rf /tmp/node-build
mkdir -p /tmp/node-build
cd /tmp/node-build

echo "Downloading node-$VERSION (including dependencies)"
wget http://nodejs.org/dist/node-v$VERSION.tar.gz

echo "Extracting node-$VERSION (including dependencies)"
tar -zxf node-v$VERSION.tar.gz

echo "Building node-$VERSION (including dependencies)"
cd node-v$VERSION
{
  ./configure --prefix=$PREFIX_PATH
  make
  make install
  export PATH="$PREFIX_PATH/bin:$PATH"
  curl http://npmjs.org/install.sh | clean=yes sh
} 1>/dev/null
cd /tmp/node-build

/bin/rm -rf /tmp/node-build
