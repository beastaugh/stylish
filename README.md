Stylish
=======

[Stylish](http://github.com/ionfish/stylish/) is a tool for writing
<abbr title="Cascading Stylesheets">CSS</abbr> with Ruby.


Creating stylesheets
--------------------

    style = Stylish.generate do
      rule ".header", :background => {:color => "teal", :image => "header.png"}
      rule ".content" do
        h2 :font_size => "2em"
        p :margin => "0 0 1em 0"
      end
    end

Calling the stylesheet's `to_s` method would produce the following
<abbr title="Cascading Stylesheets">CSS</abbr> code.

    .header {background-color:teal; background-image:url('header.png');}
    .content h2 {font-size:2em;}
    .content p {margin:0 0 1em 0;}


Compatibility
-------------

Stylish is compatible with Ruby 1.9. To expand on this slightly, the Stylish
test suite passes under Ruby 1.9; the usual caveats about this apply.


Future considerations
---------------------

*   Add a native mapping construct to allow symbol lookup for alternate
    stylesheets.
*   Change stylesheet generation to a two-step process where the tree structure
    is generated in the first step and symbols (for example, those employed by
    a mapping construct) are evaluated the second.
*   Fundamental objects like percentages and URIs need their own classes rather
    than being dealt with in an ad-hoc manner by higher-level objects.
*   Add a parser so CSS can be read as well as written.


Design notes
------------

CSS is a remarkably succinct and powerful language, with several marked
deficiencies. It lacks both variables and iteration, and its long-winded
property names are often irritating. Stylish attempts to address these issues
by reducing duplication, providing a cleaner namespacing syntax and reducing
transcription errors. It is not intended as a replacement for hand-authored
CSS, but as a supplement to it.

Stylish treats CSS as object code--but it treats it nicely.


Licence
-------

Copyright (c) 2008-2009, Benedict Eastaugh

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

*   Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
*   Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
*   The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
