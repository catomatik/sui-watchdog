## sui-watchdog
SUI watchdog bash script

![BASH](https://badgen.net/badge/language/BASH/black)

![Logo](https://pbs.twimg.com/media/FgPxXnyWAAEtre-.jpg)

## Installation

Script installation

1. Copy script to sui node home folder
2. Set telegram ids

4. Set cron job
```bash
  crontab -e
  # Paste and save
  */5 * * * * $HOME/sui-watchdog.sh
```

## Watchdog

1. For running sui-node process
2. For growing up transactions
