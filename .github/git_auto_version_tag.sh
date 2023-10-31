#!/bin/bash

CURTAG=`git describe --abbrev=0 --tags`;
CURTAG="${CURTAG/v/}"

IFS='.' read -a vers <<< "$CURTAG"

MAJ=${vers[0]}
MIN=${vers[1]}
PATCH=${vers[2]}
echo "Current Tag: v$MAJ.$MIN.$BUG"

for cmd in "$@"
do
	case $cmd in
		"--major")
			# $((MAJ+1))
			((MAJ+=1))
			MIN=0
			BUG=0
			echo "Incrementing Major Version#"
			;;
		"--minor")
			((MIN+=1))
			BUG=0
			echo "Incrementing Minor Version#"
			;;
		"--patch")
			((PATCH+=1))
			echo "Incrementing Patch Version#"
			;;
                *)
		   echo "Error in versioning"
		   ;;
	esac
done
NEWTAG="v$MAJ.$MIN.$PATCH"
echo "Adding Tag: $NEWTAG";
git tag -a $NEWTAG -m $NEWTAG
