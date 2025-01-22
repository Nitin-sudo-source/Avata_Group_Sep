//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 18-10-2023
//-------------------------------------------//
public class Ex_LeadTriggerHandler {
    public static void beforeInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        Map<Id, List<Lead__c>> pLeadMap = new Map<Id, List<Lead__c>>();
        
        for(Lead__c l: leadList) {
            if(l.Mobile__c.length() > 10) {
                l.Mobile__c = l.Mobile__c.substring(l.Mobile__c.length()-10);
            }
            // if(!l.Legacy_Record__c)
            lList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            Ex_LeadHandlerServices.duplicationCheck('Yes',lList);
    }
    
    public static void afterInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        List<Lead__c> cLeadList = new List<Lead__c>();
        Set<Id> newLeadSet = new Set<Id>();
        
        for(Lead__c l: leadList) {
            if(l.Project__c != null)
                newLeadSet.add(l.Id);
            if(l.Campaign__c != null)
                lList.add(l);
        }
        
        if(!lList.isEmpty() && lList != null)
            Ex_CampaignHandlerServices.calculateCampaignPerformance('Lead', leadList, null);
        System.debug('newLeadSet: '+newLeadSet);
        if(!newLeadSet.isEmpty()){
            Ex_GetStartConnectAPIServices.getStartConnectData(newLeadSet);
        }
        
    }
    
    public static void beforeUpdate(Map<Id, Lead__c> oldMap, Map<Id, Lead__c> newMap) {
        List<Lead__c> lList = new List<Lead__c>();
        List<Lead__c> NewList = new List<Lead__c>();
        Set<Id> newLeadSet = new Set<Id>();
        
        for(Lead__c oldLead: oldMap.values()) {
            Lead__c newLead = newMap.get(oldLead.Id);
            if(oldLead.Send_Star_Connect__c != newLead.Send_Star_Connect__c && newLead.Send_Star_Connect__c == true){
                newLeadSet.add(newLead.Id);
            }
            
            if(oldLead.Mobile__c != newLead.Mobile__c || oldLead.Phone__c != newLead.Phone__c || oldLead.Email__c != newLead.Email__c || oldLead.Alternate_Email_Id__c != newLead.Alternate_Email_Id__c || oldLead.Project__c != newLead.Project__c)
                lList.add(newLead);
        }
         if(!newLeadSet.isEmpty()){
            Ex_GetStartConnectAPIServices.getStartConnectData(newLeadSet);
        }
        if(!lList.isEmpty() && lList != null)
            Ex_LeadHandlerServices.duplicationCheck('No',lList);
    }
}