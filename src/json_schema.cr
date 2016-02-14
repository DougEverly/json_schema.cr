require "./json_schema/*"
require "json"

module JSON
	struct Property
		JSON.mapping({
			description: {type: String, nilable: true},
			type: String,
			minimum: {type: Float64, nilable: true},
			exclusiveMinimum: {type: Bool, nilable: true},
			minItems: {type: Int64, nilable: true},
			uniqueItems: {type: Bool, nilable: true},
			properties: {type: Hash(String, Property), nilable: true},
			required: {type: Array(String), nilable: true},
			
		})
		
		def validate(v)
			puts "Validating #{@type}..."
			puts [@description, @type, @minimum]
			pp v
			puts typeof(v)
			
			case @type
			when "integer"
				puts typeof(v)
				pp v as Int64
				# pp v.as_i
			when "string"
				# pp v.as_s
				v as String
			when "object"
				h = v as Hash(String, JSON::Type)
				keys = Set(String).new
				if required = @required as Array(String)
					keys.merge(required)
				end
				if (properties = @properties as Hash(String, Property))
					puts "Here are my props"
					pp properties
					keys.merge(properties.keys)
					pp keys
					properties.each do |key, property|
						puts
						if value = h[key]?
							puts "Going to validate #{key}"
							property.validate(h[key])
						else
							puts "Required property #{key} not set"
						end
					end
				end
			when "number"
				puts typeof(v)
				n = v as Float64
				puts typeof(n)
				puts "here"
				# pp v.as_f
				r = if (n) && (@minimum) && (minimum = @minimum as Float64)
					if @exclusiveMinium
						n > minimum
					else
						n >= minimum
					end
				end
				return r
			end
			
			return true
		end
	end
	
	struct Schema
		JSON.mapping({
			title: String,
			type: String,
			properties: Hash(String, Property),
			required: Array(String),
		})
		
		def start(any :  JSON::Any)
			case @type
			when "object"
				h = any.as_h
				keys = Set(String).new
				keys.merge(@required)
				keys.merge(@properties.keys)
				pp keys
				@properties.each do |key, property|
					puts
					if value = h[key]?
						puts "Going to validate #{key}"
						property.validate(h[key])
					else
						puts "Required property #{key} not set"
					end
				end
			end
		end
		
		def validate(any : JSON::Any)
			puts
			case type
			when "object"
				if t = any .as_h
					 JSON::Schema.from_json(a)
					puts typeof(t)
					pp t
				end
				# validate(any)
			when "array"
				if array = any.as_a
					# pp array
					array.each do |item|
						validate(item)
					end
				end
			else
				puts type
				return false
			end
		end
	end
end

v = <<-THE_END
{
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
}
THE_END
v = <<-THE_END
{
    "id": 2,
    "name": "An ice sculpture",
    "price": 12.50,
    "tags": ["cold", "ice"],
    "dimensions": {
        "length": 7.1,
        "width": 12.0,
        "height": 9.5
    },
    "warehouseLocation": {
        "latitude": -78.75,
        "longitude": 20.4
    }
}
THE_END
v = JSON.parse(v)

a = <<-THE_END
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Product",
    "description": "A product from Acme's catalog",
    "type": "object",
    "properties": {
      "id": {
          "description": "The unique identifier for a product",
          "type": "integer"
      },
      "name": {
          "description": "The unique identifier for a product",
          "type": "string"
      },
      "price": {
          "type": "number",
          "minimum": 0,
          "exclusiveMinimum": true
      },
      "dimensions": {
          "type": "object",
          "properties": {
              "length": {"type": "number"},
              "width": {"type": "number"},
              "height": {"type": "number"}
          },
          "required": ["length", "width", "height"]
      }
			
    },
    "required": ["id"]
}
THE_END

x = <<-THE_END
{
	"title": "Example Schema",
	"type": "object",
  "properties": {
      "id": {
          "description": "The unique identifier for a product",
          "type": "number"
      },
      "name": {
          "type": "string"
      },
      "price": {
          "type": "number",
          "minimum": 0,
          "exclusiveMinimum": true
      },
      "tags": {
          "type": "array",
          "items": {
              "type": "string"
          },
          "minItems": 1,
          "uniqueItems": true
      },
      "dimensions": {
          "type": "object",
          "properties": {
              "length": {"type": "number"},
              "width": {"type": "number"},
              "height": {"type": "number"}
          },
          "required": ["length", "width", "height"]
      },
      "warehouseLocation": {
          "description": "Coordinates of the warehouse with the product",
          "$ref": "http://json-schema.org/geo"
      }
  },
	"required": ["firstName", "lastName"]
}
THE_END

j = JSON::Schema.from_json(a)
if j.start(v)
	puts "valid"
else
	puts "bad"
end
pp j