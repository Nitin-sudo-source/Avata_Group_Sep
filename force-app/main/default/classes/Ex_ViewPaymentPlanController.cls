public class Ex_ViewPaymentPlanController {
    @AuraEnabled
    public static List<Booking__c> getBooking(String recId) {
        System.debug(recId);
        List<Booking__c> BookingList = new List<Booking__c>(); 
        String queryFields = '';
        if(recId != null)
        {
            String[] types = new String[]{'Booking__c'};
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
            System.debug('Got describe information for ' + results.size() + ' sObjects.');
            
            for(Schema.DescribeSobjectResult res : results) {
                System.debug('sObject Label: ' + res.getLabel());
                string sObjectname = res.getName();
                System.debug('Number of fields: ' + res.fields.getMap().size());
                System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
                System.debug('Fields Map:' + res.fields.getMap());
                Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe();
                    String fieldLabel = dfield.getLabel();
                    if(queryFields == null || queryFields == ''){
                        queryFields = dField.getName();
                    }
                    else{
                        queryFields = queryFields + ', ' + dField.getName();
                    }
                }
            }
            
            String query = 'SELECT ' + queryFields + ' FROM Booking__c WHERE Id = \'' + recId + '\' LIMIT 1';
            BookingList = Database.query(query);
            system.debug('BookingList::'+BookingList);
        }
        
        if(!BookingList.isEmpty() && BookingList != null){
            return BookingList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Payment_Milestone__c> getPaymentMilestone(String recId){
        List<Booking__c> BookingList = new List<Booking__c>();    
        List<Payment_Milestone__c> PaymentList = new  List<Payment_Milestone__c>();
        String queryFields = '';
        String queryFields1 = '';
        try {
            if(recId != null){
                BookingList = getBooking(recId);
            }
            if(!BookingList.isEmpty() && BookingList != null){
                String[] types = new String[]{'Payment_Milestone__c'};
                    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
                System.debug('Got describe information for ' + results.size() + ' sObjects.');
                
                for(Schema.DescribeSobjectResult res : results) {
                    System.debug('sObject Label: ' + res.getLabel());
                    string sObjectname = res.getName();
                    System.debug('Number of fields: ' + res.fields.getMap().size());
                    System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
                    System.debug('Fields Map:' + res.fields.getMap());
                    Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
                    for(Schema.SObjectField sfield : fieldMap.Values())
                    {
                        schema.describefieldresult dfield = sfield.getDescribe();
                        String fieldLabel = dfield.getLabel();
                        if(queryFields == null || queryFields == ''){
                            queryFields = dField.getName();
                        }
                        else{
                            queryFields = queryFields + ', ' + dField.getName();
                        }
                    }
                }
                String query = 'Select ' + queryFields  + ' From Payment_Milestone__c WHERE Quotation__c = \''+BookingList[0].Quotation__c+'\'';
                PaymentList = Database.query(query);
                system.debug('PaymentList::'+PaymentList);
            }
            if(!PaymentList.isEmpty() && PaymentList != null){
                return PaymentList;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            system.debug('Exception::'+e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getPaymentScheme(String recId){
        List<Quotation__c> qList = new  List<Quotation__c>();
        String queryFields = '';
        
        try {
            if(recId != null){
                String[] types = new String[]{'Quotation__c'};
                    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
                System.debug('Got describe information for ' + results.size() + ' sObjects.');
                for(Schema.DescribeSobjectResult res : results) {
                    System.debug('sObject Label: ' + res.getLabel());
                    string sObjectname = res.getName();
                    System.debug('Number of fields: ' + res.fields.getMap().size());
                    System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
                    System.debug('Fields Map:' + res.fields.getMap());
                    Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
                    for(Schema.SObjectField sfield : fieldMap.Values())
                    {
                        schema.describefieldresult dfield = sfield.getDescribe();
                        String fieldLabel = dfield.getLabel();
                        if(queryFields == null || queryFields == ''){
                            queryFields = dField.getName();
                        }
                        else{
                            queryFields = queryFields + ', ' + dField.getName();
                        }
                    }
                }
                String query = 'Select ' + queryFields  + ', Payment_Scheme__r.Name From Quotation__c WHERE Booking__c = \''+recId+'\' LIMIT 1';
                qList = Database.query(query);
                system.debug('qList::'+qList);
            }
            
            if(!qList.isEmpty() && qList != null){
                return qList[0].Payment_Scheme__r.Name;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}