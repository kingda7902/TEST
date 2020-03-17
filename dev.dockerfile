FROM ubuntu:bionic AS bionic_curl

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
        sudo \
        vim \
        logrotate \
        ffmpeg \
        p7zip-full \
        build-essential \
# as of Stretch, "gpg" is no longer included by default
		$(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
# https://lists.debian.org/debian-devel-announce/2016/09/msg00000.html
		$( \
# if we use just "apt-cache show" here, it returns zero because "Can't select versions from package 'libmysqlclient-dev' as it is purely virtual", hence the pipe to grep
			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
				echo 'default-libmysqlclient-dev'; \
			else \
				echo 'libmysqlclient-dev'; \
			fi \
		) \
        python3.7 \
        python3.7-dev \
	&& rm -rf /var/lib/apt/lists/*

#-- set user/group IDs
ENV USER_NAME=tigerskin
ENV WORKDIR=code

RUN useradd -m -g www-data -G sudo --uid=999 --shell /bin/bash $USER_NAME
# https://docs.docker.com/engine/reference/builder/#environment-replacement
RUN echo ${USER_NAME}:${USER_PWD:-gotigerparty8$} | chpasswd

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/${WORKDIR}

COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt

# uwsgi, django-admin
ENV PATH /home/${USER_NAME}/.local/bin/:$PATH

CMD ["/bin/bash"]