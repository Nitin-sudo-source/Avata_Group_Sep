//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_LeadTriggerHandler {
    public static void beforeInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        
        for(Lead__c l: leadList) {
            lList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            Ex_LeadHandlerServices.duplicationCheck('Yes', lList);
    }
    
    public static void afterInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        
        for(Lead__c l: leadList) {
            if(l.Campaign__c != null)
                lList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            Ex_CampaignHandlerServices.calculateCampaignPerformance('Lead', lList, null);   
    }
    
    public static void beforeUpdate(Map<Id, Lead__c> oldMap, Map<Id, Lead__c> newMap) {
        List<Lead__c> lList = new List<Lead__c>();
        
        for(Lead__c oldLead: oldMap.values()) {
            Lead__c newLead = newMap.get(oldLead.Id);
            
            if(oldLead.Mobile__c != newLead.Mobile__c || oldLead.Alternate_Mobile__c != newLead.Alternate_Mobile__c || oldLead.Email__c != newLead.Email__c || oldLead.Alternate_Email__c != newLead.Alternate_Email__c)
            {
                lList.add(newLead);   
            }
                
        }
        if(!lList.isEmpty() && lList != null)
            Ex_LeadHandlerServices.duplicationCheck('No', lList);
    }
    
    public static void afterUpdate(Map<Id, Lead__c> oldMap, Map<Id, Lead__c> newMap) {
        Set<Id> convertedLeadIdSet = new Set<Id>();
        
        /*for(Lead__c oldLead: oldMap.values()) {
            Lead__c newLead = newMap.get(oldLead.Id);
            
            if(oldLead.IsConverted != newLead.IsConverted && newLead.IsConverted) {
                convertedLeadIdSet.add(newLead.Id);
            }
        }
        if(!convertedLeadIds.isEmpty() && convertedLeadIds != null) {
            Ex_LeadHandlerServices.updateOpportunityOwnerIds(convertedLeadIds);
            Ex_LeadHandlerServices.updateLeadConversionDate(convertedLeadIds);
        }*/
    }
}