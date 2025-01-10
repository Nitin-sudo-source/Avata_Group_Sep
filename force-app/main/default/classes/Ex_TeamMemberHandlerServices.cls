public class Ex_TeamMemberHandlerServices {
    public static void checkVisitForAssignment(Set<Id> tmIdSet) {
        Map<Id, List<Site_Visit__c>> unAssignedVisitMap = new Map<Id, List<Site_Visit__c>>();
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        List<Site_Visit__c> unAssignedVisitList = new List<Site_Visit__c>();
        Set<Id> pIdSet = new Set<Id>();
        Set<Id> unAssignedVisitOppIdSet = new Set<Id>();
        
        tmList = [Select Id, Name, Team__r.Project__c from Team_Member__c where Id IN: tmIdSet AND Team__r.Team_Type__c = 'Sales Team'];
        
        
        if(!tmList.isEmpty() && tmList != null) {
        system.debug('tmList: '+tmList);
        system.debug('tmList Project: '+tmList[0].Team__r.Project__c);
            for(Team_Member__c tm: tmList) {
                if(tm.Team__r.Project__c != null)
                    pIdSet.add(tm.Team__r.Project__c);
            }
        }
        
        if(!pIdSet.isEmpty() && pIdSet != null) {
            unAssignedVisitList = [Select Id, Name, Project__c, Opportunity__c, Is_Sales_Manager_Assigned__c, Sales_Manager__c, Site_Visit_count__c from Site_Visit__c
                                   where Is_Sales_Manager_Assigned__c = false AND Sales_Manager__c = null AND Project__c IN: pIdSet AND Opportunity__c != null
                                   ORDER BY Site_Visit_count__c DESC, CreatedDate ASC];
            system.debug('unAssignedVisitList: '+unAssignedVisitList);
            
            if(!unAssignedVisitList.isEmpty() && unAssignedVisitList != null) {
                for(Site_Visit__c sv: unAssignedVisitList) {
                    if(!unAssignedVisitMap.containsKey(sv.Project__c)) {
                        List<Site_Visit__c> newList = new List<Site_Visit__c>();
                        newList.add(sv);
                        unAssignedVisitMap.put(sv.Project__c, newList);
                    } else {
                        unAssignedVisitMap.get(sv.Project__c).add(sv);
                    }
                    unAssignedVisitOppIdSet.add(sv.Opportunity__c);
                }
            }
        }
        if(!unAssignedVisitMap.isEmpty() && unAssignedVisitMap != null && !unAssignedVisitOppIdSet.isEmpty() && unAssignedVisitOppIdSet != null)
            Ex_SiteVisitHandlerServices.applyRoundRobin(unAssignedVisitMap, unAssignedVisitOppIdSet);
    }
}