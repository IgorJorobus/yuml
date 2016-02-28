module YUML
  # Represents a yUML Class
  class Class
    attr_writer :name

    def initialize
      @methods = []
      @variables = []
      @relationships = []
    end

    def name(name = nil)
      @name = name if name
      "#{normalized_interface}#{@name}"
    end

    def interface(interface = nil, sterotype = 'interface')
      @interface = interface if interface
      @sterotype = sterotype if interface
      @interface
    end

    def interface=(*args)
      args.flatten!
      @interface = args.first
      @sterotype = args.size > 1 ? args.pop : 'interface'
    end

    def variables(*args)
      args.flatten!
      return attributes(@variables) if args.empty?
      @variables << normalize(args)
    end

    def methods(*args)
      args.flatten!
      return attributes(@methods) if args.empty?
      @methods << normalize(args)
    end

    def has_a(dest, type: :aggregation, cardinality: nil)
      type = :aggregation unless %i(composition aggregation).include?(type)
      relationship = YUML::Relationship.send(type, cardinality)
      @relationships << "[#{name}]#{relationship}[#{dest.name}]"
    end

    def is_a(dest, type: :inheritance)
      type = :inheritance unless %i(inheritance interface).include?(type)
      relationship = YUML::Relationship.send(type)
      @relationships << "[#{dest.name}]#{relationship}[#{name}]"
    end

    def associated_with(dest, type: :directed_assoication, cardinality: nil)
      type = :directed_assoication unless %i(
        association directed_assoication two_way_association dependency
      ).include?(type)
      relationship = YUML::Relationship.send(type, cardinality)
      @relationships << "[#{name}]#{relationship}[#{dest.name}]"
    end

    def attach_note(content, color = nil)
      @relationships << "[#{name}]-#{YUML::Note.create(content, color)}"
    end

    def to_s
      "[#{name}#{variables}#{methods}]"
    end

    def relationships
      "#{@relationships.join(',')}" unless @relationships.empty?
    end

    private

    def normalize(values)
      values.map(&:to_s).map do |v|
        YUML::ESCAPE_CHARACTERS.each { |char, escape| v.tr!(char, escape) }
        v
      end
    end

    def normalized_interface
      name interface unless @name
      return normalize(["<<#{@sterotype}>>"]).first << ';' if interface
    end

    def attributes(attrs)
      "|#{attrs.join(';')}" unless attrs.empty?
    end
  end
end
