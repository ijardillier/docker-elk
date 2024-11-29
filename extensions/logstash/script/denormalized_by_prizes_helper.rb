module LogStash::Util::DenormalizationByPricesHelper
    include LogStash::Util::Loggable

    # Keep original event if asked
    def self.getOriginalEvent(event, keepOriginalEvent)
        logger.debug('keepOriginalEvent is :' + keepOriginalEvent.to_s)
        if keepOriginalEvent.to_s == 'true'
            event.set('[@metadata][_index]', 'prizes-original');
            return event;
        end
        return nil;
    end

    # Get prizes items (to denormalize)
    def self.getPrizes(event)
        prizes = event.get("prize");
        if prizes.nil?
            logger.warn("No prizes for event " + event.to_s)
        end
        return prizes;
    end

    # Create a clone base event
    def self.getEventBase(event)
        eventBase = event.clone();
        eventBase.set('[@metadata][_index]', 'prizes-denormalized');
        eventBase.remove("prize");
        return eventBase;
    end

    # Create a clone event for current prize item with needed modification
    def self.createEventForPrize(eventBase, prize)
        eventPrize = eventBase.clone();
        # Copy each prize item value to prize object
        prize.each { |key,value|
            eventPrize.set("[prize][" + key + "]", value)
        }
        return eventPrize;
    end

end