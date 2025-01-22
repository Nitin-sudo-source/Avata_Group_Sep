@isTest
public class TestWhatsappTempateTrigger {
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    

    @isTest
    static void testNewTemplateApproval() {
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;
            
        Whatsapp_Template__c testTemplate = new Whatsapp_Template__c();
        testTemplate.Whatsapp_Template_Name__c = 'Test Template';
        testTemplate.Template__c = 'Test Template Content';
        testTemplate.Template_Category__c = 'MARKETING';
        testTemplate.Type__c = 'TEXT';
        testTemplate.Sample_Text__c = 'Test Sample Text';
        testTemplate.Submit_For_Approval__c = false;
        testTemplate.Type_1__c = 'PHONE_NUMBER';
        testTemplate.Value_1__c = 'Test';
        testTemplate.Title_1__c = 'Test';
        testTemplate.Type_2__c = 'URL';
        testTemplate.Value_2__c = 'Test';
        testTemplate.Title_2__c = 'Test';
        testTemplate.Sample_Text__c = 'Test';
        testTemplate.Parameters__c = 'Test';
        testTemplate.Template_ID__c = 'Test';
        testTemplate.API_Hit_Status__c = 'Success';
        testTemplate.Project__c = pro.Id;
        insert testTemplate;
        
        testTemplate.Submit_For_Approval__c = true;
        update testTemplate;
        
        Whatsapp_Template__c testTemplate1 = new Whatsapp_Template__c();
        testTemplate1.Whatsapp_Template_Name__c = 'Test Template';
        testTemplate1.Template__c = 'Test Template Content';
        testTemplate1.Template_Category__c = 'MARKETING';
        testTemplate1.Type__c = 'TEXT';
        testTemplate1.Sample_Text__c = 'Test Sample Text';
        testTemplate1.Submit_For_Approval__c = false;
        testTemplate1.Type_1__c = 'PHONE_NUMBER';
        testTemplate1.Value_1__c = 'Test';
        testTemplate1.Title_1__c = 'Test';
        testTemplate1.Type_2__c = 'URL';
        testTemplate1.Value_2__c = 'Test';
        testTemplate1.Title_2__c = 'Test';
        testTemplate1.Sample_Text__c = 'Test';
        testTemplate1.Parameters__c = 'Test';
        testTemplate1.Template_ID__c = 'Test';
        testTemplate1.Reply1__c = 'Test';
        testTemplate1.Reply2__c = 'Test';
        testTemplate1.API_Hit_Status__c = 'Success';
        testTemplate1.Project__c = pro.Id;
        insert testTemplate1;
        
        testTemplate1.Submit_For_Approval__c = true;
        testTemplate1.Response__c ='{"status":"success","template":{"appId":"c74bca9d-47f1-413b-a2e7-5453f58248be","category":"MARKETING","containerMeta":"{\"appId\":\"c74bca9d-47f1-413b-a2e7-5453f58248be\",\"data\":\"We missed you at {{1}} as per your schedule. Do call us again to reschedule your site visit. We look forward to see you. For your convenience call us\\n\",\"buttons\":[{\"type\":\"PHONE_NUMBER\",\"text\":\"Call\",\"phone_number\":\"919856764565\"}],\"header\":\"\",\"sampleText\":\"We missed you at [Sai World] as per your schedule. Do call us again to reschedule your site visit. We look forward to see you. For your convenience call us\\n\",\"sampleHeader\":\"\",\"enableSample\":true,\"editTemplate\":false,\"allowTemplateCategoryChange\":true,\"addSecurityRecommendation\":false}","createdOn":1710240104444,"data":"We missed you at {{1}} as per your schedule. Do call us again to reschedule your site visit. We look forward to see you. For your convenience call us\n | [Call,919856764565]","elementName":"missedscheduledvisit","id":"29e99312-f7a9-4999-8b1b-826eeb245028","languageCode":"en_US","languagePolicy":"deterministic","meta":"{\"example\":\"We missed you at [Sai World] as per your schedule. Do call us again to reschedule your site visit. We look forward to see you. For your convenience call us\\n\"}","modifiedOn":1710240104444,"namespace":"33ec7780_fbe6_48e6_910d_bea285d6d22b","priority":1,"quality":"UNKNOWN","retry":0,"stage":"NONE","status":"PENDING","templateType":"TEXT","vertical":"TEXT","wabaId":"222712344266196"}}';
        update testTemplate1;
        
        
        
        Whatsapp_Template__c testTemplate2 = new Whatsapp_Template__c();
        testTemplate2.Whatsapp_Template_Name__c = 'Test Template';
        testTemplate2.Template__c = 'Test Template Content';
        testTemplate2.Template_Category__c = 'MARKETING';
        testTemplate2.Type__c = 'TEXT';
        testTemplate2.Sample_Text__c = 'Test Sample Text';
        testTemplate2.Submit_For_Approval__c = false;
        testTemplate2.Type_1__c = 'PHONE_NUMBER';
        testTemplate2.Value_1__c = 'Test';
        testTemplate2.Title_1__c = 'Test';
        testTemplate2.Type_2__c = 'URL';
        testTemplate2.Value_2__c = 'Test';
        testTemplate2.Title_2__c = 'Test';
        testTemplate2.Sample_Text__c = 'Test';
        testTemplate2.Parameters__c = 'Test';
        testTemplate2.Template_ID__c = 'Test';
        testTemplate2.Reply1__c = 'Test';
        testTemplate2.Reply2__c = 'Test';
        testTemplate2.API_Hit_Status__c = 'Failed';
        testTemplate2.Project__c = pro.Id;
        insert testTemplate2;
        
        testTemplate2.Submit_For_Approval__c = true;
        update testTemplate2;
        
        Whatsapp_Template__c testTemplate3 = new Whatsapp_Template__c();
        testTemplate3.Whatsapp_Template_Name__c = 'Test Template';
        testTemplate3.Template__c = 'Test Template Content';
        testTemplate3.Template_Category__c = 'MARKETING';
        testTemplate3.Type__c = 'TEXT';
        testTemplate3.Submit_For_Approval__c = false;
        testTemplate3.Type_1__c = 'PHONE_NUMBER';
        testTemplate3.Value_1__c = 'Test';
        testTemplate3.Title_1__c = 'Test';
        testTemplate3.Type_2__c = 'URL';
        testTemplate3.Value_2__c = 'Test';
        testTemplate3.Title_2__c = 'Test';
        testTemplate3.Template_ID__c = 'Test';
        testTemplate3.Reply1__c = 'Test';
        testTemplate3.Reply2__c = 'Test';
        testTemplate3.API_Hit_Status__c = 'Success';
        testTemplate3.Project__c = pro.Id;
        insert testTemplate3;
        
        
        WA_API_Details_Gupshup__c wa = new WA_API_Details_Gupshup__c();
        wa.EndPoint__c = 'www.google.com';
        wa.token__c = 'Test';
        wa.Connection__c = 'Test';
        wa.Project_Name__c = 'Project A';
        wa.IsActive__c = true;
        insert wa;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        Ex_WhatsappTemplateApproval.newTemplateApproval(testTemplate.Id); 
        Ex_WhatsappTemplateApproval.newTemplateApproval(testTemplate1.Id);
        Ex_WhatsappTemplateApproval.newTemplateApproval(testTemplate2.Id);
        Ex_WhatsappTemplateApproval.newTemplateApproval(testTemplate3.Id);
        Test.stopTest();

        testTemplate = [SELECT Id, API_Hit_Status__c, Request__c, Response__c, Template_ID__c, Template_Approval_Status__c, Rejected_Reason__c FROM Whatsapp_Template__c WHERE Id = :testTemplate.Id];
    }

    @isTest
    static void testTemplateApprovalStatusUpdate() {
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;
        
        Whatsapp_Template__c testTemplate = new Whatsapp_Template__c();
        testTemplate.Whatsapp_Template_Name__c = 'Test Template';
        testTemplate.Template__c = 'Test Template Content';
        testTemplate.Template_Category__c = 'MARKETING';
        testTemplate.Type__c = 'TEXT';
        testTemplate.Sample_Text__c = 'Test Sample Text';
        testTemplate.Check_Template_Status__c = false;
        testTemplate.Reply1__c = 'Test';
        testTemplate.Reply2__c = 'Test';
        testTemplate.Type_1__c = 'PHONE_NUMBER';
        testTemplate.Value_1__c = 'Test';
        testTemplate.Title_1__c = 'Test';
        testTemplate.Type_2__c = 'URL';
        testTemplate.Value_2__c = 'Test';
        testTemplate.Title_2__c = 'Test';
        testTemplate.Sample_Text__c = 'Test';
        testTemplate.Parameters__c = 'Test';
        testTemplate.Template_ID__c = 'Test';
        testTemplate.Project__c = pro.Id;
        insert testTemplate;
        
        testTemplate.Check_Template_Status__c = true;
        update testTemplate;
        
        WA_API_Details_Gupshup__c wa = new WA_API_Details_Gupshup__c();
        wa.EndPoint__c = 'www.google.com';
        wa.token__c = 'Test';
        wa.Connection__c = 'Test';
        wa.Project_Name__c = 'Project A';
        wa.isActive__c = true;
        wa.appId__c = 'ass';
        insert wa;
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        Ex_WhatsappTemplateApproval.templateApprovalStatusUpdate(testTemplate.Id);
        Test.stopTest();


        testTemplate = [SELECT Id, API_Hit_Status__c, Request__c, Response__c, Template_Approval_Status__c, Rejected_Reason__c FROM Whatsapp_Template__c WHERE Id = :testTemplate.Id];
    }
}