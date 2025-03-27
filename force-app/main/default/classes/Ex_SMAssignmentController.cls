public class Ex_SMAssignmentController {
    // Check if Sales Manager is assigned and check if Is_Sales_Manager_Assigned is true
    @AuraEnabled(cacheable=true)
    public static Site_Visit__c getSVRecord(Id recordId) {
        Site_Visit__c svRecord = [SELECT Id, SM_Assignment_Date__c, OwnerId, SV_Count__c , Opportunity__r.OwnerId, Project__r.Name, 
                                  Opportunity__c, Sales_Manager__c, Is_Sales_Manager_Assigned__c 
                                  FROM Site_Visit__c where Id =: recordId];
        system.debug('svRecord:: '+svRecord);
        if(svRecord != Null){
            return svRecord;
        }else{
            return Null;
        }
    }	
    
    // Get all Sales Manager(Team Members) of Project tagged on Site Visit 
    @AuraEnabled
    public static List<Team_Member__c> getAllSalesManager(Site_Visit__c svRecord) {
        List<Team_Member__c> userList = [Select Id, User__r.Name, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, 
                                         Last_Assignment_Milliseconds__c, Team__r.Project__c from Team_Member__c
                                         where Team__r.Project__c =: svRecord.Project__c AND  User_Active_Status__c = true  AND DayOff__c = false 
                                         AND Team__r.Team_Type__c = 'Sales Team' ORDER BY Last_Assignment_DateTime__c ASC];
        system.debug('userList:: '+ userList);
        if(!userList.isEmpty() && userList != null){
            return userList;
        }else{
            return null;
        }
    }
    
    // Get all Sales TL(Team Members) of Project tagged on Site Visit 
    @AuraEnabled
    public static List<Team_Member__c> getAllSalesManagerTL(Site_Visit__c svRecord) {
        List<Team_Member__c> userList = [Select Id, User__r.Name, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, 
                                         Last_Assignment_Milliseconds__c, Team__r.Project__c from Team_Member__c
                                         where Team__r.Project__c =: svRecord.Project__c AND  User_Active_Status__c = true  AND DayOff__c = false 
                                         AND Team__r.Team_Type__c = 'TL Team' ORDER BY Last_Assignment_DateTime__c ASC];
        system.debug('userList .: '+ userList);
        if(!userList.isEmpty() && userList != null){
            return userList;
        }else{
            return null;
        }
    }
    
    // Get the Sales Manager who is Owner of Opportunity according to Avaliablity
    @AuraEnabled
    public static List<Team_Member__c> getPreferredSalesManager(Site_Visit__c svRecord) {
        List<Team_Member__c> userList = new List<Team_Member__c>();
        if(svRecord.SV_Count__c > 1){
            userList = [Select Id, User__r.Name, DayOff__c, User__c, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, 
                        Last_Assignment_Milliseconds__c, Team__r.Project__c from Team_Member__c
                        where Team__r.Project__c =: svRecord.Project__c AND  User_Active_Status__c = true AND DayOff__c = false 
                        AND Team__r.Team_Type__c = 'Sales Team' AND User__c =: svRecord.Opportunity__r.OwnerId  
                        ORDER BY Last_Assignment_DateTime__c ASC];
        }
        system.debug('userList:: '+ userList);
        if(!userList.isEmpty() && userList != null){
            return userList;
        }else{
            return null;
        }
    }
    
    // Handle for checking the User (Team Member) Availability
    @AuraEnabled
    public static Team_Member__c checkUserAvailability(String userId) {
        System.debug('userId .: '+userId);
        Team_Member__c salesManager = [Select Id, User__r.Name, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, 
                                       Last_Assignment_Milliseconds__c, DayOff__c, User__c from Team_Member__c
                                       where ID =: userId AND User_Active_Status__c = true AND Availability__c = true AND DayOff__c = false  
                                       ORDER BY Last_Assignment_DateTime__c ASC limit 1];
        system.debug('salesManager: '+salesManager);
        if(salesManager != Null){
            return salesManager;
        }else{
            return null;
        }
    }
    
    // Assigning the Sales Manager to the Site Visit 
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
                    tm.Availability__c = True;
                    updateTmList.add(tm);
                }
            }
        }
        System.debug('tmList'+tmList);
        svRecord.Sales_Manager__c = salesManager.User__r.Id;
        svRecord.OwnerId = salesManager.User__r.Id;
        svRecord.Is_Sales_Manager_Assigned__c = TRUE;
        svRecord.SM_Assignment_Date__c = System.now();
        salesManager.Last_Assignment_DateTime__c = System.now();
        salesManager.Last_Assignment_Milliseconds__c = System.now().millisecondGMT();
        if(salesManager.Assignment_Counter__c == null){
            salesManager.Assignment_Counter__c  = 1;
        }else{
            salesManager.Assignment_Counter__c = salesManager.Assignment_Counter__c + 1;
        }
        Opportunity__c oppRecord = [SELECT Id, Assignment_Validity_Date__c, Assignment_Date__c,Project__r.Assignment_TAT__c FROM Opportunity__c WHERE Id = :svRecord.Opportunity__c LIMIT 1];
        if (oppRecord != null) {
            oppRecord.Assignment_Date__c = System.today();
            if(oppRecord.Project__r.Assignment_TAT__c != null){
            oppRecord.Assignment_Validity_Date__c = System.today().addDays(Integer.valueOf(oppRecord.Project__r.Assignment_TAT__c));
            }
        }
        try {
            List<SObject> recordsToUpdate = new List<SObject>{ svRecord, salesManager, oppRecord };
                if(!recordsToUpdate.isEmpty() && recordsToUpdate != null){
                    update recordsToUpdate;
                }
            if(!updateTmList.isEmpty() && updateTmList != null){
                update updateTmList; 
            }
            System.debug('svRecord: '+svRecord);
            System.debug('salesManager: '+salesManager);
            System.debug('Opportunity Assignment Date .:' + oppRecord.Assignment_Date__c);
            System.debug('Opportunity Assignment Date updated');
            return true;
        } catch(Exception ex) {
            System.debug('Error: '+Ex.getMessage());
            return false;   
        }
    }
    
    @AuraEnabled
    public static boolean reAssignSalesManager(Site_Visit__c svRecord, Team_Member__c salesManager, Boolean reAssign) {
        System.debug('svRecord: ' + svRecord);
        System.debug('salesManager: ' + salesManager);
        System.debug('reAssign: ' + reAssign);
        
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
                    tm.Availability__c = true;
                    updateTmList.add(tm);
                }
            }
        }
        
        if (salesManager.User__r != null && salesManager.User__r.Id != null) {
            svRecord.Re_Assign_Sales_TL__c = salesManager.User__r.Id;
            svRecord.OwnerId = salesManager.User__r.Id;
        }
        
        svRecord.Is_Sales_TL_Re_Assigned__c = reAssign;
        svRecord.Re_Assignment_Sales_TL_Date__c = System.now();
        
        salesManager.Last_Assignment_DateTime__c = System.now();
        salesManager.Last_Assignment_Milliseconds__c = System.now().millisecondGMT();
        
        if(salesManager.Assignment_Counter__c == null){
            salesManager.Assignment_Counter__c  = 1;
        }else{
            salesManager.Assignment_Counter__c = salesManager.Assignment_Counter__c + 1;
        }
        
        Opportunity__c oppRecord = [SELECT Id, Closing_Manager__c, OwnerId FROM Opportunity__c WHERE Id = :svRecord.Opportunity__c LIMIT 1];
        if (oppRecord != null) {
            oppRecord.OwnerId = salesManager.User__r.Id;
        }
        try {
            List<SObject> recordsToUpdate = new List<SObject>{ svRecord, salesManager, oppRecord };
                if(!recordsToUpdate.isEmpty() && recordsToUpdate != null){
                    update recordsToUpdate;
                }
            if(!updateTmList.isEmpty() && updateTmList != null){
                update updateTmList; 
            }
            return true;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return false;
        }
    }
}