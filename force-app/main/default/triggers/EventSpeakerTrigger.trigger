trigger EventSpeakerTrigger on EventSpeakers__c (before insert, before update ) {
 

    Set<Id> speakerIdSet = new Set<Id>();
    Set<Id> eventIdSet = new Set<Id>();

    for(EventSpeakers__c es : trigger.new){
        speakerIdSet.add(es.Speaker__c);
        eventIdSet.add(es.Event__c);
    }

    Map<Id, Datetime> requestedEvents = new Map<Id, Datetime>();
    List<Event__c> relatedEventList = [select Id, Start_DateTime__c from Event__c
                                        where Id IN :eventIdSet];
    
    for(Event__c re : relatedEventList){
        requestedEvents.put(re.id, re.Start_DateTime__c);
    }

    List<EventSpeakers__c> relatedEventSpeakerList = [select Id, Event__c, Speaker__c, 
                                                      Event__r.Start_DateTime__c from EventSpeakers__c 
                                                      where Speaker__c in :speakerIdSet];

    for(EventSpeakers__c es : trigger.new){
        Datetime bookingTime = requestedEvents.get(es.Event__c);

        for(EventSpeakers__c es1 : relatedEventSpeakerList){
            if(es1.Speaker__c == es.Speaker__c && es1.Event__r.Start_DateTime__c == bookingTime){
                // es.Speaker__c.addError('The speaker is already booked at this time');
                es.addError('The speaker is already booked at this time');
            }
        }
    }
}