class AsciiControlBuffer
  
  BUFSIZE = 4.kilobytes
  
  def initialize(io, bufsize=BUFSIZE)
    io.sync = true
    @io = io
    @data = ''
    @bufsize = bufsize
  end
  
  def empty?
    @data.empty?
  end
  
  def waiting?
    !@io.eof?
  end
  
  def read
    begin
      @data += @io.read_nonblock(@bufsize)
    rescue => e
    end
    puts @data
    !empty?
  end
  
  def to_s
    data = @data
    @data = ''
    data
  end
  
end
