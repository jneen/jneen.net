class IxlLexer < Rouge::RegexLexer
  # p :consts => Rouge::Token.constants
  # include Rouge::Token::Tokens

  tag 'ixl'
  filenames '*.ix'

  id = /\w[\w-]*/

  state :root do
    rule /\s+/, Text
    rule /#.*?\n/, Comment
    rule /%#{id}?/, Name::Variable::Instance
    rule /@#{id}/, Keyword
    rule /[$]#{id}?/, Name::Variable
    rule /[\[\]>|:(){}.+=,;]|->/, Punctuation
    rule /\d+/, Num
    rule /'{/, Str, :string
    rule /"{/, Str, :string_interp
    rule /['"][^\s)\]]+/, Str
    rule /"\S+/, Str
    rule id, Name
    rule /\S+/, Text
  end

  state :string do
    rule /{/ do
      token Str; push
    end

    rule /}/, Str, :pop!
    rule /[$]/, Str
    rule /[^${}]*/, Str
  end

  state :interp do
    rule(/[(]/) { token Punctuation; push }
    rule /[)]/, Punctuation, :pop!
    mixin :root
  end

  state :string_interp do
    rule /[$]#{id}?/, Name::Variable
    rule /[$][(]/, Str::Interpol
    mixin :string
  end
end

class TulipLexer < Rouge::RegexLexer
  tag 'tulip'
  filenames '*.tlp'

  id = /\w[\w-]*/

  state :root do
    rule /\s+/, Text
    rule /#.*?\n/, Comment
    rule /%#{id}/, Keyword::Type
    rule /@#{id}/, Keyword
    rule /[.][.]?#{id}/, Name::Label
    rule /-#{id}[?]?/, Str::Symbol
    rule /\d+/, Num
    rule %r(/#{id}?), Name::Decorator
    rule %r((#{id}/)(#{id})) do
      groups Name::Namespace, Name
    end

    rule /"{/, Str, :string_interp
    rule /'{/, Str, :string
    rule /[{}]/, Punctuation
    rule /['"][^\s)\]]+/, Str

    rule /[$]/, Name::Variable

    rule /[-+:;~!()\[\]=?>|_%]/, Punctuation
    rule /[.][.][.]/, Punctuation
    rule id, Name
  end

  state :string do
    rule /{/ do
      token Str; push
    end

    rule /}/, Str, :pop!
    rule /[$]/, Str
    rule /[^${}]*/, Str
  end

  state :interp do
    rule(/[(]/) { token Punctuation; push }
    rule /[)]/, Punctuation, :pop!
    mixin :root
  end

  state :string_interp do
    rule /[$][(]/, Str::Interpol, :interp
    rule /[$]#{id}?/, Name::Variable
    mixin :string
  end
end
