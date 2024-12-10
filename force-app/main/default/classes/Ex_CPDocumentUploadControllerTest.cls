@isTest
public class Ex_CPDocumentUploadControllerTest {

    // Utility method to create test data
    private static Id createTestData() {
        // Create a test CP_Account__c record
        Account testAccount = new Account(Name = 'Test CP Account');
        insert testAccount;

        // Create a Document__c record associated with the CP_Account__c
        Document__c testDocument = new Document__c(
            CP_Account__c = testAccount.Id,
            Document_Type__c = 'Test Type',
            Uploaded__c = false
        );
        insert testDocument;

        return testDocument.Id;
    }

    @isTest
    static void testGetCPDocumentDetails() {
        // Create test data
        Id testDocumentId = createTestData();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // Call the method
        List<Document__c> result = Ex_CPDocumentUploadController.getCPDocumentDetails(testAccount.Id);
        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Expected one document');
        System.assertEquals(testDocumentId, result[0].Id, 'Document ID should match');
    }

    @isTest
    static void testUploadFile() {
        // Create test data
        Id testDocumentId = createTestData();

        // Create a JSON payload for the cpDocumentList parameter
        String jsonPayload = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'Id' => testDocumentId,
                'Uploaded__c' => true,
                'base64' => EncodingUtil.base64Encode(Blob.valueOf('Test Content')),
                'filename' => 'TestFile.txt'
            }
        });

        Test.startTest();
        // Call the uploadFile method
        Id resultId = Ex_CPDocumentUploadController.uploadFile(jsonPayload);
        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, resultId, 'Resulting ID should not be null');

        // Verify that the document was updated
        Document__c updatedDocument = [SELECT Uploaded__c FROM Document__c WHERE Id = :testDocumentId];
        System.assertEquals(true, updatedDocument.Uploaded__c, 'Document should be marked as uploaded');
    }

    @isTest
    static void testCreateContentVersion() {
        Test.startTest();
        // Call the createContentVersion method
        ContentVersion cv = Ex_CPDocumentUploadController.createContentVersion(
            EncodingUtil.base64Encode(Blob.valueOf('Sample Content')),
            'SampleFile.txt'
        );
        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, cv, 'ContentVersion should be created');
        System.assertEquals('SampleFile.txt', cv.Title, 'Filename should match');
    }

    @isTest
    static void testCreateContentLink() {
        // Create test data
        Id testDocumentId = createTestData();

        // Create a ContentVersion record
        ContentVersion cv = Ex_CPDocumentUploadController.createContentVersion(
            EncodingUtil.base64Encode(Blob.valueOf('Sample Content')),
            'SampleFile.txt'
        );

        Test.startTest();
        // Call the createContentLink method
        ContentDocumentLink cdl = Ex_CPDocumentUploadController.createContentLink(cv.Id, testDocumentId);
        Test.stopTest();

        // Assert the result
        System.assertNotEquals(null, cdl, 'ContentDocumentLink should be created');
        System.assertEquals(testDocumentId, cdl.LinkedEntityId, 'LinkedEntityId should match the document');
    }
}