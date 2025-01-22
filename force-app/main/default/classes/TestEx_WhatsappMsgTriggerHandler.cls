@isTest
public class TestEx_WhatsappMsgTriggerHandler {
	@isTest
    static void sendCustomNotificationtoUser(){
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;
        
        Lead__c ld = new Lead__c();
        ld.First_Name__c = 'Harshal';
        ld.Mobile__c = '2112211221';
        insert ld;
        
        WhatsApp_Message__c w = new WhatsApp_Message__c();
        w.Lead__c = ld.Id;
        w.Message_Text__c = 'Thank you ';
        w.Outbound__c = false;
        w.Success__c = true;
        insert w; 

        Opportunity__c opp = new opportunity__c();
        opp.Name = 'opp1';
        opp.Project__c = pro.id;
        insert opp;
        
        WhatsApp_Message__c w1 = new WhatsApp_Message__c();
        w1.Opportunity__c = opp.Id;
        w1.Message_Text__c = 'Thank you ';
        w1.Outbound__c = false;
        w1.Success__c = true;
        insert w1; 
        
        Booking__c bk = new Booking__c();
        bk.Opportunity__c = opp.Id;
        bk.Project__c = pro.Id;
        insert bk;
        
        WhatsApp_Message__c w2 = new WhatsApp_Message__c();
        w2.Booking__c = bk.Id;
        w2.Message_Text__c = 'Thank you ';
        w2.Outbound__c = false;
        w2.Success__c = true;
        insert w2; 
        

        
        test.startTest();
        Ex_WhatsappMsgTriggerHandler.getRecordById(ld.Id);
        test.stopTest();
    }
}