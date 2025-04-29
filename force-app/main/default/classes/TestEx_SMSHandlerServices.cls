@isTest
public class TestEx_SMSHandlerServices {
    @isTest
    public static void outboundSMS(){
       
        Test.startTest();
        SMS__c s = new SMS__c();
        s.Mobile__c = '1234567890';
        s.Message__c = 'Test message';
        s.Template_Id__c = 'template123';
        insert s;
        Test.stopTest();
        
    }
    
    
}