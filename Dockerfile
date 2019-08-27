FROM continuumio/miniconda3
WORKDIR /root
ADD environment.yml /tmp/environment.yml
ADD instantclient-basic-linux.x64-19.3.0.0.0dbru.zip /opt/instantclient.zip

RUN apt-get update -y && \
    apt-get install -y apt-utils unzip && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get -y autoremove && \
    apt-get clean
	
RUN conda update -n base -c defaults conda && \
    conda update --all && \
    conda env update --file /tmp/environment.yml && conda init && conda clean -y --all && \
    pip install --no-cache-dir cx-Oracle && \
    unzip /opt/instantclient.zip -d /opt && \
	rm -f /opt/instantclient_19_3.zip
	
RUN printf "export PATH=\"$PATH:/opt/instantclient_19_3\"" >> ~/.bashrc && \
	printf "printf 'Please run \"./start_notebook.sh\"'\n" >> ~/.bashrc && \
    printf "#!/bin/bash\njupyter-lab --ip='*' --no-browser --NotebookApp.token=masterclass --allow-root" >> start_notebook.sh && chmod +x start_notebook.sh

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

EXPOSE 8888
ENTRYPOINT [ "/usr/bin/tini", "--"]
CMD ["/bin/bash"]