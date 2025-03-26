@isTest
public class TestEx_CampaignHandlerServices {

    @isTest
    public static void testMethod1(){
        List<Campaign__c> campaigns = new List<Campaign__c>();
        for (Integer i = 0; i < 5; i++) {
            Campaign__c camp = new Campaign__c(
                Name = 'Test Campaign ' + i,
                //Active__c = true,
                Campaign_Code__c = 'Code' + i,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(10)
            );
            campaigns.add(camp);
        }
        insert campaigns;
        
        List<Lead__c> leads = new List<Lead__c>();
            Lead__c lead = new Lead__c();
                lead.First_Name__c = 'Test';
                lead.Last_Name__c='lead';
            leads.add(lead);
        insert leads;
        
        List<Opportunity__c> opportunities = new List<Opportunity__c>();
        for (Campaign__c camp : [SELECT Id,name FROM Campaign__c]) {
            Opportunity__c opp = new Opportunity__c(
                Name = 'Test Opportunity ' + camp.Name,
                Campaign__c = camp.Id,
                SV_Count__c = 1,
                Stage__c = 'Booked',
                Amount__c = 1000
            );
            opportunities.add(opp);
        }
        insert opportunities;
        
          // Insert test Task records
       /* List<Task> taskList=new List<Task>();
        Task t=new Task();
        t.Call_Status__c='Busy';
        t.Next_Follow_Up_Date__c = system.today().addDays(1);
        insert t;
        taskList.add(t);*/

       /* Booking__c b=new Booking__c();
        b.Booking_Stage__c='Booking In-Process';
        b.CRM_Head__c = UserInfo.getUserId();
        insert b;
        b.Booking_Stage__c='Booking Confirmed';
        update b;*/
        
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign__c camp : [SELECT Id FROM Campaign__c]) {
            campaignIds.add(camp.Id);
        }
        
        List<Lead__c> leadss = [SELECT Id, Campaign__c, Created_Date__c FROM Lead__c LIMIT 1];
        List<Task> tasks = [SELECT Id, Campaign__c, Created_Date__c FROM Task LIMIT 1];
        
        Ex_CampaignHandlerServices.createCampaignPerformance(campaignIds);
        Ex_CampaignHandlerServices.updateCampaignDetails(campaignIds,'Site Visit');
        Ex_CampaignHandlerServices.updateCampaignDetails(campaignIds, 'Booking');
        Ex_CampaignHandlerServices.calculateCampaignPerformance('Lead', leadss, null);
        
        List<Campaign_Performance__c> cpList = [SELECT Lead_Count__c FROM Campaign_Performance__c WHERE Campaign__c = :leads[0].Campaign__c AND Date__c = :leads[0].Created_Date__c];
        Ex_CampaignHandlerServices.calculateCampaignPerformance('t',null,tasks);
    }
}