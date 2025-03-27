public class Ex_OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity__c> opportunityList) {
        Ex_OpportunityHandlerServices.duplicationCheck(opportunityList);
    }
    
    public static void afterInsert(List<Opportunity__c> oppLst) {
        Set<Id> convertedCampaignIdSet = new  Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> CP_Project_Ids = new Set<Id>();
        
        for(Opportunity__c opp: oppLst) {
            
            if(opp.Sourcing_Manager__c != null){
                oppIdSet.add(opp.Id);
            }
            if(opp.CP_Project__c != null){
                CP_Project_Ids.add(opp.CP_Project__c);
            }
        }
        if(!oppIdSet.isEmpty() && oppIdSet != null)
            Ex_OpportunityHandlerServices.apexSharingWithSourcingManager(oppIdSet);
        
        if(!CP_Project_Ids.isEmpty() && CP_Project_Ids != null){
            System.debug('CP_Project_Ids');
            Ex_OpportunityHandlerServices.calulateNoofOpporunity(CP_Project_Ids,'Opportunity');
        }
    }
    
    public static void beforeUpdate(Map<Id, Opportunity__c> oldMap, Map<Id, Opportunity__c> newMap) {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        Map<Id, Id> oppsalesManager = new Map<Id, Id>();
        Set<Id> oppIds = new Set<Id>();
        
        for(Opportunity__c oldOpp: oldMap.values()) {
            Opportunity__c newOpp = newMap.get(oldOpp.Id);
            
            if(oldOpp.Project__c != newOpp.Project__c || oldOpp.Account__c != newOpp.Account__c){
                oppList.add(newOpp);
            }
            if(oldOpp.Sourcing_Manager__c != newOpp.Sourcing_Manager__c && oldOpp.Sourcing_Manager__c != null){
                oppIds.add(oldOpp.Id);
            }
            if(oldOpp.Presales_Manager__c != newOpp.Presales_Manager__c && oldOpp.Presales_Manager__c != null){
                oppsalesManager.put(oldOpp.Id, oldOpp.Presales_Manager__c);
            }
        }
        if(!oppList.isEmpty() && oppList != null){
            Ex_OpportunityHandlerServices.duplicationCheck(oppList);
        }
        if(!oppIds.isEmpty() && oppIds != null){
            Ex_OpportunityHandlerServices.removeSharingWithSourcingManager(oppIds);
        }
        if(!oppsalesManager.isEmpty() && oppsalesManager != null){
            Ex_OpportunityHandlerServices.removeSharingWithSalesManager(oppsalesManager);   
        }
    }
    
    public static void afterUpdate(Map<Id, Opportunity__c> oldMap, Map<Id, Opportunity__c> newMap) {
        Set<Id> salesManagerIdSet = new Set<Id>();
        Set<Id> svCampaignIdSet = new Set<Id>();
        Set<Id> bookingCampaignIdSet = new Set<Id>();
        Set<Id> convertedCampaignIdSet = new  Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> CP_Project_Ids = new Set<Id>();
        
        for(Opportunity__c oldOpp: oldMap.values()) {
            Opportunity__c newOpp = newMap.get(oldOpp.Id);
            if((oldOpp.Is_Opp_Share__c != newOpp.Is_Opp_Share__c && newOpp.Is_Opp_Share__c == true) || oldOpp.Sourcing_Manager__c != newOpp.Sourcing_Manager__c && newOpp.Sourcing_Manager__c != null){
                oppIdSet.add(newOpp.Id);
            }
            if((oldOpp.Closing_Manager__c != newOpp.Closing_Manager__c && newOpp.Closing_Manager__c != null) 
               || (oldOpp.OwnerId != newOpp.OwnerId && newOpp.OwnerId != null)
               || (oldOpp.Is_Opp_Share__c != newOpp.Is_Opp_Share__c && newOpp.Is_Opp_Share__c == true)){
                   salesManagerIdSet.add(newOpp.Id);
               }
            if(newOpp.CP_Project__c != null && oldOpp.CP_Project__c != newOpp.CP_Project__c){
                CP_Project_Ids.add(newOpp.CP_Project__c);
            }
        }
        
        if(!salesManagerIdSet.isEmpty() && salesManagerIdSet != null){
            Ex_OpportunityHandlerServices.apexSharingWithSalesManager(salesManagerIdSet);
        }
        if(!oppIdSet.isEmpty() && oppIdSet != null){
            Ex_OpportunityHandlerServices.apexSharingWithSourcingManager(oppIdSet);
        }
        if(!CP_Project_Ids.isEmpty() && CP_Project_Ids != null){
            Ex_OpportunityHandlerServices.calulateNoofOpporunity(CP_Project_Ids,'Opportunity');
        }
    }
}