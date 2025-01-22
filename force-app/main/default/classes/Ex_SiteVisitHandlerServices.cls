public class Ex_SiteVisitHandlerServices {
    
    public static void rollupOnOpportunity(Site_Visit__c sv){
        List<Opportunity__c> oppList=[Select Id, Last_SV_Comment__c,Last_SV_attended_by__c,Last_SV_Date__c,SV_Comment_History__c,CP_Project__c,
                                      Configuration_Required__c, Project__c, Budget__c, Project_Type__c, Buying_Purpose__c, Possession_Timeframe_Required__c,
                                      Opportunity_Stage__c, Opportunity_Sub_Stage__c, Opportunity_Sub_Stage_Reason__c, Account__c,Sales_Next_Follow_up_Date__c,Sales_Proposed_Visit_Date__c,
                                      Sourcing_Manager__c
                                      from Opportunity__c 
                                      where Id=:sv.Opportunity__c];
        Set<Id> accId = new Set<Id>();
        
        system.debug('oppList is::'+oppList);
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        for(Opportunity__c opp : oppList){
            opp.Last_SV_Date__c = sv.Site_Visit_Date__c;
            opp.Last_SV_Comment__c = sv.Comment__c;
            opp.Last_SV_attended_by__c = sv.OwnerId;
            if(opp.Last_SV_Comment__c != null){
                if(opp.SV_Comment_History__c == null)
                    opp.SV_Comment_History__c = '';
                opp.SV_Comment_History__c = string.ValueOf(myDate)+': ' + opp.Last_SV_Comment__c + '\n' + opp.SV_Comment_History__c;
            }
            
            opp.Configuration_Required__c = sv.Configuration_Required__c;
            opp.Project__c = sv.Project_Name__c;
            opp.Project_Type__c = sv.Project_Type__c;
            opp.Budget__c = sv.Budget__c;
            opp.Buying_Purpose__c = sv.Buying_Purpose__c;
            opp.Possession_Timeframe_Required__c = sv.Possession_Timeframe_Required__c;
            opp.Opportunity_Stage__c = sv.Opportunity_Stage__c;
            opp.Opportunity_Sub_Stage__c = sv.Opportunity_Sub_Stage__c;
            opp.Opportunity_Sub_Stage_Reason__c = sv.Opportunity_Sub_Stage_Reason__c;
            opp.Sales_Next_Follow_up_Date__c = sv.Next_Follow_up_Date__c;
            opp.Sales_Proposed_Visit_Date__c = sv.Proposed_Re_Visit_Date__c;
            
            if(sv.Channel_Partner__c != null){
                opp.Channel_Partner__c = sv.Channel_Partner__c;
                opp.CP_Project__c = sv.CP_Project__c;
                opp.Sourcing_Manager__c = sv.Sourcing_Manager__c;
            }
            if(sv.Site_Visit_Count__c == 1){
                opp.First_Site_Visit_Date__c = sv.CreatedDate;
            }
            accId.add(opp.Account__c);
            System.debug('Account Id .: '+accId);
            update opp;
        }
        
        List<Account> accList =[SELECT Id, Locality__c, Locality_details__c, City_Name__c, Ethnicity__c, Religion__c, City_Type__c, Country__c
                                FROM Account WHERE Id IN : accId];
        if(accList != null && !accList.isEmpty()){
            for(Account acc : accList){
                acc.Locality__c = sv.Locality__c;
                acc.Locality_details__c = sv.Locality_details__c;
                acc.Country__c = sv.Country__c;
                acc.City_Name__c = sv.City_Name__c;
                acc.City_Type__c = sv.City_Type__c;
                acc.Age_Group__c = String.valueOf(sv.Age__c);
                acc.Gender__c = sv.Gender__c;
                acc.Occupation__c = sv.Occupation__c;
                acc.Designation__c = sv.Designation__c;
                acc.Martial_Status__c = sv.Martial_Status__c;
                acc.Current_Residence_Configuration__c = sv.Current_Residence_Configuration__c;
                acc.Company_Name__c = sv.Company_Name__c;
                acc.Salutation = sv.Salutation__c;
                acc.Ethnicity__c = sv.Ethnicity__c;
                acc.Religion__c	= sv.Religion__c;
                update acc;
            }  
        }
    }
    
    
   /* public static void appCPProjectOnSV(List<Site_Visit__c> svList){
        List<CP_Project__c> cpAccountList = [Select Id,Name,CP_Account__r.Name from CP_Project__c 
                                             where Project__c =: svList[0].Project_Name__c AND CP_Account__c =: svList[0].Channel_Partner__c];
        system.debug('cpAccountList is::'+cpAccountList);
        if(!cpAccountList.isEmpty() && cpAccountList != null){
            svList[0].CP_Project__c = cpAccountList[0].Id;   
        }
    }*/
    
    
    
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
    
    public static void removeSharingWithSourcingManager(Map<Id, Id> siteVisitCPSubAccountMap) {
        Set<Id> cpSubAccountIdSet = new Set<Id>();
        List<Site_Visit__Share> siteVisitShareList = new List<Site_Visit__Share>();
        List<Site_Visit__Share> deleteSiteVisitShareList = new List<Site_Visit__Share>();
        Map<Id, List<Site_Visit__Share>> siteVisitShareMap = new Map<Id, List<Site_Visit__Share>>();
        Map<Id, Id> sourcingManagerMap = new Map<Id, Id>();
        
        
        siteVisitShareList = [Select Id, ParentId, UserOrGroupId from Site_Visit__Share where ParentId IN: siteVisitCPSubAccountMap.keySet()];
        system.debug('siteVisitShareList: '+siteVisitShareList);
        
        if(!siteVisitShareList.isEmpty() && siteVisitShareList != null) {
            for(Site_Visit__Share svs: siteVisitShareList) {
                if(siteVisitShareMap.containsKey(svs.ParentId)) {
                    siteVisitShareMap.get(svs.ParentId).add(svs);
                } else {
                    List<Site_Visit__Share> newList = new List<Site_Visit__Share>();
                    newList.add(svs);
                    siteVisitShareMap.put(svs.ParentId, newList);
                }
            }
        }
        
        for(Id svId: siteVisitCPSubAccountMap.keySet()) {
            for(Site_Visit__Share svs: siteVisitShareMap.get(svId)) {
                if(svs.UserOrGroupId == siteVisitCPSubAccountMap.get(svs.ParentId)) {
                    deleteSiteVisitShareList.add(svs);
                }
            }
        }
        System.debug('deleteSiteVisitShareList: '+deleteSiteVisitShareList);
        if(!deleteSiteVisitShareList.isEmpty() && deleteSiteVisitShareList != null)
            delete deleteSiteVisitShareList;
        system.debug('deleteSiteVisitShareList delete--->'+deleteSiteVisitShareList);
    }
    
    public static void shareSiteVisitWithSourcingManager(Map<Id, List<Site_Visit__c>> cpSubAccountSiteVisitMap) {
        Map<Id, Id> sourcingManagerMap = new Map<Id, Id>();
        List<Site_Visit__Share> siteVisitShareList = new List<Site_Visit__Share>();
        List<Opportunity__Share> opportunityShareList = new List<Opportunity__Share>();
        
       // sourcingManagerMap = getSourcingManagerMap(cpSubAccountSiteVisitMap.keySet());
       // system.debug('sourcingManagerMap: '+sourcingManagerMap);
        
       // if(!sourcingManagerMap.isEmpty() && sourcingManagerMap != null) {
            for(Id cpAccountId: cpSubAccountSiteVisitMap.keySet()) {
                for(Site_Visit__c sv: cpSubAccountSiteVisitMap.get(cpAccountId)) {
                    //Site Visit share with Sourcing Manager
                    Site_Visit__Share svs = new Site_Visit__Share();
                    svs.ParentId = sv.Id;
                    svs.UserOrGroupId = sv.Sourcing_Manager__c;
                    svs.AccessLevel = 'Read';
                    svs.RowCause = Schema.Site_Visit__Share.RowCause.Manual;
                    siteVisitShareList.add(svs);
                    
                    //Opportunity share with Sourcing Manager
                    /*Opportunity__Share os = new Opportunity__Share();
                    os.ParentId = sv.Opportunity__c;
                    os.UserOrGroupId = sv.Sourcing_Manager__c;
                    os.AccessLevel = 'Read';
                    os.RowCause = Schema.Opportunity__Share.RowCause.Manual;
                    opportunityShareList.add(os);*/
                }
            }
      
       // }
        if(!siteVisitShareList.isEmpty() && siteVisitShareList != null) {
            try {
                insert siteVisitShareList;
                system.debug('siteVisitShareList Insert--->'+siteVisitShareList);
            } catch(Exception ex) {
                system.debug('Error in Site Visit Sharing: '+ex.getMessage());
            }
        }
        /*if(!opportunityShareList.isEmpty() && opportunityShareList != null) {
            try {
                insert opportunityShareList;
            } catch(Exception ex) {
                system.debug('Error in Opportunity Sharing: '+ex.getMessage());
            }
        }*/
    }
    
   /* public static Map<Id, Id> getSourcingManagerMap(Set<Id> cpAccountIdSet) {
        Map<Id, Id> sourcingManagerMap = new Map<Id, Id>();
        List<CP_Project__c> cpSubAccountList = new List<CP_Project__c>();
        
        cpSubAccountList = [Select Id, OwnerId from CP_Project__c where OwnerId IN: cpAccountIdSet];
        system.debug('cpSubAccountList: '+cpSubAccountList);
        
        if(!cpSubAccountList.isEmpty() && cpSubAccountList != null) {
            for(CP_Project__c csa: cpSubAccountList) {
                sourcingManagerMap.put(csa.Id, csa.OwnerId);
            }
        }
        return sourcingManagerMap;
    }*/
    
    public static void updateSiteVisitDetailsOnCPProject(Set<Id> cpAccountIdSet) {
        List<CP_Project__c> cpAccountList = new List<CP_Project__c>();
        List<AggregateResult> svCPAccountList1 = new List<AggregateResult>();
        Map<Id, Integer> svCountCPAccountMap = new Map<Id, Integer>();
        
        cpAccountList = [Select Id, Site_Visit_Count__c from CP_Project__c 
                         where Id IN: cpAccountIdSet];
        system.debug('cpAccountList: '+cpAccountList);
        
        svCPAccountList1 = [Select Count(Id) totalSV, CP_Project__c  from Site_Visit__c 
                            where CP_Project__c IN: cpAccountIdSet GROUP BY CP_Project__c];
        system.debug('svCPAccountList1: '+svCPAccountList1);
        
        
        if (!svCPAccountList1.isEmpty() && svCPAccountList1 != null) {
            for (AggregateResult ag : svCPAccountList1) {
                svCountCPAccountMap.put((Id) ag.get('CP_Project__c'), (Integer) ag.get('totalSV'));
            }
        }
        
        if(!cpAccountList.isEmpty() && cpAccountList != null) {
            for(CP_Project__c cpAccount: cpAccountList) {
                cpAccount.Site_visit_count__c = svCountCPAccountMap.get(cpAccount.Id);
            }
            update cpAccountList;
        }
    }
}

/*
public static void applyRoundRobin(Map<Id, List<Site_Visit__c>> svMap, Set<Id> oppIdSet, String assignType) {
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

* Priority wise assignment should be done
* 1] Firstly, check Revisit of available team Member & assign to respective team member
* 2] Secondly, check Revisit of day off team member & assign that to another team member who is available
* 3] After that, check fresh visits & assign that to available team member

if(!teamMemberMap.isEmpty() && teamMemberMap != null) {
if(sv.Site_Visit_Count__c > 1) {
if(teamMemberMap.containsKey(opportunityMap.get(sv.Opportunity__c).OwnerId)) {
//Priority 1//
DateTime now = DateTime.now();
sv.Sales_Manager__c = teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId).User__c;
// sv.Sales_Assignment_Date__c = now;
sv.OwnerId = teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId).User__c;
sv.Is_Sales_Manager_Assigned__c = true;
if(assignType.equalsIgnoreCase('After')) {
updateSiteVisitList.add(sv);
}

Team_Member__c member = teamMemberMap.get(opportunityMap.get(sv.Opportunity__c).OwnerId);
member.Last_Assignment_DateTime__c = now;
member.Last_Assignment_Milliseconds__c = now.millisecondGMT();
member.Assignment_Counter__c = member.Assignment_Counter__c + 1;
member.Availability__c = false;
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
// sv.Sales_Assignment_Date__c = now;
sv.OwnerId = tmList[0].User__c;
sv.Is_Sales_Manager_Assigned__c = true;
if(assignType.equalsIgnoreCase('After')) {
updateSiteVisitList.add(sv);
}

tmList[0].Last_Assignment_DateTime__c = now;
tmList[0].Last_Assignment_Milliseconds__c = now.millisecondGMT();
tmList[0].Assignment_Counter__c = tmList[0].Assignment_Counter__c + 1;
tmList[0].Availability__c = false;
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
// sv.Sales_Assignment_Date__c = now;
sv.OwnerId = tmList[0].User__c;
sv.Is_Sales_Manager_Assigned__c = true;
if(assignType.equalsIgnoreCase('After')) {
updateSiteVisitList.add(sv);
}

tmList[0].Last_Assignment_DateTime__c = now;
tmList[0].Last_Assignment_Milliseconds__c = now.millisecondGMT();
tmList[0].Assignment_Counter__c = tmList[0].Assignment_Counter__c + 1;
tmList[0].Availability__c = false;
updateMemberList.add(tmList[0]);

//After assignment it should assigned to any other site visit
teamMemberMap.remove(tmList[0].User__c);
}
}
}
}
}
if(!updateSiteVisitList.isEmpty() && updateSiteVisitList != null)
update updateSiteVisitList;
if(!updateMemberList.isEmpty() && updateMemberList != null)
update updateMemberList;
}

public static Set<Id> getDayOffUserIdSet(Set<Id> pIdSet) {
Set<Id> dayOffUserIdSet = new Set<Id>();
List<Team_Member__c> tmList = new List<Team_Member__c>();

tmList = [Select Id, User__c from Team_Member__c
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

public static Map<Id, Map<Id, Team_Member__c>> getProjectTeamMemberMap(Set<Id> pIdSet) {
Map<Id, Map<Id, Team_Member__c>> projectTeamMemberMap = new Map<Id, Map<Id, Team_Member__c>>();
List<Team_Member__c> tmList = new List<Team_Member__c>();

tmList = [Select Id, Availability__c, Team__c, Team__r.Project__c, User__c, Last_Assignment_DateTime__c, User_Active_Status__c, Last_Assignment_Milliseconds__c, Assignment_Counter__c from Team_Member__c
where Team__r.Project__c =: pIdSet  AND User_Active_Status__c = true AND Availability__c = true AND DayOff__c = false AND Team__r.Team_Type__c = 'Sales Team' 
ORDER BY Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c];
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

public static void updateSalesManagerAvailability(Map<Id, Set<Id>> projectUserIdMap) {
List<Team_Member__c> tmList = new List<Team_Member__c>();
List<Team_Member__c> updateTMList = new List<Team_Member__c>();

tmList = [Select Id, Team__r.Project__c, Availability__c, User__c from Team_Member__c 
where Team__r.Project__c IN: projectUserIdMap.keySet() AND Availability__c =: false AND Team__r.Team_Type__c =: 'Sales Team'];
system.debug('Team :' +tmList);

if(!tmList.isEmpty() && tmList != null) {
for(Team_Member__c tm: tmList) {
if(projectUserIdMap.containsKey(tm.Team__r.Project__c)) {
if(projectUserIdMap.get(tm.Team__r.Project__c).contains(tm.User__c)) {
tm.Availability__c = true;
updateTMList.add(tm);
}
}
}
}
if(!updateTMList.isEmpty() && updateTMList != null)
update updateTMList;
}

public static void rollupOnOpportunity(Site_Visit__c sv){
List<Opportunity__c> oppList=[Select Id, Last_SV_Comment__c,Last_SV_attended_by__c,Last_SV_Date__c,SV_Comment_History__c,CP_Project__c,
Configuration_Required__c, Project__c, Budget__c, Project_Type__c, Buying_Purpose__c, Possession_Timeframe_Required__c,
Opportunity_Stage__c, Opportunity_Sub_Stage__c, Opportunity_Sub_Stage_Reason__c, Account__c,Sales_Next_Follow_up_Date__c,Sales_Proposed_Visit_Date__c
from Opportunity__c 
where Id=:sv.Opportunity__c];
Set<Id> accId = new Set<Id>();

system.debug('oppList is::'+oppList);
DateTime dT = System.now();
Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
for(Opportunity__c opp : oppList){
opp.Last_SV_Date__c = sv.Site_Visit_Date__c;
opp.Last_SV_Comment__c = sv.Comment__c;
opp.Last_SV_attended_by__c = sv.OwnerId;
if(opp.Last_SV_Comment__c != null){
if(opp.SV_Comment_History__c == null)
opp.SV_Comment_History__c = '';
opp.SV_Comment_History__c = string.ValueOf(myDate)+': ' + opp.Last_SV_Comment__c + '\n' + opp.SV_Comment_History__c;
}

opp.Configuration_Required__c = sv.Configuration_Required__c;
opp.Project__c = sv.Project_Name__c;
opp.Project_Type__c = sv.Project_Type__c;
opp.Budget__c = sv.Budget__c;
opp.Buying_Purpose__c = sv.Buying_Purpose__c;
opp.Possession_Timeframe_Required__c = sv.Possession_Timeframe_Required__c;
opp.Opportunity_Stage__c = sv.Opportunity_Stage__c;
opp.Opportunity_Sub_Stage__c = sv.Opportunity_Sub_Stage__c;
opp.Opportunity_Sub_Stage_Reason__c = sv.Opportunity_Sub_Stage_Reason__c;
opp.Sales_Next_Follow_up_Date__c = sv.Next_Follow_up_Date__c;
opp.Sales_Proposed_Visit_Date__c = sv.Proposed_Re_Visit_Date__c;

if(sv.Channel_Partner__c != null){
opp.Channel_Partner__c = sv.Channel_Partner__c;
opp.CP_Project__c = sv.CP_Project__c;
}
if(sv.Site_Visit_Count__c == 1){
opp.First_Site_Visit_Date__c = sv.CreatedDate;
}
accId.add(opp.Account__c);
System.debug('Account Id .: '+accId);
update opp;
}

List<Account> accList =[SELECT Id, Locality__c, Locality_details__c, City_Name__c, City_Type__c, Country__c
FROM Account WHERE Id IN : accId];
if(accList != null && !accList.isEmpty()){
for(Account acc : accList){
acc.Locality__c = sv.Locality__c;
acc.Locality_details__c = sv.Locality_details__c;
acc.Country__c = sv.Country__c;
acc.City_Name__c = sv.City_Name__c;
acc.City_Type__c = sv.City_Type__c;
acc.Age_Group__c = String.valueOf(sv.Age__c);
acc.Gender__c = sv.Gender__c;
acc.Occupation__c = sv.Occupation__c;
acc.Designation__c = sv.Designation__c;
acc.Martial_Status__c = sv.Martial_Status__c;
acc.Current_Residence_Configuration__c = sv.Current_Residence_Configuration__c;
acc.Company_Name__c = sv.Company_Name__c;
acc.Salutation = sv.Salutation__c;
update acc;
}  
}
}
}*/