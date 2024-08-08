extends Node

const ASCII_ZERO = 0x30
const ASCII_CAPITAL_A = 0x41
const ASCII_LOWER_A = 0x61

## Encode a single 6-bit value as an ASCII character
func b64_encode_byte(data: int) -> String:
	assert(data < 64)
	if data < 10:
		return char(ASCII_ZERO + data)
	elif data < 36:
		return char(ASCII_CAPITAL_A + data - 10)
	elif data < 62:
		return char(ASCII_LOWER_A + data - 36)
	elif data == 62:
		return "="
	elif data == 63:
		return "+"
	else:
		push_error("Invalid base 64 number passed to b64_encode_byte")
		return ""


func b64_decode_byte(data: String) -> int:
	assert(len(data) == 1)
	if data in "0123456789":
		return data.unicode_at(0) - ASCII_ZERO
	elif data in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		return data.unicode_at(0) - ASCII_CAPITAL_A + 10
	elif data in "abcdefghijklmnopqrstuvwxyz":
		return data.unicode_at(0) - ASCII_LOWER_A + 36
	elif data == "=":
		return 62
	elif data == "+":
		return 63
	else:
		push_error("Invalid base 64 character passed to b64_decode_byte")
		return -1


## Express a PackedByteArray as a base 64 string.
## The data passed in must be a multiple of 3 bytes long.
func b64_encode(data: PackedByteArray) -> String:
	assert(len(data) % 3 == 0)
	var output := ""
	for index in range(0, data.size(), 3):
		output += b64_encode_byte((data[index] >> 2) & 0x3F)
		output += b64_encode_byte(((data[index] << 4) & 0x30) | ((data[index + 1] >> 4) & 0x0F))
		output += b64_encode_byte(((data[index + 1] << 2) & 0x3C) | ((data[index + 2] >> 6) & 0x03))
		output += b64_encode_byte(data[index + 2] & 0x3F)

	return output


## Decode a base 64 string into a PackedByteArray.
## The length of the string passed in must be a multiple of 4.
func b64_decode(data: String) -> PackedByteArray:
	assert(len(data) % 4 == 0)
	var output := PackedByteArray()
	for index in range(0, len(data), 4):
		var ints := []
		for character in data.substr(index, 4):
			ints.push_back(b64_decode_byte(character))

		output.push_back(((ints[0] << 2) & 0xFC) | ((ints[1] >> 4) & 0x03))
		output.push_back(((ints[1] << 4) & 0xF0) | ((ints[2] >> 2) & 0x0F))
		output.push_back(((ints[2] << 6) & 0xC0) | (ints[3] & 0x3F))

	return output


func test() -> void:
	for character in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz=+":
		assert(character == b64_encode_byte(b64_decode_byte(character)))
