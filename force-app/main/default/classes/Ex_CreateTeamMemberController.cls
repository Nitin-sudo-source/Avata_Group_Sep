public class Ex_CreateTeamMemberController {
    
    @AuraEnabled(cacheable = true)
    public static List<String> getPicklistValues() {
        List<String> values = new List<String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('Team__c') ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get('Team_Type__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            values.add(pickListVal.getValue());
        }
        system.debug('values' +values);
        return values;
    }
    
    @AuraEnabled(cacheable = true)
    public static Project__c getPojectDetails(String projectId) {
        Project__c p = [SELECT Id , Name FROM Project__c where Id =: projectId];
        return p;
    }
    
    public class UserDetailsWrapper {
        @AuraEnabled
        public List<User> userList { get; set; }
        
        @AuraEnabled
        public List<Team_Member__c> tmList { get; set; }
        
        public UserDetailsWrapper(List<User> userList, List<Team_Member__c> tmList) {
            this.userList = userList;
            this.tmList = tmList;
        }
    }
    
    @AuraEnabled(cacheable = false)
    public static List<UserDetailsWrapper> getUserDetails(String selectedTeamType , String projectId) {
        List<UserDetailsWrapper> userDetailsList = new List<UserDetailsWrapper>();
        
        try {
            Member_Profile__c mp = [SELECT Name, ProfileName__c FROM Member_Profile__c WHERE Name = :selectedTeamType];
            List<User> userList = new List<User>();
            List<Team_Member__c> tmList = new List<Team_Member__c>();
            
            List<Profile> pfList = null;
            List<String> pfNameList = new List<String>();
            if (mp != null && mp.ProfileName__c != null) {
                String[] pfNameArray = mp.ProfileName__c.split(',');                
                for(String name : pfNameArray) {
                    pfNameList.add(name.trim());
                }
                
              //  String finalString = String.join(pfNameList, ',');
            }
             System.debug('pfNameList :::' + pfNameList);
            if (!pfNameList.isEmpty()) {
                pfList = [SELECT Id, Name FROM Profile WHERE Name IN :pfNameList];
                System.debug('pfList :::' + pfList);
                
                Set<Id> profileIds = new Set<Id>();
                for (Profile pf : pfList) {
                    profileIds.add(pf.Id);
                }
                
                if (!profileIds.isEmpty()) {
                    userList = [SELECT Id, Name FROM User WHERE ProfileId IN :profileIds AND isActive = true];
                }
                
                Set<Id> userIds = new Set<Id>();
                for (User u : userList) {
                    userIds.add(u.Id);
                }
                List<Team__c> teamList = [SELECT Name, Team_Type__c FROM Team__c WHERE Team_Type__c = :selectedTeamType AND Project__c = :projectId LIMIT 1];
                
                if (!teamList.isEmpty()) {
                    Team__c t = teamList[0];
                    if (t != null) {
                        tmList = [SELECT Name, Availability__c, Sequence_Number__c, User__c FROM Team_Member__c WHERE Team__c = :t.Id AND User__c IN :userIds];
                    } else {
                        System.debug('No Team__c record found for Team_Type__c: ' + selectedTeamType);
                    }
                } else {
                    System.debug('No matching Team__c record found.');
                }                                   
            }
            
            if (!userList.isEmpty()) {
                System.debug('userList :::' + userList);
                userDetailsList.add(new UserDetailsWrapper(userList, tmList));
            }
            
            return userDetailsList;
        } catch (Exception e) {
            System.debug('Error in getUserDetails: ' + e.getMessage());
            return null;
        }
    }
        
    @AuraEnabled(cacheable = false)
    public static List<Team_Member__c> saveData(List<Team_Member__c> tmList, String projectId, String selectedTeamType) { 
        List<Team_Member__c> updateTeamList = new List<Team_Member__c>();
        
        try {
            List<Team__c> existingTeams = [SELECT Id FROM Team__c WHERE Team_Type__c = :selectedTeamType AND Project__c =: projectId];
            
            Team__c t;
            
            if (!existingTeams.isEmpty()) {
                t = existingTeams[0];
            } else {
                t = new Team__c(
                    Name = selectedTeamType,
                    Project__c = projectId,
                    Team_Type__c = selectedTeamType
                );
                insert t;
            }
            
            if (t.Id != null) {
                for (Team_Member__c tm : tmList) {
                    List<Team_Member__c> existingTeamMembers = [SELECT Id FROM Team_Member__c WHERE User__c = :tm.Id AND Team__c = :t.Id LIMIT 1];
                    system.debug('existingTeamMembers ::' +existingTeamMembers);
                    Team_Member__c tms;
                    
                    if (!existingTeamMembers.isEmpty()) {
                        tms = existingTeamMembers[0];
                        tms.Name = tm.Name;
                        tms.Availability__c = tm.Availability__c;
                        tms.Sequence_Number__c = tm.Sequence_Number__c;
                    } else {
                        tms = new Team_Member__c(
                            Name = tm.Name,
                            Availability__c = tm.Availability__c,
                            Sequence_Number__c = tm.Sequence_Number__c,
                            Team__c = t.Id,
                            User__c = tm.Id
                        );
                    }
                    updateTeamList.add(tms);
                }
                
                if (!updateTeamList.isEmpty()) {
                    upsert updateTeamList;
                    return updateTeamList;
                }
            }
        } catch (Exception e) {
            System.debug('Error in saveData: ' + e.getMessage());
        }
        
        return null;
    }
    
}