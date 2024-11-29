# syntax=docker/dockerfile:1
# check=error=true

#-------------------------------------------------------
# Build Arguments
#-------------------------------------------------------
ARG APP_PORT
#-------------------------------------------------------
# Variables
#-------------------------------------------------------
ARG BUILDER_APP_DIR=/app
ARG RUNNER_APP_DIR=/app

###=======================================================
### Builder image
###=======================================================
FROM debian:bookworm-slim AS builder

# 変数を利用できるように再宣言する
ARG BUILDER_APP_DIR

WORKDIR ${BUILDER_APP_DIR}

# Volta のインストールのために bash が必要
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV BASH_ENV=~/.bashrc
ENV VOLTA_HOME=/root/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

# Volta をインストールするために curl と ca-certificates が必要
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl
EOF

# Volta のインストール
RUN curl https://get.volta.sh | bash

# 依存関係のインストール
COPY .yarnrc.yml package.json yarn.lock ./
RUN yarn install --immutable

# ビルド
COPY tsconfig*.json ./
COPY src ./src
RUN yarn build

# 実行時に必要な依存関係のみを再インストール
RUN <<EOF
yarn workspaces focus --all --production
EOF

###=======================================================
### Runner image
###=======================================================
# nonroot イメージを利用する
FROM gcr.io/distroless/nodejs22-debian12:nonroot AS runner

# 変数を利用できるように再宣言する
ARG APP_PORT
ARG BUILDER_APP_DIR
ARG RUNNER_APP_DIR

WORKDIR ${RUNNER_APP_DIR}

# builder から 実行時に必要なファイルのみをコピー
COPY --from=builder ${BUILDER_APP_DIR}/dist ./dist
COPY --from=builder ${BUILDER_APP_DIR}/node_modules ./node_modules

ENV NODE_ENV=production

EXPOSE ${APP_PORT}

ENTRYPOINT [ "/nodejs/bin/node", "dist/src/index.js" ]
