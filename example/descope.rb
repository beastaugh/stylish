require './lib/stylish'

scoped = Stylish.generate do
  body do
    div :margin => "1em" do
      img :text_transform => "uppercase"
      p :padding_bottom => "0.5em" do
        a :border_bottom => "1px solid #ccc"
      end
    end
  end
end

descoped = scoped.rules

puts descoped.join("\n") # => div {margin:1em;}
                         #    img {text-transform:uppercase;}
                         #    p {padding-bottom:0.5em;}
                         #    a {border-bottom:1px solid #ccc;}
                         #
                         # Handy if you want to just extract the base rules and
                         # ignore the selector scope.
