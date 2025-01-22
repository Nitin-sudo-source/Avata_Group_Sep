//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 19-10-2023
//-------------------------------------------//
public class Ex_LeadConversionServices {
    @InvocableMethod
    public static void convertLead(List<Lead__c> leadList) {
        List<Lead__c> leadUpdateList = new List<Lead__c>();
        List<Task> taskUpdateList = new List<Task>();
        Map<Id, List<Task>> leadTaskMap = new Map<Id, List<Task>>();
        Map<Id, Account> leadIdAccountMap = new Map<Id, Account>();
        Map<Id, Id> leadPersonContactMap = new Map<Id, Id>();
        system.debug('leadlist: ' +leadList);
        leadTaskMap = getLeadTaskMap(leadList);
        leadIdAccountMap = getLeadIdAccountMap(leadList);
        
        for(Lead__c l: leadList) {
            Opportunity__c op = new Opportunity__c();
            
            if(!leadIdAccountMap.containsKey(l.Id)) {
                Account acc = new Account();
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                acc.FirstName = l.First_Name__c;
                acc.LastName = l.Last_Name__c;	
                acc.PersonMobilePhone = l.Mobile__c;
                acc.Phone = l.Phone__c;
                acc.PersonEmail = l.Email__c;
                acc.Alternate_Email__c = l.Alternate_Email_Id__c;
                acc.OwnerId = l.OwnerId;
                acc.Age_Group__c = l.Age_Group__c;
                acc.Gender__c = l.Gender__c;
                acc.Designation__c = l.Designation__c;
                acc.Occupation__c = l.Occupation__c;
                acc.Martial_Status__c = l.Marital_Status__c;
                acc.Current_Residence_Configuration__c = l.Current_Resdient_Configuration__c;
                acc.Company_Name__c = l.Company_Name__c;
                acc.Religion__c	= l.Religion__c;
                acc.Ethnicity__c = l.Ethnicity__c;
                
               
                
                insert acc;
                
                Account a = [Select Id, PersoncontactId from Account where Id =: acc.Id];
                leadPersonContactMap.put(l.Id, a.PersonContactId);
                
                if(String.isNotBlank(l.First_Name__c) && l.First_Name__c != null)
                    op.Name = l.First_Name__c+' '+l.Last_Name__c;
                else
                    op.Name = l.Last_Name__c;
                op.Account__c = acc.Id;
                //op.CloseDate__c = system.today().addDays(60);
                op.Campaign__c = l.Campaign__c;
                op.Campaign_Code__c = l.Campaign_Code__c;
                op.Lead_Source__c = l.Lead_Source__c;
                op.Lead_Sub_Source__c = l.Lead_Sub_Source__c;
                op.Source_Description__c = l.Source_Description__c;
                op.Project__c = l.Project__c;
                op.Budget__c = l.Budget_Range__c;
                op.Buying_Purpose__c = l.Buying_Purpose__c;
                op.Configuration_Required__c = l.Configuration_Required__c;
                op.Project_Type__c = l.Project_Type__c;
                op.Possession_Timeframe_Required__c = l.Possession_Timeframe_Required__c;
                op.Source_of_Finance__c = l.Source_of_Finance__c;
                op.Presales_Next_Follow_Up_Date__c = l.Presale_Next_Follow_up_Date__c;
                op.Presales_Call_Count__c = l.Presales_Call_Count__c;
                op.Last_Presales_Call_Date__c = l.Last_Presales_Call_Date__c;
                op.Presales_Proposed_Visit_Date__c = l.Presale_Date_of_Visit__c;
                op.Presales_Call_Comment__c = l.Presale_Call_Comment__c;
                op.Presales_Comment_History__c = l.Presales_Comment_History__c;
                op.Last_Presales_Call_Status__c = l.Presales_Call_Status__c;
                op.Presales_Manager__c = l.OwnerId;
                op.OwnerId = l.OwnerId;
                op.Phone__c = l.Phone__c;
                op.Alternate_Email_Id__c = l.Alternate_Email_Id__c;
                if(l.Lead_Source__c == 'Channel Partner'){
                    op.Channel_Partner__c = l.Channel_Partner__c;
                    op.CP_Project__c = l.CP_Project__c;
                }
                if(op.Site_Visit_Count__c > 0 && op.Site_Visit_Count__c != null)
                    op.Last_SV_attended_by__c = l.OwnerId;
                insert op;
                
                l.ConvertedAccountId__c = acc.Id;
                l.ConvertedOpportunityId__c = op.Id;
                l.IsConverted__c = true;
                l.Lead_Stage__c = 'Visit Done';
                l.Lead_Sub_Stages__c = 'Visit Done';
                leadUpdateList.add(l);
            } else {
                leadPersonContactMap.put(l.Id, leadIdAccountMap.get(l.Id).PersonContactId);
                
                if(String.isNotBlank(l.First_Name__c) && l.First_Name__c != null)
                    op.Name = l.First_Name__c+' '+l.Last_Name__c;
                else
                    op.Name = l.Last_Name__c;
                op.Account__c = leadIdAccountMap.get(l.Id).Id;
                //op.CloseDate__c = system.today().addDays(60);
                op.Campaign__c = l.Campaign__c;
                op.Campaign_Code__c = l.Campaign_Code__c;
                op.Lead_Source__c = l.Lead_Source__c;
                op.Lead_Sub_Source__c = l.Lead_Sub_Source__c;
                op.Source_Description__c = l.Source_Description__c;
                op.Project__c = l.Project__c;
                op.Budget__c = l.Budget_Range__c;
                op.Buying_Purpose__c = l.Buying_Purpose__c;
                op.Configuration_Required__c = l.Configuration_Required__c;
                op.Presales_Next_Follow_Up_Date__c = l.Presale_Next_Follow_up_Date__c;
                op.Project_Type__c = l.Project_Type__c;
                op.Possession_Timeframe_Required__c = l.Possession_Timeframe_Required__c;
                op.Source_of_Finance__c = l.Source_of_Finance__c;
                
                op.Presales_Call_Count__c = l.Presales_Call_Count__c;
                op.Last_Presales_Call_Date__c = l.Last_Presales_Call_Date__c;
                op.Presales_Proposed_Visit_Date__c = l.Presale_Date_of_Visit__c;
                op.Presales_Call_Comment__c = l.Presale_Call_Comment__c;
                op.Presales_Comment_History__c = l.Presales_Comment_History__c;
                op.Last_Presales_Call_Status__c = l.Presales_Call_Status__c;
                op.OwnerId = l.OwnerId;
                if(l.Lead_Source__c == 'Channel Partner'){
                    op.Channel_Partner__c = l.Channel_Partner__c;
                    op.CP_Project__c = l.CP_Project__c;
                }
                op.Presales_Manager__c = l.OwnerId;
                if(op.Site_Visit_Count__c > 0 && op.Site_Visit_Count__c != null)
                    op.Last_SV_attended_by__c = l.OwnerId;
                	
                insert op;
                
                l.ConvertedAccountId__c = leadIdAccountMap.get(l.Id).Id;
                l.ConvertedOpportunityId__c = op.Id;
                l.IsConverted__c = true;
                l.Lead_Stage__c = 'Visit Done';
                l.Lead_Sub_Stages__c = 'Visit Done';
                leadUpdateList.add(l);
            }
            if(leadTaskMap.containsKey(l.Id)) {
                for(Task t: leadTaskMap.get(l.Id)) {
                    t.WhatId = leadPersonContactMap.get(l.Id);
                    t.WhatId = op.Id;
                    taskUpdateList.add(t);
                }
            }
        }
        if(!leadUpdateList.isEmpty() && leadUpdateList != null)
            system.debug('leadUpdateList is::'+leadUpdateList);
        update leadUpdateList;
        if(!taskUpdateList.isEmpty() && taskUpdateList != null)
            update taskUpdateList;
    }
    
    public static Map<Id, Account> getLeadIdAccountMap(List<Lead__c> leadList) {
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        Map<Id, Account> leadIdAccountMap = new Map<Id, Account>();
        Map<Id, Account> leadAccMap = new Map<Id, Account>();
        List<Account> accList = new List<Account>();
        
        for(Lead__c l: leadList) {
            Account a = new Account();
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            a.FirstName = l.First_Name__c;
            a.LastName = l.Last_Name__c;
            a.PersonMobilePhone = l.Mobile__c;
            a.Phone = l.Phone__c;
            a.PersonEmail = l.Email__c;
            a.Alternate_Email__c = l.Alternate_Email_Id__c;
            accList.add(a);
            leadAccMap.put(l.Id, a);
        }
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accList);
        system.debug('duplicateWrapperMap: '+duplicateWrapperMap);
        
        if(!duplicateWrapperMap.isEmpty() && duplicateWrapperMap != null) {
            for(Lead__c l: leadList) {
                if(duplicateWrapperMap.containsKey(leadAccMap.get(l.Id))) {
                    leadIdAccountMap.put(l.Id, duplicateWrapperMap.get(leadAccMap.get(l.Id))[0].dupAccount);
                }
            }
        }
        return leadIdAccountMap;
    } 
    
    public static Map<Id, List<Task>> getLeadTaskMap(List<Lead__c> leadList) {
        Map<Id, List<Task>> leadTaskMap = new Map<Id, List<Task>>();
        Set<Id> lIdSet = new Set<Id>();
        List<Task> taskList = new List<Task>();
        system.debug('leadlist: ' +leadList);
        for(Lead__c l: leadList) {
            system.debug('lead: ' +l);
            lIdSet.add(l.Id);
        }
        taskList = [Select Id, WhatId from Task where WhatId IN: lIdSet];
        system.debug('taskList: '+taskList);
        
        if(!taskList.isEmpty() && taskList != null) {
            for(Task t: taskList) {
                if(!leadTaskMap.containsKey(t.WhatId)) {
                    List<Task> newList = new List<Task>();
                    newList.add(t);
                    leadTaskMap.put(t.WhatId, newList);
                } else {
                    leadTaskMap.get(t.WhatId).add(t);
                }
            }
        }
        return leadTaskMap;
    } 
}