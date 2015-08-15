module LanguageConfig

  module Formats
    RUBY        = ".rb"
    JAVASCRIPT  = ".js"
    HTML        = ".html"
    CSS         = ".css"
    YAML        = ".yml"
    C           = ".c"
    CPP         = ".cpp"
  # SAMPLE_LANG = ".sample_ext"
  end

  FormatNames =  {
      Formats::RUBY => {name: "Ruby"},
      Formats::JAVASCRIPT => {name: "JS"},
      Formats::HTML => {name: "HTML"},
      Formats::CSS => {name: "CSS"},
      Formats::YAML => {name: "YAML"},
      Formats::C => {name: "C"},
      Formats::CPP => {name: "C++"}
      # Formats::SAMPLE_LANG => {name: "<as you would like in output"}
  }

  module CommentTypes
    INLNE = 0
    BLOCK = 1
  end

  COMMENT_REGEX_IN_FORMATS = {
    Formats::RUBY => {inline_comment: /[#].*$/, block_comment: {:begin => /^=begin/, :end => /^=end/}},
    Formats::JAVASCRIPT => {inline_comment: /\/\//, block_comment: {:begin => /\/\*/,:end => /\*\\/}},
    Formats::HTML => {block_comment: {:begin => /<!--/,:end => /-->/}},
    Formats::CSS => {block_comment: {:begin => /\/\*/,:end => /\*\\/}},
    Formats::YAML => {inline_comment: /[#].*$/},
    Formats::C => {inline_comment: /\/\//, block_comment: {:begin => /\/\*/, :end => /\*\\/}},
    Formats::CPP => {inline_comment: /\/\//, block_comment: {:begin => /\/\*/, :end => /\*\\/}}
  # Formats::SAMPLE_LANG => {inline_comment: <reg_exp>, block_comment: {:begin => <reg_exp>, :end => <reg_exp>}}
  }
end