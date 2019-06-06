#!/bin/bash


### DEPENDENCIES ###############################################################
  # nothing


### BUGLIST ####################################################################
  # nothing


### operating parameters #######################################################
readonly WORKSPACE="/tmp/workspace_config_centos"


### package variables ##########################################################
readonly CMAKE_VERSION2="3.12"
readonly CMAKE_VERSION="${CMAKE_VERSION2}.4"
readonly CMAKE_SOURCE_PACKAGE_NAME="cmake-${CMAKE_VERSION}.tar.gz"
readonly CMAKE_SOURCE_PACKAGE_LINK="https://cmake.org/files/v${CMAKE_VERSION2}/cmake-${CMAKE_VERSION}.tar.gz"


### utility function ###########################################################
function version_ge() { # ">="; arguments: version1, version2; return true/false
  test "$(echo -e "$@" | tr " " "\n" | sort -rV | head -n 1)" = "$1"
}


### package block ###############################################################

function install_cmake_from_source() {
  if [[ ! -d ${WORKSPACE} ]]; then mkdir ${WORKSPACE}; fi

  if ! command -v cmake >/dev/null 2>&1; then
    echo -e "-- cmake ${CMAKE_VERSION} installed [\e[31mFALSE\e[39m]"
  else
    if version_ge $(cmake --version | head -n 1 | gawk '{ print $3 }') ${CMAKE_VERSION}; then
      echo -e "-- cmake $(cmake --version | head -n 1 | gawk '{ print $3 }') (>= ${CMAKE_VERSION}) installed [\e[32mTRUE\e[39m]"
      exit
    else
      echo -e "-- cmake ${CMAKE_VERSION} installed [\e[31mFALSE\e[39m]"
    fi
  fi

  cd ${WORKSPACE}

  test -f ${CMAKE_SOURCE_PACKAGE_NAME} || wget ${CMAKE_SOURCE_PACKAGE_LINK} -O ${CMAKE_SOURCE_PACKAGE_NAME} --no-check-certificate
  local source_dir="cmake-${CMAKE_VERSION}"
  test -d ${source_dir} && rm -rf ${source_dir}
  mkdir ${source_dir}
  tar -xzf ${CMAKE_SOURCE_PACKAGE_NAME} --directory ${source_dir} --strip-components=1
  cd ${source_dir}

  ./bootstrap
  make -j $(nproc)
  make install

  if ! command -v cmake >/dev/null 2>&1; then
    echo -e "-- cmake installed [\e[31mFALSE\e[39m]"
  else
    echo -e "-- cmake installed [\e[32mTRUE\e[39m] $(which cmake) $(cmake --version | head -n 1 | gawk '{ print $3 }')"
  fi
}


### main #######################################################################
# set -x
echo "- start to install cmake from source ..."
install_cmake_from_source
echo "- finished installing cmake from source ..."
exit
