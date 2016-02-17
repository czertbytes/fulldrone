FROM gliderlabs/alpine:3.3

ADD bin /app

ENTRYPOINT ["/fulldrone"]
