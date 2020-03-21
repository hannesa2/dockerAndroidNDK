FROM ubuntu:18.04

ARG ANDROID_TARGET_SDK=29
ARG ANDROID_BUILD_TOOLS=29.0.3
ARG ANDROID_SDK_TOOLS=4333796
ARG ANDROID_NDK_TOOLS=r21
ARG SONAR_CLI=3.3.0.1492

ENV ANDROID_HOME=${PWD}/android-sdk-linux
ENV ANDROID_NDK_HOME=${PWD}/android-ndk-${ANDROID_NDK_TOOLS}
ENV PATH=${PATH}:${ANDROID_HOME}/platform-tools
ENV PATH=${PATH}:${ANDROID_HOME}/tools
ENV PATH=${PATH}:${ANDROID_HOME}/tools/bin
ENV PATH=${PATH}:${ANDROID_NDK}
ENV PATH=${PATH}:/root/gcloud/google-cloud-sdk/bin

RUN apt-get update \
 && apt-get install wget apt-utils gnupg openjdk-8-jdk unzip git curl python-pip bzip2 make --no-install-recommends -y \
 && export DEBIAN_FRONTEND="noninteractive" \
 && apt-get install procmail lsof --no-install-recommends -y \
 && rm -rf /var/cache/apt/archives \
 && update-ca-certificates \
 && pip install -U setuptools \
 && pip install -U wheel \
 && pip install -U crcmod \
# gcloud
 && curl -sSL https://sdk.cloud.google.com > /tmp/gcl && bash /tmp/gcl --install-dir=/root/gcloud --disable-prompts \
 && rm -rf /tmp/gcl \
# SDK
 && wget -q --show-progress -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
 && mkdir ${ANDROID_HOME} \
 && unzip -qo android-sdk.zip -d ${ANDROID_HOME} \
 && chmod +x ${ANDROID_HOME}/tools/android \
 && rm android-sdk.zip \
# NDK
 && wget -q --show-progress -O android-ndk.zip https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_TOOLS}-linux-x86_64.zip \
 && unzip -qo android-ndk.zip \
 && rm android-ndk.zip \
# Config
 && mkdir -p ~/.gradle \
 && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
 && mkdir ~/.android \
 && touch ~/.android/repositories.cfg \
 && yes | sdkmanager --licenses > /dev/null \
 && sdkmanager --update > /dev/null \
 && sdkmanager "platforms;android-${ANDROID_TARGET_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" platform-tools tools > /dev/null
