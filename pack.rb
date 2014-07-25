chunk_size = 8192
require 'bigdecimal'

def pack(chunk)
  big = chunk.unpack("B*").first.to_i(2)
  foo = big ** 2
  foo
end

def unpack(packed)
end

File.open("/backup/enwik8", "rb") do |file|

  chunk = file.read(chunk_size)
  
  packed = pack(chunk)
  
  puts packed
  
  puts 'WIN!' if unpack(packed) == chunk
  
end