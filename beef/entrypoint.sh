#!/bin/bash
echo $1 | base64 -d >> /Project/src/Program.bf
BeefBuild -workspace=Project -run