@isTest
public class TestEx_WhatsappMsg {
    
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
    public static void testMethod1(){
        
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;
        
        WA_API_Details_Gupshup__c wa = new WA_API_Details_Gupshup__c();
        wa.Name__c = 'SatyamDevelopersSFDC';
        wa.isActive__c = true;
        wa.token__c = 'Test';
        wa.Connection__c = 'test';
        wa.Channel__c = 'Test';
        wa.Source_Phone__c = '1212121212';
        wa.src_name__c = 'google';
        wa.API_Key__c = 'asdf';
        wa.Project_Name__c = 'Project A';
        insert wa;
        
        Lead__c ld = new Lead__c();
        ld.Mobile__c = '2112211221';
        ld.Project__c = pro.Id;
        insert ld;
        
        Account acc = new Account();
        acc.PersonMobilePhone = '1221122221';
       	//acc.POC_Mobile__c = '1212121212';
        acc.Phone = '1111122222';
        acc.LastName = 'Test';
        insert acc;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Account__c = acc.Id;
        opp.Project__c = pro.Id;
        insert opp;

        Booking__c bk = new Booking__c();
        bk.Opportunity__c = opp.id;
        bk.Project__c = pro.Id;
        insert bk;
        
        Set<Id> recordIds1 = new Set<Id>();
        Set<Id> recordIds2 = new Set<Id>();
        Set<Id> recordIds3 = new Set<Id>();
        String str = ld.Id+',Test';
        List<String> s = new List<String>();
        s.add(str);
        recordIds1.add(ld.Id);
        recordIds2.add(opp.Id);
        recordIds3.add(bk.Id);
        String leadId = ld.Id;
        String oppoId = opp.Id;
        String bkId = bk.Id;
        
        Whatsapp_Template__c wt = new Whatsapp_Template__c();
        wt.Value_1__c = 'test';
        wt.Title_1__c = 'Test';
        wt.Type_1__c = 'PHONE_NUMBER';
        wt.Value_2__c = 'test';
        wt.Title_2__c = 'Test';
        wt.Type_2__c = 'URL';
        wt.Reply1__c = 'Yes';
        wt.Reply2__c = 'No';
        wt.Parameters__c = '{!Lead__r.Mobile}';
        wt.Template_ID__c = 'Test Template';
        wt.Parameters__c = 'Test';
        wt.Template__c = 'Test';
        insert wt;
        
        WhatsApp_Message__c wm = new WhatsApp_Message__c();
        wm.Message_Text__c = 'test';
        wm.Outbound__c = true;
        wm.Message_Type__c = 'Template';
        wm.Lead__c = ld.Id;
        insert wm;
        Map<String, Object> attachmentData = new Map<String, Object>();
        attachmentData.put(wm.Id,wm);
        
        
       	Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        test.startTest();
        Ex_WhatsappMessageServicesNew.Ex_WhatsappMsg(recordIds1,'Test Template');
        Ex_WhatsappMessageServicesNew.Ex_WhatsappMsg(recordIds2,'Test Template');
        Ex_WhatsappMessageServicesNew.Ex_WhatsappMsg(recordIds3,'Test Template');
        Ex_WhatsappMessageServicesNew.sendMessage(recordIds1,'Test Template');
        Ex_WhatsappMessageServicesNew.generateHTMLString(leadId, wt.Parameters__c,wt.Template__c);
        Ex_WhatsappMessageServicesNew.generateHTMLString(oppoId, wt.Parameters__c,wt.Template__c);
        Ex_WhatsappMessageServicesNew.generateHTMLString(bkId, wt.Parameters__c,wt.Template__c);
        Ex_WhatsappMessageServicesNew.getRecordById(ld.Id);
        Ex_WhatsappMessageServicesNew.getPhoneNumber(ld);
        Ex_WhatsappMessageServicesNew.Ex_WhatsappUsingFlow(s);
  
        Ex_whatsAppMsgService.getSObjectName(ld.Id);
        Ex_whatsAppMsgService.getSObjectName(opp.Id);
        Ex_whatsAppMsgService.getSObjectName(bk.Id);
        Ex_whatsAppMsgService.getConversationStartDateTime(ld.Id);
        Ex_whatsAppMsgService.getConversationStartDateTime(opp.Id);
        Ex_whatsAppMsgService.getConversationStartDateTime(bk.Id);
        Ex_whatsAppMsgService.AllMsgs(ld.Id);
        Ex_whatsAppMsgService.AllMsgs(opp.Id);
        Ex_whatsAppMsgService.AllMsgs(bk.Id);
        Ex_whatsAppMsgService.refreshMessages(ld.Id);
        Ex_whatsAppMsgService.refreshMessages(opp.Id);
        Ex_whatsAppMsgService.refreshMessages(bk.Id);
		Ex_whatsAppMsgService.InsertMessage('Hie',ld.Id);
        Ex_whatsAppMsgService.SendTemplate(wt.Id,ld.Id);
        Ex_whatsAppMsgService.getTemplate(ld.Id, 'Marketing');
        Ex_whatsAppMsgService.removeHtmlTags('Hie');
        Ex_whatsAppMsgService.generateHTMLString(ld.Id, '{!Lead__c.First_Name__c}', 'Hie {{1}}');
        Ex_whatsAppMsgService.getAllRecordDetails(ld.Id);
        Ex_whatsAppMsgService.InsertAttachment(attachmentData, 'hi');
      
        test.stopTest();
    }
}