#!/usr/bin/env bash

mkdir -p /tmp/elixir
curl -s -o /tmp/elixir/Precompiled.zip 'https://github.com/elixir-lang/elixir/releases/download/v1.5.2/Precompiled.zip' -L
unzip -qq -o /tmp/elixir/Precompiled.zip -d /opt/elixir
mkdir -p /home/ubuntu/bin
for binfile in $(ls /opt/elixir/bin); do ln -sf /opt/elixir/bin/$binfile /home/ubuntu/bin/; done
rm -rf /tmp/elixir
rm -f /tmp/esl.deb /tmp/erlang.deb
