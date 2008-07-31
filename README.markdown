Stylish
=======

[Stylish](http://github.com/ionfish/stylish/) is a simple <abbr title="Cascading Stylesheets">CSS</abbr> documentation parser written in Ruby.

Examples
--------

    doc = Stylish::Doc.new('/path/to/test.css')
    doc.chew
    doc.print('/path/to/template.html.erb', '/path/to/output.html')

<abbr title="Cascading Stylesheets">CSS</abbr> documentation for a block of code should be formatted in the following fashion:

    /**
     * A brief description of the purpose of this code.
     * 
     * A longer set of notes about this code, detailing (for example) any
     * browser-specific hacks that it uses, or its place within the general
     * structure of the stylesheet.
     * @author Benedict Eastaugh
     */
     .test {display:block; margin:0 0 1em 0; padding:5px; background:#fafafa;}
     .test H1 {font-family:'Times New Roman'; font-size:2em;}
     .test P {margin:0 0 1em 0; line-height:1.5;}
     .test CODE {font-family:Courier; font-size:12px;}

In the pipeline
---------------

* Default <abbr title="Embedded Ruby">ERB</abbr> templates
* Printing Lists to multiple pages, complete with navigation
* Split up some of the larger methods into smaller, more modular ones
