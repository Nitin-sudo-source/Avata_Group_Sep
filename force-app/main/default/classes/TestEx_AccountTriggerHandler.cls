@isTest
public class TestEx_AccountTriggerHandler {

    @isTest
    static void testBeforeInsert() {
        // Create test data
        RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Person Account' LIMIT 1];
        RecordType channelPartnerRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Channel Partner' LIMIT 1];

        Account personAcc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonMobilePhone = '1234567890',
            RecordTypeId = personAccountRT.Id,
            PAN_NO__c='76767'
        );

        Account channelPartnerAcc = new Account(
            Name = 'Channel Partner Inc.',
            Phone = '9876543210',
            RecordTypeId = channelPartnerRT.Id,
             PAN_NO__c='76767'
        );

        Test.startTest();
        insert new List<Account>{personAcc, channelPartnerAcc};
        Test.stopTest();

        // Assertions to verify behavior
        // Example: Assert if duplication checks were triggered
        // Add relevant asserts based on your service methods
    }

    @isTest
    static void testBeforeUpdate() {
        RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Person Account' LIMIT 1];
        RecordType channelPartnerRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Channel Partner' LIMIT 1];

        // Create test data
        Account personAcc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonMobilePhone = '1234567890',
            RecordTypeId = personAccountRT.Id,
             PAN_NO__c='76767'
        );
        insert personAcc;

        Account channelPartnerAcc = new Account(
            Name = 'Channel Partner Inc.',
            Phone = '9876543210',
            RecordTypeId = channelPartnerRT.Id,
             PAN_NO__c='76767'
        );
        insert channelPartnerAcc;

        // Update test data
        personAcc.PersonMobilePhone = '0987654321';
        channelPartnerAcc.Phone = '1122334455';

        Test.startTest();
        update new List<Account>{personAcc, channelPartnerAcc};
        Test.stopTest();

        // Assertions
        // Add relevant assertions based on behavior in your service methods
    }

    @isTest
    static void testAfterInsert() {
        RecordType channelPartnerRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Channel Partner' LIMIT 1];

        Account channelPartnerAcc = new Account(
            Name = 'Channel Partner Inc.',
            Phone = '9876543210',
            RecordTypeId = channelPartnerRT.Id,
            PAN_NO__c='7786786'
        );

        Test.startTest();
        insert channelPartnerAcc;
        Test.stopTest();

        // Assertions to verify insertDocument method execution
        // Add relevant assertions based on your service methods
    }

    @isTest
    static void testAfterUpdate() {
        RecordType channelPartnerRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Channel Partner' LIMIT 1];

        Account channelPartnerAcc = new Account(
            Name = 'Channel Partner Inc.',
            Phone = '9876543210',
            RERA_Available__c = 'No',
            RecordTypeId = channelPartnerRT.Id,
             PAN_NO__c='76767'
        );
        insert channelPartnerAcc;

        // Update RERA_Available__c to trigger logic
        channelPartnerAcc.RERA_Available__c = 'Yes';

        Test.startTest();
        update channelPartnerAcc;
        Test.stopTest();

        // Assertions to verify updateDocument method execution
        // Add relevant assertions based on your service methods
    }
}