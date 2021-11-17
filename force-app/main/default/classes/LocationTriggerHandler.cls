public class LocationTriggerHandler {

    @future(callout=true)
    public static void verifyAddress(String recordId){

        Location__c loc = [select Id, Street__c, City__c, Postal_Code__c, 
                            State__c from Location__c where Id =: recordId];
        

          //https://www.smartystreets.com/products/apis/us-street-api?key=21102174564513388&street=22%20Degroat%20Rd&street2=&city=Sandyston&state=NJ&zipcode=07827&candidates=10&match=invalid&method=get
        
          String baseURL = 'https://www.smartystreets.com/products/apis/us-street-api?key=21102174564513388';
          baseURL = baseURL + '&street='+loc.Street__c+'&city='+loc.City__c+'&state='+loc.State__c+'&zipcode='+loc.Postal_Code__c;
          Http http = new Http();
          HttpRequest Req = new HttpRequest();
          Req.setEndpoint(baseURL);
          Req.setMethod('GET');
          Req.setHeader('Content-Type', 'application/json');
          //HttpResponse Res = new HttpResponse();

          try{
            HttpResponse Res = Http.send(Req);
            if(Res.getStatusCode()==200){
                String responseBody = Res.getBody();

            }else{
                TransactionLogHandler.doHandleExceptionWithError(Res.getBody(), 'LocationTriggerHandler');

            }

          }catch(System.CalloutException ex){
              TransactionLogHandler.doHandleException(ex, 'LocationTriggerHandler');
          }

    }
}
