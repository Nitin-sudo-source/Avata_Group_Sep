@isTest
public class testEx_setwebhookurl {

    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}'); // Ensure the status matches what the code expects
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSetup() {
        // Create test data for CallBack_Webhook_URL__c
        CallBack_Webhook_URL__c callBack1 = new CallBack_Webhook_URL__c(Name='Webhook URL-1', Webhook_URL__c='https://example.com/callback1', Status__c='success', AutoNumber__c=1, Created_Date__c=System.now());
        CallBack_Webhook_URL__c callBack2 = new CallBack_Webhook_URL__c(Name='Webhook URL-2', Webhook_URL__c='https://example.com/callback2', Status__c='success', AutoNumber__c=2, Created_Date__c=System.now().addDays(-1));
        insert new List<CallBack_Webhook_URL__c>{callBack1, callBack2};
        
        // Create test data for WA_API_Details_Gupshup__c
        WA_API_Details_Gupshup__c gupShupDetails = new WA_API_Details_Gupshup__c(Name='Test API Detail', appId__c='testAppId', token__c='testToken', isActive__c=true, Project_Name__c='Project A');
        insert gupShupDetails;
    }

    @isTest
    static void testGetCallBackURL() {
        Test.startTest();
        List<CallBack_Webhook_URL__c> result = Ex_SetWebhookURL.getCallBackURL();
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(2, result.size(), 'The size of the result should be 2');
        System.assertEquals('Webhook URL-1', result[0].Name, 'The first result should be Webhook URL-1');
    }

    @isTest
    static void testUpdateURL() {
        // Mocking HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        Ex_SetWebhookURL.updateURL('https://newexample.com/callback');
        Test.stopTest();

        // Verify that a new CallBack_Webhook_URL__c record was created
        List<CallBack_Webhook_URL__c> callBackWebhookURLList = [SELECT Name, Webhook_URL__c, Status__c, AutoNumber__c FROM CallBack_Webhook_URL__c ORDER BY Created_Date__c DESC LIMIT 1];
        System.assertEquals(1, callBackWebhookURLList.size(), 'One new CallBack_Webhook_URL__c record should be created');
        System.assertEquals('https://newexample.com/callback', callBackWebhookURLList[0].Webhook_URL__c, 'The Webhook_URL__c should be updated correctly');
        System.assertEquals('success', callBackWebhookURLList[0].Status__c, 'The Status__c should be updated to success');
        System.assertEquals(3, callBackWebhookURLList[0].AutoNumber__c, 'The AutoNumber__c should be incremented correctly');
    }
}