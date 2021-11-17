#!/bin/bash

FILE=helloWorld.log

print() {
  echo "Hello World!" >> $FILE
}

print
