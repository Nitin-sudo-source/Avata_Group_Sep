//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 17-10-2023
//-------------------------------------------//
public class Ex_CampaignBatchClass implements Database.Batchable<sObject>,Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = System.today();
        
        return Database.getQueryLocator([
            SELECT  Id, Name, IsActive__c, Start_Date__c, End_Date__c
            FROM Campaign__c
            WHERE Start_Date__c <= :today AND (End_Date__c = NULL OR End_Date__c >= today)
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Campaign__c> scope) {
        List<Campaign_Performance__c> cpList = new List<Campaign_Performance__c>();
        
        for (Campaign__c campaign : scope) {
            Campaign_Performance__c cp = new Campaign_Performance__c();
            cp.Campaign__c = campaign.Id;
            cp.Date__c = System.today();
            cpList.add(cp);
        }
        
        if (!cpList.isEmpty()) {
            insert cpList;
        }
    }
    public void execute(SchedulableContext sc) {
        Ex_CampaignBatchClass batch = new Ex_CampaignBatchClass();
        Database.executeBatch(batch, 200); 
        
        // Schedule the batch to run daily at 12 PM
        //System.schedule('CampaignBatchClass Job', '0 12 0  * * ?', batch);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}