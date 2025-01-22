@isTest
public class TestEx_TemplateMediaSelectorHandler {
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"status": "Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void method1(){
        WA_API_Details_Gupshup__c wa = new WA_API_Details_Gupshup__c();
        wa.Name__c = 'ParadiseGroup';
        wa.isActive__c = true;
        wa.token__c = 'Test';
        wa.Connection__c = 'test';
        wa.Channel__c = 'Test';
        wa.Source_Phone__c = '1212121212';
        wa.src_name__c = 'google';
        wa.API_Key__c = 'asdf';
        wa.Project_Name__c = 'Project A';
        insert wa;
        
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        //pro.Lead_validity_in_days__c = 45;
        pro.Public_Link__c = 'www.google.com';
        insert pro;
        
        Lead__c l3 = new Lead__c();
        l3.Last_Name__c = 'Lead__c 1';
        l3.Mobile__c = '1122334455';
        l3.Phone__c = '7887755663';
        //l3.Alternate_Email__c = 'Test@gmail.com';
        l3.Email__c = 'Test2@gmail.com';
        l3.Project__c = pro.Id;
        l3.Last_Presales_Call_Date__c = System.Today();
        l3.Lead_Stage__c = 'Incoming';
        insert l3;
        
        
        
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455');
        insert a1;
        
        Opportunity__c o1 = new Opportunity__c(Name = 'Test1', /*Close_Date__c = System.today(),*/Opportunity_Stage__c = 'In Follow-up', Project__c = pro.Id,Account__c = a1.id);
        insert o1;
        
        
        Whatsapp_Template__c wt= new Whatsapp_Template__c();
        wt.Public_Link_1__c  = 'www.google.com';
        wt.Whatsapp_Template_Name__c = 'wtn';
        wt.Type__c = 'TEXT';
        wt.Public_Link_1__c = 'www.google.com';
        wt.Object__c = 'Lead__c';
        wt.Template_Category__c ='MARKETING';
        wt.Template_Approval_Status__c = 'APPROVED';
        wt.Sample_Text__c= 'tesad';
        wt.Template__c = 'templatewe';
        wt.Parameters__c = 'parameter';
        wt.Value_1__c = 'test';
        wt.Title_1__c = 'Test';
        wt.Type_1__c = 'PHONE_NUMBER';
        wt.Value_2__c = 'test';
        wt.Title_2__c = 'Test';
        wt.Type_2__c = 'URL';
        wt.Reply1__c = 'Yes';
        wt.Reply2__c = 'No';
        insert wt;
        
        Whatsapp_Template__c wt1= new Whatsapp_Template__c();
        wt1.API_Hit_Status__c = 'Success';
        insert wt1;
        
        Whatsapp_Template__c wt2= new Whatsapp_Template__c();
        wt2.Public_Link_1__c  = 'www.google.com';
        wt2.Whatsapp_Template_Name__c = 'wtn';
        wt2.Type__c = 'DOCUMENT';
        wt2.Object__c = 'Opportunity__c';
        wt2.Template_Category__c ='MARKETING';
        wt2.Template_Approval_Status__c = 'APPROVED';
        insert wt2;
        
        Whatsapp_Template__c wt3= new Whatsapp_Template__c();
        wt3.Public_Link_1__c  = 'www.google.com';
        wt3.Whatsapp_Template_Name__c = 'wtn';
        wt3.Type__c = 'DOCUMENT';
        wt3.Object__c = 'Account';
        wt3.Template_Category__c ='MARKETING';
        wt3.Template_Approval_Status__c = 'APPROVED';
        insert wt3;
        
        Whatsapp_Template__c wt4= new Whatsapp_Template__c();
        wt4.Public_Link_1__c  = 'www.google.com';
        wt4.Whatsapp_Template_Name__c = 'wtn';
        wt4.Type__c = 'DOCUMENT';
        wt4.Object__c = 'Site_Visit__c';
        wt4.Template_Category__c ='MARKETING';
        wt4.Template_Approval_Status__c = 'APPROVED';
        insert wt4;
        
        Whatsapp_Template__c wt5= new Whatsapp_Template__c();
        wt5.Public_Link_1__c  = 'www.google.com';
        wt5.Whatsapp_Template_Name__c = 'wtn';
        wt5.Type__c = 'DOCUMENT';
        wt5.Object__c = 'Quotation__c';
        wt5.Template_Category__c ='MARKETING';
        wt5.Template_Approval_Status__c = 'APPROVED';
        insert wt5;
        
                
        List<Whatsapp_Template__c> wtlist = new List<Whatsapp_Template__c>();
        wtlist.add(wt);
        
        string searchTerm = 'wtn';
        List<Id> idlist = new List<Id>();
        idlist.add(l3.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.StartTest();
        Ex_TemplateMediaSelectorHandler.getStaticResources();
        Ex_TemplateMediaSelectorHandler.checkPublicURL(wt.Id);
        Ex_TemplateMediaSelectorHandler.UpdateTemplate(wtlist);
        Ex_TemplateMediaSelectorHandler.searchTemplateRecord(searchTerm);
        Ex_TemplateMediaSelectorHandler.getStaticResourcesforProject();
        Ex_TemplateMediaSelectorHandler.searchProjectRecord('searchTerm');
        
        string tempId = 'test';
       
        Ex_TemplateMediaSelectorHandler.checkPublicURLforProject(pro.id);
        Ex_TemplateMediaSelectorHandler.UpdateProject(new List<Project__c>{pro});
        
        
        Ex_LeadDashboard.getCategory(wt.Object__c, wt.Project__c);
        Ex_LeadDashboard.getTemplate(wt.Template_Category__c, wt.Object__c, wt.Project__c);
        Ex_LeadDashboard.getTemplate(wt2.Template_Category__c, wt2.Object__c,wt2.Project__c);
        Ex_LeadDashboard.getTemplate(wt3.Template_Category__c, wt3.Object__c,wt3.Project__c);
        Ex_LeadDashboard.getTemplate(wt4.Template_Category__c, wt4.Object__c,wt4.Project__c);
        Ex_LeadDashboard.getTemplate(wt5.Template_Category__c, wt5.Object__c,wt5.Project__c);
        Ex_LeadDashboard.previewTemplate(wt.id);
        Ex_LeadDashboard.getLeadsByDateAndProject(System.today(), System.today(), pro.Id, wt.Object__c, l3.Lead_Stage__c, l3.OwnerId);
        Ex_LeadDashboard.getLeadsByDateAndProject(System.today(), System.today(), pro.Id, wt3.Object__c,l3.Lead_Stage__c, l3.OwnerId);
        Ex_LeadDashboard.updateLeadSendWhatsApp(idlist, wt.Id, wt.Object__c);
        Ex_LeadDashboard.getPicklistValues('Lead__c', 'Lead_Stage__c');
        Ex_LeadDashboard.getPicklistValues1('Lead__c', 'Lead_Stage__c');
        Ex_LeadDashboard.getPicklistValues2('Lead__c', 'Lead_Stage__c');
        Ex_LeadDashboard.getPicklistValues3('Lead__c', 'Lead_Stage__c');
        
        
        Test.StopTest();
        
        
       
       
    }
    
    @isTest
    public static void method2(){
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        //pro.Lead_validity_in_days__c = 45;
        pro.Public_Link__c = '';
        insert pro;
        
        List<Project__c> testProjects = new List<Project__c>();
        testProjects.add(pro);
        
         Whatsapp_Template__c wt1= new Whatsapp_Template__c();
        wt1.API_Hit_Status__c = 'Success';
        wt1.Type__c = 'TEXT';
        insert wt1;
        
        List<Whatsapp_Template__c> wtlist = new List<Whatsapp_Template__c>();
       // wtlist.add(wt1);
        
        
        Ex_TemplateMediaSelectorHandler.checkPublicURL('wt1.id');
        Ex_TemplateMediaSelectorHandler.getStaticResources();
        Ex_TemplateMediaSelectorHandler.UpdateTemplate(wtlist);
        Ex_TemplateMediaSelectorHandler.searchTemplateRecord('searchTerm');
        Ex_TemplateMediaSelectorHandler.getStaticResourcesforProject();
        Ex_TemplateMediaSelectorHandler.searchProjectRecord(pro.id);
        
        string tempId = 'test';
       
        Ex_TemplateMediaSelectorHandler.checkPublicURLforProject(pro.id);
        Ex_TemplateMediaSelectorHandler.UpdateProject(testProjects);
        

        
    }
}