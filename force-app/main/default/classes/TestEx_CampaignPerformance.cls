@isTest
public class TestEx_CampaignPerformance {
@isTest
     public static void testMethod1(){
         
         List<Campaign__c> campaigns = new List<Campaign__c>();
            Campaign__c camp = new Campaign__c();
                camp.Name = 'Test Campaign ';
                camp.Campaign_Code__c = 'Code';
                camp.Start_Date__c = Date.today();
                camp.End_Date__c = Date.today().addDays(10);
            campaigns.add(camp);
        
        insert campaigns;
         
         List<Campaign_Performance__c> campList=new List<Campaign_Performance__c>();
         Campaign_Performance__c camper=new Campaign_Performance__c();
         camper.Lead_Count__c=1;
         camper.Campaign__c=camp.id;
         camper.Amount_Spend__c=1000;
         camper.Enquiry_Count__c=5;
         campList.add(camper);
         
         insert campList;
         
          List<Campaign_Performance__c> campaignPerformances = [SELECT Id, Campaign__c, Amount_Spend__c, Lead_Count__c, Enquiry_Count__c FROM Campaign_Performance__c];

        // Create old and new maps for the after update trigger context
        Map<Id, Campaign_Performance__c> oldMap = new Map<Id, Campaign_Performance__c>(campaignPerformances);
        
        // Update records with new values
        for (Campaign_Performance__c cp : campaignPerformances) {
            if(cp.Amount_Spend__c != null)
            cp.Amount_Spend__c += 500; 
            if(cp.Lead_Count__c != null)
            cp.Lead_Count__c += 5; 
        }
        update campaignPerformances;
        
        Test.startTest();
        Ex_CampaignPerformanceTriggerHandler.afterUpdate(oldMap, new Map<Id, Campaign_Performance__c>([SELECT Id, Campaign__c, Amount_Spend__c, Lead_Count__c, Enquiry_Count__c FROM Campaign_Performance__c]));
        Test.stopTest();
     }
}