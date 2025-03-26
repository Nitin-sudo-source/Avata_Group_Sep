public class Ex_ReceiptAction {
 @AuraEnabled
    public static boolean receiptrecord( String Selectoption , String Remarks, String recordId){
        
        try{
            System.debug('Selectoption: ' +Selectoption);
            System.debug('Remarks: ' +Remarks);
            System.debug('recordId: ' +recordId);
            
            Receipt__c rec = [Select Id, Name, Receipt_Status__c, Remarks__c From Receipt__c where Id =:recordId];
            System.debug('demnd: ' +rec); 
            rec.Receipt_Status__c = Selectoption;
            system.debug('Demand Status: ' +rec.Receipt_Status__c);
            rec.Remarks__c = Remarks;
            system.debug('Remarks: ' +rec.Remarks__c);
            update rec;
            
            if(Selectoption == 'Delete'){
                system.debug('Inside Delete ::::');
                delete rec;
            }
            
            return true;
        }
        catch(Exception e){
            System.debug('An error occurred while saving the records: ' + e.getMessage());
            return false;
        }
    }
    
}