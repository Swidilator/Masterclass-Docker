FROM continuumio/miniconda3

RUN conda update -n base -c defaults conda

ADD environment.yml /tmp/environment.yml
RUN conda env update --file /tmp/environment.yml && conda clean -y --all && conda init 
# Pull the environment name out of the environment.yml
# RUN conda init
# RUN echo $(head -1 /tmp/environment.yml | cut -d' ' -f2)

# ENV PATH /opt/conda/envs/$(head -1 /tmp/environment.yml | cut -d' ' -f2)/bin:$PATH
# RUN conda init
# RUN echo "conda activate $(head -1 /tmp/environment.yml | cut -d' ' -f2)" >> ~/.bashrc


WORKDIR /root

EXPOSE 8888
RUN printf  "#!/bin/bash\njupyter-lab --ip='*' --no-browser --NotebookApp.token=masterclass --allow-root" >> start_notebook.sh && chmod +x start_notebook.sh
# RUN chmod +x start_notebook.sh
ENTRYPOINT [ "/usr/bin/tini", "--"]
CMD ["/bin/bash"]