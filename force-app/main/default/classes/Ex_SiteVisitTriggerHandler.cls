public class Ex_SiteVisitTriggerHandler {
    public static void beforeInsert(List<Site_Visit__c> svList) {
        Map<Id, List<Site_Visit__c>> svMap = new Map<Id, List<Site_Visit__c>>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Site_Visit__c sv: svList) {
            if(!sv.Is_Sales_Manager_Assigned__c && sv.Sales_Manager__c == null && sv.Project_Name__c != null && sv.Opportunity__c != null) {
                if(!svMap.containsKey(sv.Project_Name__c)) {
                    List<Site_Visit__c> newList = new List<Site_Visit__c>();
                    newList.add(sv);
                    svMap.put(sv.Project_Name__c, newList);
                } else {
                    svMap.get(sv.Project_Name__c).add(sv);
                }
                oppIdSet.add(sv.Opportunity__c);
            }
        }
       // if(!svMap.isEmpty() && svMap != null && !oppIdSet.isEmpty() && oppIdSet != null)
           // Ex_SiteVisitHandlerServices.applyRoundRobin(svMap, oppIdSet, 'Before');
    }
    
    public static void afterInsert(List<Site_Visit__c> svList) {
        Set<Id> cpAccountIdSet = new Set<Id>();
        Set<Id> cpSubAccountIdSet = new Set<Id>();
        Set<Id> childCampaignIdSet = new Set<Id>();
        Map<Id, List<Site_Visit__c>> SiteVisitSourcingMap = new Map<Id, List<Site_Visit__c>>();
        
        for(Site_Visit__c sv: svList) {
            if(sv.CP_Project__c != null) {
                cpAccountIdSet.add(sv.CP_Project__c);
            }
            if(sv.Sourcing_Manager__c != null) {
                if(SiteVisitSourcingMap.containsKey(sv.Sourcing_Manager__c)) {
                    SiteVisitSourcingMap.get(sv.Sourcing_Manager__c).add(sv);
                } else {
                    List<Site_Visit__c> newList = new List<Site_Visit__c>();
                    newList.add(sv);
                    SiteVisitSourcingMap.put(sv.Sourcing_Manager__c, newList);
                }
            }
        }
        if(!cpAccountIdSet.isEmpty() && cpAccountIdSet != null){
            Ex_SiteVisitHandlerServices.updateSiteVisitDetailsOnCPProject(cpAccountIdSet);
        }
        System.debug('SiteVisitSourcingMapAfterInsert: '+SiteVisitSourcingMap);
        if(!SiteVisitSourcingMap.isEmpty() && SiteVisitSourcingMap != null){
            Ex_SiteVisitHandlerServices.shareSiteVisitWithSourcingManager(SiteVisitSourcingMap);   
        }
        /*if(!SiteVisitSourcingMap.isEmpty() && SiteVisitSourcingMap != null){
            Ex_OpportunityHandlerServices.shareSiteVisitWithSourcingManager(SiteVisitSourcingMap);   
        }*/
        
        
    }
    
    public static void beforeUpdate(Map<Id, Site_Visit__c> oldmap, Map<Id, Site_Visit__c> newMap) {
        Map<Id, Id> SiteVisitSourcingMap = new Map<Id, Id>();
        Map<Id, List<Site_Visit__c>> SiteVisitSourcingMapShare = new Map<Id, List<Site_Visit__c>>();
        
        for(Site_Visit__c oldSiteVisit: oldMap.values()) {
            Site_Visit__c newSiteVisit = newMap.get(oldSiteVisit.Id);
            
            if(oldSiteVisit.Is_Share__c != newSiteVisit.Is_Share__c && newSiteVisit.Is_Share__c){
                if(newSiteVisit.Sourcing_Manager__c != null) {
                    if(SiteVisitSourcingMapShare.containsKey(newSiteVisit.Sourcing_Manager__c)) {
                        SiteVisitSourcingMapShare.get(newSiteVisit.Sourcing_Manager__c).add(newSiteVisit);
                    } else {
                        List<Site_Visit__c> newList = new List<Site_Visit__c>();
                        newList.add(newSiteVisit);
                        SiteVisitSourcingMapShare.put(newSiteVisit.Sourcing_Manager__c, newList);
                    }
                }
            }
            
            if(oldSiteVisit.Sourcing_Manager__c != newSiteVisit.Sourcing_Manager__c && oldSiteVisit.Sourcing_Manager__c != null) {
                if(SiteVisitSourcingMap.containsKey(newSiteVisit.Id)) {
                    SiteVisitSourcingMap.get(newSiteVisit.Id);
                } else {
                    SiteVisitSourcingMap.put(newSiteVisit.Id, oldSiteVisit.Sourcing_Manager__c);
                }
            }
            
        }
        System.debug('is Share: '+SiteVisitSourcingMapShare);
        if(!SiteVisitSourcingMapShare.isEmpty() && SiteVisitSourcingMapShare != null){
            Ex_SiteVisitHandlerServices.shareSiteVisitWithSourcingManager(SiteVisitSourcingMapShare);   
        }
        System.debug('is remove: '+SiteVisitSourcingMap);
        if(!SiteVisitSourcingMap.isEmpty() && SiteVisitSourcingMap != null)
            Ex_SiteVisitHandlerServices.removeSharingWithSourcingManager(SiteVisitSourcingMap);
       
    }
    
    
    public static void afterUpdate(Map<Id, Site_Visit__c> oldMap, Map<Id, Site_Visit__c> newMap) {
        Map<Id, Set<Id>> projectUserIdMap = new Map<Id, Set<Id>>();
        Set<Id> uIdSet = new Set<Id>();
        Set<Id> cpAccountIdSet = new Set<Id>();
        Map<Id, List<Site_Visit__c>> SiteVisitSourcingMap = new Map<Id, List<Site_Visit__c>>();
      
        List<Site_Visit__c> newSVList = new List<Site_Visit__c>();
        for(Site_Visit__c oldSV: oldMap.values()) {
            Site_Visit__c newSV = newMap.get(oldSV.Id);
            
            if(oldSV.Comment__c != newSV.Comment__c && newSV.Comment__c != null && newSV.Sales_Manager__c != null) {
                newSVList.add(newSV);
                uIdSet.add(newSv.Sales_Manager__c);
            }
            if(oldSV.CP_Project__c != newSV.CP_Project__c && newSV.CP_Project__c != null) {
                cpAccountIdSet.add(newSV.CP_Project__c);
            }
            
            if(oldSV.Sourcing_Manager__c != newSV.Sourcing_Manager__c && newSV.Sourcing_Manager__c != null) {
                if(newSV.Sourcing_Manager__c != null) {
                    if(SiteVisitSourcingMap.containsKey(newSV.Sourcing_Manager__c)) {
                        SiteVisitSourcingMap.get(newSV.Sourcing_Manager__c).add(newSV);
                    } else {
                        List<Site_Visit__c> newList = new List<Site_Visit__c>();
                        newList.add(newSV);
                        SiteVisitSourcingMap.put(newSV.Sourcing_Manager__c, newList);
                    }
                }
            }
        }
        if(!cpAccountIdSet.isEmpty() && cpAccountIdSet != null){
            Ex_SiteVisitHandlerServices.updateSiteVisitDetailsOnCPProject(cpAccountIdSet);
        }
        if(!SiteVisitSourcingMap.isEmpty() && SiteVisitSourcingMap != null){
            Ex_SiteVisitHandlerServices.shareSiteVisitWithSourcingManager(SiteVisitSourcingMap);   
        }
        if(!uIdSet.isEmpty() && uIdSet != null){
            Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(uIdSet);   
        }
        if(!newSVList.isEmpty() && newSVList != null){
            Ex_SiteVisitHandlerServices.rollupOnOpportunity(newSVList[0]);   
        }
       /* if(!projectUserIdMap.isEmpty() && projectUserIdMap != null) {
            Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(projectUserIdMap);
        }*/
    } 
    
    
   /* public static void updateCPOnOppo(List<Site_Visit__c> svList){
        if(svList[0].Channel_Partner__c != null){
            Opportunity__c opp = [Select Id,Channel_Partner__c,Sourcing_Manager__c,CP_Project__c from Opportunity__c where Id=:svList[0].Opportunity__c];
            system.debug('opp is::'+opp);
            opp.Channel_Partner__c = svList[0].Channel_Partner__c;
            opp.CP_Project__c = svList[0].CP_Project__c;
            opp.Sourcing_Manager__c =  svList[0].Sourcing_Manager__c;
            update opp;   
        }
    }*/
}