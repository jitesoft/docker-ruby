# syntax=docker/dockerfile:experimental
FROM registry.gitlab.com/jitesoft/dockerfiles/alpine:latest
ARG VERSION
LABEL maintainer="Johannes Tegnér <johannes@jitesoft.com>" \
      maintainer.org="Jitesoft" \
      maintainer.org.uri="https://jitesoft.com" \
      com.jitesoft.project.repo.type="git" \
      com.jitesoft.project.repo.uri="https://gitlab.com/jitesoft/dockerfiles/ruby" \
      com.jitesoft.project.repo.issues="https://gitlab.com/jitesoft/dockerfiles/ruby/issues" \
      com.jitesoft.project.registry.uri="registry.gitlab.com/jitesoft/dockerfiles/ruby" \
      com.jitesoft.app.ruby.version="${VERSION}"

ARG TARGETARCH
ARG BUILDARCH

ENV GEM_HOME="usr/local/bundle" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_APP_CONFIG="/usr/local/bundle" \
    PATH="/usr/local/buundle/bin:/usr/local/bundle/gems/bin:${PATH}"

RUN --mount=type=bind,source=./out,target=/tmp/binary \
 tar -xzhf /tmp/binary/${TARGETARCH}/ruby.tar.gz -C /usr \
 && echo "Target: ${TARGETARCH} Build: ${BUILDARCH}" \
 && mkdir -p ${GEM_HOME} \
 && chmod -R 777 ${GEM_HOME} \
 && dependencies="$( \
      scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
 && apk add --no-cache --virtual .runtime-deps bzip2 ca-certificates libffi-dev procps yaml-dev zlib-dev $dependencies \
 && gem update --system && rm -r /root/.gem/
