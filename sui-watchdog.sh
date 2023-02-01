#!/bin/bash
# Node watcher for SUI
# Add to crontab for every 5 minutes
# crontab -e
#
# */5 * * * * $HOME/sui-watchdog.sh
#
# 2023 (c) catomatik@gmail.com

# Set telegram ids
TELEGRAM_BOT_ID="BOT_ID"
TELEGRAM_CHAT_ID="CHAT_ID"

# Sui api
SUI_API="http://127.0.0.1:9000/"

# Alert telegram: allert_telegram "Message"
alert_telegram() {
        curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_ID/sendMessage?parse_mode=HTML&chat_id=$TELEGRAM_CHAT_ID&text=<b>$HOSTNAME</b>%0A$1"
}

# Check error: check_error $id $condition $message
# If eval of $condition is false, then state will be raised
check_error() {
        local id=$1; local condition=$2; local message=$3; local error_file="$HOME/.error.$id"

        if ! eval "$condition"; then
                echo "STATUS: $message"
                if  ! test -f "$error_file"; then
                        echo "ERROR: $message"
                        touch "$error_file"
                        alert_telegram "ERROR: $message"
                fi
                exit
        fi
        if test -f "$error_file"; then
                rm -f "$error_file"
                echo "RECOVERED: $message"
                alert_telegram "RECOVERED $message"
        fi
}

# Check running massa-node
check_error "sui-not-running" "pgrep sui-node &> /dev/null" "Sui: node not runnning"

# Check growing up blocks
CURRENT_TRANS_NUN=$(curl --silent --location --request POST $SUI_API  --header 'Content-Type: application/json'   --data-raw '{ "jsonrpc":"2.0", "method":"sui_getTotalTransactionNumber","id":1}' | jq .result)

# Check transaction number received (if not - node in inoperate state)
check_error "sui-cannot-receive-tn" "[[ '${CURRENT_TRANS_NUN}' =~ ^[0-9]+$ ]]" "Sui: cannot receive transaction number"

# Check growing up blocks
echo "Transactions num: $CURRENT_TRANS_NUN"

OLD_TRANS_NUM=0
if [ -f "$HOME/.sui.transaction_num" ]; then
        OLD_TRANS_NUM=$(cat $HOME/.sui.transaction_num)
        echo "OLD transactions num: $OLD_TRANS_NUM"
        check_error "sui-tn-stalled" "[ $CURRENT_TRANS_NUN -ne $OLD_TRANS_NUM ]" "Sui: stalled transactions number"
fi
echo $CURRENT_TRANS_NUN > "$HOME/.sui.transaction_num"
