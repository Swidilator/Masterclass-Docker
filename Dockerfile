FROM continuumio/miniconda3
WORKDIR /root
ADD environment.yml /tmp/environment.yml

RUN apt-get update -y && \
    apt-get install -y apt-utils unzip wget libaio1 alien && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get -y autoremove && \
    apt-get clean
	
RUN conda update -n base -c defaults conda && \
    conda update --all && \
    conda env update --file /tmp/environment.yml && conda init && conda clean -y --all && \
    pip install --no-cache-dir cx-Oracle

RUN wget https://download.oracle.com/otn_software/linux/instantclient/193000/oracle-instantclient19.3-basic-19.3.0.0.0-1.x86_64.rpm -O basic.rpm && \
	wget https://download.oracle.com/otn_software/linux/instantclient/193000/oracle-instantclient19.3-sqlplus-19.3.0.0.0-1.x86_64.rpm -O sqlplus.rpm && \
	wget https://download.oracle.com/otn_software/linux/instantclient/193000/oracle-instantclient19.3-devel-19.3.0.0.0-1.x86_64.rpm -O devel.rpm && \
	alien -i basic.rpm && \
	alien -i sqlplus.rpm && \
	alien -i devel.rpm && \
	rm -f *.rpm
	
RUN printf "#!/bin/bash\njupyter-lab --ip='*' --no-browser --NotebookApp.token=masterclass --allow-root" >> start_notebook.sh && \
	chmod +x start_notebook.sh

ENV ORACLE_HOME="/usr/lib/oracle/19.3/client64"
ENV PATH=${PATH}:${ORACLE_HOME}/bin

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

EXPOSE 8888
ENTRYPOINT [ "/usr/bin/tini", "--"]
CMD ["/bin/bash"]