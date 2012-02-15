%LOCATE_GCC%

export PREFIX_PATH=%PREFIX%
export LDFLAGS="-L'${PREFIX_PATH}/lib' ${LDFLAGS}"
export CPPFLAGS="-I'${PREFIX_PATH}/include' ${CPPFLAGS}"
MAKE_OPTS="-j 2"

unset RUBYOPT
unset RUBYLIB

set -e

rm -rf /tmp/ruby-build
mkdir -p /tmp/ruby-build
cd /tmp/ruby-build

echo "Downloading ruby-1.8.7-p357 (including dependencies)"
wget  http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p357.tar.gz
wget  http://production.cf.rubygems.org/rubygems/rubygems-1.6.2.tgz

echo "Extracting ruby-1.8.7-p357 (including dependencies)"
tar -zxf ruby-1.8.7-p357.tar.gz
tar -zxf rubygems-1.6.2.tgz

echo "Building ruby-1.8.7-p357 (including dependencies)"
cd ruby-1.8.7-p357
{
  ./configure --prefix=$PREFIX_PATH --enable-shared
  make $MAKE_OPTS
  make install
} 1>&2
cd /tmp/ruby-build

export PATH="$PREFIX_PATH/bin:$PATH"

cd rubygems-1.6.2
{
  ruby setup.rb
} 1>&2
cd /tmp/ruby-build

{
  gem install bundler
} 1>&2

rm -rf /tmp/ruby-build
