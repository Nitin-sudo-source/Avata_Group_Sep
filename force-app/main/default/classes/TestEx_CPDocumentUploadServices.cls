//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 30-11-2023
//-------------------------------------------//
@isTest
public class TestEx_CPDocumentUploadServices {
    @isTest
    public static void testCPAccountDocumentUploads()
    {
        String acRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead 2',RecordTypeId = acRecordTypeID, PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in');
        insert a2;
        Account a3 = new Account(FirstName = 'Test', LastName = 'Lead 2',RecordTypeId = acRecordTypeID, PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in');
        insert a3;
        
        Document__c cpDoc = new Document__c();
        cpDoc.CP_Account__c = a2.Id;
        cpDoc.Uploaded__c = false;
        cpDoc.Document_Type__c = 'Pan Card';
        insert cpDoc;
        
        List<Document__c> result = Ex_CPDocumentUploadServices.CPAccountDocument_Uploads(cpDoc.CP_Account__c);
        
        System.assertEquals(1, result.size());
        System.assertEquals(cpDoc.Id, result[0].Id);
    }
    
    @isTest
    public static void testUploads()
    {
        String acRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead 2',RecordTypeId = acRecordTypeID, PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in');
        insert a2;
        Account a3 = new Account(FirstName = 'Test', LastName = 'Lead 2',RecordTypeId = acRecordTypeID, PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in');
        insert a3;
        
        Document__c cpDoc = new Document__c();
        cpDoc.CP_Account__c = a2.Id;
        cpDoc.Uploaded__c = false;
        cpDoc.Document_Type__c = 'Pan Card';
        insert cpDoc;
        
        ContentVersion cv = new ContentVersion();
        cv.Title='Test title';
        cv.VersionData=Blob.valueOf('Test Content Data');
        cv.PathOnClient='Test';
        insert cv;
        
        ContentDocumentLink testLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1][0].ContentDocumentId,
            LinkedEntityId = cpDoc.Id,
            ShareType = 'V'
        );
        insert testLink;       
        Ex_CPDocumentUploadServices.Uploads(cv.Id);       
    }
    
}