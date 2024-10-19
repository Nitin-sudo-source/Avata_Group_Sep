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
            if(l.IsConverted__c){
                checkMap.put(l.Id,l);
            }   
            else{
                System.debug('error');
            } 
        }
        return checkMap;
    }
    
    @AuraEnabled (cacheable=true)
    public static Map<ID, CP_Lead__c> isCPLeadChecked(String ID){
        Map<ID, CP_Lead__c> checkMap = new Map<ID, CP_Lead__c>(); 
        for (CP_Lead__c l : [select Id, CP_Lead_Stage__c FROM CP_Lead__c where id=:ID]){
            if(l.CP_Lead_Stage__c != null && l.CP_Lead_Stage__c.equalsIgnoreCase('Visit Done')){
                checkMap.put(l.Id,l);
            }   
            else{
                System.debug('error');
            } 
        }
        return checkMap;
    }
    

}