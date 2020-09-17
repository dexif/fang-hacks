# telegram.sh

## Notes

This fork adapts the [original](https://github.com/fabianonline/telegram.sh) to work on a simple shell `sh`.


## What does it do?

Telegram offers the feature of bots. A bot allows automated systems and
servers to send telegram messages to users.
Quite often it can be useful to send stuff to yourself. A classic
application of this would be receiving results of cronjob tasks via email.
Or maybe you want to grab a small file from your server, but downloading it
via SCP would be too much work or wouldn't work at all because firewall
stuff / filters / proxy servers / whatever.

telegram.sh allows you to send such things via telegram.

## Examples

```bash
# Send a message to yourself, using a bot token and a chat_id.
telegram -t 123456:AbcDefGhi-JklMnoPrw -c 12345 -m "Hello, World."

# You can define the token and chat_id in environment variables or config files.
# Then you can just use
telegram -m "Hello, World."

# Split them into multiple lines
telegram -m "Hello,"$'\n'"World."
echo -e "Hello\nWorld." | telegram -

# Or you send this one message to another chat:
telegram -c 6789 -m "Hello, Mars."

# Send stuff via stdin as monospace code:
ls -l | telegram -C -

# Use markdown in your message (HTML is available as well):
telegram -M -m "To *boldly* go, where _no man_ has gone before."

# Send a local file.
telegram -f results.txt -m "Here are the results."

# Or an image, giving you a preview and stuff.
telegram -i solar_system.png

# See all options:
telegram -h

# Use environment variables to tell curl to use a proxy server:
HTTPS_PROXY="socks5://127.0.0.1:1234" telegram -m "Hello, World."
```

## Requirements

Only shell `sh` and `curl`.

## Installation / configuration

* Grab the latest `telegram` file from this repository and put it somewhere.
* Create a bot at telegram:
  * Search for the user `@botfather` at telegram and start a chat with him.
  * Use the `/newbot` command to create a new bot. Keep the given token.
* Use your telegram client to send any message to your new bot. 
* Find your chat id runnung telegram.sh with `-l`: `telegram -t <TOKEN> -l`.
* You now have your token and your chat id. Send yourself a first message:  
    `telegram -t <TOKEN> -c <CHAT ID> -m "Hello there."`

Carrying the token and the chat id around can be quite cumbersome. You can
define them in 4 different ways:

1. In a file `/etc/telegram.sh.conf`.
2. In a file `~/.telegram.sh`.
3. In environment variables TELEGRAM_TOKEN and TELEGRAM_CHAT.
4. As seen above as parameters.

Later variants overwrite earlier variants, so you could define token and
chat in `/etc/telegram.sh.conf` and then overwrite the token with your own
in `~/.telegram.sh` or on the command line.

The files should look like this:

```bash
TELEGRAM_TOKEN="123456:AbcDefGhi-JlkMno"
TELEGRAM_CHAT="12345678"
```

Please be aware that you should keep your token a secret.

You can add other options here, like:

```bash
TELEGRAM_DISABLE_WEB_PAGE_PREVIEW=true  # will behave like  -D option"
TELEGRAM_DISABLE_NOTIFICATION=true      # will behave like  -N option"
```

### Proxy Settings

You can also add permanent proxy settings to config files by adding:

```bash
export HTTPS_PROXY="socks5://127.0.0.1:1234"
```
See the curl documentation for more information about which proxy protocols are supported.
