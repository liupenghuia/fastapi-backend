#!/bin/bash
# FastAPI 日志查看工具

show_help() {
    echo "📊 FastAPI 日志查看工具"
    echo "================================"
    echo ""
    echo "使用方法："
    echo "  ./view_logs.sh [选项]"
    echo ""
    echo "选项："
    echo "  access     查看访问日志"
    echo "  error      查看错误日志"
    echo "  app        查看应用日志"
    echo "  json       查看 JSON 格式日志"
    echo "  live       实时查看日志"
    echo "  stats      查看日志统计"
    echo "  search     搜索日志"
    echo ""
}

LOG_DIR="/var/log/fastapi"

case "$1" in
    access)
        echo "📋 访问日志（最近 50 条）："
        tail -50 /var/log/fastapi-access.log
        ;;
    
    error)
        echo "❌ 错误日志（最近 50 条）："
        tail -50 /var/log/fastapi-error.log
        ;;
    
    app)
        echo "📝 应用日志（最近 50 条）："
        tail -50 $LOG_DIR/app.log 2>/dev/null || echo "应用日志文件不存在"
        ;;
    
    json)
        echo "📄 JSON 日志（最近 10 条）："
        tail -10 $LOG_DIR/access.json 2>/dev/null | python3 -m json.tool || echo "JSON 日志文件不存在"
        ;;
    
    live)
        echo "🔴 实时日志（Ctrl+C 退出）："
        tail -f $LOG_DIR/app.log 2>/dev/null || tail -f /var/log/fastapi-access.log
        ;;
    
    stats)
        echo "📊 日志统计："
        echo "================================"
        echo ""
        echo "📂 文件大小："
        ls -lh /var/log/fastapi-* 2>/dev/null | awk '{print $9, $5}'
        ls -lh $LOG_DIR/* 2>/dev/null | awk '{print $9, $5}'
        
        echo ""
        echo "📈 今日请求统计："
        TODAY=$(date +%Y-%m-%d)
        if [ -f "/var/log/fastapi-access.log" ]; then
            TOTAL=$(grep "$TODAY" /var/log/fastapi-access.log 2>/dev/null | wc -l)
            SUCCESS=$(grep "$TODAY" /var/log/fastapi-access.log 2>/dev/null | grep -E " 200| 201" | wc -l)
            ERRORS=$(grep "$TODAY" /var/log/fastapi-access.log 2>/dev/null | grep -E " 4[0-9][0-9]| 5[0-9][0-9]" | wc -l)
            
            echo "总请求数: $TOTAL"
            echo "成功请求: $SUCCESS"
            echo "错误请求: $ERRORS"
        fi
        
        echo ""
        echo "🌍 TOP 10 访问 IP："
        grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /var/log/fastapi-access.log 2>/dev/null | sort | uniq -c | sort -rn | head -10
        
        echo ""
        echo "🔝 TOP 10 访问路径："
        awk '{print $2}' /var/log/fastapi-access.log 2>/dev/null | sort | uniq -c | sort -rn | head -10
        ;;
    
    search)
        if [ -z "$2" ]; then
            echo "❌ 请提供搜索关键词"
            echo "用法: ./view_logs.sh search <关键词>"
            exit 1
        fi
        
        echo "🔍 搜索关键词: $2"
        echo "================================"
        grep -i "$2" /var/log/fastapi-*.log $LOG_DIR/*.log 2>/dev/null | tail -50
        ;;
    
    *)
        show_help
        ;;
esac
