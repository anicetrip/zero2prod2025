#!/usr/bin/env bash
set -euo pipefail

# =====================
# 1️⃣ 代码格式化
# =====================
echo "🔹 Running cargo fmt..."
cargo fmt --all

# =====================
# 2️⃣ 运行测试
# =====================
echo "🔹 Running cargo test..."
cargo test --all

# =====================
# 3️⃣ 代码覆盖率 (使用 cargo-tarpaulin)
# =====================
if ! command -v cargo-tarpaulin &> /dev/null
then
    echo "⚠️ cargo-tarpaulin not found, installing..."
    cargo install cargo-tarpaulin
fi

echo "🔹 Running code coverage..."
cargo tarpaulin --ignore-tests --out Html
echo "Coverage report generated: ./tarpaulin-report.html"

# =====================
# 4️⃣ 构建 Docker 镜像
# =====================
IMAGE_NAME="zero2prod:latest"
echo "🔹 Building Docker image: $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

echo "✅ Done! Docker image ready."
