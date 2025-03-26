//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 04-09-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_TaskHandlerServices {
    public static void validationCheckforPresaleCall(Map<Id, List<Task>> taskMap) {
        List<Lead__c> leadList = new List<Lead__c>();
        Map<Id, Lead__c> leadMap = new Map<Id, Lead__c>();
        Map<String, String> stageMap = getStagesMap();
        
        leadList = [Select Id, Name, Lead_Stage__c from Lead__c where Id IN: taskMap.keySet()];
        system.debug('leadList: '+leadList);
        
        if(!leadList.isEmpty()) {
            for(Lead__c l: leadList) {
                leadMap.put(l.Id, l);
            }
        }
        
        if(!leadMap.isEmpty() && leadMap != null) {
            for(Id lId: taskMap.keySet()) {
                for(Task t: taskMap.get(lId)) {
                    if(leadMap.containsKey(lId)) {
                        if(String.isNotBlank(leadMap.get(lId).Lead_Stage__c)) {
                            if(stageMap.containsKey(leadMap.get(lId).Lead_Stage__c)) {
                                if(t.Stage__c != null){
                                    if(stageMap.get(leadMap.get(lId).Lead_Stage__c).containsIgnoreCase(t.Stage__c) == false) {
                                        if(!test.isRunningTest()) {
                                            t.addError('You can not create the task with Stage: '+t.Stage__c+' where Lead Stage is: '+leadMap.get(lId).Lead_Stage__c);
                                        }       
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void CallHandlerServices(Set<Id> taskId, String operation, Boolean count) {
        Map<Id, List<Task>> mapRollUpLead = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpOpp  = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpCp = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpCpLead = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpRegistration = new Map<Id, List<Task>>();
        
        
        
        List<Task> taskList = [Select Id, Status__c, Opportunity_Stage__c, Opportunity_Sub_Stage__c, Opportunity_Sub_Stage_Reason__c, Registration_Date__c, Registration_Scheduled_Date__c, Registration_Venue__c, WhoId, WhatId, CreatedDate, CallType, Call_Status__c, CallDurationInSeconds, Description, Subject, RecordTypeId, RecordType.Name,
                               Stage__c, Sub_Stage__c, Sub_Stage_Reason__c, Next_Follow_Up_Date__c, Proposed_Date_Of_Visit__c, Date__c, Meeting_Type__c,
                               Next_Call_Date__c, Next_Meeting_Date__c, Purpose_of_Meeting__c from Task where Id IN: taskId 
                               AND (RecordType.Name = 'Presales Call' OR RecordType.Name = 'Sales Call'OR  RecordType.Name = 'CP Call' OR RecordType.Name = 'CP Meeting' OR RecordType.Name = 'CP Lead Call' OR RecordType.Name = 'Registration Call')];
        system.debug('taskList: '+taskList);
        
        for(Task t: taskList) {
            if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'Lead__c') {
                if(t.RecordType.Name == 'Presales Call') {
                    if(!mapRollUpLead.containsKey(t.WhatId)) {
                        List<Task> newTaskList = new List<Task>();
                        newTaskList.add(t);
                        mapRollUpLead.put(t.WhatId, newTaskList);
                    } else {
                        mapRollUpLead.get(t.WhatId).add(t);
                    }
                }
            } else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity__c') {
                if(t.RecordType.Name == 'Sales Call') {
                    if(!mapRollUpOpp.containsKey(t.WhatId)) {
                        List<Task> newTaskList = new List<Task>();
                        newTaskList.add(t);
                        mapRollUpOpp.put(t.WhatId, newTaskList);
                    } else {
                        mapRollUpOpp.get(t.WhatId).add(t);
                    }
                }
            } else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'CP_Project__c') {
                if(t.RecordType.Name == 'CP Call') {
                    if(!mapRollUpCp.containsKey(t.WhatId)) {
                        List<Task> newTaskList = new List<Task>();
                        newTaskList.add(t);
                        mapRollUpCp.put(t.WhatId, newTaskList);
                    } else {
                        mapRollUpCp.get(t.WhatId).add(t);
                    }
                } else if(t.RecordType.Name == 'CP Meeting') {
                    if(!mapRollUpCp.containsKey(t.WhatId)) {
                        List<Task> newTaskList = new List<Task>();
                        newTaskList.add(t);
                        mapRollUpCp.put(t.WhatId, newTaskList);
                    } else {
                        mapRollUpCp.get(t.WhatId).add(t);
                    }
                }
            }else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'CP_Lead__c') {
                if(t.RecordType.Name == 'CP Lead Call') {
                    if(!mapRollUpCpLead.containsKey(t.WhatId)) {
                        List<Task> newTaskList = new List<Task>();
                        newTaskList.add(t);
                        mapRollUpCpLead.put(t.WhatId, newTaskList);
                    } else {
                        mapRollUpCpLead.get(t.WhatId).add(t);
                    }
                }
            }else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'Registration__c') {
                if(t.RecordType.Name == 'Registration Call') {
                    if(!mapRollUpRegistration.containsKey(t.WhatId)) {
                        List<Task> newTaskList = new List<Task>();
                        newTaskList.add(t);
                        mapRollUpRegistration.put(t.WhatId, newTaskList);
                    } else {
                        mapRollUpRegistration.get(t.WhatId).add(t);
                    }
                }
            }
        }
        if(!mapRollUpLead.isEmpty()) {
            RollUpTaskLeadServices(mapRollUpLead, operation, count);
        }
        if(!mapRollUpOpp.isEmpty()) {
            RollUpTaskOpportunityServices(mapRollUpOpp, operation, count);
        }
        if(!mapRollUpCp.isEmpty() && mapRollUpCp != null) {
            RollUpTaskCPProjectServices(mapRollUpCp);
        }
        if(!mapRollUpCpLead.isEmpty() && mapRollUpCpLead != null) {
            RollUpTaskCPLeadServices(mapRollUpCpLead);
        }
        if(!mapRollUpRegistration.isEmpty() && mapRollUpRegistration !=null){
            RollUpTaskRegistrationServices(mapRollUpRegistration);
        }
    }
    
    
    public static void RollUpTaskRegistrationServices(Map<Id, List<Task>> mapRollUpRegistration) {
        List<Registration__c> updateRCList = new List<Registration__c>();
        List<Registration__c> rcList = [SELECT Id, Name, Registration_Date__c, Registration_Call_Count__c, Last_Call_Comment__c, Registration_Call_History__c, Last_Call_Status__c, Registration_Venue__c, Registration_Stage__c,  Registration_Scheduled_Date__c
                                   from Registration__c where Id =: mapRollUpRegistration.keySet()];
        system.debug('rcList: '+rcList);
        
        for(Registration__c rc: rcList) {
            List<Task> getcpTaskList = mapRollUpRegistration.get(rc.Id);
            system.debug('getcpTaskList: '+getcpTaskList);
            
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(!getcpTaskList.isEmpty()) {
                for(Task t: getcpTaskList) {
                    if(t.RecordType.Name == 'Registration Call') {
                        if(t.Call_Status__c != null)
                        rc.Last_Call_Status__c = t.Call_Status__c;
                        if(t.Registration_Scheduled_Date__c != null)
                        rc.Registration_Scheduled_Date__c = t.Registration_Scheduled_Date__c;
                        rc.Last_Call_Comment__c = t.Description;
                        if(t.Status__c != null)
                            rc.Registration_Stage__c = t.Status__c;
                        if(t.Registration_Date__c != null)
                            rc.Registration_Date__c = t.Registration_Date__c;
                        if(t.Registration_Venue__c != null){
                            rc.Registration_Venue__c = t.Registration_Venue__c;
                        }
                        
                        if(rc.Registration_Call_Count__c == null)
                            rc.Registration_Call_Count__c = 1;
                        else
                            rc.Registration_Call_Count__c = rc.Registration_Call_Count__c + 1;
                        if(rc.Last_Call_Comment__c != null) {
                            if(rc.Registration_Call_History__c == null)
                                rc.Registration_Call_History__c = '';
                            rc.Registration_Call_History__c = String.ValueOf(myDate)+': ' + rc.Last_Call_Comment__c + '\n' + rc.Registration_Call_History__c ;
                        }
                        updateRCList.add(rc);    
                    }
                }
            }
            system.debug('updateRCList: '+updateRCList);
            if(!updateRCList.isEmpty() && updateRCList != null)
                update updateRCList;
        }
        
    }
    
    
    public static void RollUpTaskLeadServices(Map<Id, List<Task>> mapRollUpLead, String operation, Boolean count) {
        List<Lead__c> updateLeadList = new List<Lead__c>();
        List<Lead__c> leadList = [Select Id, Name, Is_Serviced__c, Lead_Stage__c, Lead_Sub_Stage__c, Lead_Sub_Stage_Reason__c, 
                                  Presales_Last_Call_Date__c, Presales_Last_Call_Comment__c, Presales_Call_Comment_History__c, Presales_Call_Count__c, 
                                  Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c, Presales_Last_Call_Status__c
                                  from Lead__c where Id =: mapRollUpLead.keySet()];
        system.debug('leadList: '+leadList);
        
        for(Lead__c l: leadList) {
            List<Task> getLeadTaskList = mapRollUpLead.get(l.Id);
            system.debug('getLeadTaskList: '+getLeadTaskList);
            
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(!getLeadTaskList.isEmpty()) {
                for(Task t: getLeadTaskList) {
                    if(t.RecordType.Name == 'Presales Call') {
                        l.Presales_Last_Call_Date__c = t.CreatedDate;
                        l.Presales_Next_Follow_up_Date__c = t.Next_Follow_Up_Date__c;
                        l.Presales_Proposed_Visit_Date__c = t.Proposed_Date_Of_Visit__c;
                        l.Presales_Last_Call_Comment__c = t.Description;
                        l.Presales_Last_Call_Status__c = t.Call_Status__c;
                        l.Is_Serviced__c = true;
                        if(t.Stage__c != null) {
                            l.Lead_Stage__c = t.Stage__c;
                            if(t.Sub_Stage__c != null)
                            l.Lead_Sub_Stage__c = t.Sub_Stage__c;
                            if(t.Sub_Stage_Reason__c != null)
                            l.Lead_Sub_Stage_Reason__c = t.Sub_Stage_Reason__c;
                        }
                        if(l.Presales_Call_Count__c == null)
                            l.Presales_Call_Count__c = 0;  
                        if((operation == 'insert' || operation == 'update') && t.Stage__c != null) 
                            l.Presales_Call_Count__c  = l.Presales_Call_Count__c + 1;
                        if(l.Presales_Last_Call_Comment__c != null) {
                            if(l.Presales_Call_Comment_History__c == null)
                                l.Presales_Call_Comment_History__c = '';
                            l.Presales_Call_Comment_History__c = String.ValueOf(myDate)+': ' + l.Presales_Last_Call_Comment__c + '\n' + l.Presales_Call_Comment_History__c ;
                        }
                        updateLeadList.add(l);
                    }
                }
            }
        }
        system.debug('updateLeadList: '+updateLeadList);
        if(!updateLeadList.isEmpty() && updateLeadList != null)
            update updateLeadList;
    }
    
    public static void RollUpTaskOpportunityServices(Map<Id, List<Task>> mapRollUpOpp, String operation, Boolean count) {
        List<Opportunity__c> updateOppList = new List<Opportunity__c>();
        List<Opportunity__c> oppList = [Select Id, Name, Stage__c, Sub_Stage__c, Sub_Stage_Reason__c, 
                                        Sales_Last_Call_Date__c, Sales_Last_Call_Comment__c, Sales_Call_Comment_History__c, Sales_Call_Count__c, 
                                        Sales_Next_Follow_up_Date__c, Sales_Proposed_Visit_Date__c
                                        from Opportunity__c where Id =: mapRollUpOpp.keySet()];
        system.debug('oppList: '+oppList);
        
        for(Opportunity__c op: oppList) {
            List<Task> getOppTaskList = mapRollUpOpp.get(op.Id);
            system.debug('getOppTaskList: '+getOppTaskList);
            
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(!getOppTaskList.isEmpty()) {
                for(Task t: getOppTaskList) {
                    if(t.RecordType.Name == 'Sales Call') {
                        op.Sales_Last_Call_Date__c = t.CreatedDate;
                        op.Sales_Next_Follow_up_Date__c = t.Next_Follow_Up_Date__c  ;
                        op.Sales_Proposed_Visit_Date__c = t.Proposed_Date_Of_Visit__c;
                        op.Sales_Last_Call_Comment__c = t.Description;
                        if(t.Opportunity_Stage__c != null) {
                            op.Stage__c = t.Opportunity_Stage__c;
                            op.Sub_Stage__c = t.Opportunity_Sub_Stage__c;
                            op.Sub_Stage_Reason__c = t.Opportunity_Sub_Stage_Reason__c;
                        }
                        if(op.Sales_Call_Count__c == null)
                            op.Sales_Call_Count__c = 0;
                        if((operation == 'insert' || operation == 'update') && t.Opportunity_Stage__c != null)
                            op.Sales_Call_Count__c = op.Sales_Call_Count__c + 1;
                        if(op.Sales_Last_Call_Comment__c != null) {
                            if(op.Sales_Call_Comment_History__c == null)
                                op.Sales_Call_Comment_History__c ='';
                            op.Sales_Call_Comment_History__c = String.ValueOf(myDate)+': '+op.Sales_Last_Call_Comment__c   + '\n' +  op.Sales_Call_Comment_History__c;
                        }    
                        updateOppList.add(op);    
                    }
                }
            }
        }
        system.debug('updateOppList: '+updateOppList);
        if(!updateOppList.isEmpty() && updateOppList != null)
            update updateOppList;
    }
    
    public static void RollUpTaskCPProjectServices(Map<Id, List<Task>> mapRollUpCp) {
        List<CP_Project__c> updateCPList = new List<CP_Project__c>();
        List<CP_Project__c> CPList = [SELECT Id, Name, Last_CP_Call_Date__c, Last_CP_Call_Remarks__c, Next_Call_Date__c, Last_CP_Call_Status__c, Last_Meeting_Call_Remarks__c,
                                      Last_CP_Meeting_Date__c, Next_Meeting_Date__c, Purpose_of_Meeting__c, Last_CP_Meeting_Status__c,
                                      CreatedDate,CP_Call_Count__c, CP_Meeting_Count__c, CP_Call_Remark_History__c,CP_Meeting_Remark_History__c
                                      from CP_Project__c where Id =: mapRollUpCp.keySet()];
        system.debug('CPList: '+CPList);
        
        for(CP_Project__c cp: CPList) {
            List<Task> getcpTaskList = mapRollUpCp.get(cp.Id);
            system.debug('getcpTaskList: '+getcpTaskList);
            
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(!getcpTaskList.isEmpty()) {
                for(Task t: getcpTaskList) {
                    if(t.RecordType.Name == 'CP Call') {
                        cp.Last_CP_Call_Date__c = Date.valueof(t.CreatedDate);
                        cp.Last_CP_Call_Remarks__c = t.Description;
                        cp.Next_Call_Date__c = t.Next_Call_Date__c;
                        cp.Next_Meeting_Date__c = t.Next_Meeting_Date__c;
                        if(t.Call_Status__c != null)
                            cp.Last_CP_Call_Status__c = t.Call_Status__c; 
                        cp.CP_Call_Count__c = cp.CP_Call_Count__c + 1;
                        if(cp.Last_CP_Call_Remarks__c != null) {
                            if(cp.CP_Call_Remark_History__c == null)
                                cp.CP_Call_Remark_History__c = '';
                            cp.CP_Call_Remark_History__c = String.ValueOf(myDate)+': ' + cp.Last_CP_Call_Remarks__c + '\n' + cp.CP_Call_Remark_History__c ;
                        }
                        updateCPList.add(cp);    
                    } else if(t.RecordType.Name == 'CP Meeting') {
                        cp.Last_CP_Meeting_Date__c = Date.valueof(t.CreatedDate);
                        cp.Last_Meeting_Call_Remarks__c = t.Description;
                        cp.Next_Meeting_Date__c = t.Next_Meeting_Date__c ;
                        if(t.Purpose_of_Meeting__c != null)
                            cp.Purpose_of_Meeting__c = t.Purpose_of_Meeting__c;
                        if(t.Meeting_Type__c != null)
                            cp.Last_Meeting_Type__c = t.Meeting_Type__c;
                        cp.CP_Meeting_Count__c = cp.CP_Meeting_Count__c + 1;
                        if(t.Call_Status__c != null)
                            cp.Last_CP_Meeting_Status__c = t.Call_Status__c; 
                        if(cp.Last_Meeting_Call_Remarks__c != null) {
                            if(cp.CP_Meeting_Remark_History__c == null)
                                cp.CP_Meeting_Remark_History__c = '';
                            cp.CP_Meeting_Remark_History__c = String.ValueOf(myDate)+': ' + cp.Last_Meeting_Call_Remarks__c + '\n' + cp.CP_Meeting_Remark_History__c;
                        }
                        updateCPList.add(cp);    
                    }
                }
            }
            system.debug('updateCPList: '+updateCPList);
            if(!updateCPList.isEmpty() && updateCPList != null)
                update updateCPList;
        }
        
        
    }
    
    public static void RollUpTaskCPLeadServices(Map<Id, List<Task>> mapRollUpCpLead) {
        List<CP_Lead__c> updateCPList = new List<CP_Lead__c>();
        List<CP_Lead__c> CPList = [SELECT Id, CP_Lead_Stage__c,  Cp_Lead_Sub_Stage__c,  Cp_Lead_Sub_Stage_Reason__c, Name, Last_CP_Lead_Call_Date__c, Last_CP_Lead_Call_Comment__c, Proposed_Visit_Date__c, CP_Lead_Next_Follow_up_Date__c, CP_Lead_Call_Count__c, CP_Lead_Call_Comment_History__c
                                   from CP_Lead__c where Id =: mapRollUpCpLead.keySet()];
        system.debug('CPList: '+CPList);
        
        for(CP_Lead__c cp: CPList) {
            List<Task> getcpTaskList = mapRollUpCpLead.get(cp.Id);
            system.debug('getcpTaskList: '+getcpTaskList);
            
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(!getcpTaskList.isEmpty()) {
                for(Task t: getcpTaskList) {
                    if(t.RecordType.Name == 'CP Lead Call') {
                        cp.Last_CP_Lead_Call_Date__c = t.CreatedDate;
                        cp.Last_CP_Lead_Call_Comment__c = t.Description;
                        cp.CP_Lead_Next_Follow_up_Date__c = t.Next_Follow_Up_Date__c;
                        cp.Proposed_Visit_Date__c = t.Proposed_Date_Of_Visit__c;
                        if(t.Stage__c != null){
                            cp.CP_Lead_Stage__c = t.Stage__c;
                            cp.Cp_Lead_Sub_Stage__c = t.Sub_Stage__c;
                            cp.Cp_Lead_Sub_Stage_Reason__c = t.Sub_Stage_Reason__c;
                        }
                        
                        if(cp.CP_Lead_Call_Count__c == null)
                            cp.CP_Lead_Call_Count__c = 1;
                        else
                            cp.CP_Lead_Call_Count__c = cp.CP_Lead_Call_Count__c + 1;
                        if(cp.Last_CP_Lead_Call_Comment__c != null) {
                            if(cp.CP_Lead_Call_Comment_History__c == null)
                                cp.CP_Lead_Call_Comment_History__c = '';
                            cp.CP_Lead_Call_Comment_History__c = String.ValueOf(myDate)+': ' + cp.Last_CP_Lead_Call_Comment__c + '\n' + cp.CP_Lead_Call_Comment_History__c ;
                        }
                        updateCPList.add(cp);    
                    }
                }
            }
            system.debug('updateCPListCPLead: '+updateCPList);
            if(!updateCPList.isEmpty() && updateCPList != null)
                update updateCPList;
        }
        
    }
    
    public static Map<String, String> getStagesMap() {
        Map<String, String> stageMap = new  Map<String, String>();
        List<Stage_Management__c> stageList = [Select Name, Allowed_Stages__c from Stage_Management__c];
        system.debug('stageList: '+stageList);
        
        if(!stageList.isEmpty()) {
            for(Stage_Management__c st: stageList) {
                stageMap.put(st.Name, st.Allowed_Stages__c);
            }
        }
        return stageMap;
    }

    // Send Project Brochure to Customer when Lead stage is 'Prospect' and Sub Stage is 'Hot'
    public static void sendProjectBrochureEmail(Set<Id> leadIdSet) {
        
        // Collect Leads with Project and Email
        List<Lead__c> leads = [ SELECT Id, Name, Email__c, Project__c, Project__r.Name, 
                                        Project__r.Project_Address__c, First_Name__c, Last_Name__c
                                FROM Lead__c 
                                WHERE Id IN: leadIdSet AND
                                      Project__c != null  AND
                                      Email__c != null];
        
        
        // Project Brochures
        Set<Id> projectIDSet = new Set<Id>();
        for (Lead__c lead : leads) {
            projectIDSet.add(lead.Project__c);
        }
        Map<String, Blob> projectBrochures = getProjectBrochuresInBLOB(projectIDSet);
        if (projectBrochures.size() == 0) {
            System.debug('No Project Brochures found');
            return; 
        }

        // Send Email to Customer
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        emailMessages = createEmailMessages(leads, projectBrochures);

        System.debug('emailMessages: ' + emailMessages);
        if (emailMessages.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    for (Messaging.SendEmailError error : result.getErrors()) {
                        System.debug('The following error has occurred: ' + error.getMessage());
                    }
                }
            }
        }
    
        
    }

    public static List<Messaging.SingleEmailMessage> createEmailMessages(List<Lead__c> leads, Map<String, Blob> projectBrochures) {
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Lead__c lead : leads) {

            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setSubject('Thank you for showing interest in our project');
            emailMessage.setPlainTextBody('' + 
                                    'Hi ' + lead.First_Name__c + ' ' + lead.Last_Name__c + ',\n\n' +
                                    'We are excited to introduce '+ lead.Project__r.Name + ', your access to affordable luxury right on ' + lead.Project__r.Project_Address__c + '.\n\n' +
                                    'As requested, I am sharing the project brochure with you and will be happy to assist you with any further queries. Please do allow me the liberty to call you later to take your feedback and possibly book a site visit for you.\n\n' +
                                    'Look forward to speaking with you again soon.\n\n' +
                                    'Best Regards,\n' +
                                    'Team Avant.');  
            emailMessage.setWhatId(lead.Id);
            emailMessage.setToAddresses(new String[] {lead.Email__c});
            emailMessage.setSaveAsActivity(false);
            
            // Get Org Wide Email Address
            String orgWideEmailAddress = getOrgWideEmailAddress();
            if(orgWideEmailAddress != null && orgWideEmailAddress != ''){
                emailMessage.setOrgWideEmailAddressId(orgWideEmailAddress);
            }

            // Attach Project Brochure
            Messaging.EmailFileAttachment emailAttachment = getEmailAttachmentFromVersionData(projectBrochures.get(lead.Project__c), 'ProjectBrochure.pdf');

            emailMessage.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachment});
            emailMessages.add(emailMessage);

        }

        return emailMessages;
    }

    public static Messaging.EmailFileAttachment getEmailAttachmentFromVersionData(Blob versionData, String filename) {
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(filename);
        emailAttachment.setBody(versionData);

        System.debug('emailAttachment: ' + emailAttachment);
        return emailAttachment;
    }

    public static String getOrgWideEmailAddress(){
        String fromEmail = 'info@avantinfra.com';
        String orgWideEmailAddress = '';

        List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :fromEmail];
        if(orgWideEmailAddresses.size() > 0){
            orgWideEmailAddress = orgWideEmailAddresses[0].Id;
        }

        System.debug('orgWideEmailAddress: ' + orgWideEmailAddress);
        return orgWideEmailAddress;
    }

    public static Map<String, Blob> getProjectBrochuresInBLOB(Set<Id> projectIDSet) {

        // Store all Project Brochures
        Map<String, Blob> projectBrochures = new Map<String, Blob>();


        // Get ContentDocumentLink for all documents related to Project
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId
                                                          FROM ContentDocumentLink 
                                                          WHERE LinkedEntityId IN :projectIDSet];
        
        Map<String, String> projectToContentIDMapping = new Map<String, String>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            projectToContentIDMapping.put(contentDocumentLink.LinkedEntityId, contentDocumentLink.ContentDocumentId);
        }
        System.debug('projectToContentIDMapping: ' + projectToContentIDMapping);


        // Get ContentVersion for all ContentDocumentId
        Map<String, Blob> contentLinkToBLOBMappings = new Map<String, Blob>();
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId IN : projectToContentIDMapping.values()];
        System.debug('contentVersions: ' + contentVersions);
        for (ContentVersion contentVersion : contentVersions) {
            contentLinkToBLOBMappings.put(contentVersion.ContentDocumentId, contentVersion.VersionData);
        }
        System.debug('contentLinkToBLOBMappings: ' + contentLinkToBLOBMappings);

        // Map Project to ContentVersion
        for (String projectID : projectToContentIDMapping.keySet()) {
            String contentVersionID = projectToContentIDMapping.get(projectID);
            Blob contentVersion = contentLinkToBLOBMappings.get(contentVersionID);

            System.debug('contentVersionID' + contentVersionID);
            System.debug('contentVersion' + contentVersion);

            projectBrochures.put(projectID, contentVersion);
        }
        System.debug('projectBrochures: ' + projectBrochures);

        return projectBrochures;
    }
}