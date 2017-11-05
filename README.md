# BokerTovNissimBot

**TODO**
Docs and README :)

### Why Elixir?

Because I wanted to write a _Telegram_ bot in _Elixir_.
As a fan of Erlang/OTP, I wanted to give it a shot, it's 🔥.

#### But isn't it an overkill for this kind of project?

It probably is. See _Why Elixir?_

## Building

Using the battery included `Makefile`;

```bash
$ make
```

For `dev` environment, run with `MIX_ENV` environment set up to `dev`;

```bash
$ MIX_ENV=dev make
```

## Release

## Running

### Using systemd

Currently the bot is running using `systemd` service, here's how it's written in my server:

```
# cat /lib/systemd/system/boker-tov-nissim.service
[Unit]
Description=Boker Tov Nissim bot

[Service]
User=root
Restart=on-failure
Environment=LANG=en_US.UTF-8
Environment="WEBHOOK_URL=https://your_host.com/whatever"
Environment="TELEGRAM_BOT_TOKEN=<redacted>"

WorkingDirectory=/opt/boker_tov_nissim
ExecStart=/opt/boker_tov_nissim/bin/boker_tov_nissim foreground
ExecStop=/opt/boker_tov_nissim/bin/boker_tov_nissim stop
PIDFile=/var/run/boker_tov_nissim.pid

[Install]
WantedBy=multi-user.target
```

## References

  * [Telegram bot API webhooks](https://core.telegram.org/bots/webhooks)
