#!/usr/bin/ruby
$LOAD_PATH << '.'
require "language_config"

class FileProcessor
  include LanguageConfig

  def get_file_type filename
    File.extname(filename)
  end

  def increment_counter hash, key
    hash[key] += 1
  end

  def is_blank? line
    !(line =~ /\S/)
  end

  def reached_block_comment_end? line, config
    return [line.match(config[:block_comment][:end]), line.gsub(config[:block_comment][:end],'')]
  end

  def remove_quotes line
    # replacing quotes while taking care of escaped quotes
    line.gsub!(/(?<!\\)((['"])(?:\\\2|(?!\2).)*\2)/,'~~some content here~~')
  end

  def get_inline_regex config
    config[:inline_comment]
  end

  def get_start_of_block_regex config
    config[:block_comment][:begin] if config[:block_comment]
  end

  def match_inline_or_start_of_block_comment str, config
    inline_regex = get_inline_regex config
    block_regex = get_start_of_block_regex config
    final_regex = (inline_regex.nil? || block_regex.nil?) ? 
            						    (inline_regex || block_regex) : 
                						Regexp.union(inline_regex, block_regex)
    ret = str.match final_regex
    unless ret.nil?
      type = inline_regex ? 
            (ret[0].match(inline_regex).nil? ? CommentTypes::BLOCK : CommentTypes::INLNE) :
            CommentTypes::BLOCK
      return [type, ret.begin(0)]
    end
  end

  def strip_off_comment_till_eol str, index
    str.slice! index..-1
  end

  def process_code_line config, line, file_count
  	remove_quotes(line) #replacing quotes so that if any special comment character occurs there, it will not be considered
    match_type, match_index = match_inline_or_start_of_block_comment(line, config) #if encountered a comment
    strip_off_comment_till_eol(line, match_index) unless match_index.nil?
    increment_counter file_count, :comment unless match_index.nil?
    increment_counter file_count, :code if match_index.nil? || !is_blank?(line)
    return match_type
  end

  def get_details_of_file filename, config
    f = File.new(filename, "r")
    file_count = {blank: 0, comment: 0, code: 0}
    isBlockComment = false
    while(line = f.gets)
      if(isBlockComment) #if block is going in this case even blank line will be considered in comment
        increment_counter file_count, :comment
        saw_end, line = reached_block_comment_end?(line, config)
        next unless saw_end
        isBlockComment = false
        next if is_blank?(line)
      end
      if is_blank?(line)
        increment_counter file_count, :blank
      else
        match_type = process_code_line config, line, file_count
        isBlockComment = true if match_type == CommentTypes::BLOCK #starting block
      end
    end
    f.close
    return file_count
  end
end