# Fetches UML from yUML
require 'net/http'
require 'yuml/class'
require 'yuml/relationship'
require 'yuml/note'

# A module to create a DSL for yuml.me
module YUML
  extend self

  ESCAPE_CHARACTERS = {
    '{' => "\u23A8",
    '}' => "\u23AC",
    '<' => "\u3008",
    '>' => "\u3009",
    ',' => "\u201A",
    '#' => "\u0023"
  }

  def generate(file: '/tmp/yuml.jpg')
    classes.clear
    notes.clear
    yield self
    fetch_uml file
  end

  def class(&block)
    yuml_class = YUML::Class.new
    block.arity < 1 ? yuml_class.instance_eval(&block) : block.call(yuml_class)
    classes << yuml_class
    yuml_class
  end

  def attach_note(content, color = nil)
    notes << YUML::Note.create(content, color)
  end

  private

  def classes
    @classes ||= []
  end

  def notes
    @notes ||= []
  end

  def yuml
    uml = classes.map(&:to_s).join(',')
    relationships = classes.map(&:relationships).compact
    uml << ',' << relationships.join(',') unless relationships.empty?
    uml << ',' << notes.join(',') unless notes.empty?
    URI.encode(uml, encodings)
  end

  def fetch_uml(file)
    uri = URI("https://yuml.me/diagram/class/#{yuml}#{extname(file)}")
    response = Net::HTTP.get_response(uri)
    File.open(file, 'wb') {|f| f.write(response.body)}
  end

  def extname(filename)
    return '.jpg' unless %w(.png .jpg .jpeg).include?(File.extname(filename))
    File.extname(filename).sub('.jpg', '.jpeg')
  end

  def encodings
    "#{ESCAPE_CHARACTERS.values.join}[](){}+->|.,=;*^ "
  end
end
