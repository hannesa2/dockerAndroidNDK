FROM us-docker.pkg.dev/android-emulator-268719/images/30-google-x64:30.1.2
MAINTAINER team@f-droid.org

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=$ANDROID_SDK_ROOT \
    GRADLE_USER_HOME=$HOME/.gradle \
    GRADLE_OPTS=-Dorg.gradle.daemon=false

RUN echo Etc/UTC > /etc/timezone \
	&& echo 'APT::Install-Recommends "0";' \
		'APT::Install-Suggests "0";' \
		'APT::Acquire::Retries "20";' \
		'APT::Get::Assume-Yes "true";' \
		'Dpkg::Use-Pty "0";' \
		'quiet "1";' \
        >> /etc/apt/apt.conf.d/99gitlab

RUN printf "Package: androguard fdroidserver python3-asn1crypto python3-ruamel.yaml\nPin: release a=stretch-backports\nPin-Priority: 500\n" > /etc/apt/preferences.d/debian-stretch-backports.pref \
	&& echo "deb http://deb.debian.org/debian/ stretch-backports main" > /etc/apt/sources.list.d/backports.list

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
	&& printf "\n8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
	&& printf "\n84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
	&& printf "\n79120722343a6f314e0719f863036c702b0e6b2a\n84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license-old

# This installs fdroidserver and all its requirements for things like
# fdroid nightly.  The source image uses stretch-slim, which strips
# out the docs and man pages.  So do some hacks to ensure packages do
# not trip up on missing things.  Also, add in a fake fdroid-icon.png
# to make fdroid init happy.
RUN \
	printf "path-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/doc/*\npath-include=/usr/share/doc/*/copyright\n" >/etc/dpkg/dpkg.cfg.d/01_nodoc \
	&& mkdir -p /usr/share/man/man1 \
	&& apt-get update \
	&& apt-get -qy dist-upgrade \
	&& apt-get -qy install --no-install-recommends \
		androguard \
		default-jdk-headless \
		fdroidserver \
		file \
		gcc \
		git \
		gnupg \
		libpulse0 \
		make \
		mesa-utils \
		openssh-client \
		pciutils \
		python3-asn1crypto \
		python3-qrcode \
		python3-ruamel.yaml \
		python3-setuptools \
		zip \
	&& apt-get -qy autoremove --purge \
	&& apt-get clean \
	&& mkdir -p /usr/share/doc/fdroidserver/examples \
	&& touch /usr/share/doc/fdroidserver/examples/fdroid-icon.png \
	&& touch /usr/share/doc/fdroidserver/examples/config.py \
	&& sed -Ei 's,^(\s+.+)("archive_icon),\1"archive_description = '"\'archived old builds\'\\\\n"'"\n\1\2,g' \
		/usr/lib/python3/dist-packages/fdroidserver/nightly.py \
	&& rm -rf /var/lib/apt/lists/*

COPY start-emulator /usr/bin/
COPY wait-for-emulator /usr/bin/
COPY test /

