//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 16-5-2023
//-------------------------------------------//
public class LeadConversionServices {
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
                acc.Salutation = l.Salutation__c;
                acc.FirstName = l.First_Name__c;
                acc.LastName = l.Last_Name__c;	
                acc.PersonMobilePhone = l.Mobile__c;
                acc.Phone = l.Phone__c;
                acc.PersonEmail = l.Email__c;
                acc.Alternate_Email__c = l.Alternate_Email_Id__c;
                acc.OwnerId = l.OwnerId;
                acc.Age__c = l.Age__c;
                acc.Gender__c = l.Gender__c;
                acc.Designation__c = l.Designation__c;
                acc.Occupation__c = l.Occupation__c;
                acc.Other_Occupation__c = l.Other_Occupation__c;
                acc.Martial_Status__c = l.Martial_Status__c;
                acc.Current_Residence_Configuration__c = l.Current_Residence_Configuration__c;
                acc.House_No__c = l.House_No__c;
                acc.Locality__c = l.Locality__c;
                acc.BillingStreet = l.Street__c;
                acc.BillingCity = l.City__c;
                acc.BillingState = l.State__c;
                acc.BillingCountry = l.Country__c;
                acc.BillingPostalCode = l.PostalCode__c;
                
                insert acc;
                
                Account a = [Select Id, PersoncontactId from Account where Id =: acc.Id];
                leadPersonContactMap.put(l.Id, a.PersonContactId);
                
                if(String.isNotBlank(l.First_Name__c) && l.First_Name__c != null)
                    op.Name = l.First_Name__c+' '+l.Last_Name__c;
                else
               	   op.Name = l.Last_Name__c;
                op.Account__c = acc.Id;
                //op.CloseDate__c = system.today().addDays(60);
                op.Campaign_Custom__c = l.Campaign_Custom__c;
                op.Campaign_Code__c = l.Campaign_Code__c;
                op.Master_Source__c = l.Master_Source__c;
                op.Channel_Partner__c = l.Channel_Partner__c;
                op.Referrer_Name__c = l.Referrer_Name__c;
                op.Project__c = l.Project__c;
                op.Budget__c = l.Budget__c;
                op.Buying_Purpose__c = l.Buying_Purpose__c;
                op.Configuration_Required__c = l.Configuration_Required__c;
                op.Current_Residence_Configuration__c = l.Current_Residence_Configuration__c;
                op.Last_Presales_Call_Date__c = l.Last_Presale_Call_Date__c;
                op.Last_Presale_Call_Comment__c = l.Last_Presale_Call_Comment__c;
                op.Presales_Comment_History__c = l.Presales_Comment_History__c;
                op.Last_Presales_Call_Status__c = l.Last_Presales_Call_Status__c;
                op.Presales_Next_Follow_Up_Date__c = l.Presale_Next_Follow_up_Date__c;
                op.Presales_Date_of_Visit__c = l.Presale_Date_of_Visit__c;
                op.Presales_Call_Count__c = l.Presales_Call_Count__c;
                op.OwnerId = l.OwnerId;
                op.UTM_Medium__c = l.UTM_Medium__c;
                op.UTM_Source__c = l.UTM_Source__c;
                op.Actual_Budget_in_Lakhs__c = l.Actual_Budget_in_Lakhs__c;
                op.Possession_Timeframe_Required__c = l.Possession_Timeframe_Required__c;
                op.Management_Name__c = l.Management_Name__c;
                
                insert op;
                
                l.Account__c = acc.Id;
                l.Opportunity__c = op.Id;
                l.IsConverted__c = true;
                //if(l.Status__c == 'Site Visit Conducted')
                leadUpdateList.add(l);
            } else {
                leadPersonContactMap.put(l.Id, leadIdAccountMap.get(l.Id).PersonContactId);
                
                if(String.isNotBlank(l.First_Name__c) && l.First_Name__c != null)
                    op.Name = l.First_Name__c+' '+l.Last_Name__c;
                else
                op.Name = l.Last_Name__c;
                op.Account__c = leadIdAccountMap.get(l.Id).Id;
                //op.CloseDate__c = system.today().addDays(60);
                op.Campaign_Custom__c = l.Campaign_Custom__c;
                op.Campaign_Code__c = l.Campaign_Code__c;
                op.Master_Source__c = l.Master_Source__c;
                op.Channel_Partner__c = l.Channel_Partner__c;
                op.Referrer_Name__c = l.Referrer_Name__c;
                op.Project__c = l.Project__c;
                op.Budget__c = l.Budget__c;
                op.Buying_Purpose__c = l.Buying_Purpose__c;
                op.Configuration_Required__c = l.Configuration_Required__c;
                op.Last_Presales_Call_Date__c = l.Last_Presale_Call_Date__c;
                op.Last_Presale_Call_Comment__c = l.Last_Presale_Call_Comment__c;
                op.Presales_Comment_History__c = l.Presales_Comment_History__c;
                op.Last_Presales_Call_Status__c = l.Last_Presales_Call_Status__c;
                op.Presales_Next_Follow_Up_Date__c = l.Presale_Next_Follow_up_Date__c;
                op.Presales_Date_of_Visit__c = l.Presale_Date_of_Visit__c;
                op.Presales_Call_Count__c = l.Presales_Call_Count__c;
                op.OwnerId = l.OwnerId;
                op.Actual_Budget_in_Lakhs__c = l.Actual_Budget_in_Lakhs__c;
				op.UTM_Medium__c = l.UTM_Medium__c;
				op.UTM_Source__c = l.UTM_Source__c;
                op.Management_Name__c = l.Management_Name__c;
               // op.Last_SV_attended_by__c = l.OwnerId;
                                // op.Purchase_Timeframe__c = l.Purchase_Timeframe__c;
                // op.Possession_Timeframe_Required__c = l.Possession_Timeframe_Required__c;

                insert op;
                
                l.Account__c = leadIdAccountMap.get(l.Id).Id;
                l.Opportunity__c = op.Id;
                l.IsConverted__c = true;
                //if(l.Status__c == 'Site Visit Conducted')
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
            update leadUpdateList;
        if(!taskUpdateList.isEmpty() && taskUpdateList != null)
            update taskUpdateList;
    }
    
    public static Map<Id, Account> getLeadIdAccountMap(List<Lead__c> leadList) {
        Map<Account, List<DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<DuplicationHandlerServices.duplicateWrapper>>();
        Map<Id, Account> leadIdAccountMap = new Map<Id, Account>();
        Map<Id, Account> leadAccMap = new Map<Id, Account>();
        List<Account> accList = new List<Account>();
        
        for(Lead__c l: leadList) {
            Account a = new Account();
            a.FirstName = l.First_Name__c;
            a.LastName = l.Last_Name__c;
            a.PersonMobilePhone = l.Mobile__c;
            a.Phone = l.Phone__c;
            a.PersonEmail = l.Email__c;
            a.Alternate_Email__c = l.Alternate_Email_Id__c;
            accList.add(a);
            leadAccMap.put(l.Id, a);
        }
        duplicateWrapperMap = DuplicationHandlerServices.duplicationCheckAcccount(accList);
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