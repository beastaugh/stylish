require 'lib/stylish'

# One of the most compelling use cases for Stylish is generating alternate or
# custom stylesheets, where a number of pieces of code share the same basic
# structure but differ in details, such as colours.
#
# By automating out the repetition we can not only reduce the amount of work
# needed to generate these alternate styles, but eliminate transcription errors
# and structural inconsistencies between the various files or sections of code.
#
# For example, we might want to write some code which highlights emphasised
# portions of text in different bright colours, depending on the section.
#
#   ["red", "green", "blue"].each do |colour|
#     rule "." + colour do
#       rule "em, strong", color(colour)
#     end
#   end
#
# Which would generate the following CSS code:
#
#   .red em, .red strong {color:red;}
#   .green em, .green strong {color:green;}
#   .blue em, .blue strong {color:blue}
#
# Another advantage which it highlights is that Stylish provides a far more
# elegant and convenient way of dealing with highly nested descendant
# selectors. E.g.,
#
#   #main .content h3 {color:red;}
#   #main .content p {font-style:italic;}
#
# Would become the following:
#
#   rule "#main .content" do
#     rule "h3", color("red")
#     rule "p", font_style("italic")
#   end
#
# This ability to group rules is demonstrated to best effect towards the end of
# the example code.

Stylish.generate("tarski", nil, nil, :indent => "") do
  [
    ["classic", {}],
    ["polar", {}],
    ["skyline", {}]
  ].each do |name, mapping|
    subsheet(name, "body.#{name}") {
      comment "#{name.capitalize} style for Tarski",
              "Designed by Benedict Eastaugh, http://extralogical.net/"
      
      subsheet("navigation", "#wrapper") do
        comment "Navigation"
        rule ".nav-current:link, .nav-current:visited, .nav-current:active", color("bf6030")
        rule ".nav-current:hover", color("e59900")
      end
      
      comment "Content" do
        rule "code", color("bf8060")
        rule "abbr, acronym", border_bottom("1px solid #bf8060")
      end
      
      comment "Headers" do
        rule "h3", color("bf6030")
      end
      
  		comment "Article content" do
    		rule ".articlenav", background(:color => "fcfeff")
      end
      
      subsheet("inserts", ".insert",
        [background(:color => "fcfeff"), margin("0 0 1em 0"),
        border("1px solid #cfdde5"), padding("9px")]) do
    		comment "Inserts"
        rule "h3", border_bottom("1px solid #cfdde5")
      end
      
      subsheet("downloads", ".content") do
    		comment "Downloads"
  		  rule "a.download:link, a.download:visited, a.download:active",
  		    background(:color => "#fcfeff"), border("1px solid #cfdde5")
      end
      
  		comment "Images" do
    		rule "a img", border("1px solid #0f6b99")
    		rule "a:hover img, .comment a:hover .avatar", border("1px solid #e59900")
      end
      
  		comment "Links" do
    		rule "a:link, a:active, a:visited", color("#0f6b99")
        rule "a:hover", color("#e59900")
        rule ".content, .link-pages, .tagdata, .widget_tag_cloud" do
          rule "a:link, a:active, a:visited", border_bottom("1px solid #cfdde5")
          rule "a:hover", border_bottom("1px solid #e59900")
        end
      end
      
      subsheet("widgets", ".widget_calendar tbody td") {
        comment "Calendar widget"
        rule "a", color("#fff"), background(:color => "#8bb6cc")
        rule "a:hover", color("#fff"), background(:color => "#cca352")
      }
    }.write(File.dirname(__FILE__))
  end
end
