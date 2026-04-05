#!/bin/bash
# Claude Code statusline script (3-line layout)

# ANSIカラー定義
GREEN=$'\e[38;2;151;201;195m'
YELLOW=$'\e[38;2;229;192;123m'
RED=$'\e[38;2;224;108;117m'
GRAY=$'\e[38;2;74;88;92m'
RESET=$'\e[0m'
SEP="${GRAY} │ ${RESET}"

# stdinからJSONを読み込む
input=$(cat)

# ────────────────────────────────────────────
# モデル名の取得・変換
# ────────────────────────────────────────────
model_id=$(echo "$input" | jq -r '.model.id // ""')
case "$model_id" in
  *claude-opus-4-6*)    model_label="Opus 4.6" ;;
  *claude-opus-4*)      model_label="Opus 4" ;;
  *claude-opus-3-5*)    model_label="Opus 3.5" ;;
  *claude-opus*)        model_label="Opus" ;;
  *claude-sonnet-4-6*)  model_label="Sonnet 4.6" ;;
  *claude-sonnet-4-5*)  model_label="Sonnet 4.5" ;;
  *claude-sonnet-4*)    model_label="Sonnet 4" ;;
  *claude-sonnet-3-5*)  model_label="Sonnet 3.5" ;;
  *claude-sonnet*)      model_label="Sonnet" ;;
  *claude-haiku-4-5*)   model_label="Haiku 4.5" ;;
  *claude-haiku-4*)     model_label="Haiku 4" ;;
  *claude-haiku-3-5*)   model_label="Haiku 3.5" ;;
  *claude-haiku*)       model_label="Haiku" ;;
  *)
    model_label=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
    ;;
esac

# ────────────────────────────────────────────
# コンテキスト使用率の取得
# ────────────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -z "$used_pct" ]; then
  used_pct="0"
fi
ctx_pct_int=$(printf "%.0f" "$used_pct")

# ────────────────────────────────────────────
# git diff 追加/削除行数
# ────────────────────────────────────────────
insertions=$(echo "$input" | jq -r '.git_diff_stats.insertions // empty')
deletions=$(echo "$input" | jq -r '.git_diff_stats.deletions // empty')
if [ -n "$insertions" ] || [ -n "$deletions" ]; then
  insertions=${insertions:-0}
  deletions=${deletions:-0}
  diff_label="+${insertions}/-${deletions}"
else
  diff_label=""
fi

# ────────────────────────────────────────────
# gitブランチ名
# ────────────────────────────────────────────
git_branch=$(echo "$input" | jq -r '.git_branch // empty')
if [ -z "$git_branch" ]; then
  git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
fi

# ────────────────────────────────────────────
# 累積コスト計算
# ────────────────────────────────────────────
cumulative_cost=$(echo "$input" | jq -r '.cumulative_cost // empty')
if [ -n "$cumulative_cost" ]; then
  cost=$(printf "%.4f" "$cumulative_cost")
else
  total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
  total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
  if echo "$model_id" | grep -qi "opus"; then
    input_price="15.0"; output_price="75.0"
  elif echo "$model_id" | grep -qi "haiku"; then
    input_price="0.25"; output_price="1.25"
  else
    input_price="3.0"; output_price="15.0"
  fi
  cost=$(awk "BEGIN {printf \"%.4f\", ($total_input * $input_price / 1000000) + ($total_output * $output_price / 1000000)}")
fi

# ────────────────────────────────────────────
# 使用率に応じたカラー選択
# ────────────────────────────────────────────
pct_color() {
  local pct=$1
  local pct_int=$(printf "%.0f" "$pct")
  if [ "$pct_int" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$pct_int" -ge 50 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# ────────────────────────────────────────────
# プログレスバー生成 (▰▱ 10セグメント)
# ────────────────────────────────────────────
build_bar() {
  local pct=$1
  local width=10
  local filled=$(awk "BEGIN {n=int($pct * $width / 100 + 0.5); if(n>$width) n=$width; if(n<0) n=0; print n}")
  local empty=$((width - filled))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar="${bar}▰"; done
  for ((i=0; i<empty; i++)); do bar="${bar}▱"; done
  printf '%s' "$bar"
}

# ────────────────────────────────────────────
# リセット時刻のフォーマット (UTC ISO8601 → Asia/Tokyo)
# ────────────────────────────────────────────
format_reset_time() {
  local iso_utc="$1"
  local format="$2"  # "time" or "datetime"
  if [ -z "$iso_utc" ]; then
    echo "N/A"
    return
  fi
  # macOS の date コマンドで変換
  local epoch
  epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_utc" "+%s" 2>/dev/null)
  if [ -z "$epoch" ]; then
    # フォールバック: python3 で変換
    epoch=$(python3 -c "
import sys
from datetime import datetime, timezone
try:
    dt = datetime.fromisoformat('${iso_utc}'.replace('Z','+00:00'))
    print(int(dt.timestamp()))
except:
    print('')
" 2>/dev/null)
  fi
  if [ -z "$epoch" ]; then
    echo "N/A"
    return
  fi
  if [ "$format" = "time" ]; then
    TZ="Asia/Tokyo" python3 -c "
from datetime import datetime, timezone, timedelta
import sys
JST = timezone(timedelta(hours=9))
dt = datetime.fromtimestamp(${epoch}, tz=JST)
h = dt.hour
if h == 0:
    print('12am')
elif h < 12:
    print(f'{h}am')
elif h == 12:
    print('12pm')
else:
    print(f'{h-12}pm')
" 2>/dev/null || echo "N/A"
  else
    TZ="Asia/Tokyo" python3 -c "
from datetime import datetime, timezone, timedelta
JST = timezone(timedelta(hours=9))
dt = datetime.fromtimestamp(${epoch}, tz=JST)
months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
h = dt.hour
if h == 0:
    time_str = '12am'
elif h < 12:
    time_str = f'{h}am'
elif h == 12:
    time_str = '12pm'
else:
    time_str = f'{h-12}pm'
print(f'{months[dt.month-1]} {dt.day} at {time_str}')
" 2>/dev/null || echo "N/A"
  fi
}

# ────────────────────────────────────────────
# レートリミット情報の取得（キャッシュ付き）
# ────────────────────────────────────────────
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
NOW=$(date +%s)
usage_json=""

# キャッシュ確認
if [ -f "$CACHE_FILE" ]; then
  cache_ts=$(python3 -c "import json,sys; d=json.load(open('${CACHE_FILE}')); print(d.get('timestamp',0))" 2>/dev/null || echo "0")
  cache_age=$((NOW - cache_ts))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    usage_json=$(python3 -c "import json,sys; d=json.load(open('${CACHE_FILE}')); print(json.dumps(d.get('data',{})))" 2>/dev/null || echo "")
  fi
fi

# キャッシュがなければAPIを叩く
if [ -z "$usage_json" ]; then
  CREDENTIALS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  ACCESS_TOKEN=$(echo "$CREDENTIALS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('claudeAiOauth',{}).get('accessToken',''))" 2>/dev/null || echo "")
  if [ -n "$ACCESS_TOKEN" ]; then
    api_response=$(curl -s --max-time 5 \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "anthropic-beta: oauth-2025-04-20" \
      https://api.anthropic.com/api/oauth/usage 2>/dev/null)
    if [ -n "$api_response" ] && echo "$api_response" | jq -e '.five_hour' >/dev/null 2>&1; then
      usage_json="$api_response"
      python3 -c "
import json, sys
data = json.loads('''${api_response}''')
cache = {'timestamp': ${NOW}, 'data': data}
with open('${CACHE_FILE}', 'w') as f:
    json.dump(cache, f)
" 2>/dev/null
    fi
  fi
fi

# レートリミット値の抽出
if [ -n "$usage_json" ]; then
  five_util=$(echo "$usage_json" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
  five_reset=$(echo "$usage_json" | jq -r '.five_hour.resets_at // .five_hour.reset_time // empty' 2>/dev/null)
  seven_util=$(echo "$usage_json" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
  seven_reset=$(echo "$usage_json" | jq -r '.seven_day.resets_at // .seven_day.reset_time // empty' 2>/dev/null)
else
  five_util=""
  five_reset=""
  seven_util=""
  seven_reset=""
fi

# ────────────────────────────────────────────
# 1行目の組み立て
# ────────────────────────────────────────────
ctx_color=$(pct_color "$ctx_pct_int")

line1=""

# モデル名
line1="${GREEN}🤖 ${model_label}${RESET}"

# コンテキスト使用率
line1="${line1}${SEP}${ctx_color}📊 ${ctx_pct_int}%${RESET}"

# git diff
if [ -n "$diff_label" ]; then
  line1="${line1}${SEP}${GREEN}✏️  ${diff_label}${RESET}"
fi

# gitブランチ
if [ -n "$git_branch" ]; then
  line1="${line1}${SEP}${GREEN}🔀 ${git_branch}${RESET}"
fi

# コスト
line1="${line1}${SEP}${GREEN}\$${cost}${RESET}"

# ────────────────────────────────────────────
# 2行目: 5時間レートリミット
# ────────────────────────────────────────────
if [ -n "$five_util" ]; then
  five_pct=$(awk "BEGIN {printf \"%.0f\", $five_util}")
  five_bar=$(build_bar "$five_pct")
  five_color=$(pct_color "$five_pct")
  five_reset_str=$(format_reset_time "$five_reset" "time")
  line2="${five_color}⏱ 5h  ${five_bar}  ${five_pct}%  Resets ${five_reset_str} (Asia/Tokyo)${RESET}"
else
  line2="${GRAY}⏱ 5h  ▱▱▱▱▱▱▱▱▱▱  N/A${RESET}"
fi

# ────────────────────────────────────────────
# 3行目: 7日間レートリミット
# ────────────────────────────────────────────
if [ -n "$seven_util" ]; then
  seven_pct=$(awk "BEGIN {printf \"%.0f\", $seven_util}")
  seven_bar=$(build_bar "$seven_pct")
  seven_color=$(pct_color "$seven_pct")
  seven_reset_str=$(format_reset_time "$seven_reset" "datetime")
  line3="${seven_color}📅 7d  ${seven_bar}  ${seven_pct}%  Resets ${seven_reset_str} (Asia/Tokyo)${RESET}"
else
  line3="${GRAY}📅 7d  ▱▱▱▱▱▱▱▱▱▱  N/A${RESET}"
fi

# ────────────────────────────────────────────
# 出力（必ず3行）
# ────────────────────────────────────────────
printf '%s\n' "${line1}"
printf '%s\n' "${line2}"
printf '%s\n' "${line3}"
