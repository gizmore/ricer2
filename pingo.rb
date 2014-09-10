result = `ping 192.168.2.107 -c 2 -s 4096`
puts result
sleep 5
#exit

1024.times do
  Thread.new do |t|
    puts "START"
    puts `ping 192.168.2.107 -c 50 -s 4096`
    puts "END"
  end
end

loop do 
  sleep 10
end
