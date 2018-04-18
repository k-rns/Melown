#!/bin/bash
# ask the user for its name
echo "Hello, who am I talking to?"
read varname
echo "nice to meet you" "$varname"
echo "new test"
exec $SHELL
