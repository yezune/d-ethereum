#!/bin/bash

DUB=`which dub`

if [ "$1" = "test" ] 
then
	$DUB --build=unittest
elif [ "$1" = "remove" ] 
then
	$DUB --build --force-remove
elif [ "$1" = "upgrade" ]
then
	$DUB upgrade
else
	$DUB --build=release
fi

