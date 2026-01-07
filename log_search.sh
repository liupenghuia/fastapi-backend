#!/bin/bash
# 日志搜索和管理工具

show_help() {
    echo "🔍 FastAPI 日志搜索工具"
    echo "================================"
    echo ""
    echo "使用方法："
    echo "  ./log_search.sh [选项] [参数]"
    echo ""
    echo "选项："
    echo "  user <username>      搜索特定用户的所有日志"
    echo "  ip <ip_address>      搜索特定 IP 的所有日志"
    echo "  error                搜索所有错误日志"
    echo "  slow                 搜索慢查询日志"
    echo "  today                搜索今天的日志"
    echo "  range <start> <end>  搜索时间范围内的日志"
    echo "  clean                清理压缩的旧日志"
    echo "  size                 查看日志文件大小"
    echo ""
    echo "示例："
    echo "  ./log_search.sh user alice"
    echo "  ./log_search.sh ip 192.168.1.100"
    echo "  ./log_search.sh slow"
    echo ""
}

LOG_DIR="/var/log/fastapi"

# 搜索特定用户
search_user() {
    local username="$1"
    echo "🔍 搜索用户: $username"
    echo "================================"
    echo ""
    
    # 搜索当前日志
    echo "📝 当前日志："
    grep -n "user.*$username" "$LOG_DIR/app.log" 2>/dev/null | tail -50
    
    # 搜索 JSON 日志
    echo ""
    echo "📄 JSON 日志："
    grep "\"user\": \"$username\"" "$LOG_DIR/access.json" 2>/dev/null | \
        python3 -m json.tool 2>/dev/null | head -100
    
    # 搜索归档日志
    echo ""
    echo "📦 归档日志："
    for file in "$LOG_DIR"/app.log.*.gz; do
        if [ -f "$file" ]; then
            echo "检查: $file"
            zgrep "user.*$username" "$file" 2>/dev/null | tail -20
        fi
    done
}

# 搜索特定 IP
search_ip() {
    local ip="$1"
    echo "🔍 搜索 IP: $ip"
    echo "================================"
    echo ""
    
    echo "📝 当前日志："
    grep -n "$ip" "$LOG_DIR/app.log" 2>/dev/null | tail -50
    
    # 统计该 IP 的请求
    echo ""
    echo "📊 请求统计："
    TOTAL=$(grep "$ip" "$LOG_DIR/app.log" 2>/dev/null | grep "Incoming" | wc -l)
    ERRORS=$(grep "$ip" "$LOG_DIR/app.log" 2>/dev/null | grep -E "❌|⚠️" | wc -l)
    echo "总请求数: $TOTAL"
    echo "错误请求: $ERRORS"
}

# 搜索错误日志
search_errors() {
    echo "❌ 错误日志"
    echo "================================"
    echo ""
    
    # 从错误日志文件
    if [ -f "$LOG_DIR/error.log" ] && [ -s "$LOG_DIR/error.log" ]; then
        echo "📝 ERROR/CRITICAL 日志："
        tail -100 "$LOG_DIR/error.log"
    fi
    
    # 从应用日志
    echo ""
    echo "📝 应用日志中的错误："
    grep -E "ERROR|CRITICAL|❌|💥" "$LOG_DIR/app.log" 2>/dev/null | tail -50
}

# 搜索慢查询
search_slow() {
    echo "🐌 慢查询日志"
    echo "================================"
    echo ""
    
    grep "Slow request" "$LOG_DIR/app.log" 2>/dev/null | tail -50
    
    # 统计
    echo ""
    echo "📊 慢查询统计："
    COUNT=$(grep "Slow request" "$LOG_DIR/app.log" 2>/dev/null | wc -l)
    echo "慢查询总数: $COUNT"
    
    if [ $COUNT -gt 0 ]; then
        echo ""
        echo "🔝 最慢的 10 个请求："
        grep "Slow request" "$LOG_DIR/app.log" 2>/dev/null | \
            grep -oE "took [0-9.]+s" | \
            sort -t' ' -k2 -rn | \
            head -10
    fi
}

# 搜索今天的日志
search_today() {
    local today=$(date +%Y-%m-%d)
    echo "📅 今天的日志: $today"
    echo "================================"
    echo ""
    
    grep "$today" "$LOG_DIR/app.log" 2>/dev/null | tail -100
}

# 搜索时间范围
search_range() {
    local start_date="$1"
    local end_date="$2"
    
    echo "📅 时间范围: $start_date 到 $end_date"
    echo "================================"
    echo ""
    
    # 搜索当前日志
    awk -v start="$start_date" -v end="$end_date" \
        '$0 ~ start,$0 ~ end' "$LOG_DIR/app.log" 2>/dev/null
    
    # 搜索归档日志
    for file in "$LOG_DIR"/app.log.*.gz; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            file_date=${filename#app.log.}
            file_date=${file_date%.gz}
            
            if [[ "$file_date" > "$start_date" ]] && [[ "$file_date" < "$end_date" ]]; then
                echo "检查归档: $file"
                zcat "$file" | head -100
            fi
        fi
    done
}

# 清理旧日志
clean_old_logs() {
    echo "🧹 清理旧日志"
    echo "================================"
    echo ""
    
    echo "📊 清理前的文件："
    ls -lh "$LOG_DIR"/*.gz 2>/dev/null
    
    # 删除 14 天前的日志
    echo ""
    echo "🗑️  删除 14 天前的日志..."
    find "$LOG_DIR" -name "*.gz" -mtime +14 -delete -print
    
    echo ""
    echo "📊 清理后的文件："
    ls -lh "$LOG_DIR"/*.gz 2>/dev/null
}

# 查看日志大小
show_size() {
    echo "📊 日志文件大小"
    echo "================================"
    echo ""
    
    echo "当前日志："
    du -h "$LOG_DIR"/*.log 2>/dev/null | sort -h
    
    echo ""
    echo "归档日志："
    du -h "$LOG_DIR"/*.gz 2>/dev/null | sort -h
    
    echo ""
    echo "总计："
    du -sh "$LOG_DIR"
}

# 主逻辑
case "$1" in
    user)
        if [ -z "$2" ]; then
            echo "❌ 请提供用户名"
            echo "用法: $0 user <username>"
            exit 1
        fi
        search_user "$2"
        ;;
    
    ip)
        if [ -z "$2" ]; then
            echo "❌ 请提供 IP 地址"
            echo "用法: $0 ip <ip_address>"
            exit 1
        fi
        search_ip "$2"
        ;;
    
    error)
        search_errors
        ;;
    
    slow)
        search_slow
        ;;
    
    today)
        search_today
        ;;
    
    range)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "❌ 请提供开始和结束日期"
            echo "用法: $0 range 2026-01-01 2026-01-07"
            exit 1
        fi
        search_range "$2" "$3"
        ;;
    
    clean)
        clean_old_logs
        ;;
    
    size)
        show_size
        ;;
    
    *)
        show_help
        ;;
esac
