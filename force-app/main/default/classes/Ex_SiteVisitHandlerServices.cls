// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_SiteVisitHandlerServices {
    
    public static void applyRoundRobin(Map<Id, List<Site_Visit__c>> svMap, Set<Id> oppIdSet){
        Map<Id, Map<Id, Team_Member__c>> projectTeamMemberMap = new Map<Id, Map<Id, Team_Member__c>>();
        Map<Id, Opportunity__c> opportunityMap = new Map<Id, Opportunity__c>();
        List<Team_Member__c> updateMemberList = new List<Team_Member__c>();
        List<Site_Visit__c> updateSiteVisitList = new List<Site_Visit__c>();
        Set<Id> dayOffUserIdSet = new Set<Id>();
        
        projectTeamMemberMap = getProjectTeamMemberMap(svMap.keySet());
        opportunityMap = getOpportunityMap(oppIdSet);
        dayOffUserIdSet = getDayOffUserIdSet(svMap.keySet());
        
        for(Id pId: svMap.keySet()) {
            if(!projectTeamMemberMap.isEmpty() && projectTeamMemberMap != null) {
                List<Site_Visit__c> svList = svMap.get(pId);
                Map<Id, Team_Member__c> teamMemberMap = projectTeamMemberMap.get(pId);
                System.debug('teamMemberMap: '+teamMemberMap);
                    
                Integer index = 0;
                for(Site_Visit__c sv: svList) {
                    system.debug('SV Number: '+sv.Name);
                    system.debug('teamMemberMap: '+teamMemberMap);
                    /*
                     * Priority wise assignment should be done
                     * 1] Firstly, check Revisit of available team Member & assign to respective team member
                     * 2] Secondly, check Revisit of day off team member & assign that to another team member who is available
                     * 3] After that, check fresh visits & assign that to available team member
                    */
                    if(!teamMemberMap.isEmpty() && teamMemberMap != null) {
                        if(sv.Site_Visit_Count__c > 1) {
                            if(teamMemberMap.containsKey(opportunityMap.get(sv.Opportunity__c).OwnerId)) {
                                //Priority 1//
                                DateTime now = DateTime.now();
                                sv.Sales_Manager__c = teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId).User__c;
                                sv.SM_Assignment_Date__c = now;
                                sv.OwnerId = teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId).User__c;
                                sv.Is_Sales_Manager_Assigned__c = true;
                               /* if(assignType.equalsIgnoreCase('After')) {
                                    updateSiteVisitList.add(sv);
                                }*/
                                updateSiteVisitList.add(sv);
                                
                                Team_Member__c member = teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId);
                                member.Last_Assignment_DateTime__c = now;
                                member.Last_Assignment_Milliseconds__c = now.millisecondGMT();
                                member.Assignment_Counter__c = member.Assignment_Counter__c + 1;
                                member.Availability__c = false;
                                member.Site_Visit__c = sv.id; // Tag Sv on team memeber
                                updateMemberList.add(member);
                                
                                //After assignment it should assigned to any other site visit
                                teamMemberMap.remove(teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId).User__c);
                            } else {
                                //Priority 2//
                                if(!dayOffUserIdSet.isEmpty() && dayOffUserIdSet != null) {
                                    if(dayOffUserIdSet.contains(opportunityMap.get(sv.Opportunity__c).OwnerId)) {
                                        List<Team_Member__c> tmList = teamMemberMap.values();
                                        DateTime now = DateTime.now();
                                        sv.Sales_Manager__c = tmList[0].User__c;
                                        sv.SM_Assignment_Date__c = now;
                                        sv.OwnerId = tmList[0].User__c;
                                        sv.Is_Sales_Manager_Assigned__c = true;
                                       /* if(assignType.equalsIgnoreCase('After')) {
                                            updateSiteVisitList.add(sv);
                                        }*/
                                        updateSiteVisitList.add(sv);
                                        
                                        tmList[0].Last_Assignment_DateTime__c = now;
                                        tmList[0].Last_Assignment_Milliseconds__c = now.millisecondGMT();
                                        tmList[0].Assignment_Counter__c = tmList[0].Assignment_Counter__c + 1;
                                        tmList[0].Availability__c = false;
                                        tmList[0].Site_visit__c = sv.Id; //Tag Sv on team memeber
                                        updateMemberList.add(tmList[0]);
                                        
                                        //After assignment it should assigned to any other site visit
                                        teamMemberMap.remove(tmList[0].User__c);
                                    }
                                }
                            }
                        } else {
                            //Priority 3//
                            System.debug('teamMemberMap values:::'+teamMemberMap.values());
                            List<Team_Member__c> tmList = teamMemberMap.values();
                            
                            
                            DateTime now = DateTime.now();
                            sv.Sales_Manager__c = tmList[0].User__c;
                            sv.SM_Assignment_Date__c = now;
                            sv.OwnerId = tmList[0].User__c;
                            sv.Is_Sales_Manager_Assigned__c = true;
                           /* if(assignType.equalsIgnoreCase('After')) {
                                updateSiteVisitList.add(sv);
                            }*/
                            updateSiteVisitList.add(sv);
                            
                            tmList[0].Last_Assignment_DateTime__c = now;
                            tmList[0].Last_Assignment_Milliseconds__c = now.millisecondGMT();
                            tmList[0].Assignment_Counter__c = tmList[0].Assignment_Counter__c + 1;
                            tmList[0].Availability__c = false;
                            System.debug('sv.Id:::'+sv.Id);
                            tmList[0].Site_Visit__c = sv.Id; //Tag Sv on team memeber
                            updateMemberList.add(tmList[0]);
                            
                            //After assignment it should assigned to any other site visit
                            teamMemberMap.remove(tmList[0].User__c);
                        }
                    }
                }
            }
        }
        if(!updateSiteVisitList.isEmpty() && updateSiteVisitList != null)
            System.debug('updateSiteVisitList::'+updateSiteVisitList);
            update updateSiteVisitList;
        if(!updateMemberList.isEmpty() && updateMemberList != null)
            System.debug('updateMemberList::'+updateMemberList);
            update updateMemberList;
    }
    
    public static Set<Id> getDayOffUserIdSet(Set<Id> pIdSet) {
        Set<Id> dayOffUserIdSet = new Set<Id>();
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        
        tmList = [Select Id, User__c , Site_Visit__c from Team_Member__c
                  where Team__r.Project__c =: pIdSet AND User_Active_Status__c = true AND DayOff__c = true AND Team__r.Team_Type__c = 'Sales Team'];
        system.debug('tmList: '+tmList);
        
        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Member__c tm: tmList) {
                if(tm.User__c != null)
                    dayOffUserIdSet.add(tm.User__c);
            }
        }
        return dayOffUserIdSet;
    }
    
    public static Map<Id, Map<Id, Team_Member__c>> getProjectTeamMemberMap(Set<Id> pIdSet) {
        Map<Id, Map<Id, Team_Member__c>> projectTeamMemberMap = new Map<Id, Map<Id, Team_Member__c>>();
        List<Team_Member__c> tmList = new List<Team_Member__c>();

        tmList = [Select Id, Availability__c, Team__c, Team__r.Project__c, User__c, Last_Assignment_DateTime__c, User_Active_Status__c, Last_Assignment_Milliseconds__c, Assignment_Counter__c, Site_Visit__c from Team_Member__c
                  where Team__r.Project__c IN: pIdSet  AND User_Active_Status__c = true AND Availability__c = true AND DayOff__c = false AND Team__r.Team_Type__c = 'Sales Team' 
                  ORDER BY Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c ];
        system.debug('tmList: '+tmList);
        
        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Member__c tm: tmList) {
                if(projectTeamMemberMap.containsKey(tm.Team__r.Project__c)) {
                    Map<Id, Team_Member__c> getMap = projectTeamMemberMap.get(tm.Team__r.Project__c);
                    
                    if(getMap != null) {
                        if(getMap.containsKey(tm.User__c)) {
                            getMap.put(tm.User__c, tm);
                        } else {
                            getMap.put(tm.User__c, tm);
                        }
                    }
                    projectTeamMemberMap.get(tm.Team__r.Project__c).putAll(getMap);
                } else {
                    Map<Id, Team_Member__c> memberMap = new Map<Id, Team_Member__c>();
                    memberMap.put(tm.User__c, tm);
                    projectTeamMemberMap.put(tm.Team__r.Project__c, memberMap);
                }
            }
        }
        System.Debug('projectTeamMemberMap'+projectTeamMemberMap);
        return projectTeamMemberMap;
    }
    
    public static Map<Id, Opportunity__c> getOpportunityMap(Set<Id> oppIdSet) {
        Map<Id, Opportunity__c> opportunityMap = new Map<Id, Opportunity__c>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        
        oppList = [Select Id, Name, OwnerId from Opportunity__c where Id IN: oppIdSet];
        system.debug('oppList: '+oppList);
        
        if(!oppList.isEmpty() && oppList != null) {
            for(Opportunity__c op: oppList) {
                opportunityMap.put(op.Id, op);
            }
        }
        return opportunityMap;
    }
    
    public static void updateSalesManagerAvailability(Map<Id, Set<Id>> projectUserIdMap) {
        System.debug('projectUserIdMap Size:: '+projectUserIdMap.size());
        System.debug('projectUserIdMap:: '+projectUserIdMap);
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        List<Team_Member__c> updateTMList = new List<Team_Member__c>();
        
        tmList = [Select Id, Availability__c, User__c, Site_Visit__c, Team__r.Project__c from Team_Member__c 
                  where Team__r.Project__c IN : projectUserIdMap.keySet() AND Availability__c = false AND Team__r.Team_Type__c = 'Sales Team'];
        
        System.debug('tmList Size:: '+tmList.size());
        System.debug('tmList:: '+tmList);

        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Member__c tm: tmList) {
              if(projectUserIdMap.containsKey(tm.Team__r.Project__c)){
                  if(projectUserIdMap.get(tm.Team__r.Project__c).contains(tm.User__c)){
                        tm.Availability__c = true;
                        tm.Site_Visit__c = null;
                        updateTMList.add(tm);
                  }
               }
            }
        }
        if(!updateTMList.isEmpty() && updateTMList != null)
            update updateTMList;
    }
    
    public static void fetchSVDateonOpportunity(Set<Id> oppIdSetForSV) {
        List<String> formattedVisits = new List<String>();
        List<Site_Visit__c> svList = new  List<Site_Visit__c>();
        List<Opportunity__c> oppList  = new List<Opportunity__c>();
        
        if(oppIdSetForSV != null){
            svList =  [Select Id, Name, CreatedDate from Site_Visit__c where Opportunity__c IN: oppIdSetForSV Order BY Name DESC];
            System.debug('svList: '+svList);
        }
        if(svList != null && !svList.isEmpty()){
            for (Site_Visit__c sv : svList) {
                if (sv.CreatedDate != null) {
                    String formattedDate = sv.CreatedDate.format('dd MMM yyyy', UserInfo.getTimeZone().toString());
                    formattedVisits.add(sv.Name + ':-> ' + formattedDate);
                }
            }
            String siteVisitDetails = String.join(formattedVisits, '\n');
            System.debug('siteVisitDetails: '+siteVisitDetails);
            
            
            if (!formattedVisits.isEmpty()) {
                Opportunity__c opp = [SELECT Id, SV_Date_History__c FROM Opportunity__c WHERE Id = :oppIdSetForSV LIMIT 1];
                opp.SV_Date_History__c = siteVisitDetails;
                oppList.add(opp);
            }
            System.debug('updateoppListWithDate:'+oppList);
            if(oppList != null && !oppList.isEmpty()){
                update oppList;
            }
        }
    }
}