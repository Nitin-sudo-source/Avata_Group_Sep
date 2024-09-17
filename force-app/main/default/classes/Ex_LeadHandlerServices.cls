//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_LeadHandlerServices {
    public static void duplicationCheck(String performRoundRobin, List<Lead__c> leadList) {
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
        
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
                /*if(l.Apply_Round_Robin__c && l.Project__c != null && performRoundRobin.equalsIgnoreCase('Yes')) {
                    if(projectLeadMap.containsKey(l.Project__c)) {
                        projectLeadMap.get(l.Project__c).add(l);
                    } else {
                        List<Lead> newList = new List<Lead>();
                        newList.add(l);
                        projectLeadMap.put(l.Project__c, newList);
                    }
                }*/
            }
        }
    }
    
    /*public static void applyRoundRobinLogic(Map<Id, List<Lead>> projectLeadMap) {
        Map<Id, List<Team_Members__c>> projectTeamMemberMap = new Map<Id, List<Team_Members__c>>();
        Map<Id, Team_Members__c> memberMapToUpdate = new Map<Id, Team_Members__c>();
        
        projectTeamMemberMap = getProjectTeamMemberMap(projectLeadMap.keySet());
        system.debug('projectTeamMemberMap: '+projectTeamMemberMap);
        
        for(Id pId: projectLeadMap.keySet()) {
            List<Lead> leadList = projectLeadMap.get(pId);
            List<Team_Members__c> tmList = projectTeamMemberMap.get(pId);
            
            Integer index = 0;
            for(Lead l: leadList) {
                // Pick the next person to be assigned
                if(tmList != null ) {
                    Team_Members__c member = tmList.get(Math.mod(index, tmList.size()));
                    
                    l.OwnerId = member.User__c;
                    l.Presales_Executive__c = member.User__c;
                    DateTime now = DateTime.now();
                    member.Last_Assignment_Date_Time__c = now;
                    member.Last_Assignment_Milliseconds__c = now.millisecondGMT();
                    member.Assignment_Counter__c = member.Assignment_Counter__c + 1;
                    memberMapToUpdate.put(member.Id, member);
                    index++;
                }
            }
        }
        if(!memberMapToUpdate.isEmpty() && memberMapToUpdate != null) {
            List<Team_Members__c> updateTMList = memberMapToUpdate.values();
            update updateTMList;
        }
    }
    
    public static Map<Id, List<Team_Members__c>> getProjectTeamMemberMap(Set<Id> pIdSet) {
        Map<Id, List<Team_Members__c>> projectTeamMemberMap = new Map<Id, List<Team_Members__c>>();
        List<Team_Members__c> tmList = new List<Team_Members__c>();
        
        tmList = [Select Id, Team__c, Team__r.Project__c, User__c, Last_Assignment_Date_Time__c, Last_Assignment_Milliseconds__c, Assignment_Counter__c from Team_Members__c
                  where Team__r.Project__c =: pIdSet AND Availability__c = true AND Team__r.Team_Type__c = 'Presales Team' AND User_Active_Status__c = true
                  ORDER BY Last_Assignment_Date_Time__c, Last_Assignment_Milliseconds__c];
        system.debug('tmList: '+tmList);
        
        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Members__c tm: tmList) {
                if(projectTeamMemberMap.containsKey(tm.Team__r.Project__c)) {
                    projectTeamMemberMap.get(tm.Team__r.Project__c).add(tm);
                } else {
                    List<Team_Members__c> newList = new List<Team_Members__c>();
                    newList.add(tm);
                    projectTeamMemberMap.put(tm.Team__r.Project__c, newList);
                }
            }
        }
        return projectTeamMemberMap;
    }*/
}