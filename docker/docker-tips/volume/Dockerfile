FROM alpine:latest

RUN apk update
RUN apk --no-cache add curl

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=048b95b48b708983effb2e5c935a1ef8483d9e3e

RUN curl -fsSLO ${SUPERCRONIC_URL} \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x ${SUPERCRONIC} \
    && mv "${SUPERCRONIC}" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

COPY my-cron /app/my-cron
WORKDIR /app

VOLUME [ "/app" ]

# RUN cron job
CMD [ "/usr/local/bin/supercronic", "/app/my-cron" ]

