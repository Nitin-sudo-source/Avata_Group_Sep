@isTest
public class TestEx_TaskHandlerServices {
     @isTest
    public static Project__c createProject() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        return p;
    }
    
    @isTest
    public static void createPresaleCall() {
        Project__c p = createProject();
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1', Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id);
        insert l1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = l1.Id;

        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Busy';
        t.Status = 'Open';
        insert t;
        
        t.Stage__c = 'Incoming';
        t.Sub_Stage__c = '';
        t.Sub_Stage_Reason__c = ' ';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        update t;
    }
	@isTest
    public static void coldCall(){
        
        Project__c p = createProject();
        
        
        
    }  
    
    @isTest
    public static void createSalesCall() {
        Project__c p = createProject();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a = new Account(FirstName = 'Test', LastName = 'Account', PersonMobilePhone = '1122334455',RecordtypeId = rtId);
        insert a;
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp',Account__c = a.Id,Stage__c = 'In Follow-up',Project__c = p.Id);
        insert op;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = op.Id;
        t.Type = 'Sales Call';
        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Busy';
        t.Sub_Stage__c = '';
        t.Sub_Stage_Reason__c = ' ';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        insert t;
    }
    @isTest
    public static void createCPCall() {
        Project__c p = createProject();
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t.Subject = 'CP Call';
        t.WhatId = cp1.Id;
        
        t.Priority = 'Normal';
        t.Call_Status__c = 'Call Completed';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        insert t;
    }
    @isTest
    public static void createCPMeetingCall() {
        Project__c p = createProject();
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Meeting').getRecordTypeId();
        t.Subject = 'CP Meeting';
        t.WhatId = cp1.Id;
       // t.Call_Status__c = 'Call Completed';
        t.Priority = 'Normal';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Meeting_Type__c = 'None';
        t.Status = 'Completed';
        t.Description = 'Test Call';
        insert t;
    }
    @isTest
    public static void testCPLeadCall(){
        Project__c p = createProject();
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        List<Cp_Lead__c> cpLeadList = new List<Cp_Lead__c>();
        Cp_Lead__c cpLead = new Cp_Lead__c();
        cpLead.CP_Project__c = cp1.Id;
        cpLead.First_Name__c = 'Test';
        cpLead.Last_Name__c = 'Call';
        cpLead.Email__c = 'testcplead123@gmail.com';
        cpLead.Phone__c = '6357428767';
        cpLead.Mobile__c = '6666371789';
        insert cpLead;
        
        cpLead.Email__c = 'testcp123@gmail.com';
        update cpLead;
        cpLeadList.add(cpLead);
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Lead Call').getRecordTypeId();
        t.Subject = 'CP Lead Call';
        t.WhatId = cpLead.Id;
       // t.Call_Status__c = 'Call Completed';
        t.Priority = 'Normal';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Meeting_Type__c = 'None';
        t.Status = 'Completed';
        t.Description = 'Test Call';
        insert t;
        
        Test.startTest();
         Ex_CPLeadHandlerServices.duplicationCheck('No', cpLeadList);
        Test.stopTest();
        
    }
     @isTest
    public static void createPresaleCallforAccount() {
        Project__c p = createProject();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455',RecordtypeId = rtId);
        insert a1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = a1.Id;
        t.Type = 'Presales Call';
        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
       // t.Call_Status__c = 'Answered';
        t.Status = 'Open';
        insert t;
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t1.Subject = 'Call';
        t1.WhatId = cp1.Id;
        t1.Type = 'CP Call';
        t1.CallType = 'Inbound';
        t1.Status = 'Completed';
        t1.Priority = 'Normal';
       // t.Call_Status__c = 'Answered';
        t1.Status = 'Open';
        insert t1;
        
        t.Stage__c = 'Incoming';
        t.Sub_Stage__c = '';
        t.Sub_Stage_Reason__c = ' ';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        update t;
    }
    
    

}