require 'thor'
require 'rest_client'
require 'reverse_markdown'

module ReverseMarkdown
  class CLI < Thor
    desc :convert, 'Download HTML from given URL and convert to Markdown'
    def convert url
      html = RestClient.get url
      markdown = ReverseMarkdown.parse html
      STDOUT.puts markdown
    end
  end
end
