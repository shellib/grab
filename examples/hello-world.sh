#!/bin/bash

source $(shellib github.com/shellib/cli)

help=$(hasflag --help $*)
greeting=$(or $(readopt --greeting $*) "Hello World!")

if [ -n "$help" ]; then
	echo "Usage: hello-world.sh --greeting <Your Greeting>"
	echo ""
	echo "Example:"
	echo "hello-world.sh --greeting Aloha"
else
	echo $greeting
fi