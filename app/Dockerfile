FROM docker:dind
RUN apk add bash ip6tables pigz sysstat procps lsof gcompat nodejs
ENV DOCKER_TMPDIR=/data/docker/tmp
COPY ./etc/docker/daemon.json /etc/docker/daemon.json
COPY ./docker-entrypoint.d/* ./docker-entrypoint.d/
COPY ./entrypoint.sh ./entrypoint.sh
COPY ./server ./server
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
CMD ["dockerd", "-p", "/var/run/docker.pid"]