@isTest
public class TestEx_WhatsappTemplate {
	@isTest
    public static void testMethod1(){
		Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;
        
        String objectName = 'Lead__c';
        
        Whatsapp_Template__c wt = new Whatsapp_Template__c();
        wt.Type__c = 'TEXT';
        wt.Parameters__c = 'Param1,Param2';
        wt.Template__c = 'Test';
        wt.Public_Link_1__c = 'www.google.com';
        wt.Template_Kind__c = 'General';
        insert wt;
        
        Whatsapp_Template__c wt1 = new Whatsapp_Template__c();
        wt1.Type__c = 'TEXT';
        wt1.Parameters__c = 'Param1,Param2';
        wt1.Template__c = 'Test';
        wt.Public_Link_1__c = 'www.google.com';
        
        List<Whatsapp_Template__c> wtList = new List<Whatsapp_Template__c>();
        wtList.add(wt1);
        
        List<String> variableList = new List<String>();
        variableList.add('Param1');
        variableList.add('Param2');
        
        test.startTest();
        Ex_WhatsappTemplate.getObjectField(objectName);
        Ex_WhatsappTemplate.getWhatsappTemplate(wt.Id);
        Ex_WhatsappTemplate.getpara(wt.Id);
        Ex_WhatsappTemplate.Save('Test','Test','MARKETING',variableList,'IMAGE','Test','Header',variableList,wtList, wt.Template_Kind__c, pro.id);
        Ex_WhatsappTemplate.QuickSave(wt.Id,'Test','Test','MARKETING',variableList,'IMAGE','Header');
        Ex_WhatsappTemplate.uploadFile('Test','Test',wt.Id,'0');
        Ex_WhatsappTemplate.getApiDetails();
        test.stopTest();
    }
}