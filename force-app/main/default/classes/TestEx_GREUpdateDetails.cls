@isTest
public class TestEx_GREUpdateDetails {

    @testSetup
    static void setupTestData() {
        // Query for the existing Channel Partner Record Type
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner' LIMIT 1];

        // Create an Account with the Channel Partner Record Type
        Account channelPartner = new Account(
            Name = 'Test Channel Partner',
            RecordTypeId = rt.Id,
            PAN_NO__c='6774',
            RERA_Available__c='Yes'
        );
        insert channelPartner;

        Document__c d=new Document__c();
        d.CP_Account__c=channelPartner.id;
        d.Document_Upload_Required__c='yes';
        insert d;
        
        CP_Document__c cpDocument = new CP_Document__c(
            Name = 'Test Document',
           // RERA_Available__c = 'Yes', // Field used by getValues() to find records
            Document_Required__c = 'Required'
            //CP_Account__c=channelPartner.id
        );
        insert cpDocument;
        
        CP_Document__c cpDoc = CP_Document__c.getValues(channelPartner.RERA_Available__c);
        if (cpDoc != null) {
            String customValues = cpDoc.Document_Required__c;
        } else {
            System.debug('No matching CP_Document__c found for RERA_Available__c: ' + channelPartner.RERA_Available__c);
        }
        
        // Create a Project
        Project__c project = new Project__c(
            Name = 'Test Project'
        );
        insert project;

        // Create a CP_Project__c record
        CP_Project__c cpProject = new CP_Project__c(
            Channel_Partner__c = channelPartner.Id,
            Project_Name__c = project.Id
        );
        insert cpProject;

        // Create a Site Visit record
        Site_Visit__c siteVisit = new Site_Visit__c(
            //Name = 'Test Site Visit',
            Lead_Source__c = 'Channel Partner',
            Channel_Partner__c = channelPartner.Id,
            Project__c = project.Id
        );
        insert siteVisit;
    }

    @isTest
    static void testFetchLookupData_Account() {
        Test.startTest();
        // Test the Account lookup functionality
        List<sObject> accounts = Ex_GREUpdateDetails.fetchLookupData('Test', 'Account');
        System.assert(accounts.size() > 0, 'Accounts should be returned.');
        Test.stopTest();
    }

    @isTest
    static void testFetchLookupData_User() {
        Test.startTest();
        // Test the User lookup functionality
        List<sObject> users = Ex_GREUpdateDetails.fetchLookupData('Test', 'User');
        System.assertEquals(0, users.size(), 'No users should be returned as no mock User data is created.');
        Test.stopTest();
    }

    @isTest
    static void testGetSVWrapper() {
        // Query the created Site Visit from setup data
        Site_Visit__c siteVisit = [SELECT Id FROM Site_Visit__c LIMIT 1];

        Test.startTest();
        // Call the method
        Ex_GREUpdateDetails.SVWrapper svWrapper = Ex_GREUpdateDetails.getSVWrapper(siteVisit.Id);
        System.assertNotEquals(null, svWrapper.sv, 'SVWrapper should return the Site Visit record.');
        Test.stopTest();
    }

    @isTest
    static void testUpdateSiteVisit() {
        // Query the created Site Visit from setup data
        Site_Visit__c siteVisit = [SELECT Id, Lead_Source__c, Channel_Partner__c, Project__c FROM Site_Visit__c LIMIT 1];

        // Create a wrapper
        Ex_GREUpdateDetails.SVWrapper svWrapper = new Ex_GREUpdateDetails.SVWrapper();
        svWrapper.sv = siteVisit;

        Test.startTest();
        // Call the updateSiteVisit method
        Ex_GREUpdateDetails.updateSiteVisit(svWrapper);

        // Verify that the Site Visit is updated
        Site_Visit__c updatedSV = [SELECT Id, CP_Project__c FROM Site_Visit__c WHERE Id = :siteVisit.Id];
        System.assertNotEquals(null, updatedSV.CP_Project__c, 'CP_Project__c should be updated.');
        Test.stopTest();
    }
}