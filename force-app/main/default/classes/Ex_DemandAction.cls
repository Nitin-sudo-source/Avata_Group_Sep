//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_DemandAction {
    @AuraEnabled
    public static boolean demandrecord( String Selectoption , String Remarks, String recordId){
        
        try{
            System.debug('Selectoption: ' +Selectoption);
            System.debug('Remarks: ' +Remarks);
            System.debug('recordId: ' +recordId);
            
            Demand__c demnd = [Select Id, Name, Demand_Status__c, Remarks__c From Demand__c where Id =:recordId];
            System.debug('demnd: ' +demnd);
            demnd.Demand_Status__c = Selectoption;
            system.debug('Demand Status: ' +demnd.Demand_Status__c);
            demnd.Remarks__c = Remarks;
            system.debug('Remarks: ' +demnd.Remarks__c);
            update demnd;
            
            if(Selectoption == 'Delete'){
                system.debug('Inside Delete ::::');
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