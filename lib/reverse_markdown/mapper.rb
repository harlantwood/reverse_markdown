module ReverseMarkdown
  class Mapper
    attr_accessor :raise_errors
    attr_accessor :log_enabled, :log_level
    attr_accessor :li_counter
    attr_accessor :github_style_code_blocks

    def initialize(opts={})
      self.log_level   = :info
      self.log_enabled = true
      self.li_counter  = 0
      self.github_style_code_blocks = opts[:github_style_code_blocks] || false
    end

    def process_element(element)
      output = ''
      if element.text?
        output << process_text(element)
      else
        output << opening(element)
        output << element.children.map{ |child| process_element(child) }.join
        output << ending(element)
      end
      output.gsub!(/ {2,}/, ' ')
      output
    end

    private

    def opening(element)
      parent = element.parent ? element.parent.name.to_sym : nil
      case element.name.to_sym
        when :html, :body
          ""
        when :li
          indent = '  ' * [(element.ancestors('ol').count + element.ancestors('ul').count - 1), 0].max
          if parent == :ol
            "#{indent}#{self.li_counter += 1}. "
          else
            "#{indent}- "
          end
        when :pre
          "\n"
        when :ol
          self.li_counter = 0
          "\n"
        when :ul, :root#, :p
          "\n"
        when :p
          if element.ancestors.map(&:name).include?('blockquote')
            "\n\n> "
          elsif [nil, :body].include? parent
            is_first = true
            previous = element.previous
            while is_first == true and previous do
              is_first = false unless previous.content.strip == "" || previous.text?
              previous = previous.previous
            end
            is_first ? "" : "\n\n"
          else
            "\n\n"
          end
        when :h1, :h2, :h3, :h4 # /h(\d)/ for 1.9
          element.name =~ /h(\d)/
          '#' * $1.to_i + ' '
        when :em
          "*"
        when :strong
          "**"
        when :blockquote
          "> "
        when :code
          if parent == :pre
            self.github_style_code_blocks ? "\n```\n" : "\n    "
          else
            " `"
          end
        when :a
          if !element.text.strip.empty? && element['href'] && !element['href'].start_with?('#')
            " ["
          else
            " "
          end
        when :img
          " !["
        when :hr
          "----------\n\n"
        when :br
          "  \n"
        else
          handle_error "unknown start tag: #{element.name.to_s}"
          ""
      end
    end

    def ending(element)
      parent = element.parent ? element.parent.name.to_sym : nil
      case element.name.to_sym
        when :html, :body, :pre, :hr, :p
          ""
        when :h1, :h2, :h3, :h4 # /h(\d)/ for 1.9
          "\n"
        when :em
          '*'
        when :strong
          '**'
        when :li, :blockquote, :root, :ol, :ul
          "\n"
        when :code
          if parent == :pre
            self.github_style_code_blocks ? "\n```" : "\n"
          else
           '` '
          end
        when :a
          if !element.text.strip.empty? && element['href'] && !element['href'].start_with?('#')
            "](#{element['href']}#{title_markdown(element)}) "
          else
            ""
          end
        when :img
          "#{element['alt']}](#{element['src']}#{title_markdown(element)}) "
        else
          handle_error "unknown end tag: #{element.name}"
          ""
      end
    end

    def title_markdown(element)
      title = element['title']
      title ? %[ "#{title}"] : ''
    end

    def process_text(element)
      parent = element.parent ? element.parent.name.to_sym : nil
      case
        when parent == :code && !self.github_style_code_blocks
          element.text.strip.gsub(/\n/,"\n    ")
        else
          squeeze_whitespace(element.text)
      end
    end

    def squeeze_whitespace(string)
      string.tr("\n\t", ' ').squeeze(' ').gsub(/\A \z/, '')
    end

    def handle_error(message)
      if raise_errors
        raise ReverseMarkdown::ParserError, message
      elsif log_enabled && defined?(Rails)
        Rails.logger.__send__(log_level, message)
      end
    end
  end
end
