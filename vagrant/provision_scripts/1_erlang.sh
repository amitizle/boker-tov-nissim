#!/usr/bin/env bash

curl -s -o /tmp/esl.deb https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb  -L
apt-get -qq install -y -f /tmp/esl.deb
curl -s -o '/tmp/erlang.deb' 'http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_19.3.6-1~ubuntu~xenial_amd64.deb' -L
apt-get -qq install -y -f /tmp/erlang.deb
