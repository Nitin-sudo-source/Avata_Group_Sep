@isTest
public class TestEx_RESTCTICallBack {
    @isTest
    public static void callforLead() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com'
                               );
        insert objUser;
        objUser.OzoneTel_AgentId__c = 'NitinAgent';  
        objUser.Ozontel_Phone__c = '8890909099';
        update objUser;
        
        Project__c pr = new Project__c();
        pr.Name = 'Test Project';
        insert pr;
        
        Campaign__c c = new Campaign__c();
        c.Virtual_Number__c = '912245811703';
        c.Is_CTI_Campaign__c = true;
        c.Project__c = pr.id;
        c.Approver_Status__c = 'Approved';
        c.Start_Date__c = System.today();
        c.Approver_Name__c = UserInfo.getuserId();
        c.Offline_Campaign__c = false;
        insert c;
        
        Campaign__c c2 = new Campaign__c();
        c2.Virtual_Number__c = '912245811703';
        c2.Is_CTI_Campaign__c = true;
        c2.Project__c = pr.id;
        c2.Approver_Status__c = 'Approved';
        c2.Start_Date__c = System.today();
        c2.Approver_Name__c = UserInfo.getuserId();
        c2.Offline_Campaign__c = true;
        //insert c2;
        
        Lead__c ld = new Lead__c();
        ld.Last_Name__c = 'Test Lead';
        ld.IsConverted__c = false;
        ld.Mobile__c = '8871430342';
       // ld.Phone__c = '08871430236';
        ld.Project__c = pr.Id;
        insert ld;
        System.debug('uuiNew: '+ld.Id);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String json = '{"monitorUCID":"9052170564273741","UUI":"a051e000005ivjYAAQ","Did":"912245811703","CampaignName":"Inbound_912245811703","Location":"","CallerID":"8871430342","PhoneName":"NitinAgent","Skill":"","StartTime":"2024-01-19 11:08:57","EndTime":"2024-01-19 11:09:34","TimeToAnswer":"00:00:16","CallDuration":"00:00:37","Duration":"00:00:21","FallBackRule":"AgentDial","DialedNumber":"8839783836","Type":"Manual","AgentID":"NitinAgent","AgentPhoneNumber":"8839783836","AgentUniqueID":"153905","AgentName":"NitinAgent","Disposition":"General Enquiry","HangupBy":"AgentHangup","Status":"Answered","AudioFile":"https://metrosatyam-llp.s3-ap-south-1.amazonaws.com/metrosatyam_llp/DIAd5ba28292b25eeae8b39655802e71d6f.mp3","TransferType":"No Transfers","TransferredTo":"","Comments":"Test Comments","DialStatus":"answered","Apikey":"KKbeac805b1c3c3c4aa63f80b53e0045b8","AgentStatus":"answered","CustomerStatus":"answered","UserName":"metrosatyam_llp","CallerConfAudioFile":"","ConfDuration":"00:00:00","CampaignStatus":"ONLINE","DataUniqueId":"","WrapUpDuration":"00:00:09","HoldDuration":"00:00:00"}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  'https://customization-velocity-7183--satyamsb.sandbox.my.salesforce-sites.com/CTIIntegration/services/apexrest/CTI/CallBack/';
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        Ex_RESTCTICallBack.createCallDetails();
        
        RestRequest req13 = new RestRequest(); 
        RestResponse res13 = new RestResponse();
        String json13 = '{"monitorUCID":"9052170564788891","UUI":"a021e000003xQaBAAU","Did":"912245811703","CampaignName":"Inbound_912245811703","Location":"","CallerID":"8871430342","PhoneName":"NitinAgent","Skill":"","StartTime":"2024-01-19 12:34:48","EndTime":"2024-01-19 12:35:54","TimeToAnswer":"","CallDuration":"00:01:06","Duration":"00:00:00","FallBackRule":"AgentDial","DialedNumber":"8839783836","Type":"Manual","AgentID":"NitinAgent","AgentPhoneNumber":"8839783836","AgentUniqueID":"153905","AgentName":"NitinAgent","Disposition":"","HangupBy":"UserHangup","Status":"NotAnswered","AudioFile":"","TransferType":"No Transfers","TransferredTo":"","Comments":"","DialStatus":"NormalUnspecified","Apikey":"KKbeac805b1c3c3c4aa63f80b53e0045b8","AgentStatus":"answered","CustomerStatus":"NormalUnspecified","UserName":"metrosatyam_llp","CallerConfAudioFile":"","ConfDuration":"00:00:00","CampaignStatus":"ONLINE","DataUniqueId":"","WrapUpDuration":"00:00:00","HoldDuration":"00:00:00"}';
        res13.responseBody = Blob.valueOf(json13);
        req13.requestURI =  'https://customization-velocity-7183--satyamsb.sandbox.my.salesforce-sites.com/CTIIntegration/services/apexrest/CTI/CallBack/';
        req13.httpMethod = 'POST';
        req13.addParameter('data', json13);    
        RestContext.request = req13;
        RestContext.response = res13;
        Ex_RESTCTICallBack.createCallDetails();       
    }
    @isTest
    public static void callforOpportunity() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com'
                               );
        insert objUser;
        objUser.OzoneTel_AgentId__c = 'NitinAgent';  
        objUser.Ozontel_Phone__c = '8890909099';
        update objUser;
        
        Project__c pr = new Project__c();
        pr.Name = 'Test Project';
        insert pr;
        
        Campaign__c c = new Campaign__c();
        c.Virtual_Number__c = '912245811703';
        c.Is_CTI_Campaign__c = true;
        c.Project__c = pr.id;
        c.Approver_Status__c = 'Approved';
        c.Start_Date__c = System.today();
        c.Approver_Name__c = UserInfo.getuserId();
        c.Offline_Campaign__c = false;
        insert c;
        
        Campaign__c c2 = new Campaign__c();
        c2.Virtual_Number__c = '912245811701';
        c2.Is_CTI_Campaign__c = true;
        c2.Project__c = pr.id;
        c2.Approver_Status__c = 'Approved';
        c2.Start_Date__c = System.today();
        c2.Approver_Name__c = UserInfo.getuserId();
        c2.Offline_Campaign__c = true;
        insert c2;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a2 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '08871430230', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        Opportunity__c op = new Opportunity__c(Name = 'Test1', Opportunity_Stage__c = 'In Follow-up', Project__c = pr.Id,Account__c = a2.id,Campaign__c = c2.Id);
        insert op;
        System.debug('op: '+op); 
        
        RestRequest req12 = new RestRequest(); 
        RestResponse res12 = new RestResponse();
        String json12 = '{"monitorUCID":"24705643089100353","UUI":"","Did":"912245811703","CampaignName":"Inbound_912245811703","Location":"Mumbai","CallerID":"08871430230","PhoneName":"NitinAgent","Skill":"General","StartTime":"2024-01-19 11:14:57","EndTime":"2024-01-19 11:15:13","TimeToAnswer":"00:00:06","CallDuration":"00:00:16","Duration":"00:00:10","FallBackRule":"AgentDial","DialedNumber":"8839783836","Type":"InBound","AgentID":"NitinAgent","AgentPhoneNumber":"8839783836","AgentUniqueID":"153905","AgentName":"NitinAgent","Disposition":"General Enquiry","HangupBy":"AgentHangup","Status":"NotAnswered","AudioFile":"https://metrosatyam-llp.s3-ap-south-1.amazonaws.com/metrosatyam_llp/TXR4ef9e8be374ef1541eda283e81d7624f.mp3","TransferType":"No Transfers","TransferredTo":"","Comments":"test","DialStatus":"answered","Apikey":"KKbeac805b1c3c3c4aa63f80b53e0045b8","AgentStatus":"answered","CustomerStatus":"answered","UserName":"metrosatyam_llp","CallerConfAudioFile":"","ConfDuration":"00:00:00","CampaignStatus":"ONLINE","DataUniqueId":"","WrapUpDuration":"00:00:07","HoldDuration":"00:00:00"}';
        res12.responseBody = Blob.valueOf(json12);
        req12.requestURI =  'https://customization-velocity-7183--satyamsb.sandbox.my.salesforce-sites.com/CTIIntegration/services/apexrest/CTI/CallBack/';
        req12.httpMethod = 'POST';
        req12.addParameter('data', json12);    
        RestContext.request = req12;
        RestContext.response = res12;
        Ex_RESTCTICallBack.createCallDetails();
        
        RestRequest req14 = new RestRequest(); 
        RestResponse res14 = new RestResponse();
        String json14 = '{"monitorUCID":"9052170564405871","UUI":"a051e000005ivnfAAA","Did":"912245811701","CampaignName":"Inbound_912245811701","Location":"","CallerID":"08871430230","PhoneName":"NitinAgent","Skill":"","StartTime":"2024-01-19 11:30:58","EndTime":"2024-01-19 11:32:05","TimeToAnswer":"00:00:31","CallDuration":"00:01:07","Duration":"00:00:36","FallBackRule":"AgentDial","DialedNumber":"8839783836","Type":"manual","AgentID":"","AgentPhoneNumber":"8839783836","AgentUniqueID":"","AgentName":"","Disposition":"","HangupBy":"UserHangup","Status":"Answered","AudioFile":"https://metrosatyam-llp.s3-ap-south-1.amazonaws.com/metrosatyam_llp/DIAf74fb2c84117d49a7ac5f0360e4ba3e6.mp3","TransferType":"No Transfers","TransferredTo":"","Comments":"","DialStatus":"answered","Apikey":"KKbeac805b1c3c3c4aa63f80b53e0045b8","AgentStatus":"answered","CustomerStatus":"answered","UserName":"metrosatyam_llp","CallerConfAudioFile":"","ConfDuration":"00:00:00","CampaignStatus":"OFFLINE","DataUniqueId":"","WrapUpDuration":"00:00:00","HoldDuration":"00:00:00"}';
        res14.responseBody = Blob.valueOf(json14);
        req14.requestURI =  'https://customization-velocity-7183--satyamsb.sandbox.my.salesforce-sites.com/CTIIntegration/services/apexrest/CTI/CallBack/';
        req14.httpMethod = 'POST';
        req14.addParameter('data', json14);    
        RestContext.request = req14;
        RestContext.response = res14;
        Ex_RESTCTICallBack.createCallDetails();
    }
}