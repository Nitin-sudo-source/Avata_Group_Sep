@isTest
public class TestEx_DigitalLeadHandlerServices {
    @isTest
    public static void createfbLead()
    {
        Map<String, Id> returnMap = new Map<String,Id>();
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a = new Account(FirstName = 'Test', LastName = 'Account',  PersonMobilePhone = '4455667722', RecordtypeId = rtId);
        insert a;
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp', Account__c = a.Id, Stage__c = 'In Follow-up', Close_Date__c = system.today().addDays(30), Project__c = p.id);
        insert op;
        
        Campaign__c camp = new Campaign__c();
        camp.Name = 'Test Campaign ';
        camp.Campaign_Code__c = 'a06H3000000NLnFIAW';
        camp.Lead_Source__c = 'Google';
        camp.Lead_Sub_Source__c = 'YouTube';
        camp.Source_Description__c = 'Social Campaign';
        camp.Project__c=p.id;
        camp.Start_Date__c = Date.today();
        camp.End_Date__c = Date.today().addDays(10);
        insert camp;   
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Campaign ';
        c3.Campaign_Code__c = 'a06H3000000NLnFIAW';
        c3.Lead_Source__c = 'Google';
        c3.Lead_Sub_Source__c = 'YouTube';
        c3.Source_Description__c = 'Social Campaign';
        c3.Project__c=p.id;
        c3.Start_Date__c = Date.today();
        c3.End_Date__c = Date.today().addDays(10);
        insert c3;
        
        Digital_Lead__c dl = new Digital_Lead__c();
         dl.First_Name__c = 'Test';
        dl.Last_Name__c = 'Test fb';
        dl.Location__c = 'Test Location';
        dl.Campaign_Code__c = c3.Campaign_Code__c;
        dl.Mobile__c = '+14455667722';
        dl.Alternate_Mobile__c = '+9994455660822';
        dl.Alternate_Email__c = 'test@fb.com';
        dl.Email__c = 'test@fb.com';
        dl.Platform__c = 'Facebook';
        insert dl;
        
        Digital_Lead__c dl1 = new Digital_Lead__c();
        dl1.Last_Name__c = 'Test fb';
         dl1.First_Name__c = 'Lead';
        dl1.Campaign_Code__c = c3.Campaign_Code__c;
        dl1.Location__c = 'Test Location';
        dl1.Mobile__c = '+17874455667722';
        dl1.Email__c = 'test@fb.com';
        dl1.Alternate_Email__c = 'test@fb.com';
        dl1.Alternate_Mobile__c = '+9994455660777';
        dl1.Platform__c = 'Facebook';
        insert dl1;
        
        Digital_Lead__c dl2 = new Digital_Lead__c();
        dl2.Last_Name__c = 'Test';
         dl2.First_Name__c = 'Lead';
        dl2.Location__c = 'Test Location';
        dl2.Campaign_Code__c = c3.id;
        dl2.Mobile__c = '+18094455667723';
        dl2.Email__c = 'test@fb1.com';
        dl2.Alternate_Email__c = 'test@fb.com';
        dl2.Alternate_Mobile__c = '+8884455660723';
        dl2.Platform__c = 'Facebook';
        insert dl2;  
        
        Digital_Lead__c dl3 = new Digital_Lead__c();
         dl3.First_Name__c = 'Test';
        dl3.Last_Name__c = 'Test1';
        dl3.Campaign_Code__c = c3.id;
        dl3.Location__c = 'Test Location';
        dl3.Mobile__c = '+9984455667723';
        dl3.Alternate_Mobile__c = '+9914455660723';
        dl3.Email__c = 'test@fb1.com';
        dl3.Alternate_Email__c = 'test@fb.com';

        dl3.Platform__c = 'Facebook';
        insert dl3;  
        
        Digital_Lead__c dl4 = new Digital_Lead__c();
        dl4.First_Name__c = 'Test';
        dl4.Location__c = 'Test Location';
        dl4.Last_Name__c = '123';
        dl4.Campaign_Code__c = camp.id;
        dl4.Mobile__c = '+9994455667723';
        dl4.Alternate_Mobile__c = '+9994455660723';
        dl4.Email__c = 'test@fb1.com';
        dl4.Alternate_Email__c = 'test@fb.com';

        dl4.Platform__c = 'Website';
        insert dl4;
        
    }   
    
}