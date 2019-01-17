#!/usr/bin/ruby
require 'http_event_store'
require 'uuid'
require 'json'

def create_event_store_connection
   
   client = HttpEventStore::Connection.new do |config|
     config.endpoint = '127.0.0.1'
     config.port = '2113'
     config.page_size = '20'
   end
   
   client
end

def generate_uuid()
   UUID.new.generate 
end


stream_name = "order_1"
EventData = Struct.new(:data, :event_type, :uuid)
client = create_event_store_connection

# Create First Event
data = {"data" => "order created"}
ed = EventData.new(data, "OrderCreated", generate_uuid)
expected_version = 1 # Optimistic lock needs
client.append_to_stream(stream_name, ed)

#Create Second event
ed = EventData.new(data, "OrderPending", generate_uuid)
client.append_to_stream(stream_name, ed)

#Create a batched event using the same UUID.
uuid = generate_uuid
data = {"data" => "batch 1"}
ed1 = EventData.new(data, "OrderPending-StillValidating", uuid)
data = {"data" => "batch 2"}
ed2 = EventData.new(data, "OrderPending-AmountLarge", uuid)
eds = [ed1,ed2]
client.append_to_stream(stream_name, eds)

#Read and display all events forward
p client.read_all_events_forward(stream_name)

#Read and display events from a point
start = 0
count = 1
p client.read_events_forward(stream_name, start, count)

#Deleting a stream. Soft delete(all events are gone but can generate the stream back) and hard delete (returns 401 after this)
hard_delete = false

#client.delete_stream(stream_name, hard_delete)
#p client.read_events_forward(stream_name, start, count)
