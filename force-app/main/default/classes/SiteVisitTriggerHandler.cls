//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class SiteVisitTriggerHandler {
	public static void afterUpdate(Map<Id, Site_Visit__c> oldMap, Map<Id, Site_Visit__c> newMap) {
        Set<Id> uIdSet = new Set<Id>();
        
        for(Site_Visit__c oldSV: oldMap.values()) {
            Site_Visit__c newSV = newMap.get(oldSV.Id);
            
            if(oldSV.Comment__c != newSV.Comment__c && newSV.Comment__c != null)
                uIdSet.add(newSv.Sales_Manager__c);
        }
        if(!uIdSet.isEmpty() && uIdSet != null)
            SiteVisitHandlerServices.updateSalesManagerAvailability(uIdSet);
    }
}