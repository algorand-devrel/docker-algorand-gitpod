################
# Build dappflow
################
FROM node:16.19.0-bullseye as dappflow-builder

WORKDIR /workdir

ADD https://github.com/joe-p/dappflow/archive/gitpod.tar.gz /tmp/tarball.tar.gz
RUN tar -xzvf /tmp/tarball.tar.gz -C ./
RUN mv ./dappflow* ./dappflow

WORKDIR /workdir/dappflow

RUN yarn install && yarn build

########################
# Build gitpod workspace
########################
FROM gitpod/workspace-full:2023-01-16-03-31-28 as gitpod-workspace

# Install python 3.10.7
RUN pyenv install -v 3.10.7
RUN pyenv global 3.10.7

# Setup poetry
RUN poetry config virtualenvs.prefer-active-python true

# Install pipx
RUN pip install pipx

# Install algokit
RUN pipx install algokit

# Copy over dappflow
COPY --from=dappflow-builder /workdir/dappflow/build /home/gitpod/dappflow
RUN npm i -g serve