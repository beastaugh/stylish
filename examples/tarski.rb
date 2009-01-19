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

Stylish.generate do
  [
    ["classic", {}],
    ["polar", {}],
    ["skyline", {}]
  ].each do |name, mapping|
    subsheet(name) {
      # ...
    }.write
  end
end
