FROM node:20.11.0

LABEL org.opencontainers.image.source=https://github.com/d0whc3r/build-expo
LABEL org.opencontainers.image.description="Expo (react-native) build image"
LABEL org.opencontainers.image.licenses=MIT

ARG DEBIAN_FRONTEND=noninteractive

# Version of tools
ARG ANDROID_API_LEVEL=34
ARG ANDROID_BUILD_TOOLS_LEVEL=30.0.3
ARG ANDROID_NDK_VERSION=23.1.7779620
ARG CMAKE_VERSION=3.22.1

ENV ANDROID_HOME /opt/android/sdk
ENV ANDROID_SDK_ROOT ${ANDROID_HOME}
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

RUN apt-get update \
    && apt-get install -yq default-jdk default-jre \
    && rm -rf /var/lib/apt/lists/*

RUN npm -g i expo-doctor

RUN curl -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && rm /tmp/cmdline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv /tmp/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest

RUN yes | sdkmanager --licenses
RUN sdkmanager --update

RUN sdkmanager --install \
    "extras;google;simulators" \
    "platform-tools" \
    "ndk;${ANDROID_NDK_VERSION}" \
    "cmake;${CMAKE_VERSION}" \
    "platforms;android-${ANDROID_API_LEVEL}" \
    "emulator" \
    "build-tools;${ANDROID_BUILD_TOOLS_LEVEL}"

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

CMD ["/bin/bash"]
