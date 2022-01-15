function toBase2(Int,Fill)
	local BitArray = {}
	while Int > 0 do
		local Rest = Int%2
		table.insert(BitArray,math.floor(Rest))
		Int = (Int-Rest)/2
	end
	local awaitingReturn = table.concat(BitArray)
	return (awaitingReturn..("0"):rep((Fill or 8)-#awaitingReturn))
end
function Uint32_encode(BufferArray)
	local Buffer = {}
	while #BufferArray > 0 do
		local Int = table.remove(BufferArray)
		local Binary = toBase2(Int,32)
		for Index=1,#Binary,8 do
			table.insert(Buffer,string.char(tonumber(Binary:sub(Index,Index+7):reverse(),2)))
		end
	end
	return table.concat(Buffer)
end
function Uint32_decode(Buffer)
	local BufferArray = {}
	for BufferIndex=1,#Buffer,4 do
		local SectorRaw = Buffer:sub(BufferIndex,BufferIndex+3)
		local Sector = {}
		for SectorIndex=1,#SectorRaw do
			table.insert(Sector,toBase2(SectorRaw:sub(SectorIndex,SectorIndex):byte()))
		end
		table.insert(BufferArray,tonumber(table.concat(Sector):reverse(),2))
	end
	return BufferArray
end
function encodeTABLE(_table,extraTypesHandle)
	local keysL,valuesL = {},{}
	local Data = ""
	local size = 0
	for key,_ in next,_table do
		local _type = type(key) == "number" and 1 or 0
		Data = Data..Uint32_encode({#tostring(key)})..string.char(_type)..tostring(key)
		size = size + 1
	end
	Data = Uint32_encode({size})..Data
	for _,value in next,_table do
		local _type = type(value) == "table" and 2 or type(value) == "number" and 1 or 0
		local value = _type == 2 and encodeTABLE(value) or value
		Data = Data..Uint32_encode({#tostring(value)})..string.char(_type)..tostring(value)
	end
	return Data
end
function decodeTABLE(_string)
	local _table = {}
	local keys = {}
	local Data = ""
	local size = Uint32_decode(_string:sub(1,4))[1]
	local _string = _string:sub(5)
	for index=1,size do
		local ksize = Uint32_decode(_string:sub(1,4))[1]
		local _type = _string:sub(5,5):byte()
		local key = _string:sub(6,5+ksize)
		keys[index] = _type == 1 and tonumber(key) or key
		_string = _string:sub(6+ksize)
	end
	for index=1,size do
		local ksize = Uint32_decode(_string:sub(1,4))[1]
		local _type = _string:sub(5,5):byte()
		local value = _string:sub(6,5+ksize)
		_table[keys[index]] = _type == 2 and decodeTABLE(value) or _type == 1 and tonumber(value) or value
		_string = _string:sub(6+ksize)
	end
	return _table
end
return {
	["encode"] = encodeTABLE,
	["decode"] = decodeTABLE
}