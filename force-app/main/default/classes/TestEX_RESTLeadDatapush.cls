@isTest
public class TestEX_RESTLeadDatapush {
    
    @testSetup
    static void setupTestData() {
        // Create a test Lead record
        Lead__c testLead = new Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Mobile__c = '1234567890',
            Email__c = 'testuser@example.com'
        );
        insert testLead;
    } 
    
    @isTest
    static void testSendLeadData_Success() {
        Lead__c testLead = [SELECT Id FROM Lead__c LIMIT 1];
        
        Test.startTest();
        Ex_RESTLeadDatapush.Rest_result result = Ex_RESTLeadDatapush.sendleaddata(testLead.Id);
        Test.stopTest();
        
        //System.assertEquals(200, result.returnCode);
        //System.assertEquals('Lead Data Send Successfully', result.message);
        //System.assertEquals('Test User', result.Name);
        //System.assertEquals('1234567890', result.Mobile);
        //System.assertEquals('testuser@example.com', result.Email);
    }
    
    @isTest
    static void testSendLeadData_InvalidId() {
        Test.startTest();
        Ex_RESTLeadDatapush.Rest_result result = Ex_RESTLeadDatapush.sendleaddata('InvalidId');
        Test.stopTest();
        
        System.assertEquals(204, result.returnCode);
        System.assertEquals('Invalid SFDC ID', result.message);
    }
    
    @isTest
    static void testSendLeadData_NullId() {
        Test.startTest();
        Ex_RESTLeadDatapush.Rest_result result = Ex_RESTLeadDatapush.sendleaddata(null);
        Test.stopTest();
        
        System.assertEquals(204, result.returnCode);
        System.assertEquals('Please Provide SFDC_Id', result.message);
    }
}