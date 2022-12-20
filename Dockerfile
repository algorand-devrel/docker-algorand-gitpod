FROM gitpod/workspace-full:2022-12-15-12-38-23

RUN pyenv install -v 3.10.7
RUN pyenv global 3.10.7

RUN git clone https://github.com/joe-p/algodeploy.git
RUN pip install -r ./algodeploy/requirements.txt

ARG TAG=stable
RUN ./algodeploy/algodeploy.py create $TAG

RUN echo "export PATH=$PATH:/home/gitpod/.algodeploy/localnet/bin" >> ~/.bashrc
