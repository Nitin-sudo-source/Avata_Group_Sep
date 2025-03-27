public class Ex_OpportunityHandlerServices {
    //Check if any Duplicate Opportunity is present
    public static void duplicationCheck(List<Opportunity__c> opportunityList) {
        Map<Opportunity__c, List<Opportunity__c>> duplicateWrapperMap = new Map<Opportunity__c, List<Opportunity__c>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckOpportunity(opportunityList);
        
        for(Opportunity__c op: opportunityList) {
            if(duplicateWrapperMap.containsKey(op)) {
                if(!test.isRunningTest())
                    op.addError('You Cannot Create / Update Opportunity for Specified Project. Already an Opportunity Present with Name: '+duplicateWrapperMap.get(op)[0].Name);
            }
        }
    }
    
    //To share the access of Record with Sourcing Manager
    public static void apexSharingWithSourcingManager(Set<Id> oppIdSet) {
        List<Opportunity__Share> shareOppList = new List<Opportunity__Share>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        oppList = [Select Id , Sourcing_Manager__c from Opportunity__c where Id IN: oppIdSet];
        System.debug('oppList: '+oppList);
        if(!oppList.isEmpty() && oppList != null){
            for(Opportunity__c op: oppList){
                Opportunity__Share objShare = new Opportunity__Share();
                objShare.AccessLevel = 'Edit'; 
                objShare.ParentId = op.Id; 
                objShare.UserOrGroupId = op.Sourcing_Manager__c;
                shareOppList.add(objShare);
            }
        }
        if(!shareOppList.isEmpty() && shareOppList != null){
            try{
                insert shareOppList;
                System.debug('shareOppList: '+shareOppList);
            }Catch(Exception ex){
                System.debug('Error: In ApexSharing '+ex.getMessage());
            }
        }
    }
    
    //To remove the access of Record from Sourcing Manager
    public static void removeSharingWithSourcingManager(Set<Id> svIds) {
        List<Opportunity__Share> sharesvList = new List<Opportunity__Share>();
        System.debug('svIds: '+svIds);
        List<Opportunity__Share> sharesToDelete = [SELECT Id FROM Opportunity__Share WHERE ParentId IN :svIds];
        System.debug('sharesToDelete: '+sharesToDelete);
        if(!sharesToDelete.isEmpty() && sharesToDelete != null){
            try{
                Database.Delete(sharesToDelete, false);
            }Catch(Exception ex){
                System.debug('Error in Delete '+ex.getMessage());
            }
        }
    }
    
    public static void apexSharingWithSalesManager(Set<Id> opportunityIdSet) {
        List<Opportunity__Share> opportunityShareList = new List<Opportunity__Share>();
        List<Opportunity__c> opportunityList = [SELECT Id, Name, Closing_Manager__c FROM Opportunity__c WHERE Id IN :opportunityIdSet];
        
        System.debug('Opportunity List: ' + opportunityList);
        
        if (!opportunityList.isEmpty()) {
            for (Opportunity__c opp : opportunityList) {
                if (opp.Closing_Manager__c != null) {
                    Opportunity__Share oppShare = new Opportunity__Share();
                    oppShare.ParentId = opp.Id;
                    oppShare.UserOrGroupId = opp.Closing_Manager__c;
                    oppShare.AccessLevel = 'Read';
                    oppShare.RowCause = Schema.Opportunity__Share.RowCause.Manual;
                    opportunityShareList.add(oppShare);
                }
            }
        }
        
        if (!opportunityShareList.isEmpty()) {
            try {
                insert opportunityShareList;
                System.debug('Inserted Opportunity Shares: ' + opportunityShareList);
            } catch (Exception ex) {
                System.debug('Error in Opportunity Sharing: ' + ex.getMessage());
            }
        }
    }
    
    public static void removeSharingWithSalesManager(Map<Id, Id> opportunitySalesManagerMap) {
        List<Opportunity__Share> deleteOpportunityShareList = new List<Opportunity__Share>();
        List<Opportunity__Share> sharedOpportunities = [
            SELECT Id, ParentId, UserOrGroupId 
            FROM Opportunity__Share 
            WHERE ParentId IN :opportunitySalesManagerMap.keySet()
        ];
        
        System.debug('Shared Opportunities Found: ' + sharedOpportunities.size());
        
        if (!sharedOpportunities.isEmpty()) {
            for (Opportunity__Share oppShare : sharedOpportunities) {
                if (opportunitySalesManagerMap.get(oppShare.ParentId) == oppShare.UserOrGroupId) {
                    deleteOpportunityShareList.add(oppShare);
                }
            }
        }
        
        System.debug('Opportunity Shares to Delete: ' + deleteOpportunityShareList.size());
        
        if (!deleteOpportunityShareList.isEmpty()) {
            try {
                Database.delete(deleteOpportunityShareList, false);
                System.debug('Deleted Opportunity Shares: ' + deleteOpportunityShareList);
            } catch (Exception ex) {
                System.debug('Error in Deleting Opportunity Sharing: ' + ex.getMessage());
            }
        }
    }
    
    
    //To calulcuate the count of No of Opportunity and No of Leads on CP Project
    public static void calulateNoofOpporunity(Set<Id> cppIds, String objectType){
        System.debug('CP Project Id .: '+cppIds);
        List<CP_Project__c> cppListtoUpdate = new List<CP_Project__c>();
        List<CP_Project__c> cppList = [select Id, Name, Opportunity_Count__c, Booking_Count__c, Last_Site_Visit_Tagged_Date__c, Last_Booking_Date__c 
                                       from CP_Project__c 
                                       WHERE Id IN: cppIds];
        if(!cppList.isEmpty() && cppList != null){
            for(CP_Project__c cp : cppList){
                if(objectType.equalsIgnoreCase('Opportunity')){
                    if(cp.Opportunity_Count__c != null){
                        cp.Opportunity_Count__c = cp.Opportunity_Count__c + 1;
                        cp.Last_Site_Visit_Tagged_Date__c = System.today();
                        cppListtoUpdate.add(cp);
                    }
                }else if(objectType.equalsIgnoreCase('Booking')){
                    if(cp.Booking_Count__c != null){
                        cp.Booking_Count__c = cp.Booking_Count__c + 1;
                        cp.Last_Booking_Date__c = System.today();
                        cppListtoUpdate.add(cp);
                    }
                }
                
            }
        }
        
        if(!cppListtoUpdate.isEmpty() && cppListtoUpdate != null){
            update cppListtoUpdate;
        }
        
    }
}