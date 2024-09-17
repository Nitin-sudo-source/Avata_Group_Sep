// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_LeadConversionPopup {
     @AuraEnabled (cacheable=true)
    public static Map<ID, Lead__c> isChecked(String ID){
        Map<ID, Lead__c> checkMap = new Map<ID, Lead__c>(); 
        for (Lead__c l : [select Id,IsConverted__c FROM Lead__c where id=:ID]){
            if(l.IsConverted__c == true){
                checkMap.put(l.Id,l);
            }   
            else{
                System.debug('error');
            } 
        }
        return checkMap;
    }
    

}