//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 27-10-2023
//-------------------------------------------//
public class Ex_OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity__c> opportunityList) {
        Ex_OpportunityHandlerServices.duplicationCheck(opportunityList);
    }
    
    public static void beforeUpdate(Map<Id, Opportunity__c> oldMap, Map<Id, Opportunity__c> newMap) {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        Map<Id, Id> OppSourcingMap = new Map<Id, Id>();
        
        for(Opportunity__c oldOpp: oldMap.values()) {
            Opportunity__c newOpp = newMap.get(oldOpp.Id);
            
            if(oldOpp.Project__c != newOpp.Project__c || oldOpp.Account__c != newOpp.Account__c || oldOpp.Opportunity_Stage__c != newOpp.Opportunity_Stage__c)
                oppList.add(newOpp);
            
            if(oldOpp.Sourcing_Manager__c != newOpp.Sourcing_Manager__c && oldOpp.Sourcing_Manager__c != null) {
                if(OppSourcingMap.containsKey(newOpp.Id)) {
                    OppSourcingMap.get(newOpp.Id);
                } else {
                    OppSourcingMap.put(newOpp.Id, oldOpp.Sourcing_Manager__c);
                }
            }
        }
        if(!OppSourcingMap.isEmpty() && OppSourcingMap != null)
            Ex_OpportunityHandlerServices.removeSharingWithSourcingManager(OppSourcingMap);
        if(!oppList.isEmpty() && oppList != null)
            Ex_OpportunityHandlerServices.duplicationCheck(oppList);
    }
     public static void afterInsert(List<Opportunity__c> oppLst) {
        Set<Id> updateConvertedCount = new  Set<Id>();
        for(Opportunity__c opp: oppLst) {
            if(opp.Campaign__c != null){
                updateConvertedCount.add(opp.Campaign__c);
            }
            if(!updateConvertedCount.isEmpty() && updateConvertedCount != null){
                Ex_CampaignHandlerServices.updateCampaignDetails(updateConvertedCount, 'Opportunity');
            }
        }
     }
    
	public static void afterUpdate(Map<Id, Opportunity__c> oldMap, Map<Id, Opportunity__c> newMap) {
        Set<Id> svCampaignIdSet = new Set<Id>();
        Set<Id> bookingCampaignIdSet = new Set<Id>();
        Set<Id> updateConvertedCount = new  Set<Id>();
        Map<Id, List<Opportunity__c>> OppSourcingMap = new Map<Id, List<Opportunity__c>>();
        Map<Id, List<Opportunity__c>> OppSourcingMapShare = new Map<Id, List<Opportunity__c>>();
        
        
        for(Opportunity__c oldOpp: oldMap.values()) {
            Opportunity__c newOpp = newMap.get(oldOpp.Id);
            
            if(oldOpp.Campaign__c != newOpp.Campaign__c) {
                
                if(newOpp.Site_Visit_Count__c > 0) {
                    svCampaignIdSet.add(newOpp.Campaign__c);
                    svCampaignIdSet.add(oldOpp.Campaign__c);
                }
                if(newOpp.Opportunity_Stage__c != null) {
                    bookingCampaignIdSet.add(newOpp.Campaign__c);
                    bookingCampaignIdSet.add(oldOpp.Campaign__c);
                }
            }
            if(oldOpp.Is_Opp_Share__c != newOpp.Is_Opp_Share__c && newOpp.Is_Opp_Share__c){
                if(OppSourcingMapShare.containsKey(newOpp.Sourcing_Manager__c)) {
                    OppSourcingMapShare.get(newOpp.Sourcing_Manager__c).add(newOpp);
                } else {
                    List<Opportunity__c> newList = new List<Opportunity__c>();
                    newList.add(newOpp);
                    OppSourcingMapShare.put(newOpp.Sourcing_Manager__c, newList);
                }
            }
            
            if(oldOpp.Sourcing_Manager__c != newOpp.Sourcing_Manager__c && newOpp.Sourcing_Manager__c != null){
                if(OppSourcingMap.containsKey(newOpp.Sourcing_Manager__c)) {
                    OppSourcingMap.get(newOpp.Sourcing_Manager__c).add(newOpp);
                } else {
                    List<Opportunity__c> newList = new List<Opportunity__c>();
                    newList.add(newOpp);
                    OppSourcingMap.put(newOpp.Sourcing_Manager__c, newList);
                }
            }
                
            if(oldOpp.Site_Visit_Count__c != newOpp.Site_Visit_Count__c && newOpp.Campaign__c != null)
                svCampaignIdSet.add(newOpp.Campaign__c);
            if(oldOpp.Opportunity_Stage__c != newOpp.Opportunity_Stage__c && newOpp.Campaign__c != null)
                bookingCampaignIdSet.add(newOpp.Campaign__c);
            if(oldOpp.Campaign__c != newOpp.Campaign__c && newOpp.Campaign__c != null)
                updateConvertedCount.add(newOpp.Campaign__c);
                
        }
        if(!OppSourcingMap.isEmpty() && OppSourcingMap != null){
            Ex_OpportunityHandlerServices.shareSiteVisitWithSourcingManager(OppSourcingMap);   
        }
         if(!OppSourcingMapShare.isEmpty() && OppSourcingMapShare != null){
            Ex_OpportunityHandlerServices.shareSiteVisitWithSourcingManager(OppSourcingMapShare);   
        }
        
        if(!svCampaignIdSet.isEmpty() && svCampaignIdSet != null)
            Ex_CampaignHandlerServices.updateCampaignDetails(svCampaignIdSet, 'Site Visit');
        if(!updateConvertedCount.isEmpty() && updateConvertedCount != null)
            Ex_CampaignHandlerServices.updateCampaignDetails(updateConvertedCount, 'Opportunity');
      //  if(!bookingCampaignIdSet.isEmpty() && bookingCampaignIdSet != null)
       //     Ex_CampaignHandlerServices.updateBookingonCampaign(bookingCampaignIdSet, 'Opportunity');
    }

}