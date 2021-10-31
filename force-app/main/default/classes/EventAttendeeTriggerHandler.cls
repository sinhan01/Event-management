public class EventAttendeeTriggerHandler {
    
    public static void sendConfirmationEmail(List<Event_Attendee__c> newRecordList ) {
  
        Set<Id> attendeesIdsSet = new Set<Id>();
        Set<Id> eventIdsSet = new Set<Id>();
        
        for(Event_Attendee__c ea : newRecordList){
            attendeesIdsSet.add(ea.Attendee__c);
            eventIdsSet.add(ea.Event__c);
        }

        map<Id, Attendee__c> attendeeMap = new map<Id, Attendee__c>(
                                            [SELECT ID, Name, Email__c from Attendee__c
                                            where ID in :attendeesIdsSet]
                                          );
    
        map<Id, Event__c> eventMap = new map<Id, Event__c>(
                                    [SELECT id, Start_DateTime__c, Event_Organizer__c, Event_Organizer__r.Name,
                                    Location__c, Location__r.name, Location__r.city__c,Location__r.State__c,
                                    Location__r.Street__c, Location__r.Postal_Code__c, Location__r.Country__c, Name__c
                                    from Event__c where ID in :eventIdsSet]
                                    );
    
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for(Event_Attendee__c ea : newRecordList){
            Attendee__c att = attendeeMap.get(ea.Attendee__c);
            Event__c evt = eventMap.get(ea.Event__c);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Pass for the'+evt.Name__c);
            List<String> toAddress = new List<String>();
            toAddress.add(att.Email__c);
            mail.setToAddresses(toAddress);
            mail.setSenderDisplayName(evt.Event_Organizer__r.Name);
            String loc = 'https://www.google.com/maps/place/'+evt.Location__r.Street__c+' '+evt.Location__r.city__c+ ' '
                         +evt.Location__r.State__c+' '+evt.Location__r.Postal_Code__c; 
                         
            String hrefLoc = '<a href="'+loc+'"'+'target="_blank">Here</a>';
                         
            String emailBody = 'Dear '+att.Name +',<br/>'+
                                'Thank you for registering for '+evt.Name__c+' which will be organized on '+
                                evt.Start_DateTime__c+' & will be held in '+evt.Location__r.name+' We are excited to have you, '+
                                'see you at the event.<br/>'+
                                'Find the google map location for the event.'+hrefLoc+ '<br/>'+
                                

                                'Thanks, <br/>'+
                                evt.Event_Organizer__r.Name;
            mail.setHtmlBody(emailBody);
            emailList.add(mail);                 
        }

        try{
            //Messaging.sendEmail(emailList, false);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList, false); 
            for(Messaging.SendEmailResult email : results){
                if(!email.isSuccess()){
                    List<Messaging.SendEmailError> errors = email.getErrors();
                    TransactionLogHandler.doHandleExceptionWithError(JSON.serialize(errors), 'EventAttendeeTriggerHandler');
                }
            }
        }catch(System.Exception ex){
            TransactionLogHandler.doHandleException(ex, 'EventAttendeeTriggerHandler');
        }
    }
}