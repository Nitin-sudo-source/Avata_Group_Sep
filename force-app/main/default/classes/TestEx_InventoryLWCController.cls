//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller Tech(Chetan handee)
//  Created Date: 10-01-2024
//-------------------------------------------//
@isTest
public class TestEx_InventoryLWCController {
     @isTest
    public static void testInventoryPage() {
        Project__c pro = new Project__c();
        pro.Name = 'Test Project';
        insert pro;
        
        Tower__c twr = new Tower__c();
        twr.Name = 'TowerA';
        twr.Project__c = pro.Id;
        insert twr;
        
        Tower__c twr1 = new Tower__c();
        twr1.Name = 'TowerA';
        twr1.Project__c = pro.Id;
        insert twr1;
        
        Unit__c un = new Unit__c();
        un.Name = '101';
        un.Purpose__c = 'Sale';
        un.Sale_Status__c = 'Vacant';
        un.Configuration__c = '1 BHK';
        un.Floor__c = 5;
        un.Project__c = pro.Id;
        un.Tower__c = twr.Id;
        insert un;
        
        Unit__c un1 = new Unit__c();
        un1.Name = '101';
        un1.Purpose__c = 'Sale';
        un1.Sale_Status__c = 'Booked';
        un1.Configuration__c = '1 BHK';
        un1.Floor__c = 5;
        un1.Project__c = pro.Id;
        un1.Tower__c = twr.Id;
        insert un1;
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.LastName = 'acc1';
        acc.Phone = '99854857584';
        acc.PersonMobilePhone = '9958455544';
        acc.Alternate_Email__c = 'acc1@gmail.com';
        acc.PersonEmail = 'acc11@gmail.com';
        insert acc;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test op';
        opp.Account__c = acc.Id;
        opp.Project__c = pro.Id;
        insert opp;
        
        Test.startTest();
       	Ex_InventoryLWCController.getOppDetails(opp.Id);
        Ex_InventoryLWCController.getProjectListDetails();
        Ex_InventoryLWCController.getTowerListDetails(pro.Id);
        Ex_InventoryLWCController.getUnitConfigurationMapDetails(twr.Id);
        Ex_InventoryLWCController.getUnitFloorMapDetails(twr.Id);
        Test.stopTest();
        
    }
}