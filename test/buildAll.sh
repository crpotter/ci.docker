#!/bin/bash

#####################################################################################
#                                                                                   #
#  Script to build and test all websphere-liberty Docker images                     #
#                                                                                   #
#                                                                                   #
#  Usage : buildAll.sh							            # 
#                                                                                   #
#####################################################################################


currentRelease=$1
readonly REPO="websphere-liberty"

# Default to podman where available, docker otherwise.
# Override by setting the DOCKER environment variable.
if test -z "$DOCKER"; then
  which podman > /dev/null 2>&1
  if [ $? != 0 ]; then
    export DOCKER=docker
  else
    export DOCKER=podman
  fi
fi

arch=$(uname -p)
if [[ $arch == "ppc64le" || $arch == "s390x" ]]; then
  $DOCKER pull $arch/ibmjava:8-jre
  $DOCKER tag $arch/ibmjava:8-jre ibmjava:8-jre
fi

# if [[ $1 =~ ^\.\.\/ga\/19\.0\.0\.[69]$ ]]; then
  while read -r imageName versionImageName buildContextDirectory
  do
    ./build.sh $imageName $versionImageName $buildContextDirectory

    if [ $? != 0 ]; then
      echo "Failed at image $imageName - exiting"
      exit 1
    fi
  done < $currentRelease/"images.txt"
# else
#     file_exts_ubi=(ubi.adoptopenjdk8 ubi.adoptopenjdk11 ubi.ibmjava8 ubuntu.ibmjava8)
#     tag_exts_ubi=(java8-openj9-ubi java11-openj9-ubi java8-ibmjava-ubi java8-ibmjava)

#     for i in "${!tag_exts_ubi[@]}"; do
#         docker_dir="${IMAGE_ROOT}/kernel"
#         full_path="${docker_dir}/Dockerfile.${file_exts_ubi[$i]}"
#         if [[ -f "${full_path}" ]]; then
#             build_tag="${REPO}:full-${tag_exts_ubi[$i]}"

#             echo "****** Building image ${build_tag}..."
#             $DOCKER build --no-cache=true "${build_tag}" -f "${full_path}"
#         else
#             echo "Could not find Dockerfile at path ${full_path}"
#             exit 1
#         fi
#     done
# fi