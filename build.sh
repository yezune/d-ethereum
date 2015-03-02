#!/bin/bash

DUB=`which dub`

if [ $1 = "test" ]
then
	$DUB --build=unittest
else
	$DUB
fi

