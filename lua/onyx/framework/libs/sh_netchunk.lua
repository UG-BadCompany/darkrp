--[[
MIT License

Copyright (c) 2023 Aleksandrs Filipovskis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

if (netchunk) then return end

netchunk = netchunk or {}
netchunk.chunks = netchunk.chunks or {}
netchunk.registered = netchunk.registered or {}
-- netchunk.maxBytes = 32768
netchunk.maxBytes = 16384

local split do
    local len = string.len
    local sub = string.sub
    local maxBytes = netchunk.maxBytes

    function split(data)
        local length = len(data)
        local index = 1
        local last = 1
        local chunks = {}

        for i = 1, length do
            if (i - last + 1) > maxBytes then
                chunks[index] = sub(data, last, i)
                index = index + 1
                last = i + 1
            end
        end

        chunks[index] = sub(data, last, length)

        return chunks
    end
end

local function merge(chunks)
    local result = ''

    for i = 1, #chunks do
        result = result .. chunks[i]
    end

    return result
end

function netchunk.Register(name)
    if (SERVER) then
        util.AddNetworkString('netchunk[' .. name .. ']:Send')
    end

    netchunk.registered[name] = true
    netchunk.chunks[name] = {}
end

if (SERVER) then
    local function send(ply)
        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end

    function netchunk.Send(ply, name, data)
        assert(netchunk.registered[name], 'Trying to send data during unregistered channel (`' .. name .. '`)')

        local encoded = pon.encode(data)
        local chunks = split(encoded)
        local count = #chunks

        for i = 1, count do
            local chunk = chunks[i]
            local length = #chunk

            net.Start('netchunk[' .. name .. ']:Send')
                net.WriteString(name)
                net.WriteUInt(length, 16)
                net.WriteData(chunks[i], length)
                net.WriteBool(i == count)
            send(ply)
        end
    end
else
    netchunk.callbacks = netchunk.callbacks or {}

    local ReadString = net.ReadString
    local ReadUInt = net.ReadUInt
    local ReadData = net.ReadData
    local ReadBool = net.ReadBool

    function netchunk.Callback(name, callback)
        assert(name)
        assert(callback)

        net.Receive('netchunk[' .. name .. ']:Send', function()
            local name = ReadString()
            local length = ReadUInt(16)
            local chunk = ReadData(length)
            local finished = ReadBool()

            local chunks = netchunk.chunks[name]

            chunks[#chunks + 1] = chunk

            if finished then
                local raw = merge(chunks)
                local amt = #chunks

                netchunk.chunks[name] = {}

                local data = pon.decode(raw)

                callback(data, #raw, amt)
            end
        end)
    end
end