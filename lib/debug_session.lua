require 're'

-- copied from https://en.wikipedia.org/wiki/Escape_sequences_in_C
local escaped_char_map = {
	a = 0x07,
	b = 0x08,
	f = 0x0C,
	n = 0x0A,
	r = 0x0D,
	t = 0x09,
	v = 0x0B
}

local literal_integer_mt = {
	__index = {
		tostring = function(self)
			return ("%d"):format(self.value)
		end
	}
}

local literal_float_mt = {
	__index = {
		tostring = function(self)
			return ("%g"):format(self.value)
		end
	}
}

local literal_character_mt = {
	__index = {
		tostring = function(self)
			local str = string.char(self.value)
			if str:find("%g") then
				return ("'%s'"):format(str)
			else
				return ("'\\x%02X'"):format(self.value)
			end
		end
	}
}

local grammar = re.compile([[
	definitions <- {| definition+ |}
	definition <- global_variable_definition
	global_variable_definition <- {|
		{type_specifier} SPACE* {identifier} SPACE* {: static_initializer :}? SPACE* SEMICOLON SPACE*
	|} -> global_variable_definition
	type_specifier <- primitive_type (SPACE+ '*'+)?
	identifier <- [_%w][_%w%d]*
	primitive_type <- 'int' / 'float' / 'char'
	static_initializer <- '=' SPACE* {: literal_value :}
	literal_value <- float / integer / character
	integer <- hexadecimal_integer / decimal_integer
	hexadecimal_integer <- ('0x' HEXCHAR+) -> literal_hexadecimal_integer
	decimal_integer <- (%d+) -> literal_decimal_integer
	float <- (%d+ '.' %d+) -> literal_float
	character <- "'" single_character "'"
	single_character <- escaped_char / ascii_char
	ascii_char <- . -> ascii_char
	escaped_char <- ('\' { [abfnrtv] } ) -> escaped_char
 	SPACE <- %s
	SEMICOLON <- ';'
	HEXCHAR <- [0-9a-fA-F]
]], {
	global_variable_definition = function(captures)
		return {
			definition = 'global',
			type = captures[1],
			name = captures[2],
			initializer = captures[3]
		}
	end,
	literal_hexadecimal_integer = function(str)
		return setmetatable(
			{type = 'literal_integer', value = tonumber(str, 16)},
			literal_integer_mt
		)
	end,
	literal_decimal_integer = function(str)
		return setmetatable(
			{type = 'literal_integer', value = tonumber(str)}, 
			literal_integer_mt
		)
	end,
	literal_float = function(str)
		return setmetatable(
			{type = 'literal_float', value = tonumber(str)},
			literal_float_mt
		)
	end,
	ascii_char = function(char)
		return setmetatable(
			{type = 'literal_character', value = string.byte(char) },
			literal_character_mt
		)
	end,
	escaped_char = function(char)
		return setmetatable(
			{type = 'literal_character', value = escaped_char_map[char] },
			literal_character_mt
		)
	end,
})

local debug_session = {}
debug_session.__index = debug_session

function debug_session.new()
	local session = {}
	setmetatable(session, debug_session)
	return session
end

function debug_session:load(filename)
	local file = io.open(filename)
	local content = file:read '*a'
	file:close()

	self.definitions = grammar:match(content)

	if self.definitions then
		table.sort(
			self.definitions,
			function(a, b)
				return a.definition < b.definition
			end
		)
	end

	return self.definitions
end

local function map(list, func)
	local mapped = {}
	for _, elem in ipairs(list) do
		table.insert(mapped, func(elem))
	end
	return mapped
end

function debug_session:dump()
	if self.definitions then
		local lines = map(self.definitions, function(definition) 
			if definition.definition == 'global' then
				local initializer = definition.initializer
				local space = ' '
				if definition.type:find('[*]$') then
					space = ''
				end
				if initializer then
					return ("%s%s%s = %s;"):format(definition.type, space, definition.name, initializer:tostring())
				else
					return ("%s%s%s;"):format(definition.type, space, definition.name)
				end
			end
		end)

		return table.concat(lines, "\n")
 	end
end

return debug_session