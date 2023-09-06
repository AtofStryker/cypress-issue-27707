FROM cypress/included:12.17.4@sha256:102b34b9e4cb9895c44a74293c6931e7282535775045dd8b1c7608667a34c4b6

# renovate: datasource=repology depName=aur/msodbcsql versioning=loose
ARG MSODBCSQL_VERSION="18.1.2.1-1"

# renovate: datasource=repology depName=aur/mssql-tools versioning=loose
ARG MSSQL_TOOLS_VERSION="18.0.1.1-1"

ENV CI=1

RUN apt-get update && \
  apt-get install -y \
  git \
  gnupg \
  lsb-release && \
  wget -O - https://packages.microsoft.com/keys/microsoft.asc | apt-key add -  && \
  wget -O /etc/apt/sources.list.d/mssql-release.list https://packages.microsoft.com/config/debian/$(lsb_release -rs)/prod.list  && \
  apt-get update && \
  ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
  msodbcsql18=${MSODBCSQL_VERSION} \
  mssql-tools18=${MSSQL_TOOLS_VERSION} \
  locales && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen && \
  rm -r /var/lib/apt/lists/* && \
  ln -s /opt/mssql-tools18/bin/sqlcmd /usr/bin/sqlcmd


RUN mkdir -p /e2e
RUN git config --global --add safe.directory /e2e

WORKDIR /e2e

COPY package.json yarn.lock

RUN yarn install --frozen-lockfile --unsafe-perm=true --allow-root

RUN npx cypress verify

COPY . .