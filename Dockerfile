# Build indexer (based on: https://github.com/joe-p/docker-algorand/blob/master/algorand-indexer/Dockerfile)
FROM golang:1.17.8-bullseye as indexer-builder

RUN apt-get update 
RUN apt-get install -y libboost-dev libtool

ARG repo=algorand/indexer
ARG ref=master

ADD https://github.com/${repo}/archive/${ref}.tar.gz /tmp/tarball.tar.gz
RUN tar -xzvf /tmp/tarball.tar.gz -C /usr/local/src/
RUN mv /usr/local/src/indexer* /usr/local/src/indexer

WORKDIR /usr/local/src/indexer

# Build process relies on submodules, so we need to setup git
RUN git init
RUN git checkout -b ${ref}
RUN git remote add origin https://github.com/${repo}
RUN git fetch origin ${ref}
RUN git reset --hard origin/${ref}
RUN make

FROM gitpod/workspace-postgres:2022-12-15-12-38-23 as gitpod-workspace
COPY --from=indexer-builder /usr/local/src/indexer/cmd/algorand-indexer/algorand-indexer /usr/local/bin/algorand-indexer

# Install python 3.10.7
RUN pyenv install -v 3.10.7
RUN pyenv global 3.10.7

# Install beaker
RUN pip install beaker-pyteal

# Install algodeploy
RUN git clone https://github.com/joe-p/algodeploy.git
RUN pip install -r ./algodeploy/requirements.txt

# Create network with algodeploy
ARG TAG=stable
RUN ./algodeploy/algodeploy.py create $TAG
RUN echo "export PATH=$PATH:/home/gitpod/.algodeploy/localnet/bin" >> ~/.bashrc

