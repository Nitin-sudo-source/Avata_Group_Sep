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
        System.debug('leadIdAccountMap: '+leadIdAccountMap);
         Map<String, Object> projectDetails = getProjectDetails(leadList);
        System.debug('projectDetails: '+projectDetails);
        
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
                acc.Company_Name__c = l.Company_Name__c;
                acc.Age_Group__c = l.Age_Group__c;
                acc.Alternate_Email__c   = l.Alternate_Email__c;
                acc.Current_Residence_Configuration__c = l.Current_Resident_Configuration__c;
                acc.Current_Resident_Status__c = l.Current_Resident_Status__c;
                acc.Source_of_Finance__c = l.Source_of_Finance__c;
                acc.Designation__c = l.Designation__c;
                acc.Ethnicity__c = l.Ethnicity__c;
                acc.Family_Size__c = l.Family_Size__c;
                acc.Gender__c = l.Gender__c;
                acc.Industry__c = l.Industry__c;
                acc.OwnerId = l.OwnerId;
                acc.Marital_Status__c = l.Marital_Status__c;
                acc.Occupation__c = l.Occupation__c;
                acc.Salutation = l.Salutation__c;
                
                
                insert acc;
                
                Account a = [Select Id, PersoncontactId from Account where Id =: acc.Id];
                leadPersonContactMap.put(l.Id, a.PersonContactId);
                
                if(String.isNotBlank(l.First_Name__c) && l.First_Name__c != null)
                    op.Name = l.First_Name__c+' '+l.Last_Name__c;
                else
                    op.Name = l.Last_Name__c;
                 if (projectDetails.containsKey('TAT')) {
                    Integer tat = (Integer) projectDetails.get('TAT');
                    op.Close_Date__c = System.today().addDays(tat);
                }
                op.Account__c = acc.Id;
                if(!l.Direct_Lead__c){
                 op.Lead__c = l.Id;   
                }
                op.Lead_Source__c = l.Lead_Source__c;
                op.Lead_Sub_Source__c = l.Lead_Sub_Source__c;
                op.Source_Description__c = l.Source_Description__c;
                op.Project__c = l.Project__c;
                op.Budget__c = l.Budget_Range__c;
                op.Actual_Budget__c = l.Actual_Budget__c;
                op.Buying_Purpose__c = l.Buying_Purpose__c;
                op.Configuration_Required__c = l.Configuration_Required__c;
                op.Current_Residence_Status__c = l.Current_Resident_Status__c;
                op.Project_Type__c = l.Project_Type__c;
                op.Possession_Timeframe_Required__c = l.Possession_Timeframe_Required__c;
                op.Source_of_Finance__c = l.Source_of_Finance__c;
                op.Presales_Next_Follow_up_Date__c = l.Presales_Next_Follow_up_Date__c;
                op.Presales_Call_Count__c = l.Presales_Call_Count__c;
                op.Last_Presales_Call_Date__c = l.Last_Presales_Call_Date__c;
                op.Presales_Proposed_Visit_Date__c = l.Presales_Date_of_Visit__c;
                op.Last_Presales_Call_Comment__c = l.Presales_Call_Comment__c;
                op.Presales_Comment_History__c = l.Presales_Comment_History__c;
                if(!l.Direct_Lead__c)
                    op.Presales_Manager__c = l.OwnerId;
                op.OwnerId = l.OwnerId;
                op.Project__c = l.Project__c;
                op.Source_of_Finance__c = l.Source_of_Finance__c;
                op.Walkin_Source__c = l.WalkIn_Source__c;
                op.Walkin_Sub_Source__c = l.Walkin_Sub_Source__c;
                op.Preferred_Location__c = l.Preferred_Location__c;
                 if(l.Lead_Stage__c == 'Visit Done'){
                    op.Is_Serviced__c = true;   
                }else{
                    op.Is_Serviced__c = l.Is_Serviced__c;
                }
                if(l.Lead_Source__c == 'Channel Partner'){
                    op.Channel_Partner__c = l.Channel_Partner__c;
                    op.CP_Project__c = l.CP_Project__c;
                    op.Sourcing_Manager__c = l.CP_Project__r.OwnerId;
                }
                if(l.Walkin_Source__c == 'Channel Partner'){
                    op.Channel_Partner__c = l.Channel_Partner__c;
                    op.CP_Project__c = l.CP_Project__c;
                    op.Sourcing_Manager__c = l.CP_Project__r.OwnerId;
                }
                if(l.Lead_Source__c == 'Reference'){
                    op.Walkin_Referrer_Name__c = l.Referrer_Name__c;
                }
                if(l.Walkin_Source__c == 'Reference'){
                    op.Walkin_Referrer_Name__c = l.Referrer_Name__c;
                }
                if(op.SV_Count__c > 0 && op.SV_Count__c != null)
                    op.Last_SV_attended_by__c = l.OwnerId;
                insert op;
                
                l.Account__c = acc.Id;
                l.Opportunity__c = op.Id;
                l.IsConverted__c = true;
                leadUpdateList.add(l);
            } else {
                leadPersonContactMap.put(l.Id, leadIdAccountMap.get(l.Id).PersonContactId);
                
                if(String.isNotBlank(l.First_Name__c) && l.First_Name__c != null)
                    op.Name = l.First_Name__c+' '+l.Last_Name__c;
                else
                    op.Name = l.Last_Name__c;
                if (projectDetails.containsKey('TAT')) {
                    Integer tat = (Integer) projectDetails.get('TAT');
                    op.Close_Date__c = System.today().addDays(tat);
                }
                if(l.Project__r.Opportunity_Source_TAT__c != null){
                    op.Close_Date__c = System.today().addDays(Integer.valueOf(l.Project__r.Opportunity_Source_TAT__c));  
                }
                op.Account__c = leadIdAccountMap.get(l.Id).Id;
                if(!l.Direct_Lead__c){
                 op.Lead__c = l.Id;   
                }
                op.Lead_Source__c = l.Lead_Source__c;
                op.Lead_Sub_Source__c = l.Lead_Sub_Source__c;
                op.Source_Description__c = l.Source_Description__c;
                op.Project__c = l.Project__c;
                op.Budget__c = l.Budget_Range__c;
                op.Actual_Budget__c = l.Actual_Budget__c;
                op.Buying_Purpose__c = l.Buying_Purpose__c;
                op.Configuration_Required__c = l.Configuration_Required__c;
                op.Current_Residence_Status__c = l.Current_Resident_Status__c;
                op.Project_Type__c = l.Project_Type__c;
                op.Possession_Timeframe_Required__c = l.Possession_Timeframe_Required__c;
                op.Source_of_Finance__c = l.Source_of_Finance__c;
                op.Presales_Next_Follow_up_Date__c = l.Presales_Next_Follow_up_Date__c;
                op.Presales_Call_Count__c = l.Presales_Call_Count__c;
                op.Last_Presales_Call_Date__c = l.Last_Presales_Call_Date__c;
                op.Presales_Proposed_Visit_Date__c = l.Presales_Date_of_Visit__c;
                op.Last_Presales_Call_Comment__c = l.Presales_Call_Comment__c;
                op.Presales_Comment_History__c = l.Presales_Comment_History__c;
                if(!l.Direct_Lead__c)
                    op.Presales_Manager__c = l.OwnerId;
                op.OwnerId = l.OwnerId;
                op.Project__c = l.Project__c;
                if(l.Lead_Stage__c == 'Visit Done '){
                    op.Is_Serviced__c = true;   
                }else{
                    op.Is_Serviced__c = l.Is_Serviced__c;
                }
                op.Walkin_Source__c = l.WalkIn_Source__c;
                op.Walkin_Sub_Source__c = l.Walkin_Sub_Source__c;
                if(l.Lead_Source__c == 'Channel Partner'){
                    op.Channel_Partner__c = l.Channel_Partner__c;
                    op.CP_Project__c = l.CP_Project__c;
                    op.Sourcing_Manager__c = l.CP_Project__r.OwnerId;
                }
                if(l.Walkin_Source__c == 'Channel Partner'){
                    op.Channel_Partner__c = l.Channel_Partner__c;
                    op.CP_Project__c = l.CP_Project__c;
                    op.Sourcing_Manager__c = l.CP_Project__r.OwnerId;
                }
                if(l.Lead_Source__c == 'Reference'){
                    op.Walkin_Referrer_Name__c = l.Referrer_Name__c;
                }
                 if(l.Walkin_Source__c == 'Reference'){
                    op.Walkin_Referrer_Name__c = l.Referrer_Name__c;
                }
                if(op.SV_Count__c > 0 && op.SV_Count__c != null)
                    op.Last_SV_attended_by__c = l.OwnerId;
                
                insert op;
                
                l.Account__c = leadIdAccountMap.get(l.Id).Id;
                l.Opportunity__c = op.Id;
                l.IsConverted__c = true;
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
            a.Salutation = l.Salutation__c;
            a.LastName = l.Last_Name__c;
            a.PersonMobilePhone = l.Mobile__c;
            a.Phone = l.Phone__c;
            a.PersonEmail = l.Email__c;
            a.Alternate_Email__c = l.Alternate_Email__c;
            a.Current_Residence_Configuration__c = l.Current_Resident_Configuration__c;
            a.Designation__c = l.Designation__c;
            a.Ethnicity__c = l.Ethnicity__c;
            a.Family_Size__c = l.Family_Size__c;
            a.Gender__c = l.Gender__c;
            a.Industry__c = l.Industry__c;
            a.Marital_Status__c = l.Marital_Status__c;
            a.Occupation__c = l.Occupation__c;
            a.Salutation = l.Salutation__c;
            a.Company_Name__c = l.Company_Name__c;
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
    
    public static Map<String, Object> getProjectDetails(List<Lead__c> leadList) {
        Map<String, Object> projectDetails = new Map<String, Object>();
        Set<Id> leadIds = new Set<Id>();
        
        if (leadList != null && !leadList.isEmpty()) {
            for (Lead__c lead : leadList) {
                leadIds.add(lead.Id);
            }
            List<Lead__c> leadWithProject = [SELECT Id, Project__c, Project__r.Opportunity_Source_TAT__c 
                                             FROM Lead__c 
                                             WHERE Id IN :leadIds AND Project__c != null AND IsConverted__c = true];
            system.debug('leadWithProject: '+leadWithProject);
            if (leadWithProject != null && !leadWithProject.isEmpty()) {
                for (Lead__c lead : leadWithProject) {
                    if (lead.Project__r.Opportunity_Source_TAT__c != null) {
                        Integer tat = Integer.valueOf(lead.Project__r.Opportunity_Source_TAT__c);
                        projectDetails.put('TAT', tat);
                        system.debug('projectDetails: '+projectDetails);
                    }
                   
                }
            }
        }
        return projectDetails;
    }
}