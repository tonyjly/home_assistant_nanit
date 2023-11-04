ARG BASE_IMAGE=debian:buster

FROM golang:1.15.5-buster AS build
ADD cmd /app/cmd
ADD pkg /app/pkg
ADD go.mod /app/
ADD go.sum /app/
ADD scripts /app/scripts
WORKDIR /app
ARG CI_COMMIT_SHORT_SHA
RUN go build -ldflags "-X main.GitCommit=$CI_COMMIT_SHORT_SHA" -o ./bin/nanit ./cmd/nanit/*.go


FROM $BASE_IMAGE
COPY --from=build /app/bin/nanit /app/bin/nanit
COPY --from=build /app/scripts /app/scripts

RUN apt-get update && apt-get install -y \
    curl \
    jq

RUN mkdir -p /data && \
    # wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \ 
    # chmod +x ./jq && \
    # cp jq /usr/bin && \
    chmod +x /app/scripts/*.sh

WORKDIR /app
ENTRYPOINT ["/app/bin/nanit"]