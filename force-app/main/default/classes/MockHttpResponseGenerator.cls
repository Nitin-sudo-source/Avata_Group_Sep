@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
    
    @testSetup
    static void setupTestData() {
        List<SMS__c> smsRecords = new List<SMS__c>();
        for (Integer i = 1; i <= 3; i++) {
            smsRecords.add(new SMS__c(
                Mobile__c = '987654321' + i,
                Message__c = 'Test message ' + i,
                Template_Id__c = 'Temp' + i
            ));
        }
        insert smsRecords;
    }
    
    @isTest
    static void testOutboundSMS() {
        List<SMS__c> testSmsRecords = [SELECT Id FROM SMS__c LIMIT 3];
        Set<Id> smsIds = new Set<Id>();
        for (SMS__c sms : testSmsRecords) {
            smsIds.add(sms.Id);
        }
        
        Test.startTest();
        Ex_SMSTriggerHandlerServices.outboundSMS(smsIds);
        Test.stopTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    }
    
}