# Android NDK Docker 

[![supportLib](https://img.shields.io/badge/targetApi-30-green)](https://opensource.google.com/projects/material-components-android)
[![supportLib](https://img.shields.io/badge/NDK-22-yellow.svg)](https://developer.android.com/ndk/downloads)

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

## Docker hub

https://hub.docker.com/repository/docker/hannesa2/android-ndk
