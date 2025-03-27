public class Ex_SiteVisitTriggerHandler {
    public Static void afterInsert(List<Site_Visit__c> svList){
        Set<Id> svIdSet = new Set<Id>();
        Set<Id> salesidIdSet = new Set<Id>();
        
        for(Site_Visit__c sv: svList){
            if(sv.Sourcing_Manager__c != null){
                svIdSet.add(sv.Id);
            } 
            if(sv.Sales_Manager__c != null){
                salesidIdSet.add(sv.Id);
            } 
        }
        if(!svIdSet.isEmpty() && svIdSet != null){
            Ex_SiteVisitHandlerServices.apexSharingWithSourcingManager(svIdSet);   
        }
        if(!salesidIdSet.isEmpty() && salesidIdSet != null){
            Ex_SiteVisitHandlerServices.apexSharingWithSalesManager(salesidIdSet);   
        }    
    }
    
    //To remove the Access of Old Sourcing Manager if Sourcing Manager is changed and Old Sourcing Manager is not null
    public static void beforeUpdate(Map<Id, Site_Visit__c> oldMap, Map<Id, Site_Visit__c> newMap){
        Set<Id> svIds = new Set<Id>();
        Set<Id> SalesIds = new Set<Id>();
        
        for(Site_Visit__c oldSV: oldMap.values()) {
            Site_Visit__c newSV = newMap.get(oldSV.Id);
            iF(oldSV.Sourcing_Manager__c != newSv.Sourcing_Manager__c && oldSV.Sourcing_Manager__c != null){
                svIds.add(oldSV.Id);
            }	
        }
        if(!svIds.isEmpty() && svIds != null){
            Ex_SiteVisitHandlerServices.removeSharingWithSourcingManager(svIds);   
        }
    }
    
    // To give the Access to New Sourcing Manager if Sourcing Manager is changed && update the Avaliablity of Sourcing Manager  
    public static void afterUpdate(Map<Id, Site_Visit__c> oldMap, Map<Id, Site_Visit__c> newMap) {
        Set<Id> updateSalesManagerIds = new Set<Id>(); 
        Set<Id> reAssignedSalesManagerIds = new Set<Id>();
        Set<Id> sourcingManagerShareIds = new Set<Id>();
        Set<Id> ownerChangedSVIds = new Set<Id>();
        Set<Id> newSalesManagerIds = new Set<Id>();
        
        for (Site_Visit__c oldSV : oldMap.values()) {
            Site_Visit__c newSV = newMap.get(oldSV.Id);
            
            // Re-Assignment of Sales TL
            if (oldSV.Re_Assign_Sales_TL__c != null && oldSV.Re_Assign_Sales_TL__c != newSV.Re_Assign_Sales_TL__c && newSV.Re_Assign_Sales_TL__c != null) {
                reAssignedSalesManagerIds.add(oldSV.Re_Assign_Sales_TL__c);
                newSalesManagerIds.add(newSV.Re_Assign_Sales_TL__c);
            }
            
            // Sales Manager update logic
            if (oldSV.Comments__c != newSV.Comments__c && newSV.Comments__c != null) {
                updateSalesManagerIds.add(newSV.Sales_Manager__c);
            }
            
            // Sourcing Manager Sharing Logic
            if ((oldSV.Is_SV_Share__c != newSV.Is_SV_Share__c && newSV.Is_SV_Share__c == true) || (oldSV.Sourcing_Manager__c != newSV.Sourcing_Manager__c && newSV.Sourcing_Manager__c != null)) {
                sourcingManagerShareIds.add(newSV.Id);
            }
            
            // Owner Change Sharing Logic
            if ((oldSV.Is_SV_Share__c != newSV.Is_SV_Share__c && newSV.Is_SV_Share__c == true) || (oldSV.OwnerId != newSV.OwnerId && newSV.OwnerId != null)) {
                ownerChangedSVIds.add(newSV.Id);
            }
        }
        
        if (updateSalesManagerIds != null && !updateSalesManagerIds.isEmpty()) {
            Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(updateSalesManagerIds);
        }
        
        if (sourcingManagerShareIds != null && !sourcingManagerShareIds.isEmpty()) {
            Ex_SiteVisitHandlerServices.apexSharingWithSourcingManager(sourcingManagerShareIds);
        }
        
        if (reAssignedSalesManagerIds != null && !reAssignedSalesManagerIds.isEmpty()) {
            Ex_SiteVisitHandlerServices.reAssignmentofSalesManager(reAssignedSalesManagerIds);
        }
        
        if (ownerChangedSVIds != null && !ownerChangedSVIds.isEmpty()) {
            Ex_SiteVisitHandlerServices.apexSharingWithSalesManager(ownerChangedSVIds);
        }
    }
    
}