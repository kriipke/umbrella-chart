#!/bin/sh
set -e
rm -rf manpages
mkdir manpages
go run . man | gzip -c -9 >manpages/mkchart.1.gz