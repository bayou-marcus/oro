# Auguste

_**"The enemy knows the system"** ([Claude Shannon](http://en.wikipedia.org/wiki/Claude_Shannon) / [Auguste Kerckhoffs](http://en.wikipedia.org/wiki/Auguste_Kerckhoffs))_

A flexible command line tool for generating memorable passwords.

## Usage

    Usage: auguste [settings]

    Part settings (all lengths optional)
        p[n] Punctuation part
        n[n] Number part
        l[n] Linnaeus part
        a[n] Latin part
        g[n] German part
        e[n] English part
        m[n] Emoticon part
        b[n] Braille part

    Config settings
        -i, --iterations=MANDATORY       The number of passwords to generate
        -c, --[no-]capitalize            Capitalize every word part
        -r, --[no-]capitalize-random     Randomly capitalize one letter in every word part
        -l, --[no-]l33t                  Make one l33t-style replacement per word part
        -s, --[no-]shuffle               Randomize map parts
        -f, --format=MANDATORY           Results format: string, json, yaml
        -e, --separator[=OPTIONAL]       Separator characters

    Action settings
            --lists                      Show all available lists
            --prefs, --preferences       Show your current preferences
            --defaults                   Show system defaults
            --set                        Set passed settings as your preferences
            --reset                      Reset your preferences to system defaults
        -v, --verbose                    Provide verbose feedback, dictionary metadata, and statistics when run
        -h, --help                       Print this dialog
            --version                    Show version

    Examples
        auguste e9 p1 n3 -s --set
        auguste e10 p1 g10 --no-capitalize
        auguste n99 -i10
        auguste e10 n5 -fjson

    See dictionary source files for associated license attributions.

## License

http://opensource.org/licenses/mit-license.php

    The MIT License (MIT)

    Copyright (c) 2015 Joel Wagener

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
