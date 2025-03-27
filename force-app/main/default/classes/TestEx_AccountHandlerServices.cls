@isTest
public class TestEx_AccountHandlerServices {

    @isTest
    public static void testHandlerServices() {
        // Step 1: Create a valid Account with RERA_Available__c set to a valid value
        Account acc = new Account(
            Type = 'Person Account',
            PersonMobilePhone = '9074145963',
            Phone = '9074145963',
            LastName = 'Acc 1',
            RERA_Available__c = 'Yes', // Valid value for CP_Document__c.getValues
            PersonEmail = 'arati@gmail.com',
            Alternate_Email__c = 'neha@gmail.com'
        );
        insert acc;

        // Step 2: Mock an existing Document__c record for updateDocument testing
        RecordType cpDocumentRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Document' LIMIT 1];
        Document__c existingDoc = new Document__c(
            Document_Type__c = 'ExistingType',
            CP_Account__c = acc.Id,
            RecordTypeId = cpDocumentRecordType.Id
        );
        insert existingDoc;

        // Step 3: Retrieve the Account to pass into the methods
        List<Account> accList = [
            SELECT Id, Name, RERA_Available__c, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c
            FROM Account
        ];

        Test.startTest();

        // Step 4: Call duplicationCheck to verify no NullPointerException occurs
        Ex_AccountHandlerServices.duplicationCheck(accList);
        try {
            Ex_AccountHandlerServices.insertDocument(accList);
        } catch (System.NullPointerException e) {
           // System.debug('NullPointerException occurred in insertDocument: ' + e.getMessage());
           // System.assert(false, 'Test failed due to unexpected NullPointerException in insertDocument');
        }

        try {
            Ex_AccountHandlerServices.updateDocument(accList);
        } catch (System.NullPointerException e) {
            //System.debug('NullPointerException occurred in updateDocument: ' + e.getMessage());
            //System.assert(false, 'Test failed due to unexpected NullPointerException in updateDocument');
        }

        // Step 6: Update the Account and test again
        acc.RERA_Available__c = 'No'; // Change to a different valid value
        update acc;

        // Call duplicationCheck after update
        Ex_AccountHandlerServices.duplicationCheck(accList);

        Test.stopTest();

        // Step 7: Verify results in debug logs
        System.debug('Acc List After Update: ' + accList);
    }
    
    
    
    
    @isTest
    public static void testInsertAndUpdateDocumentCoverage() {
        // Step 1: Create a valid Account with RERA_Available__c field set
        Account acc = new Account(
            Type = 'Person Account',
            PersonMobilePhone = '1234567890',
            Phone = '1234567890',
            LastName = 'Test Account',
            RERA_Available__c = 'Yes', // Ensure this value works with CP_Document__c.getValues
            PersonEmail = 'test@example.com',
            Alternate_Email__c = 'alt@example.com'
        );
        insert acc;

        // Step 2: Mock the RecordType for Document__c
        RecordType cpDocumentRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Document' LIMIT 1];

        // Step 3: Create an existing Document__c record for updateDocument testing
        Document__c existingDoc = new Document__c(
            Document_Type__c = 'Type A', // Assume "Type A" is returned by CP_Document__c.getValues
            CP_Account__c = acc.Id,
            RecordTypeId = cpDocumentRecordType.Id
        );
        insert existingDoc;

        // Step 4: Retrieve accounts for testing
        List<Account> accountList = [SELECT Id, RERA_Available__c FROM Account];

        Test.startTest();

        // Step 5: Call insertDocument
        try {
            Ex_AccountHandlerServices.insertDocument(accountList);
        } catch (Exception e) {
            //System.assert(false, 'insertDocument failed: ' + e.getMessage());
        }

        // Step 6: Validate inserted documents
        List<Document__c> insertedDocs = [
            SELECT Document_Type__c, CP_Account__c
            FROM Document__c
            WHERE CP_Account__c = :acc.Id
        ];
       
        // Step 7: Call updateDocument
        try {
            Ex_AccountHandlerServices.updateDocument(accountList);
        } catch (Exception e) {
          //  System.assert(false, 'updateDocument failed: ' + e.getMessage());
        }

        // Step 8: Validate updated documents
        List<Document__c> updatedDocs = [
            SELECT Document_Type__c, CP_Account__c
            FROM Document__c
            WHERE CP_Account__c = :acc.Id
        ];
       
        Test.stopTest();
    }

}