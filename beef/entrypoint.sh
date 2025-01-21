#!/bin/bash

curl -s https://microbin-misty-violet-1746.fly.dev/raw/$1 >> /Project/src/Program.bf
BeefBuild -workspace=Project -run