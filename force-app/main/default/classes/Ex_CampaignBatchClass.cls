//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 30-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_CampaignBatchClass implements Database.Batchable<sObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = System.today();
        return Database.getQueryLocator([SELECT Id, Name, Start_Date__c, End_Date__c from Campaign__c
                                         WHERE Start_Date__c <= :today AND CreatedDate != today AND Active__c = true]);
    }
    
    public void execute(Database.BatchableContext bc, List<Campaign__c> cList) {
        List<Campaign_Performance__c> cpList = new List<Campaign_Performance__c>();
        
        for(Campaign__c campaign : cList) {
            Campaign_Performance__c cp = new Campaign_Performance__c();
            cp.Campaign__c = campaign.Id;
            cp.Date__c = System.today();
            cpList.add(cp);
        }
        
        if(!cpList.isEmpty() && cpList != null)
            insert cpList;
    }
    
    public void execute(SchedulableContext sc) {
        Ex_CampaignBatchClass batch = new Ex_CampaignBatchClass();
        Database.executeBatch(batch, 200); 
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}