public class Ex_TeamMemberTriggerHandler {
    public static void afterUpdate(Map<Id, Team_Member__c> oldMap, Map<Id, Team_Member__c> newMap) {
        Set<Id> tmIdSet = new Set<Id>(); 
        
        for(Team_Member__c oldMember: oldMap.values()) {
            Team_Member__c newMember = newMap.get(oldMember.Id);
            
            if(oldMember.Availability__c != newMember.Availability__c && newMember.Availability__c == true) {
                tmIdSet.add(newMember.Id);
            }
        }
        if(!tmIdSet.isEmpty() && tmIdSet != null) 
            Ex_TeamMemberHandlerServices.checkVisitForAssignment(tmIdSet);
    }
}