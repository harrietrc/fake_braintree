require 'fake_braintree'

FakeBraintree.activate!(gateway_port: 9876)

trap('INT') do
  puts "Shutting down"
  exit 0
end

loop { sleep 1 }
