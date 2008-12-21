Stylish
=======

[Stylish](http://github.com/ionfish/stylish/) is a tool for writing <abbr title="Cascading Stylesheets">CSS</abbr> with Ruby.


Creating stylesheets
--------------------

    style = Stylish.generate do
      rule ".header", background(:color => :teal, :image => "header.png")
      rule ".content" do
        rule "h2", "font-size" => "2em"
        rule "p", "margin" => "0 0 1em 0"
      end
    end

Calling the stylesheet's `to_s` method would produce the following <abbr title="Cascading Stylesheets">CSS</abbr> code.

    .header {background-color:#008080; background-image:url('header.png');}
    .content h2 {font-size:2em;}
    .content p {margin:0 0 1em 0;}


Future considerations
---------------------

* Groupings of rules and comments could be better handled.
* Fundamental objects like percentages and URIs need their own classes rather than being dealt with in an ad-hoc manner by higher-level objects.
