# Android NDK Docker 

[![Docker Hub](https://images.microbadger.com/badges/version/rajawali/rajawali.svg)](https://hub.docker.com/r/rajawali/rajawali)
[![supportLib](https://img.shields.io/badge/supportLib-28-green.svg)](https://opensource.google.com/projects/material-components-android)
[![supportLib](https://img.shields.io/badge/NDK-18b3-yellow.svg)](https://developer.android.com/ndk/downloads)

Docker image for building Android with NDK, it uses

* Android
* NDK
* GCloud

## Build

``docker build -t android-ndk .``

## Tag

``docker tag android-ndk  hannesa2/android-ndk:api28``

## Publish

``docker push hannesa2/android-ndk:api28``

maybe you need a ``docker login`` in advance