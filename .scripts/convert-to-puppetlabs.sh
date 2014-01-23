#! /bin/sh

set -e

# copy sources to .tmp/lib/puppet and refactor them such that they're good to
# be merged back to puppet project
#
# if argument provided, it should be a path to original puppet, the script then
# shows diff

ROOT=$(readlink -f "$(dirname $0)/..")
SOURCE="."
TARGET=".tmp/puppetlabs-apache2"

function do_convert {
  search_paths="\
    ${SOURCE}/.fixtures.yml \
    ${SOURCE}/.gitignore \
    ${SOURCE}/.nodeset.yml \
    ${SOURCE}/.puppet-lint.rc \
    ${SOURCE}/.rspec \
    ${SOURCE}/.scripts \
    ${SOURCE}/.travis.yml \
    ${SOURCE}/CHANGELOG \
    ${SOURCE}/Gemfile \
    ${SOURCE}/LICENSE \
    ${SOURCE}/Modulefile \
    ${SOURCE}/README.md \
    ${SOURCE}/Rakefile \
    ${SOURCE}/lib \
    ${SOURCE}/manifests \
    ${SOURCE}/spec"

  rm -rf ${TARGET}
  find $search_paths -type f | grep -v '\.swp$' | while read F; do 
      F2=$(echo $F | sed -e "s:^${SOURCE}:${TARGET}:" \
                         -e 's/\(ptomulik\/\)\?apachex/apache2/g' \
                         -e 's/unit\/puppet/unit/g');
      D2=$(dirname $F2);
      test -e $D2 || mkdir -p $D2;
      # Some excludes ...
      test "${SOURCE}/.scripts/convert-to-puppetlabs.sh" '=' "$F" &&  continue;
      # Finally copy the files
      cp $F $F2; 
    done
  find ${TARGET} -type f | grep -v '\.swp$' | xargs sed -i \
      -e '/^\s*#\s*APACHEX_EXTRA_START/,/^\s*#\s*APACHEX_EXTRA_END/d' \
      -e 's/apachex/apache2/g' \
      -e 's/APACHEX/APACHE2/g' \
      -e 's/Apachex/Apache2/g' \
      -e 's/Util::PTomulik/Util/g' \
      -e 's/util\/ptomulik/util/g' \
      -e 's/unit\/puppet/unit/g'
}

(cd $ROOT && do_convert)
echo "conversion complete, results went to ${TARGET}"
