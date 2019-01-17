#!/usr/bin/ruby
require 'http_event_store'
require 'uuid'
require 'json'

def create_event_store_connection
   client = HttpEventStore::Connection.new do |config|
  # default value is '127.0.0.1'
  config.endpoint = '127.0.0.1'
  # default value is 2113
  config.port = '2113'
  # default value is 20 entries per page
  config.page_size = '20'
   end
   client
end

def generate_uuid()
   uuid = UUID.new.generate 
   uuid
end


stream_name = "order_1"

client = create_event_store_connection
data = {"data" => "order created"}
EventData = Struct.new(:data, :event_type, :uuid)


ed = EventData.new(data, "OrderCreated", generate_uuid)

expected_version = 1
client.append_to_stream(stream_name, ed)

ed = EventData.new(data, "OrderPending", generate_uuid)
client.append_to_stream(stream_name, ed)

uuid = generate_uuid

data = {"data" => "batch 1"}
ed1 = EventData.new(data, "OrderPending-StillValidating", uuid)
data = {"data" => "batch 2"}
ed2 = EventData.new(data, "OrderPending-AmountLarge", uuid)

eds = [ed1,ed2]
client.append_to_stream(stream_name, eds)


p client.read_all_events_forward(stream_name)
start = 0
count = 1
p client.read_events_forward(stream_name, start, count)

hard_delete = false

#client.delete_stream(stream_name, hard_delete)
#p client.read_events_forward(stream_name, start, count)