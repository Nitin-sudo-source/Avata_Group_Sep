@RestResource(urlMapping='/CTI/CallBack/')
global class Ex_RESTCTICallBack {
    @HttpPost
    global static void createCallDetails() {
        String data = '';
        String projectId = '';
        data = RestContext.request.params.get('data');
        system.debug('Data: '+data);
        
        if(String.isNotBlank(data) && data != '') {
            List<User> uList = new List<User>();
            List<Campaign__c> cList = new List<Campaign__c>();
            List<Account> accList = new List<Account>();
            List<Lead__c> leadList = new List<Lead__c>();
            List<Opportunity__c> oppList = new List<Opportunity__c>();
            List<CP_Project__c> cpProjectList = new List<CP_Project__c>();
            List<Ola_Pickup__c> olaList = new List<Ola_Pickup__c>();
            
            Boolean isAccFound = false;
            Boolean isLeadFound = false;
            Boolean isOppFound = false;
            Boolean isCPProjectFound = false;
            Boolean isOlaPickupFound = false;
            
            Ex_CTICallBackParse cbp = Ex_CTICallBackParse.parse(data);
            String customerNumber = cbp.CallerID;
            String did = cbp.DID;
            String ucid = cbp.monitorUCID; 
            String callStatus = cbp.Status;
            String callType = cbp.CallType;
            String recordingFile = cbp.AudioFile;
            String duration = cbp.Duration;
            String campaignName = cbp.CampaignName;
            String comments = cbp.Comments;
            String disposition = cbp.Disposition;
            String monitorUCID = cbp.monitorUCID;
            String agentID = cbp.AgentID;
            String hangupBy = cbp.HangupBy;
            DateTime startDateTime = DateTime.valueOf(cbp.StartTime);
            DateTime endDateTime = DateTime.valueOf(cbp.EndTime);
            Integer callDuration = 0;
            String uui = cbp.UUI;
            String offlineAgentId = cbp.PhoneName;
            String getFinalAgentId = '';
            
            System.debug('offlineAgentId: '+offlineAgentId);
            System.debug('uui: '+uui);
            
            if(String.isNotBlank(duration) && duration != null) {
                List<String> splitList = duration.split('\\:');
                callDuration = ((Integer.valueOf(splitList[0]) * 3600) + (Integer.valueOf(splitList[1]) * 60) + Integer.valueOf(splitList[2]));
            }
            
            if(String.isNotBlank(did) && did != null) {
                cList = [Select Id, Virtual_Number__c, Source__c, Project__c from Campaign__c
                         where IsActive__c = true AND Is_CTI_Campaign__c = true AND Virtual_Number__c =: did];
                system.debug('cList: '+cList);
                
                if(!cList.isEmpty() && cList != null) {
                    projectId = cList[0].Project__c;
                }
            }
            System.debug('uui: '+uui);
            if(String.isNotBlank(uui) && uui != null) {
                oppList = [Select Id, Mobile__c, Phone__c, OwnerId from Opportunity__c where Id =: uui];
                System.debug('oppList: '+oppList);
                
                if(!oppList.isEmpty() && oppList != null){
                    isOppFound = true;
                } else {
                    leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c, Phone__c, ownerId from Lead__c where Id =: uui];
                    system.debug('leadList: '+leadList);
                    if(!leadList.isEmpty() && leadList != null) {
                        isLeadFound = true;
                    }else{
                        cpProjectList = [Select Id, Name, OwnerId from CP_Project__c where Id =: uui];
                        system.debug('cpProjectList: '+cpProjectList);
                        if(!cpProjectList.isEmpty() && cpProjectList != null){
                            isCPProjectFound = true;
                        }else{
                            olaList = [Select Id, Name, OwnerId from Ola_Pickup__c where Id =: uui];
                            system.debug('olaList: '+olaList);
                            if(!olaList.isEmpty() && olaList != null){
                                isOlaPickupFound = true;
                            }
                        }
                    }
                }
            }else{
                if(String.isNotBlank(customerNumber) && customerNumber != ''){
                    if(customerNumber.length() > 10) {
                        customerNumber = customerNumber.substring(customerNumber.length()-10);
                    }
                    oppList = [Select Id, Mobile__c, Phone__c, OwnerId  from Opportunity__c where (Mobile__c =: customerNumber OR Phone__c =: customerNumber)AND Is_Active__c = true AND Project__c =: projectId];
                    System.debug('oppList: '+oppList);
                    if(!oppList.isEmpty() && oppList != null) {
                        isOppFound = true;
                    } else {
                        leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c,Phone__c,OwnerId from Lead__c where (Mobile__c =: customerNumber OR Phone__c =: customerNumber) AND IsConverted__c = false AND Project__c =: projectId];
                        system.debug('leadList: '+leadList); 
                        
                        if(!leadList.isEmpty() && leadList != null) {
                            isLeadFound = true;
                        }
                    }
                }
            }
            
            if(String.isNotBlank(callStatus) && callStatus != null) {
                if(String.isNotBlank(agentID) && agentID != null) {
                    List<String> getAgentSequence = new List<String>();
                    getAgentSequence = agentID.split(' -> ');
                    getFinalAgentId = getAgentSequence[getAgentSequence.size() - 1];
                    System.debug('getFinalAgentId: '+getFinalAgentId);
                    if(String.isNotBlank(getFinalAgentId) && getFinalAgentId != null) {
                        uList = [Select Id from User where Ozonetel_AgentId__c =: getFinalAgentId AND IsActive = true];
                        system.debug('uList: '+uList); 
                    }
                }else if(String.isNotBlank(offlineAgentId) && offlineAgentId != null){
                    uList = [Select Id from User where Ozonetel_AgentId__c =: offlineAgentId AND IsActive = true];
                    system.debug('uList: '+uList); 
                }
                
                Task t = new Task();
                if(callStatus.equalsIgnoreCase('NotAnswered')) {
                    t.Subject = 'Missed Call: '+did;
                    t.Description = 'Missed Call: ' + did;
                    if(callType.equalsIgnoreCase('InBound')) {
                        t.CallType = 'Inbound';
                        t.Status = 'Completed';
                        t.Priority = 'High';
                    } else if(callType.equalsIgnoreCase('Manual')) {
                        t.CallType = 'Outbound';
                        t.Status = 'Open';
                        t.Priority = 'Low';
                    }
                    
                    t.Virtual_Number__c = did;
                    t.Call_Status__c = callStatus;
                    t.Mobile__c = customerNumber;
                    t.Audio_File__c = recordingFile;
                    t.Call_Start_DateTime__c = startDateTime;
                    t.Call_End_DateTime__c = endDateTime;
                    //  t.Hangup_By__c = hangupBy;
                    if(String.isNotBlank(agentID) && agentID != null) {
                        t.AgentID__c = agentID;
                    }else if(String.isNotBlank(offlineAgentId) && offlineAgentId != null){
                        t.AgentID__c = offlineAgentId;
                    }
                    if(!cList.isEmpty() && cList != null) {
                        t.Campaign__c = cList[0].Id;
                        t.Project__c = cList[0].Project__c;
                    }
                    
                    if(isOppFound) {
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
                        t.WhatId = oppList[0].Id;
                        t.OwnerId = oppList[0].OwnerId;
                    } else if(isLeadFound) {
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                        t.WhatId = leadList[0].Id;
                        t.OwnerId = leadList[0].OwnerId;
                    }else if(isCPProjectFound){
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
                        t.WhatId = cpProjectList[0].Id;
                        t.OwnerId = cpProjectList[0].OwnerId;
                    }else if(isOlaPickupFound){
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Ola Pickup Activity').getRecordTypeId();
                        t.WhatId = olaList[0].Id;
                        t.OwnerId = olaList[0].OwnerId;
                    }
                } else {
                    if(callType.equalsIgnoreCase('InBound')) {
                        t.Subject = 'Inbound Call: '+did;
                        t.CallType = 'Inbound';
                    } else if(callType.equalsIgnoreCase('Manual')) {
                        t.Subject = 'Outbound Call: '+did;
                        t.CallType = 'Outbound';
                    }
                    t.Call_Status__c = callStatus;
                    t.Description = comments;
                    t.Mobile__c = customerNumber;
                    t.CallDurationInSeconds = callDuration;
                    t.Call_Disposition__c = disposition;
                    t.Virtual_Number__c = did;
                    t.CallObject = monitorUCID;
                    t.Call_Start_DateTime__c = startDateTime;
                    t.Call_End_DateTime__c = endDateTime;
                    t.Audio_File__c = recordingFile;
                    t.Status = 'Open';
                    t.Priority = 'Normal';
                    // t.Hangup_By__c = hangupBy;
                    if(String.isNotBlank(agentID) && agentID != null) {
                        t.AgentID__c = agentID;
                    }else if(String.isNotBlank(offlineAgentId) && offlineAgentId != null){
                        t.AgentID__c = offlineAgentId;
                    }
                    if(!cList.isEmpty() && cList != null) {
                        t.Campaign__c = cList[0].Id;
                        t.Project__c = cList[0].Project__c;
                    }
                    if(!uList.isEmpty() && uList != null) {
                        t.OwnerId = uList[0].Id;
                    }
                    
                    if(isOppFound) {
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
                        t.WhatId = OppList[0].Id;
                        if(!cList.isEmpty() && cList != null) {
                            t.Campaign__c = cList[0].Id;
                            t.Project__c = cList[0].Project__c;
                        }
                    } else if(isLeadFound) {
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                        t.WhatId = leadList[0].Id;
                    }else if(isCPProjectFound){
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
                        t.WhatId = cpProjectList[0].Id;
                    }else if(isOlaPickupFound){
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Ola Pickup Activity').getRecordTypeId();
                        t.WhatId = olaList[0].Id;
                    }
                }
                
                try {
                    insert t;
                    System.debug('task created:' + t.id);
                } catch (Exception ex) {
                    System.debug('task insert failed :' + ex.getMessage());
                }
            }
        }
    }
}