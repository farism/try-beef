FROM teeks99/clang-ubuntu:latest
RUN apt update && \
  apt install -y libxml2 libhunspell-dev && \ 
  rm -rf /var/lib/apt/lists/*
ENV PATH="${PATH}:/beef/bin"
COPY ./beef /beef
COPY ./Project /Project
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]