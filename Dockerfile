FROM docker.io/alpine:edge

RUN apk add --update alpine-sdk sudo neovim bash curl openssh

SHELL ["bash", "-c"]
RUN adduser -D -G abuild -s /bin/bash builder && \
	echo builder:nopasswd | chpasswd -e
RUN echo '%abuild ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/abuild; \
	chmod 440 /etc/sudoers.d/abuild
RUN cd /etc/apk && \
	cp repositories repositories.bak && \
	printf "%s\n" /home/builder/packages/{main,community,testing} > repositories && \
	cat repositories.bak >> repositories && \
	rm -f repositories.bak

COPY update-aports.sh /etc/periodic/daily/update-aports.sh

COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
ENTRYPOINT ["/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
