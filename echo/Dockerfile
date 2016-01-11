FROM ubuntu
MAINTAINER Eric Harrison
RUN apt-get update; apt-get install netcat
EXPOSE 8080
COPY ./entry.sh /
ENTRYPOINT ["/entry.sh"]


