@isTest
public class TestEx_LeadConversionServices {
	
    @isTest
    public static void testconvertLead(){
        
        Project__c p = new Project__c();
        p.Name = 'Project 1';
        p.Source_TAT__c = 45;
        p.Assignment_TAT__c = 60;
		insert p;        
        
        // Create an Account record
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.FirstName = 'John';
        acc.LastName = 'Doe';
        acc.Phone = '9999888801';
        insert acc;
        
        List<Lead__c> ldList = new List<Lead__c>();
        
        Lead__c ld1 = new Lead__c();
        ld1.Mobile__c = '9999888801';
        ld1.Email__c = 'nineeight1@gmail.com';
        ld1.Lead_Source__c = 'Google';
        ld1.Lead_Sub_Source__c = 'Google Search';
        ld1.Project__c = p.Id;
        ld1.First_Name__c = 'First Name';
        ld1.Last_Name__c = 'Last name';
        ld1.OwnerId = UserInfo.getUserId();
        ld1.IsConverted__c = true;
        ld1.Account__c = acc.Id; 
        
        Lead__c ld2 = new Lead__c();
        ld2.Mobile__c = '9999888801';
        ld2.Email__c = 'nineeight1@gmail.com';
        ld2.Lead_Source__c = 'Google';
        ld2.Lead_Sub_Source__c = 'Google Search';
        ld2.Project__c = p.Id;
        ld2.Last_Name__c = 'Last name';
        ld2.OwnerId = UserInfo.getUserId();
        ld2.IsConverted__c = true;
        ld2.Account__c = acc.Id;
        
        Lead__c ld3 = new Lead__c();
        ld3.Mobile__c = '9999888801';
        ld3.Email__c = 'nineeight1@gmail.com';
        ld3.Lead_Source__c = 'Channel Partner';
        ld3.Lead_Sub_Source__c = 'Channel Partner';
        ld3.Walkin_Source__c = 'Channel Partner';
        ld3.Walkin_Sub_Source__c = 'Channel Partner';
        ld3.Project__c = p.Id;
        ld3.Last_Name__c = 'Last name';
        ld3.OwnerId = UserInfo.getUserId();
        ld3.IsConverted__c = true;
        ld3.Account__c = acc.Id;
        
        ldList.add(ld1);
        ldList.add(ld2);
        ldList.add(ld3);
        
        insert ldList;
        
        List<Task> taskList = new List<Task>();
    
        Id presalesCallRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Presales_Call' AND SObjectType = 'Task' LIMIT 1].Id;

        Task task1 = new Task();
        task1.Subject = 'Follow Up';
        task1.Next_Follow_Up_Date__c = System.today()+3;
        task1.WhatId = ld1.Id; 
        task1.RecordTypeId = presalesCallRTId;
        insert task1;
                
        Test.startTest();
        Ex_LeadConversionServices.convertLead(ldList);
        Map<Id, List<Task>> resultMap = Ex_LeadConversionServices.getLeadTaskMap(ldList);
        Test.stopTest();
    }

	@isTest
    public static void testconvertLead2(){
        
        Project__c p = new Project__c();
        p.Name = 'Project 1';
        p.Source_TAT__c = 45;
        p.Assignment_TAT__c = 60;
		insert p;        
        
        List<Lead__c> ldList = new List<Lead__c>();
        
        Lead__c ld1 = new Lead__c();
        ld1.Mobile__c = '9999888801';
        ld1.Email__c = 'nineeight1@gmail.com';
        ld1.Lead_Source__c = 'Google';
        ld1.Lead_Sub_Source__c = 'Google Search';
        ld1.Project__c = p.Id;
        ld1.First_Name__c = 'First Name';
        ld1.Last_Name__c = 'Last name';
        ld1.OwnerId = UserInfo.getUserId();
        ld1.IsConverted__c = true; 
        
        Lead__c ld2 = new Lead__c();
        ld2.Mobile__c = '9999888801';
        ld2.Email__c = 'nineeight1@gmail.com';
        ld2.Lead_Source__c = 'Google';
        ld2.Lead_Sub_Source__c = 'Google Search';
        ld2.Project__c = p.Id;
        ld2.Last_Name__c = 'Last name';
        ld2.OwnerId = UserInfo.getUserId();
        ld2.IsConverted__c = true;
        
        Lead__c ld3 = new Lead__c();
        ld3.Mobile__c = '9999888801';
        ld3.Email__c = 'nineeight1@gmail.com';
        ld3.Lead_Source__c = 'Channel Partner';
        ld3.Lead_Sub_Source__c = 'Channel Partner';
        ld3.Walkin_Source__c = 'Channel Partner';
        ld3.Walkin_Sub_Source__c = 'Channel Partner';
        ld3.Project__c = p.Id;
        ld3.Last_Name__c = 'Last name';
        ld3.OwnerId = UserInfo.getUserId();
        ld3.IsConverted__c = true;
        
        ldList.add(ld1);
        ldList.add(ld2);
        ldList.add(ld3);
        
        insert ldList;
        
        List<Task> taskList = new List<Task>();

        Id presalesCallRTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Presales_Call' AND SObjectType = 'Task' LIMIT 1].Id;

        Task task1 = new Task();
        task1.Subject = 'Follow Up';
        task1.Next_Follow_Up_Date__c = System.today()+2;
        task1.WhatId = ld1.Id; 
        task1.RecordTypeId = presalesCallRTId; 
        insert task1;
                
        Test.startTest();
        Ex_LeadConversionServices.convertLead(ldList);
        Map<Id, List<Task>> resultMap = Ex_LeadConversionServices.getLeadTaskMap(ldList);
        Test.stopTest();
    }
}