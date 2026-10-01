#!/bin/bash

set -euo pipefail

# 定义项目名称变量
PROJECT_NAME="GeoMagSwift"
# 创建项目名称的小写版本
PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

# 检查是否存在旧的文档目录，如果存在则删除
if [ -d ".github/.pages" ]; then
    rm -rf ".github/.pages"
    echo "已清理现有的文档目录"
fi

# 检查是否存在旧的构建目录，如果存在则删除
# if [ -d ".build" ]; then
#     rm -rf ".build"
#     echo "已清理现有的构建目录"
# fi

# 创建新的文档目录
mkdir -p .github/.pages

# 使用 Swift Package Manager 生成文档
# --allow-writing-to-directory: 允许写入指定目录
# generate-documentation: 生成文档命令
# --disable-indexing: 禁用索引
# --transform-for-static-hosting: 转换为静态托管格式
# --hosting-base-path: 托管基础路径
# --output-path: 输出路径
swift package --allow-writing-to-directory .github/.pages \
generate-documentation \
--disable-indexing \
--transform-for-static-hosting \
--hosting-base-path "$PROJECT_NAME" \
--output-path .github/.pages

# 创建重定向 HTML 文件，将访问者重定向到文档页面
cat > .github/.pages/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>重定向中...</title>
</head>
<body>
    <script>
        window.location.href = './documentation/$PROJECT_NAME_LOWER';
    </script>
</body>
</html>
EOF
