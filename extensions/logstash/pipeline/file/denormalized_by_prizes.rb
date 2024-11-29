require './script/denormalized_by_prizes_utils.rb'
#require_relative '../../script/denormalized_by_prizes_utils.rb'

# The value of `params` is the value of the hash passed to `script_params` in the logstash configuration.
def register(params)
    @keep_original_event = params["keep_original_event"]
end

# The filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array.
# Creating new ones only requires you to add a new instance of LogStash::Event to the returned array.
def filter(event)

    items = Array.new

    # Keep original event if asked
    originalEvent = getOriginalEvent(event);
    if not originalEvent.nil?
        items.push originalEvent
    end

    # Get prizes items (to denormalize)
    prizes = getPrizes(event);
    if prizes.nil?
        return items
    end
   
    # Create a clone base event
    eventBase = getEventBase(event);

    # Create one event by prize item with needed modification
    prizes.each { |prize| 
        items.push createEventForPrize(eventBase, prize);
    }

    return items;
end

# test "Case 1: one prize in event / don't keep original event" do

#     parameters do
#     { 
#         "keep_original_event" => false
#     }
#     end

#     in_event { 
#         { 
#             "id"        => 1, 
#             "firstname" => "Pierre", 
#             "surname"   => "Curie",
#             "gender"    => "male",
#             "prize"     => [
#                 {
#                     "year" => 1903,
#                     "category" => "physics"
#                 }
#             ]
#         } 
#     }

#     expect("Count of events") do |events|
#         events.length == 1
#     end

#     expect("Each event has same shared fields") do |events|
#         result = true
#         events.each { |event|
#             result &= event.get("[id]") == 1
#             result &= event.get("[firstname]") == "Pierre"
#             result &= event.get("[surname]") == "Curie"
#             result &= event.get("[gender]") == "male"
#         }
#         result
#     end

#     expect("Each event has good _index") do |events|  
#         events[0].get("[@metadata][_index]") == "prizes-denormalized"
#     end

#     expect("Each event has good prize fields") do |events|  
#         result = true
#         result &= events[0].get("[prize][year]") == 1903
#         result &= events[0].get("[prize][category]") == "physics"
#         result
#     end

# end

# test "Case 2: one prize in event / keep original event" do

#     parameters do
#     { 
#         "keep_original_event" => true
#     }
#     end

#     in_event { 
#         { 
#             "id"        => 1, 
#             "firstname" => "Pierre", 
#             "surname"   => "Curie",
#             "gender"    => "male",
#             "prize"     => [
#                 {
#                     "year" => 1903,
#                     "category" => "physics"
#                 }
#             ]
#         } 
#     }

#     expect("Count of events") do |events|
#         events.length == 2
#     end

#     expect("Each event has same shared fields") do |events|
#         result = true
#         events.each { |event|
#             result &= event.get("[id]") == 1
#             result &= event.get("[firstname]") == "Pierre"
#             result &= event.get("[surname]") == "Curie"
#             result &= event.get("[gender]") == "male"
#         }
#         result
#     end

#     expect("Each event has good _index") do |events|  
#         result = true
#         result &= events[0].get("[@metadata][_index]") == "prizes-original"
#         result &= events[1].get("[@metadata][_index]") == "prizes-denormalized"
#         result
#     end

#     expect("Each event has good prize fields") do |events|  
#         result = true
#         result &= events[0].get("[prize][0][year]") == 1903
#         result &= events[0].get("[prize][0][category]") == "physics"
#         result &= events[1].get("[prize][year]") == 1903
#         result &= events[1].get("[prize][category]") == "physics"
#         result
#     end

# end

# test "Case 3: two prizes in event / don't keep original event" do

#     parameters do
#     { 
#         "keep_original_event" => false
#     }
#     end

#     in_event { 
#         { 
#             "id"        => 2, 
#             "firstname" => "Marie", 
#             "surname"   => "Curie",
#             "gender"    => "female",
#             "prize"     => [
#                 {
#                     "year" => 1903,
#                     "category" => "physics"
#                 },
#                 {
#                     "year" => 1911,
#                     "category" => "chemistry"
#                 }
#             ]
#         } 
#     }

#     expect("Count of events") do |events|
#         events.length == 2
#     end

#     expect("Each event has same shared fields") do |events|
#         result = true
#         events.each { |event|
#             result &= event.get("[id]") == 2
#             result &= event.get("[firstname]") == "Marie"
#             result &= event.get("[surname]") == "Curie"
#             result &= event.get("[gender]") == "female"
#         }
#         result
#     end

#     expect("Each event has good _index") do |events|  
#         result = true
#         result &= events[0].get("[@metadata][_index]") == "prizes-denormalized"
#         result &= events[1].get("[@metadata][_index]") == "prizes-denormalized"
#         result
#     end

#     expect("Each event has good prize fields") do |events| 
#         result = true 
#         result &= events[0].get("[prize][year]") == 1903
#         result &= events[0].get("[prize][category]") == "physics"
#         result &= events[1].get("[prize][year]") == 1911
#         result &= events[1].get("[prize][category]") == "chemistry"
#         result
#     end

# end

# test "Case 4: two prizes in event / keep original event" do

#     parameters do
#     { 
#         "keep_original_event" => true
#     }
#     end

#     in_event { 
#         { 
#             "id"        => 2, 
#             "firstname" => "Marie", 
#             "surname"   => "Curie",
#             "gender"    => "female",
#             "prize"     => [
#                 {
#                     "year" => 1903,
#                     "category" => "physics"
#                 },
#                 {
#                     "year" => 1911,
#                     "category" => "chemistry"
#                 }
#             ]
#         } 
#     }

#     expect("Count of events") do |events|
#         events.length == 3
#     end

#     expect("Each event has same shared fields") do |events|
#         result = true
#         events.each { |event|
#             result &= event.get("[id]") == 2
#             result &= event.get("[firstname]") == "Marie"
#             result &= event.get("[surname]") == "Curie"
#             result &= event.get("[gender]") == "female"
#         }
#         result
#     end

#     expect("Each event has good _index") do |events|  
#         result = true
#         result &= events[0].get("[@metadata][_index]") == "prizes-original"
#         result &= events[1].get("[@metadata][_index]") == "prizes-denormalized"
#         result &= events[2].get("[@metadata][_index]") == "prizes-denormalized"
#         result
#     end

#     expect("Each event has good prize fields") do |events| 
#         result = true 
#         result &= events[0].get("[prize][0][year]") == 1903
#         result &= events[0].get("[prize][0][category]") == "physics"
#         result &= events[0].get("[prize][1][year]") == 1911
#         result &= events[0].get("[prize][1][category]") == "chemistry"
#         result &= events[1].get("[prize][year]") == 1903
#         result &= events[1].get("[prize][category]") == "physics"
#         result &= events[2].get("[prize][year]") == 1911
#         result &= events[2].get("[prize][category]") == "chemistry"
#         result
#     end

# end