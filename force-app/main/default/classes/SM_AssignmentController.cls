//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class SM_AssignmentController {
    @AuraEnabled
    public static Site_Visit__c getSVRecord(Id RecordSV) {
        Site_Visit__c svRecord = [SELECT Id, OwnerId, Project__r.Name, Sales_Manager__c, Opportunity__r.Last_SV_attended_by__c, Is_Sales_Manager_Assigned__c FROM Site_Visit__c where Id =: RecordSV];
        system.debug('SvRecord::'+svRecord);
        if(svRecord != Null)
            return svRecord;
        else
            return Null;
    }
    
    @AuraEnabled
    public static List<Team_Member__c> getAllSalesManager(Site_Visit__c svRecord) {
        List<Team_Member__c> userList = [Select Id, User__r.Name, User__r.Id, Availability__c, Last_Assignment_DateTime__c from Team_Member__c
                                       	  where Team__r.Project__c =: svRecord.Project__c AND User_Active_Status__c = true AND  Team__r.Team_Type__c = 'Sales Team' ];
        system.debug('UserList:::'+userList);
        return userList;
    }
    
    @AuraEnabled
    public static Team_Member__c checkUserAvailability(Id userId) {
        system.debug('userId'+userId);
        Team_Member__c salesManager = [Select Id, User__r.Name, Availability__c, Last_Assignment_DateTime__c from Team_Member__c 
                                        where Id =: userid AND User_Active_Status__c = true AND Availability__c = true];
        system.debug('SalesManager'+salesManager);
        if(salesManager != Null)
            return salesManager;
        else
            return Null;
    }
    
    @AuraEnabled
    public static boolean assignSalesManager(Site_Visit__c svRecord, Team_Member__c salesManager) {
        svRecord.Sales_Manager__c = salesManager.User__r.Id;
        svRecord.OwnerId = salesManager.User__r.Id;
       // svRecord.Opportunity__r.Last_SV_attended_by__c = salesManager.User__r.Id ; 
        svRecord.Is_Sales_Manager_Assigned__c = true;
        salesManager.Availability__c = false;
        salesManager.Last_Assignment_DateTime__c = system.now();
        
        
        try {
            update svRecord;
            update salesManager;
            return true;
        } catch(Exception ex) {
          return false;   
        }
    }
}