FROM scratch

ADD root.x86_64/ /
ADD install.sh /

RUN chmod +x /install.sh
RUN /install.sh

ENV LANG=en_US.UTF-8
ENV TERM xterm

ENTRYPOINT ["/usr/bin/tini", "--"]