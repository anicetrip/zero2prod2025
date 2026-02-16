#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="zero2prod:latest"
CONTAINER_NAME="zero2prod_test"

export APP_ENVIRONMENT=LOCAL
export APP_DATABASE__HOST="127.0.0.1"



# # =====================
# # 1️⃣ 代码格式化
# # =====================
echo "🔹 Running cargo fmt..."
cargo fmt --all


# # =====================
# # 3️⃣ 代码覆盖率
# # =====================
if ! command -v cargo-tarpaulin &> /dev/null; then
    echo "⚠️ cargo-tarpaulin not found, installing..."
    cargo install cargo-tarpaulin
fi

echo "🔹 Running code coverage..."
cargo tarpaulin --ignore-tests --out Html
echo "Coverage report: ./tarpaulin-report.html"

# =====================
# 4️⃣ 构建 Docker 镜像
# =====================
echo "🔹 Building Docker image: $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

# =====================
# 5️⃣ 启动容器
# =====================
echo "🔹 Running container $CONTAINER_NAME..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

docker run -d \
    --name $CONTAINER_NAME \
    -p 8000:8000 \
    $IMAGE_NAME


# =====================
# 8️⃣ 清理
# =====================
echo "🔹 Stopping and removing container..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

echo "✅ All done!"