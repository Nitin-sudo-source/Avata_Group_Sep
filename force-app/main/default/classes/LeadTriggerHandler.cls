//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 16-5-2023
//-------------------------------------------//
public class LeadTriggerHandler {
    public static void beforeInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        Map<Id, List<Lead__c>> pLeadMap = new Map<Id, List<Lead__c>>();
        
        for(Lead__c l: leadList) {
            if(!l.Legacy_Record__c)
                lList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            LeadHandlerServices.duplicationCheck(lList);
    }
    
    public static void afterInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        List<Lead__c> cLeadList = new List<Lead__c>();
        
        for(Lead__c l: leadList) {
            if(l.Campaign_Custom__c != null)
                lList.add(l);
            if(l.Campaign_Code__c != null)
                cLeadList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            CampaignHandlerServices.calculateCampaignPerformance('Lead', leadList, null);
        /*if(!cLeadList.isEmpty() && cLeadList != null)
			CampaignHandlerServices.createCampaignMember(cLeadList);*/
    }
    
    public static void beforeUpdate(Map<Id, Lead__c> oldMap, Map<Id, Lead__c> newMap) {
        List<Lead__c> lList = new List<Lead__c>();
        
        for(Lead__c oldLead: oldMap.values()) {
            Lead__c newLead = newMap.get(oldLead.Id);
            
            if(oldLead.Mobile__c != newLead.Mobile__c || oldLead.Phone__c != newLead.Phone__c || oldLead.Email__c != newLead.Email__c || oldLead.Alternate_Email_Id__c != newLead.Alternate_Email_Id__c || oldLead.Project__c != newLead.Project__c)
                lList.add(newLead);
        }
        if(!lList.isEmpty() && lList != null)
            LeadHandlerServices.duplicationCheck(lList);
    }
    
    /*public static void afterUpdate(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        List<Lead> cLeadList = new List<Lead>();
        
		for(Lead oldLead: oldMap.values()) {
            Lead newLead = newMap.get(oldLead.Id);
            
            if(oldLead.Campaign_Code__c != newLead.Campaign_Code__c && newLead.Campaign_Code__c != null)
                cLeadList.add(newLead);
        }
        if(!cLeadList.isEmpty() && cLeadList != null)
            CampaignHandlerServices.createCampaignMember(cLeadList);
    }*/
}