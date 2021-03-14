FROM ubuntu:20.04

ARG ANDROID_TARGET_SDK=30
ARG ANDROID_BUILD_TOOLS=30.0.3
# https://developer.android.com/studio/index.html#command-tools
ARG ANDROID_SDK_TOOLS=7302050
ARG ANDROID_NDK_TOOLS=r22
ARG SONAR_CLI=3.3.0.1492

ENV ANDROID_HOME=${PWD}/android-sdk-linux
ENV ANDROID_NDK_HOME=${PWD}/android-ndk-${ANDROID_NDK_TOOLS}
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin
ENV PATH=${PATH}:${ANDROID_NDK}
ENV PATH=${PATH}:/root/gcloud/google-cloud-sdk/bin
ENV TZ=Europe/Madrid

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
 && apt-get install wget libarchive-tools apt-utils gnupg openjdk-11-jdk unzip git curl python3-pip bzip2 make --no-install-recommends -y \
 && export DEBIAN_FRONTEND="noninteractive" \
 && apt-get install procmail lsof --no-install-recommends -y \
 && rm -rf /var/cache/apt/archives \
 && update-ca-certificates \
 && pip3 install -U setuptools \
 && pip3 install -U wheel \
 && pip3 install -U crcmod

# Set up KVM
RUN apt-get -y --no-install-recommends install bridge-utils libpulse0 qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager \
 && echo Install Java 11 and KVM done

RUN apt-get install -y libxtst6 libnss3-dev libnspr4 libxss1 libasound2 libatk-bridge2.0-0 libgtk-3-0 libgdk-pixbuf2.0-0 \
 # && adduser $USER libvirt \
 # && adduser $USER kvm \
 && echo Install LVM done

# gcloud
# RUN curl -sSL https://sdk.cloud.google.com > /tmp/gcl && bash /tmp/gcl --install-dir=/root/gcloud --disable-prompts \
# && rm -rf /tmp/gcl
# SDK

RUN mkdir -p ${ANDROID_HOME} \
    && cd  ${ANDROID_HOME} \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && bsdtar --strip-components=1 -xvf commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && rm commandlinetools-linux-6858069_latest.zip

RUN find . -name "sdkmanager"

RUN yes | bin/sdkmanager --licenses --sdk_root= ${ANDROID_HOME} \
    && bin/sdkmanager --sdk_root= ${ANDROID_HOME} "platforms;android-${ANDROID_TARGET_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" platform-tools tools > /dev/null


RUN echo "Install Android SDK" \
 && set -x && wget -q -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
 && mkdir ${ANDROID_HOME} \
 && unzip -qo android-sdk.zip -d ${ANDROID_HOME} \
 && chmod -R +x ${ANDROID_HOME} \
 && rm android-sdk.zip \
 && mv ${ANDROID_HOME}/cmdline-tools ${ANDROID_HOME}/latest \
 && mkdir ${ANDROID_HOME}/cmdline-tools \
 && mv ${ANDROID_HOME}/latest ${ANDROID_HOME}/cmdline-tools/latest
# NDK
RUN  wget -q -O android-ndk.zip https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_TOOLS}-linux-x86_64.zip \
 && unzip -qo android-ndk.zip \
 && rm android-ndk.zip

# Config
RUN mkdir -p ~/.gradle \
 && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
 && mkdir ~/.android \
 && touch ~/.android/repositories.cfg

RUN keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -storepass android -keypass android -dname "CN=somewhere.in.munich, OU=ID, O=BMW, L=Bogenhausen, S=Hants, C=DE"

#RUN yes | sdkmanager --licenses > /dev/null \
# && sdkmanager --update > /dev/null

#RUN sdkmanager "platforms;android-${ANDROID_TARGET_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" platform-tools tools > /dev/null

