//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 27-10-2023
//-------------------------------------------//
public class Ex_OpportunityHandlerServices {
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
    
     public static void shareSiteVisitWithSourcingManager(Map<Id, List<Opportunity__c>> cpSubAccountSiteVisitMap) {
        Map<Id, Id> sourcingManagerMap = new Map<Id, Id>();
        List<Opportunity__Share> opportunityShareList = new List<Opportunity__Share>();
        
            for(Id cpAccountId: cpSubAccountSiteVisitMap.keySet()) {
                for(Opportunity__c op: cpSubAccountSiteVisitMap.get(cpAccountId)) {
                    //Opportunity share with Sourcing Manager
                    Opportunity__Share os = new Opportunity__Share();
                    os.ParentId = op.Id;
                    os.UserOrGroupId = op.Sourcing_Manager__c;
                    os.AccessLevel = 'Read';
                    os.RowCause = Schema.Opportunity__Share.RowCause.Manual;
                    opportunityShareList.add(os);
                }
            }
      
       
        if(!opportunityShareList.isEmpty() && opportunityShareList != null) {
            try {
                insert opportunityShareList;
            } catch(Exception ex) {
                system.debug('Error in Opportunity Sharing: '+ex.getMessage());
            }
        }
    }
    
    
    public static void removeSharingWithSourcingManager(Map<Id, Id> siteVisitCPSubAccountMap) {
        Set<Id> cpSubAccountIdSet = new Set<Id>();
        List<Opportunity__Share> opportunityShareList = new List<Opportunity__Share>();
        List<Opportunity__Share> deleteOpportunityShareList = new List<Opportunity__Share>();
        Map<Id, List<Opportunity__Share>> OpportunityShareMap = new Map<Id, List<Opportunity__Share>>();
        Map<Id, Id> sourcingManagerMap = new Map<Id, Id>();
       
        
        opportunityShareList = [Select Id, ParentId, UserOrGroupId from Opportunity__Share where ParentId IN: siteVisitCPSubAccountMap.keySet()];
        system.debug('opportunityShareList: '+opportunityShareList);
        
        if(!opportunityShareList.isEmpty() && opportunityShareList != null) {
            for(Opportunity__Share svs: opportunityShareList) {
                if(OpportunityShareMap.containsKey(svs.ParentId)) {
                    OpportunityShareMap.get(svs.ParentId).add(svs);
                } else {
                    List<Opportunity__Share> newList = new List<Opportunity__Share>();
                    newList.add(svs);
                    OpportunityShareMap.put(svs.ParentId, newList);
                }
            }
        }
        System.debug('OpportunityShareMap: '+OpportunityShareMap);
        
        if(OpportunityShareMap != null && !OpportunityShareMap.isEmpty()){
            for(Id svId: siteVisitCPSubAccountMap.keySet()) {
                for(Opportunity__Share svs: OpportunityShareMap.get(svId)) {
                    if(svs.UserOrGroupId == siteVisitCPSubAccountMap.get(svs.ParentId)) {
                        deleteOpportunityShareList.add(svs);
                    }
                }
            }
        }
        
        if(!deleteOpportunityShareList.isEmpty() && deleteOpportunityShareList != null)
            delete deleteOpportunityShareList;
        system.debug('deleteOpportunityShareList delete--->'+deleteOpportunityShareList);
    }
}