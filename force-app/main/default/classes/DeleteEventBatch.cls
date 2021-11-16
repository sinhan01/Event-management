global class DeleteEventBatch implements Database.Batchable<SObject>{

    global Database.QueryLocator Start(Database.BatchableContext batchContext){
        String Query = 'SELECT ID, NAME FROM Event__c WHERE Live__c = TRUE AND End_Date_Time__c < LAST_N_MONTHS:2';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext batchContext, List<Event__c> eventList){
        if(!eventList.isEmpty()){
            List<Database.DeleteResult> deleteResult = Database.delete(eventList);
            for(Database.DeleteResult dr : deleteResult){
                if(!dr.isSuccess()){
                    List<Database.Error> errors = dr.getErrors();
                    String errorinString = String.join(errors, ',');
                    TransactionLogHandler.doHandleExceptionWithError(errorinString, 'DeleteEventBatch');
                }
            }
        }
    }

    global void finish(Database.BatchableContext batchContext){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('DeleteEventBatch Batch Processing---Completed');
        List<String> toAddress = new List<String>();
        toAddress.add('n.sinha1982@gmail.com');
        mail.setToAddresses(toAddress);
        mail.setSenderDisplayName('NikhilSinhaBatchClassDeleteEventBatch');

        mail.setHtmlBody('The DeleteEventBatch Batch Processing Is Completed');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail}); 
        
    }
}
