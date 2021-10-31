public class TransactionLogHandler {
    
    public static void doHandleException(system.Exception ex, String processName){

        Error_Log__c transactionLog = new Error_Log__c(
            Log_Details__c = ex.getStackTraceString() + '<br/>' + ex.getMessage()
                            + '<br/>' + ex.getTypeName() + '<br/>' + ex.getCause()
                            + '<br/>' + ex.getLineNumber(),
            Lod_DateTime__c = System.now(),
            Process_Name__c = processName
            );

            insert transactionLog;
    }
    public static void doHandleExceptionWithError(String errors, String processName){

        Error_Log__c transactionLog = new Error_Log__c(
            Log_Details__c = errors,
            Lod_DateTime__c = System.now(),
            Process_Name__c = processName
            );

            insert transactionLog;
    }    
}
