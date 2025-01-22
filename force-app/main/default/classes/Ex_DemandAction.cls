public class Ex_DemandAction {
 
    @AuraEnabled
    public static boolean demandrecord( String Selectoption , String Remarks, String recordId){
        
        try{
            
            Demand__c demnd = [Select Id, Name, Demand_Status__c, Remarks__c From Demand__c where Id =:recordId];
            demnd.Demand_Status__c = Selectoption;
            demnd.Remarks__c = Remarks;
            update demnd;
            
            if(Selectoption == 'Delete'){
                delete demnd;
            }
            
            return true;
        }
        catch(Exception e){
            System.debug('An error occurred while saving the records: ' + e.getMessage());
            return false;
        }
    }
}