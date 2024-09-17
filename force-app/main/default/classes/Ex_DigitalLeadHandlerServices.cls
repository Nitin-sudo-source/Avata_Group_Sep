//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 05-09-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_DigitalLeadHandlerServices {
    public static void leadProcess(Set<Id> dLeadId) {
        List<Opportunity__c> oppList = New List<Opportunity__c>();
        String mobile = '';
        String altMobile = '';
        String details = '';
        
        List<Digital_Lead__c> dLeadList = [Select Id, Name, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, Email__c, Alternate_Email__c,
                                           Campaign_Code__c, Location__c, Company_Name__c,
                                           Platform__c, Executed__c, Result__c, Lead__c, Account__c, Opportunity__c
                                           from Digital_Lead__c
                                           where Id IN: dLeadId];
        system.debug('dLeadList: '+dLeadList);
        
        if(!dLeadList.isEmpty() && dLeadList.size() == 1) {
            List<Lead__c> leadList = new List<Lead__c>();
            List<Digital_Lead__c> updateDigitalLeadList = new List<Digital_Lead__c>();
            
            mobile = dLeadList[0].Mobile__c;
            system.debug('Before Substring Mobile: '+mobile);
            if(mobile.length() > 10) {
                mobile = mobile.substring(mobile.length() - 10);
            }
            system.debug('After Substring Mobile: '+mobile);
            
            if(dLeadList[0].Alternate_Mobile__c != null) {
                altmobile = dLeadList[0].Alternate_Mobile__c;
                system.debug('Before Substring Mobile: '+altmobile);
                if(altmobile.length() > 10) {
                    altmobile = altmobile.substring(altmobile.length() - 10);
                }
                system.debug('After Substring Mobile: '+altmobile);
            }
            
            if(dLeadList[0].Platform__c.equalsIgnoreCase('Website')) {
                details = 'First Name: '+dLeadList[0].First_Name__c+ '\n'
                    +'Last Name: '+dLeadList[0].Last_Name__c+ '\n'
                    +'Mobile No: '+dLeadList[0].Mobile__c+ '\n'
                    +'Email Id: '+dLeadList[0].Email__c+ '\n'
                    +'Campaign Code: '+dLeadList[0].Campaign_Code__c+ '\n'
                    +'Location: '+dLeadList[0].Location__c+ '\n'
                    +'Company Name: '+dLeadList[0].Company_Name__c+ '\n'
                    +'Platform:'+dLeadList[0].Platform__c;
            }
            
            String projectId;
            String campaignId;
            String source;
            String subSource;
            String sourceDescription;
            
            if(dLeadList[0].Campaign_Code__c != Null && !String.isEmpty(dLeadList[0].Campaign_Code__c)) {
                List<Campaign__c> cList = [Select Id, Campaign_Code__c, Active__c, Project__c, Lead_Source__c, Lead_Sub_Source__c, Source_Description__c from Campaign__c
                                           where Campaign_Code__c =: dLeadList[0].Campaign_Code__c AND Active__c =: true];
                system.debug('cList: '+cList);
                
                if(cList != null) {
                    projectId = cList[0].Project__c;
                    campaignId = cList[0].Id;
                    source = cList[0].Lead_Source__c;
                    subSource = cList[0].Lead_Sub_Source__c;
                    sourceDescription = cList[0].Source_Description__c;
                }
            }
            
            Lead__c l = new Lead__c();
            l.First_Name__c = dLeadList[0].First_Name__c;
            l.Last_Name__c = dLeadList[0].Last_Name__c;
            l.Mobile__c = mobile;
            l.Alternate_Mobile__c = altMobile;
            l.Email__c = dLeadList[0].Email__c;
            l.Alternate_Email__c = dLeadList[0].Alternate_Email__c;
            l.Company_Name__c = dLeadList[0].Company_Name__c;
            l.Location__c = dLeadList[0].Location__c;
            l.Lead_Identifier__c = dLeadList[0].Platform__c;
            l.Project__c = projectId;
            l.Campaign_Code__c = dLeadList[0].Campaign_Code__c;
            l.Campaign__c = campaignId;
            l.Lead_Source__c = source;
            l.Lead_Sub_Source__c = subSource;
            l.Source_Description__c = sourceDescription;
            l.Remarks__c = details;
            l.Apply_Round_Robin__c = true;
            l.Is_Serviced__c = false;   
            
            if(l != null){  
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                leadList.add(l);
                system.debug('leadList: '+leadList);   
                
                try {
                    Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
                    duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
                    
                    for(Lead__c newLead: leadList) {
                        if(!duplicateWrapperMap.containsKey(l)) {
                            try {
                                Database.saveResult[] srList = Database.insert(leadList,dml);
                                for(Database.SaveResult sr: srList) {
                                    if(sr.isSuccess()) {
                                        try {
                                            task t = new task();
                                            t.Status = 'Completed';
                                            t.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();
                                            t.Subject = 'New Enquiry Received From: '+ newLead.Lead_Source__c;
                                            t.WhatId = sr.getId();
                                            
                                            List<Lead__c> newLeadList = [Select Id, Name, OwnerId from Lead__c where Id =: sr.getId()];
                                            system.debug('newLeadList: '+newLeadList);
                                            
                                            if(!newLeadList.isEmpty()) {
                                                t.OwnerId = newLeadList[0].OwnerId;
                                            }
                                            if(String.isNotBlank(newLead.First_Name__c))
                                                t.Name__c = newLead.First_Name__c + ' ';
                                            if(String.isNotBlank(newLead.Last_Name__c))
                                                t.Name__c += newLead.Last_Name__c;
                                            if(String.isNotBlank(newLead.Mobile__c))
                                                t.Mobile__c = newLead.Mobile__c;
                                            if(String.isNotBlank(newLead.Alternate_Mobile__c))
                                                t.Mobile__c = newLead.Alternate_Mobile__c;
                                            if(String.isNotBlank(newLead.Email__c))
                                                t.Email__c = newLead.Email__c;
                                            if(String.isNotBlank(newLead.Alternate_Email__c))
                                                t.Alternate_Email__c = newLead.Alternate_Email__c;
                                            if(newLead.Project__c != null)
                                                t.Project__c = newLead.Project__c;
                                            if(newLead.Campaign__c != null)
                                                t.Campaign__c = newLead.Campaign__c;
                                            if(String.isNotBlank(newLead.Campaign_Code__c))
                                                t.Campaign_Code__c = newLead.Campaign_Code__c;
                                            if(String.isNotBlank(newLead.Location__c))
                                                t.Location__c = newLead.Location__c;
                                            if(String.isNotBlank(newLead.Company_Name__c))
                                                t.Company_Name__c = newLead.Company_Name__c;
                                            if(String.isNotBlank(newLead.Remarks__c))
                                                t.Description = newLead.Remarks__c;
                                            if(String.isNotBlank(newLead.Lead_Identifier__c))
                                                t.Task_Identifier__c = newLead.Lead_Identifier__c;
                                            t.Is_New_Lead_Created__c = true;
                                            insert t;
                                            
                                            //Update Digital Lead
                                            dLeadList[0].Executed__c = True;
                                            dLeadList[0].Result__c = 'New Lead';
                                            dLeadList[0].Lead__c = leadList[0].Id;
                                            update dLeadList[0];
                                        } catch(Exception ex) {
                                            system.debug('Error: '+ex);
                                            //Update Digital Lead
                                            dLeadList[0].Executed__c = True;
                                            dLeadList[0].Result__c = 'Error';
                                            dLeadList[0].Error__c = ex.getMessage();
                                            update dLeadList[0];
                                        }
                                    } else {
                                        String msg = '';
                                        for(Database.Error err: sr.getErrors()) {
                                            msg = 'Lead Creation Failed: ' + err.getMessage();
                                        }
                                        system.debug('Error: '+msg);
                                        //Update Digital Lead
                                        dLeadList[0].Executed__c = True;
                                        dLeadList[0].Result__c = 'Error';
                                        dLeadList[0].Error__c = msg;
                                        update dLeadList[0];
                                    }
                                }
                            } catch(Exception ex) {
                                system.debug('Error: '+ex);
                                //Update Digital Lead
                                dLeadList[0].Executed__c = True;
                                dLeadList[0].Result__c = 'Error';
                                dLeadList[0].Error__c = ex.getMessage();
                                update dLeadList[0];
                            }
                        } else {
                            Ex_DuplicationHandlerServices.duplicateWrapper dw = duplicateWrapperMap.get(newLead)[0];
                            if(dw.objectType.equalsIgnoreCase('Lead')) {
                                try {
                                    task t = new task();
                                    t.Status = 'Completed';
                                    t.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();
                                    t.Subject = 'New Enquiry Received From: '+ newLead.Lead_Source__c;
                                    t.WhatId = dw.dupLead.Id;
                                    t.OwnerId = dw.dupLead.OwnerId;
                                    
                                    if(String.isNotBlank(newLead.First_Name__c))
                                        t.Name__c = newLead.First_Name__c + ' ';
                                    if(String.isNotBlank(newLead.Last_Name__c))
                                        t.Name__c += newLead.Last_Name__c;
                                    if(String.isNotBlank(newLead.Mobile__c))
                                        t.Mobile__c = newLead.Mobile__c;
                                    if(String.isNotBlank(newLead.Alternate_Mobile__c))
                                        t.Mobile__c = newLead.Alternate_Mobile__c;
                                    if(String.isNotBlank(newLead.Email__c))
                                        t.Email__c = newLead.Email__c;
                                    if(String.isNotBlank(newLead.Alternate_Email__c))
                                        t.Alternate_Email__c = newLead.Alternate_Email__c;
                                    if(newLead.Project__c != null)
                                        t.Project__c = newLead.Project__c;
                                    if(newLead.Campaign__c != null)
                                        t.Campaign__c = newLead.Campaign__c;
                                    if(String.isNotBlank(newLead.Campaign_Code__c))
                                        t.Campaign_Code__c = newLead.Campaign_Code__c;
                                    if(String.isNotBlank(newLead.Location__c))
                                        t.Location__c = newLead.Location__c;
                                    if(String.isNotBlank(newLead.Company_Name__c))
                                        t.Company_Name__c = newLead.Company_Name__c;
                                    if(String.isNotBlank(newLead.Remarks__c))
                                        t.Description = newLead.Remarks__c;
                                    if(String.isNotBlank(newLead.Lead_Identifier__c))
                                        t.Task_Identifier__c = newLead.Lead_Identifier__c;
                                    insert t;
                                    
                                    //Update Digital Lead
                                    dLeadList[0].Executed__c = True;
                                    dLeadList[0].Result__c = 'New Enquiry Against Lead';
                                    dLeadList[0].Lead__c = dw.dupLead.Id;
                                    update dLeadList[0];
                                } catch(Exception ex) {
                                    system.debug('Error: '+ex);
                                    //Update Digital Lead
                                    dLeadList[0].Executed__c = True;
                                    dLeadList[0].Result__c = 'Error';
                                    dLeadList[0].Error__c = ex.getMessage();
                                    update dLeadList[0];
                                }
                            } else if(dw.objectType.equalsIgnoreCase('Account')) {
                                oppList = [Select Id, Name, Is_Active__c, Account__c, Account__r.PersonContactId, OwnerId from Opportunity__c 
                                           Where Project__c =: newLead.Project__c AND Account__c =: dw.dupAccount.Id AND Is_Active__c = true];
                                
                                try {
                                    task t = new task();
                                    t.Status = 'Completed';
                                    t.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();
                                    t.Subject = 'New Enquiry Received From: '+ newLead.Lead_Source__c;
                                    if(!oppList.isEmpty() && oppList != null) {
                                        t.WhatId = oppList[0].Id;
                                        t.WhoId = oppList[0].Account__r.PersonContactId;
                                        t.OwnerId = oppList[0].OwnerId;
                                    } else {
                                        t.WhoId = dw.dupAccount.PersonContactId;
                                        t.OwnerId = dw.dupAccount.OwnerId;
                                    }
                                    
                                    if(String.isNotBlank(newLead.First_Name__c))
                                        t.Name__c = newLead.First_Name__c + ' ';
                                    if(String.isNotBlank(newLead.Last_Name__c))
                                        t.Name__c += newLead.Last_Name__c;
                                    if(String.isNotBlank(newLead.Mobile__c))
                                        t.Mobile__c = newLead.Mobile__c;
                                    if(String.isNotBlank(newLead.Alternate_Mobile__c))
                                        t.Mobile__c = newLead.Alternate_Mobile__c;
                                    if(String.isNotBlank(newLead.Email__c))
                                        t.Email__c = newLead.Email__c;
                                    if(String.isNotBlank(newLead.Alternate_Email__c))
                                        t.Alternate_Email__c = newLead.Alternate_Email__c;
                                    if(newLead.Project__c != null)
                                        t.Project__c = newLead.Project__c;
                                    if(newLead.Campaign__c != null)
                                        t.Campaign__c = newLead.Campaign__c;
                                    if(String.isNotBlank(newLead.Campaign_Code__c))
                                        t.Campaign_Code__c = newLead.Campaign_Code__c;
                                    if(String.isNotBlank(newLead.Location__c))
                                        t.Location__c = newLead.Location__c;
                                    if(String.isNotBlank(newLead.Company_Name__c))
                                        t.Company_Name__c = newLead.Company_Name__c;
                                    if(String.isNotBlank(newLead.Remarks__c))
                                        t.Description = newLead.Remarks__c;
                                    if(String.isNotBlank(newLead.Lead_Identifier__c))
                                        t.Task_Identifier__c = newLead.Lead_Identifier__c;
                                    insert t;
                                    
                                    //Update Digital Lead
                                    dLeadList[0].Executed__c = True;
                                    if(!oppList.isEmpty() && oppList != null) {
                                        dLeadList[0].Account__c = oppList[0].Account__c;
                                        dLeadList[0].Opportunity__c = oppList[0].Id;
                                        dLeadList[0].Result__c = 'New Enquiry Against Opportunity';
                                    } else {
                                        dLeadList[0].Account__c = dw.dupAccount.Id;
                                        dLeadList[0].Result__c = 'New Enquiry Against Account';
                                    }
                                    update dLeadList[0];
                                } catch(Exception ex) {
                                    system.debug('Error: '+ex);
                                    //Update Digital Lead
                                    dLeadList[0].Executed__c = True;
                                    dLeadList[0].Result__c = 'Error';
                                    dLeadList[0].Error__c = ex.getMessage();
                                    update dLeadList[0];
                                }
                            }
                        }
                    }
                } catch(Exception ex) {
                    system.debug('Error: '+ex);
                    //Update Digital Lead
                    dLeadList[0].Executed__c = True;
                    dLeadList[0].Result__c = 'Error';
                    dLeadList[0].Error__c = ex.getMessage();
                    update dLeadList[0];
                }
            } 
        }
    }
}