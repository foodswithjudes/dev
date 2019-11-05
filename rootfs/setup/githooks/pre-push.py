#!/usr/bin/env python3

# An example hook script to verify what is about to be pushed.  Called by "git
# push" after it has checked the remote status, but before anything has been
# pushed.  If this script exits with a non-zero status nothing will be pushed.
#
# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done
#
# If pushing without using a named remote those arguments will be equal.
#
# Information about the commits which are being pushed is supplied as lines to
# the standard input in the form:
#
#   <local ref> <local sha1> <remote ref> <remote sha1>
#
# This sample shows how to prevent push of commits where the log message starts
# with "WIP" (work in progress).

import sys
from subprocess import run

remote = sys.argv[1]
url = sys.argv[2]

needsMerge = []
needsRebase = []

origin = "origin"
trunk = "master"

z40 = "0000000000000000000000000000000000000000"

for line in sys.stdin:
    [local_ref, local_sha, remote_ref, remote_sha] = line.split()
    if local_sha == z40:
        # Handle delete
        continue

    if remote_sha == z40:
        # New branch, examine all commits
        range = local_sha
    else:
        # Update to existing branch, examine new commits
        range = "{}..{}".format(remote_sha, local_sha)

    # Check for WIP commit
    commit = run(["git", "rev-list", "-n", "1", "--grep", "^WIP", range]).stdout
    if commit != None:
        print("Found WIP commit in {}, not pushing".format(local_ref))
        exit(1)

    [refs, heads, branch] = local_ref.split("/", 2)
    if heads == "heads" and branch != trunk:
        if remote_ref == z40:
            # If the remote doesn't exist, it's safe to rebase without a force
            # push.
            needsRebase.append(branch)
        else:
            # If the remote exists, just merge for now. Next time a PR is merged
            # the remote will
            # be rebased onto trunk and then deleted, and we'll rebase the local
            # then too.
            needsMerge.append(branch)

if len(needsMerge) + len(needsRebase) > 0:
    print("fetching {}...".format(trunk))
    run(["git", "fetch", origin, trunk])

for branch in needsMerge:
    print("merging {} into {}/{}...".format(trunk, origin, branch))
    run(["git", "merge", origin, trunk])

for branch in needsRebase:
    print("rebasing {} on {}/{}...".format(branch, origin, trunk))
    run(["git", "rebase", origin, trunk])
