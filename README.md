# Node.js + TypeScript における Dockerfile のベストプラクティス

[![Formatted with Biome](https://img.shields.io/badge/Formatted_with-Biome-60a5fa?style=flat&logo=biome)](https://biomejs.dev/)
[![Linted with Biome](https://img.shields.io/badge/Linted_with-Biome-60a5fa?style=flat&logo=biome)](https://biomejs.dev)
[![Checked with Biome](https://img.shields.io/badge/Checked_with-Biome-60a5fa?style=flat&logo=biome)](https://biomejs.dev)

## 環境構築

### node.js のバージョン管理ツール

node.js のバージョン管理ツールとして Volta を利用しています。

- [Volta](https://volta.sh/)

Volta を使用しない場合は、 `package.json` を参考にして node, yarn のバージョンを合わせてください。

### hadolint

静的解析ツールとして hadolint を使用しています。

- [hadolint/hadolint](https://github.com/hadolint/hadolint)

### Docker Scout CLI

Docker Desktop 以外の環境で Docker を使用している場合は、 Docker Scout CLI をインストールしてください。

- [docker/scout-cli](https://github.com/docker/scout-cli)

```bash
curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh -s --
```

### dockle

CIS Docker Benchmarks への準拠チェックを行うために dockle をインストールしてください。

- [goodwithtech/dockle](https://github.com/goodwithtech/dockle)

### 依存関係のインストール

```bash
yarn install
```

## Build & Run

以下のコマンドで Docker イメージをビルドします。

```bash
docker build . \
  -f Dockerfile \
  -t node-ts-docker:0.0.1 \
  --target runner \
  --build-arg "APP_PORT=3000"
```

その後、以下のコマンドで Docker コンテナを起動します。

```bash
docker run \
  --init \
  -p 127.0.0.1:3000:3000 \
  -e "NODE_ENV=production" \
  --name node-ts-docker \
  node-ts-docker:0.0.1
```

その後、以下のコマンドで、 `{"hello":"world"}` が返ってくるか確認します。

```bash
curl http://127.0.0.1:3000/
```

## Checks

### 静的解析

#### hadolint を用いる場合

```bash
hadolint Dockerfile -c .hadolint.yml
```

#### Docker Build checks を用いる場合

- [Build checks](https://docs.docker.com/build/checks/)

```bash
docker build --check . -f Dockerfile
```

### 脆弱性チェック

Docker Scout CLI を使用してイメージの脆弱性をチェックします。

```bash
docker scout qv node-ts-docker:0.0.1
```

### CIS Docker Benchmarks への準拠チェック

Dockle を使用してイメージの脆弱性をチェックします。

```bash
dockle node-ts-docker:0.0.1
```
