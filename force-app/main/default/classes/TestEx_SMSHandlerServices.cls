@isTest
public class TestEx_SMSHandlerServices {
    @isTest
    public static void outboundSMS(){
        
        
        
        Vendor__c v = new Vendor__c();
        v.Name = 'Test Vendor';
        v.Vendor_Url__c = 'https://example.com';
        v.Param_1_Name__c = 'param1';
        v.Param_1_Value__c = 'value1';
        v.Param_1_Status__c = true;
        v.Param_2_Name__c = 'param2';
        v.Param_2_Value__c = 'value2';
        v.Param_2_Status__c = true;
        v.Param_3_Name__c = 'param3';
        v.Param_3_Value__c = 'value3';
        v.Param_3_Status__c = true;
        v.Param_4_Name__c = 'param4';
        v.Param_4_Value__c = 'value4';
        v.Param_4_Status__c = true;
        v.Vendor_Status__c = true;
        
        insert v;
        
        
        
        Test.startTest();
        SMS__c s = new SMS__c();
        s.Sender_Mobile_No__c = '1234567890';
        s.Message__c = 'Test message';
        s.Template_Id__c = 'template123';
        insert s;
        Test.stopTest();
        
    }
    
}