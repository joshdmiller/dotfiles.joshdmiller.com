#!/usr/bin/env python2

import sys
import markdown

def mkd2html(filename):
    # load contents to variable
    f = open(filename, 'r')
    mkd = f.read()

    # convert to markdown
    html = markdown.markdown(mkd)

    # print to stdout
    print html

if __name__ == "__main__":
    # get file name from vars
    if len(sys.argv) < 2:
        print "A filename must be passed."
        sys.exit(1)
    filename = sys.argv[1]
    mkd2html(filename)

