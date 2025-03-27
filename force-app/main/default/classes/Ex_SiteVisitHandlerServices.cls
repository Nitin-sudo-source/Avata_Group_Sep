public class Ex_SiteVisitHandlerServices {
    public static void updateSalesManagerAvailability(Set<Id> uIdSet) {
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        List<Team_Member__c> updateTMList = new List<Team_Member__c>();
        
        tmList = [Select Id, Availability__c, User__c from Team_Member__c 
                  where User__c IN: uIdSet AND Availability__c = false AND Team__r.Team_Type__c = 'Sales Team'];
        
        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Member__c tm: tmList) {
                tm.Availability__c = true;
                updateTMList.add(tm);
            }
        }
        if(!updateTMList.isEmpty() && updateTMList != null)
            update updateTMList;
    }
    
    public static void reAssignmentofSalesManager(Set<Id> oldSMIds) {
        List<Team_Member__c> old_tmList = [SELECT Id, Availability__c, User__c, Assignment_Counter__c, 
                                           Last_Assignment_Milliseconds__c, Last_Assignment_DateTime__c 
                                           FROM Team_Member__c 
                                           WHERE User__c IN :oldSMIds 
                                           AND Availability__c = false 
                                           AND Team__r.Team_Type__c = 'TL Team'];
        
        System.debug('oldtmList .: ' + old_tmList);
        
        List<Team_Member__c> old_updateTMList = new List<Team_Member__c>();
        
        if (!old_tmList.isEmpty() && old_tmList != null) {
            for (Team_Member__c tm : old_tmList) {
                tm.Availability__c = true;
                tm.Assignment_Counter__c--;
                tm.Last_Assignment_Milliseconds__c = 0;
                tm.Last_Assignment_DateTime__c = null;
                old_updateTMList.add(tm);
            }
        }
        
        if (old_updateTMList != null && !old_updateTMList.isEmpty()) {
            update old_updateTMList;
        }
    }
    
    public static void apexSharingWithSourcingManager(Set<Id> svIdSet) {
        List<Site_Visit__Share> sharesvList = new List<Site_Visit__Share>();
        List<Site_Visit__c> svList = new List<Site_Visit__c>();
        svList = [Select Id , Sourcing_Manager__c from Site_Visit__c where Id IN: svIdSet];
        System.debug('svList: '+svList);
        if(!svList.isEmpty() && svList != null){
            for(Site_visit__c sv: svList){
                Site_Visit__Share objShare = new Site_Visit__Share();
                objShare.AccessLevel = 'Edit'; 
                objShare.ParentId = sv.Id; 
                objShare.UserOrGroupId = sv.Sourcing_Manager__c; //The user with whom the SV record is to be shared
                // objShare.RowCause = Schema.Site_Visit__Share.RowCause.Sourcing_Member_Share__c; 
                sharesvList.add(objShare);
            }
        }
        if(!sharesvList.isEmpty() && sharesvList != null){
            try{
                insert sharesvList;
                System.debug('sharesvList: '+sharesvList);
            }Catch(Exception ex){
                System.debug('Error: In ApexSharing '+ex.getMessage());
            }
        }
    }
    public static void removeSharingWithSourcingManager(Set<Id> svIds) {
        List<Site_Visit__Share> sharesvList = new List<Site_Visit__Share>();
        System.debug('svIds: '+svIds);
        List<Site_Visit__Share> sharesToDelete = [SELECT Id FROM Site_Visit__Share WHERE ParentId IN :svIds];
        System.debug('sharesToDelete: '+sharesToDelete);
        if(!sharesToDelete.isEmpty() && sharesToDelete != null){
            try{
                Database.Delete(sharesToDelete, false);
            }Catch(Exception ex){
                System.debug('Error in Delete '+ex.getMessage());
            }
        }
    }
    
    public static void apexSharingWithSalesManager(Set<Id> svIdSet) {
        List<Site_Visit__Share> sharesvList = new List<Site_Visit__Share>();
        List<Opportunity__Share> opportunityShareList = new List<Opportunity__Share>();
        
        List<Site_Visit__c> svList = [SELECT Id, Opportunity__c, Sales_Manager__c 
                                      FROM Site_Visit__c 
                                      WHERE Id IN: svIdSet];
        System.debug('svList: ' + svList);
        
        if (svList != null && !svList.isEmpty()) {
            for (Site_Visit__c sv : svList) {
                if (sv.Sales_Manager__c != null) {
                    // Site Visit share with Sales Manager
                    Site_Visit__Share objShare = new Site_Visit__Share();
                    objShare.AccessLevel = 'Read';
                    objShare.ParentId = sv.Id;
                    objShare.UserOrGroupId = sv.Sales_Manager__c;
                    objShare.RowCause = Schema.Site_Visit__Share.RowCause.Manual;
                    sharesvList.add(objShare);
                }
                
                if (sv.Opportunity__c != null && sv.Sales_Manager__c != null) {
                    // Opportunity share with Sales Manager
                    Opportunity__Share os = new Opportunity__Share();
                    os.ParentId = sv.Opportunity__c;
                    os.UserOrGroupId = sv.Sales_Manager__c;
                    os.AccessLevel = 'Read';
                    os.RowCause = Schema.Opportunity__Share.RowCause.Manual;
                    opportunityShareList.add(os);
                }
            }
        }
        
        // Insert Site Visit Shares
        if (sharesvList != null && !sharesvList.isEmpty()) {
            try {
                insert sharesvList;
                System.debug('sharesvList: ' + sharesvList);
            } catch (Exception ex) {
                System.debug('Error in ApexSharing: ' + ex.getMessage());
            }
        }
        
        if (opportunityShareList != null && !opportunityShareList.isEmpty()) {
            try {
                insert opportunityShareList;
                System.debug('opportunityShareList: ' + opportunityShareList);
            } catch (Exception ex) {
                System.debug('Error in OpportunitySharing: ' + ex.getMessage());
            }
        }
    }
    
}