require "pathname"
$LOAD_PATH << '.'
require "language_config"
require "file_processor"

class GetContentDetails
  include LanguageConfig

  attr_accessor :category_counts

  def initialize
    default_counts = {number: 0, blank: 0, comment: 0, code: 0}
    @category_counts = FormatNames
    @category_counts.each {|key, value| value.merge! default_counts}
  end

  def get_specific_counts
    return category_counts
  end

  def update_from_file file_details, type
    category_counts[type][:number] += 1
    file_details.each do |key,value|
      category_counts[type][key] += value
    end
  end

  def process_file filename
    fp = FileProcessor.new
    filetype = fp.get_file_type(filename)
    if(COMMENT_REGEX_IN_FORMATS.keys.include?(filetype))
      begin
        file_details = fp.get_details_of_file filename, COMMENT_REGEX_IN_FORMATS[filetype]
        update_from_file file_details, filetype
      rescue Exception => e
        puts "Encountered error " + e.message + "FILE => #{filename}"
      end
    end
  end

  def scan_directory path_name
    path_name.children.each do |item|
      if File.file?(item)
        scan_file item
      elsif File.directory?(item)
        scan_directory(item)
      end
    end
  end

  def scan_file path_name
    process_file path_name
  end

  def scan_content path_name
    scan_directory path_name if File.directory?(path_name)
    scan_file path_name if File.file?(path_name)
  end
end

a = GetContentDetails.new
a.scan_content(Pathname.new(ARGV[0]))
a.get_specific_counts.each do |key, value|
  puts "#{value[:name]} \t - #{value[:number]} files - #{value[:blank]} Blank Lines - #{value[:comment]} Comment Lines - #{value[:code]} Code lines"
end