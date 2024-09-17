// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_SMAssignmentController {
    @AuraEnabled(cacheable=false)
    public static Site_Visit__c getSVRecord(Id recordId) {
        Site_Visit__c svRecord = [SELECT Id, SM_Assignment_Date__c, OwnerId, Site_Visit_Count__c , Opportunity__r.OwnerId, Project__r.Name, Opportunity__c, Sales_Manager__c, Is_Sales_Manager_Assigned__c FROM Site_Visit__c where Id =: recordId];
        system.debug('InsidesvRecord:::'+svRecord);
        if(svRecord != Null)
            return svRecord;
        else
            return Null;
    }	
    
    @AuraEnabled
    public static List<Team_Member__c> getAllSalesManager(Site_Visit__c svRecord) {
        List<Team_Member__c> userList = [Select Id, User__r.Name, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c, Team__r.Project__c from Team_Member__c
                                         where Team__r.Project__c =: svRecord.Project__c AND  User_Active_Status__c = true AND Team__r.Team_Type__c = 'Sales Team' ORDER BY Last_Assignment_DateTime__c ASC];
        system.debug('Inside:::'+ userList);
        if(!userList.isEmpty() && userList != null){
            return userList;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static List<Team_Member__c> getPreferredSalesManager(Site_Visit__c svRecord) {
        List<Team_Member__c> userList = new List<Team_Member__c>();
        if(svRecord.Site_Visit_Count__c > 1){
            userList = [Select Id, User__r.Name, DayOff__c, User__c, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c, Team__r.Project__c from Team_Member__c
                        where Team__r.Project__c =: svRecord.Project__c AND  User_Active_Status__c = true AND DayOff__c = false AND Team__r.Team_Type__c = 'Sales Team' AND User__c =: svRecord.Opportunity__r.OwnerId  ORDER BY Last_Assignment_DateTime__c ASC];
        }
        system.debug('getPreferredSalesManager: '+ userList);
        if(!userList.isEmpty() && userList != null){
            return userList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Team_Member__c checkUserAvailability(String userId) {
        System.debug('userId: '+userId);
        Team_Member__c salesManager = [Select Id, User__r.Name, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c, DayOff__c, User__c from Team_Member__c
                                       where ID =: userId AND User_Active_Status__c = true AND Availability__c = true  AND DayOff__c = false  ORDER BY Last_Assignment_DateTime__c ASC limit 1];
        system.debug('salesManager: '+salesManager);
        if(salesManager != Null)
            return salesManager;
        else
            return Null;
    }
    
    @AuraEnabled
    public static boolean assignSalesManager(Site_Visit__c svRecord, Team_Member__c salesManager) {
        Set<Id> teamIdset = new Set<Id>();
        
        if(salesManager.User__c != null){
            teamIdset.add(salesManager.User__c);
        }
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        List<Team_Member__c> updateTmList = new List<Team_Member__c>();
        if(!teamIdset.isEmpty() && teamIdset != null){
            tmList = [Select Id, User__r.Id, Availability__c from Team_Member__c where User__c IN: teamIdset];
        }
        
        if(!tmList.isEmpty() && tmList != null){
            for(Team_Member__c tm: tmList){
                if(tm.Availability__c){
                    tm.Availability__c = false;
                    updateTmList.add(tm);
                }
            }
        }
       
        System.debug('tmList'+tmList);
        svRecord.Sales_Manager__c = salesManager.User__r.Id;
        svRecord.OwnerId = salesManager.User__r.Id;
        svRecord.Is_Sales_Manager_Assigned__c = true;
        svRecord.SM_Assignment_Date__c = System.today();
        // svRecord.SM_Assignment_Date__c = System.now();
        salesManager.Last_Assignment_DateTime__c = System.now();
        salesManager.Last_Assignment_Milliseconds__c = System.now().millisecondGMT();
        if(salesManager.Assignment_Counter__c == null){
            salesManager.Assignment_Counter__c  = 1;
        }else{
            salesManager.Assignment_Counter__c = salesManager.Assignment_Counter__c + 1;
        }
        try {
            update svRecord;
            update salesManager;
            if(!updateTmList.isEmpty() && updateTmList != null){
                update updateTmList; 
            }
            System.debug('svRecord: '+svRecord);
            System.debug('salesManager: '+salesManager);
            return true;
        } catch(Exception ex) {
            System.debug('Error: '+Ex.getMessage());
            return false;   
        }
    }
    
}