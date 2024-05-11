#!/bin/bash
echo url="https://www.duckdns.org/update?domains=<domain>&token=<token>&ip=" | curl -k -o ~/duckdns.log -K -
