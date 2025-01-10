//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity__c> oppList) {
        List<Opportunity__c> opList = new List<Opportunity__c>();
        List<Opportunity__c> newOPPTaskUpdateList = new List<Opportunity__c>();
        
        for(Opportunity__c op: oppList) {
            opList.add(op);
            if(op.CP_Lead__c !=null){
                newOPPTaskUpdateList.add(op);
            }
        }
        if(!opList.isEmpty() && opList != null)
            Ex_OpportunityHandlerServices.duplicationCheck(opList);
        if(!newOPPTaskUpdateList.isEmpty() && newOPPTaskUpdateList != null){
            Ex_OpportunityHandlerServices.updateTaskOnOpp(newOPPTaskUpdateList);
        }
    }
    
    public static void afterInsert(List<Opportunity__c> oppLst) {
        Set<Id> updateConvertedCount = new  Set<Id>();
        
        for(Opportunity__c opp: oppLst) {
            if(opp.Campaign__c != null)
                updateConvertedCount.add(opp.Campaign__c);
        }
        if(!updateConvertedCount.isEmpty() && updateConvertedCount != null)
            Ex_CampaignHandlerServices.updateCampaignDetails(updateConvertedCount, 'Opportunity');
    }
    
    public static void beforeUpdate(Map<Id, Opportunity__c> oldMap, Map<Id, Opportunity__c> newMap) {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        
        for(Opportunity__c oldOpp: oldMap.values()) {
            Opportunity__c newOpp = newMap.get(oldOpp.Id);
            
            if(oldOpp.Account__c != newOpp.Account__c || oldOpp.Project__c != newOpp.Project__c)
                oppList.add(newOpp);
        }
        if(!oppList.isEmpty() && oppList != null)
            Ex_OpportunityHandlerServices.duplicationCheck(oppList);
    }
    
    public static void afterUpdate(Map<Id, Opportunity__c> oldMap, Map<Id, Opportunity__c> newMap) {
        Set<Id> svCampaignIdSet = new Set<Id>();
        Set<Id> bookingCampaignIdSet = new Set<Id>();
        Set<Id> convertedCampaignIdSet = new  Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> oppIdSetForSV = new Set<Id>();
        List<Opportunity__c> newOPPTaskUpdateList = new List<Opportunity__c>();
        
        
        for(Opportunity__c oldOpp: oldMap.values()) {
            Opportunity__c newOpp = newMap.get(oldOpp.Id);
            
            if(oldOpp.CP_Lead__c != newOpp.CP_Lead__c && newOpp.CP_Lead__c != null){
                newOPPTaskUpdateList.add(newOpp);
            }
            
            if(oldOpp.Campaign__c != newOpp.Campaign__c) {
                if(newOpp.Campaign__c != null) {
                    if(oldOpp.Campaign__c != null)
                        convertedCampaignIdSet.add(oldOpp.Campaign__c);
                    convertedCampaignIdSet.add(newOpp.Campaign__c);
                }
                if(newOpp.SV_Count__c > 0) {
                    if(oldOpp.Campaign__c != null)
                        svCampaignIdSet.add(oldOpp.Campaign__c);
                    svCampaignIdSet.add(newOpp.Campaign__c);
                }
                if(newOpp.Stage__c != null && newOpp.Stage__c.equalsIgnoreCase('Booked')) {
                    if(oldOpp.Campaign__c != null)
                        bookingCampaignIdSet.add(oldOpp.Campaign__c);
                    bookingCampaignIdSet.add(newOpp.Campaign__c);
                }
            }
            if(oldOpp.SV_Count__c != newOpp.SV_Count__c && newOpp.Campaign__c != null)
                svCampaignIdSet.add(newOpp.Campaign__c);
            
            if(oldOpp.SV_Count__c != newOpp.SV_Count__c)
                oppIdSetForSV.add(newOpp.Id);
            
            if(oldOpp.Stage__c != newOpp.Stage__c && newOpp.Stage__c != null &&  newOpp.Stage__c.equalsIgnoreCase('Booked') && newOpp.Campaign__c != null)
                bookingCampaignIdSet.add(newOpp.Campaign__c);
        }
        if(!convertedCampaignIdSet.isEmpty() && convertedCampaignIdSet != null)
            Ex_CampaignHandlerServices.updateCampaignDetails(convertedCampaignIdSet, 'Opportunity');
        if(!svCampaignIdSet.isEmpty() && svCampaignIdSet != null)
            Ex_CampaignHandlerServices.updateCampaignDetails(svCampaignIdSet, 'Site Visit');
        if(!bookingCampaignIdSet.isEmpty() && bookingCampaignIdSet != null)
            Ex_CampaignHandlerServices.updateCampaignDetails(bookingCampaignIdSet, 'Booking');
        if(!oppIdSetForSV.isEmpty() && oppIdSetForSV != null)
            Ex_SiteVisitHandlerServices.fetchSVDateonOpportunity(oppIdSetForSV);
        if(!newOPPTaskUpdateList.isEmpty() && newOPPTaskUpdateList != null){
            Ex_OpportunityHandlerServices.updateTaskOnOpp(newOPPTaskUpdateList);
        }
        
    }
}