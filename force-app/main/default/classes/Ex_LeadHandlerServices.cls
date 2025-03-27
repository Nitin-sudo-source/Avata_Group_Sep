public class Ex_LeadHandlerServices {
    public static void duplicationCheck(String applyRoundRobin, List<Lead__c> leadList) {
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
        Map<Id, List<Lead__c>> projectLeadMap = new Map<Id, List<Lead__c>>();
        
        for(Lead__c l: leadList) {
            String errMsg = '';
            if(duplicateWrapperMap.containsKey(l)) {
                for(Ex_DuplicationHandlerServices.duplicateWrapper dw: duplicateWrapperMap.get(l)) {
                    if(dw.objectType.equalsIgnoreCase('Lead'))
                        errMsg = 'Duplicate Lead Found with Name: '+dw.dupLead.Name+' & Id: '+dw.dupLead.Id;
                    else if(dw.objectType.equalsIgnoreCase('Opportunity'))
                        errMsg = 'Duplicate Opportunity Found with Name: '+dw.dupOpp.Name+' & Id: '+dw.dupOpp.Id;
                }
                if(!test.isRunningTest() && errMsg != null)
                    l.addError(errMsg);
            }  else {
                if(l.Apply_Round_Robin__c && l.Project__c != null && applyRoundRobin.equalsIgnoreCase('Yes')) {
                    if(projectLeadMap.containsKey(l.Project__c)) {
                        projectLeadMap.get(l.Project__c).add(l);
                    } else {
                        List<Lead__c> newList = new List<Lead__c>();
                        newList.add(l);
                        projectLeadMap.put(l.Project__c, newList);
                    }
                }
            }
        }
        if(!projectLeadMap.isEmpty() && projectLeadMap != null)
            applyRoundRobinLogic(projectLeadMap);       
    }
    
    public static void applyRoundRobinLogic(Map<Id, List<Lead__c>> projectLeadMap) {
        Map<Id, List<Team_Member__c>> projectTeamMemberMap = new Map<Id, List<Team_Member__c>>();
        Map<Id, Team_Member__c> memberMapToUpdate = new Map<Id, Team_Member__c>();
        projectTeamMemberMap = getProjectTeamMemberMapSourceWise(projectLeadMap);
        system.debug('projectTeamMemberMap: '+projectTeamMemberMap);        
        
        for(Id pId: projectLeadMap.keySet()) {
            List<Lead__c> leadList = projectLeadMap.get(pId);
            List<Team_Member__c> tmList = projectTeamMemberMap.get(pId);
            
            Integer index = 0;
            for(Lead__c l: leadList) {
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
        }
        if(!memberMapToUpdate.isEmpty() && memberMapToUpdate != null) {
            List<Team_Member__c> updateTMList = memberMapToUpdate.values();
            update updateTMList;
        }
    }
    
    public static Map<Id, List<Team_Member__c>> getProjectTeamMemberMapSourceWise(Map<Id, List<Lead__c>> projectLeadMap) {
        Map<Id, List<Team_Member__c>> projectTeamMemberMap = new Map<Id, List<Team_Member__c>>();
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        
        tmList = [Select Id, Team__c, Team__r.Project__c, User__c, Last_Assignment_DateTime__c, User_Active_Status__c, 
                  Last_Assignment_Milliseconds__c, Assignment_Counter__c from Team_Member__c
                  where Team__r.Project__c =: projectLeadMap.keySet() AND User_Active_Status__c = true AND Availability__c = true 
                  AND Team__r.Team_Type__c = 'Presales Team' 
                  ORDER BY Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c];
        system.debug('tmList .: '+tmList);
        
        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Member__c tm: tmList) {
                if(projectTeamMemberMap.containsKey(tm.Team__r.Project__c)) {
                    projectTeamMemberMap.get(tm.Team__r.Project__c).add(tm);
                } else {
                    List<Team_Member__c> newList = new List<Team_Member__c>();
                    newList.add(tm);
                    projectTeamMemberMap.put(tm.Team__r.Project__c, newList);
                }
            }
        }
        return projectTeamMemberMap;
    }
    
    public static void updateFirstCallDate(List<Lead__c> LeadList){
        LeadList[0].First_Presales_Call_Date__c = system.now();
    }
}