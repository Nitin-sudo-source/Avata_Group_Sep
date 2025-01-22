//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 30-11-2023
//-------------------------------------------//
@isTest
public class TestEx_CPAccountTriggerHandlerService {
    @isTest
    public static void CreateCPAccount() {
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name='Yes';
        cpd.Document_Required__c='Pan Card, GST Registration Certificate, RERA Certificate, Passport';
        insert cpd;
        
        List<Account> accList = new List<Account>();
      //  Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId();
        
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId(),
            RERA_Available__c = 'Yes',
            MahaRERA_Registration_No__c = 'mah123',
            CP_Type__c = 'ICP',
            Owner_Name__c = 'Test',
            Owner_Mobile_No__c = '8989898989',
            Name_as_per_MahaRERA__c = 'testt'
        );
        insert testAccount;
        accList.add(testAccount);
        
        Ex_CPAccountTriggerHandler.AfterInsert(accList);
        Ex_CPAccountTriggerHandler.BeforeInsert(accList);
        
        
    }
    @isTest
    public static void UpdateCPAccount() {
        CP_Document__c cpd=new CP_Document__c();
        cpd.Name='Yes';
        cpd.Document_Required__c='Pan Card, GST Registration Certificate, RERA Certificate, Passport';
        insert cpd;
        
        List<Account> accList = new List<Account>();
       // Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId();
        
       // Account a1 = new Account(Name = 'Test Account',  RecordTypeId = devRecordTypeId,MahaRERA_Registration_No__c = '123');
       // insert a1;
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId(),
            RERA_Available__c = 'Yes',
            MahaRERA_Registration_No__c = 'mah123',
            CP_Type__c = 'ICP',
            Owner_Name__c = 'Test',
            Owner_Mobile_No__c = '8989898989',
            Name_as_per_MahaRERA__c = 'testt'
        );
        insert testAccount;
        testAccount.MahaRERA_Registration_No__c = '456';
        update testAccount;
        
        Map<Id, Account> oldMap = new Map<Id, Account>{ testAccount.Id => testAccount.clone() };
            Map<Id, Account> newMap = new Map<Id, Account>{ testAccount.Id => testAccount.clone() };
                
                }
    
    
}