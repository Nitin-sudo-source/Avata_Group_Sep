@isTest
public class TestEx_CampaignBatchClass {
	@isTest
    public static void testMethod1(){

        List<Campaign__c> campList = new  List<Campaign__c>();
        Campaign__c c = new Campaign__c();
    	c.Name = 'Test Campaign';
        campList.add(c);
        insert c;
        Test.startTest();
        
        Ex_CampaignBatchClass batch = new Ex_CampaignBatchClass();
        Database.QueryLocator queryLocator = batch.start(null);
        batch.execute(null, campList);
    	Test.stopTest();
    }
     

}