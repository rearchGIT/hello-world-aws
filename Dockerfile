FROM ruby
COPY src/index.html /index.html
CMD ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => Dir.pwd).start'
