require "./json_schema/*"
require "json"

module JSON
	struct Property
		JSON.mapping({
			description: {type: String, nilable: true},
			type: String,
			minimum: {type: Int64, nilable: true},
		})
		
		def validate(v)
			puts "Validating..."
			puts [@description, @type, @minimum]
			pp v
			case @type
			when "integer"
				puts typeof(v)
				pp v as Int64
				# pp v.as_i
			when "string"
				puts typeof(v)
				# pp v.as_s
				v as String
			else
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
						pp item
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
    "namex": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
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
      }
    },
    "required": ["id"]
}
THE_END

json_s = <<-THE_END
{
	"title": "Example Schema",
	"type": "object",
	"properties": {
		"firstName": {
			"type": "string"
		},
		"lastName": {
			"type": "string"
		},
		"age": {
			"description": "Age in years",
			"type": "integer",
			"minimum": 0
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