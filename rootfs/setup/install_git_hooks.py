#!/usr/bin/env python3

import os
import stat
from os.path import join, splitext
from shutil import copyfile

# Remove extensions as files are copied from /githooks/* to /fwj/.git/hooks/*
for (dirpath, dirnames, filenames) in os.walk("/setup/githooks"):
    for file in filenames:
        src = join("/setup", "githooks", dirpath, file)
        filename, _ = splitext(file)
        dst = join("/fwj", ".git", "hooks", filename)
        copyfile(src, dst)
        # Set executable bit of copied file
        st = os.stat(dst)
        os.chmod(dst, st.st_mode | stat.S_IEXEC)
