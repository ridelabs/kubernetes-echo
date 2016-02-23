FROM alpine:3.3
MAINTAINER Eric Harrison
RUN echo "Building the project, ok, here we go..." ; \
    echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' >> /etc/resolv.conf ; \
    cat /etc/resolv.conf ; \
    echo "ipv6" >> /etc/modules ; \
    echo "http://dl-1.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-2.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-3.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-4.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    echo "http://dl-5.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories; \
    apk --update add netcat-openbsd bash && \
    rm -rf /var/cache/apk/*

EXPOSE 8080
COPY ./entry.sh /
ENTRYPOINT ["/entry.sh"]


