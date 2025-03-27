// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_SiteVisitTriggerHandler {
    public static void afterInsert(List<Site_Visit__c> svList){
        Set<Id> newSet = new Set<id>();
        Set<Id>SvIds =new Set<Id>();
        for(Site_Visit__c sv: svList) {
            if(sv.Mobile__c != null && sv.Project__c != null){
                newSet.add(sv.Id);
            }
            If(Sv.Id != null)
                SvIds.add(Sv.id);
        }
        List<Site_visit__c> siteVisit = [Select Id , name ,CP_Project__c, Project__c,Opportunity__c, Is_Sales_Manager_Assigned__c,Sales_Manager__c,Site_Visit_Count__c,SM_Assignment_Date__c,
                                         OwnerId
                                         From Site_visit__C Where Id IN: SvIds ];
        Map<Id, List<Site_Visit__c>> svMap = new Map<Id, List<Site_Visit__c>>();
        Set<Id> oppIdSet = new Set<Id>();
        if(siteVisit != null && siteVisit.size()>0){
            for(Site_Visit__c sv: siteVisit) {
                if(!sv.Is_Sales_Manager_Assigned__c && sv.Sales_Manager__c == null && sv.Project__c != null && sv.Opportunity__c != null) {
                    if(!svMap.containsKey(sv.Project__c)) {
                        List<Site_Visit__c> newList = new List<Site_Visit__c>();
                        newList.add(sv);
                        svMap.put(sv.Project__c, newList);
                    } else {
                        svMap.get(sv.Project__c).add(sv);
                    }
                    oppIdSet.add(sv.Opportunity__c);
                } 
            }
        }
        system.debug('oppIdSet //:'+oppIdSet);
        if(!svMap.isEmpty() && svMap != null && !oppIdSet.isEmpty() && oppIdSet != null)
         Ex_SiteVisitHandlerServices.applyRoundRobin(svMap, oppIdSet);
        
    }
     public static void afterUpdate(Map<Id, Site_Visit__c> oldMap, Map<Id, Site_Visit__c> newMap) {
        Map<Id, Set<Id>> projectUserIdMap = new Map<Id, Set<Id>>();
        for(Site_Visit__c oldSV: oldMap.values()) {
            Site_Visit__c newSV = newMap.get(oldSV.Id);
            
            if(oldSV.Comments__c != newSV.Comments__c && newSV.Comments__c != null && !String.isBlank(newSV.Comments__c)  && newSV.Project__c != null){
                if(projectUserIdMap.containsKey(newSV.Project__c)) {
                    projectUserIdMap.get(newSV.Project__c).add(newSV.Sales_Manager__c);
                } else {
                    Set<Id> newIdSet = new Set<Id>();
                    newIdSet.add(newSV.Sales_Manager__c);
                    projectUserIdMap.put(newSV.Project__c, newIdSet);
                }
            }
                   
        }
       if(!projectUserIdMap.isEmpty() && projectUserIdMap != null) {
            Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(projectUserIdMap);
        }  
       
    }

}