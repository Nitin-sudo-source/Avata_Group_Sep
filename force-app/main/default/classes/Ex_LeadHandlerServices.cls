//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_LeadHandlerServices {
    public static void duplicationCheck(String performRoundRobin, List<Lead__c> leadList) {
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
        List<Lead__c> leadListForAssignment = new List<Lead__c>();

        for(Lead__c l : leadList) {
            String errMsg = '';
            if (duplicateWrapperMap.containsKey(l)) {
                for (Ex_DuplicationHandlerServices.duplicateWrapper dw : duplicateWrapperMap.get(l)) {
                    if (dw.objectType.equalsIgnoreCase('Lead'))
                        errMsg = 'Duplicate Lead Found With Name: ' + dw.dupLead.Full_Name__c +' Owner Name: '+ dw.dupLead.Owner.Name + '. Record Id is ' + dw.dupLead.Id;
                    else if (dw.objectType.equalsIgnoreCase('Account'))
                        errMsg = 'Duplicate Account Found With Name: ' + dw.dupAccount.LastName +' Owner Name: '+ dw.dupAccount.Owner.Name + '. Record Id is ' + dw.dupAccount.Id;
                }
                if (!Test.isRunningTest() && errMsg != '')
                    l.addError(errMsg);
            } else {
                if(l.Apply_Round_Robin__c && performRoundRobin.equalsIgnoreCase('Yes')) {
                    leadListForAssignment.add(l);
                }
            }
            
        }
        if(!leadListForAssignment.isEmpty() && leadListForAssignment != null) {
            applyRoundRobinLogic(leadListForAssignment);
        }
    }
    
    public static void applyRoundRobinLogic(List<Lead__c> leadListForAssignment) {
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        Map<Id, Team_Member__c> memberMapToUpdate = new Map<Id, Team_Member__c>();
        
        tmList = getTeamMembers();
        system.debug('tmList: '+tmList);
        
        Integer index = 0;
        for(Lead__c l: leadListForAssignment) {
            // Pick the next person to be assigned
            if(tmList != null) {
                Team_Member__c member = tmList.get(Math.mod(index, tmList.size()));
                
                l.OwnerId = member.User__c;

                DateTime now = DateTime.now();
                member.Last_Assignment_DateTime__c = now;
                member.Last_Assignment_Milliseconds__c = now.millisecondGMT();
                member.Assignment_Counter__c = member.Assignment_Counter__c + 1;
                memberMapToUpdate.put(member.Id, member);
                index++;
            }
        }
        if(!memberMapToUpdate.isEmpty() && memberMapToUpdate != null) {
            List<Team_Member__c> updateTMList = memberMapToUpdate.values();
            update updateTMList;
        }
    }
    
    public static List<Team_Member__c> getTeamMembers() {
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        
        tmList = [Select Id, Team__c, Team__r.Project__c, User__c, Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c, Assignment_Counter__c from Team_Member__c
                  where Availability__c = true AND Team__r.Team_Type__c = 'Presales Team' AND User_Active_Status__c = true AND DayOff__c = false
                  ORDER BY Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c];
        system.debug('tmList: '+tmList);
        
        return tmList;
    }
}