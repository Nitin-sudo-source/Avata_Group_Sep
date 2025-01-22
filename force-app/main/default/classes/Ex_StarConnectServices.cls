@RestResource(urlMapping='/StarConnect/*')
global class Ex_StarConnectServices {
    
    @HttpGET
    global static Rest_result getData() {
        Rest_result r = new Rest_result();
        List<Lead__c> leadList = new List<Lead__c>();
        List<Lead__c> newleadList = new List<Lead__c>();
        Set<Id> leadSet = new Set<Id>();
        List<User> userList = new List<User>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        Boolean isOppFound = false;
        Boolean isLeadFound = false;
        Id ownerId = null;
        
        String name = '';
        String email  = '';
        String customerNo = '';
        String alternateNo = '';
        String projectId = '';
        String location = '';
        String callType = '';
        String AgentName = '';
        String virtualNo = '';
        String callStatus = '';
        String subStage = '';
        String audioFile = '';
        String storeaudio = '';
        Integer duration = 0;
        DateTime nextFollupDate = null;  
        DateTime proposedVisitDate = null;
        String remarks = '';
        String LeadIdentifier = '';
        DateTime parsedDate = null;
        
        DateTime storeProp = null;
        DateTime StroeNext = null;
        
        name = RestContext.request.params.get('name');
        email = RestContext.request.params.get('email');
        customerNo = RestContext.request.params.get('mobile');
        alternateNo = RestContext.request.params.get('alternateNo');
        projectId = RestContext.request.params.get('projectId'); 
        location = RestContext.request.params.get('Location');
        callType = RestContext.request.params.get('callType'); 
        AgentName = RestContext.request.params.get('AgentName'); 
        virtualNo = RestContext.request.params.get('virtualNo');  
        callStatus = RestContext.request.params.get('callStatus');   
        subStage =   RestContext.request.params.get('subStage'); 
        storeaudio =   RestContext.request.params.get('audioFile'); 
        
        if(System.label.StartConnectAudioUrl != null){
            if(String.isNotBlank(storeaudio)){
                audioFile = System.label.StartConnectAudioUrl + storeaudio;
            }else{
                audioFile  = System.label.StartConnectAudioUrl;
            }
        }
        if(customerNo.length() > 10 && String.isNotBlank(customerNo)) {
            customerNo = customerNo.substring(customerNo.length()-10);
        }
        duration = Integer.valueOf(RestContext.request.params.get('callDuration'));
        
        String nextFollupDateString = RestContext.request.params.get('NextfollupDate');
        if(nextFollupDateString != null && nextFollupDateString != ''){
            nextFollupDate = DateTime.valueof(nextFollupDateString);
        }
        String proposedVisitDateString = RestContext.request.params.get('proposedVisitDate');
        
        if(String.isNotBlank(proposedVisitDateString)){
            parsedDate = Date.valueOf(proposedVisitDateString);
        }
        
        // System.debug('parsedDate: '+parsedDate);
        
        String proposedVisitTimeString = '';
        if(parsedDate != null){
            proposedVisitTimeString =  parsedDate.format('yyyy-MM-dd')+' ' + RestContext.request.params.get('proposedVisitTime');
            System.debug('proposedVisitTimeString: '+proposedVisitTimeString);
        }
        
        if (String.isNotBlank(proposedVisitTimeString)) {
            String timePart = RestContext.request.params.get('proposedVisitTime');
            String formattedDateTimeStr;
            
            if (timePart.contains('AM') || timePart.contains('PM')) {
                formattedDateTimeStr = convertTo24HourFormat(proposedVisitTimeString);
            } else {
                formattedDateTimeStr = proposedVisitTimeString.trim() + ':00';  
            }
            
            formattedDateTimeStr += '.000Z'; // Append milliseconds and Zulu time designator
            System.debug('Formatted DateTime String: ' + formattedDateTimeStr);
            proposedVisitDate = DateTime.valueOf(formattedDateTimeStr);
        }
        
        remarks = RestContext.request.params.get('remarks');
        LeadIdentifier = 'Start Connect';
        
        // Check for missing required fields
        if(String.isBlank(name) || String.isBlank(customerNo)  || String.isBlank(projectId)) {
            r.returnCode = 1;
            r.message = 'Missing required fields.';
            return r;
        }
        else {
            Lead__c l = new Lead__c();
            if(String.isNotBlank(name)){
                l.Last_Name__c = name;
            }
            if(String.isNotBlank(customerNo)){
                l.Mobile__c = customerNo;
            }
            if(String.isNotBlank(projectId)){
                l.Project__c = projectId;
            }
            l.Lead_Created_From__c = 'Start Connect';
            l.Email__c = email;
            l.Phone__c = alternateNo;
            l.Apply_Round_Robin__c = true;
            l.Lead_Source__c = 'Start Connect';
            l.Lead_Sub_Source__c = 'Start Connect';
            if(String.isNotBlank(AgentName))
                l.Start_Connect_Agent_Name__c = AgentName;
            if(String.isNotBlank(location))
                l.Start_Connect_Location__c = location;
            if(NextfollupDate != null){
                l.Presale_Next_Follow_up_Date__c = NextfollupDate;
            }
            if(proposedVisitDate != null){
                l.Presale_Date_of_Visit__c = proposedVisitDate;
            }
            
            
            
            if(l != Null) {
                newleadList.add(l);
                System.debug('newleadList: '+newleadList);
                
                try {
                    Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
                    duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(newleadList);
                    
                    for(Lead__c newLead: newleadList) {
                        if(!duplicateWrapperMap.containsKey(l)) {
                            try {
                                Database.saveResult[] srList = Database.insert(newleadList);
                                for(Database.SaveResult sr: srList) {
                                    leadSet.add(sr.getId());
                                    if(sr.isSuccess()) {
                                        try {
                                            task t = new task();
                                            System.debug('subStage: '+subStage);
                                            t.Status = 'Completed';
                                            t.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                                            t.Subject =  callType + ': '+ LeadIdentifier;
                                            t.whatId = sr.getId();
                                            if(String.isNotBlank(newLead.Last_Name__c))
                                                t.Name__c = newLead.Last_Name__c;
                                            if(String.isNotBlank(newLead.Mobile__c))
                                                t.Mobile__c = newLead.Mobile__c;
                                            if(String.isNotBlank(newLead.Email__c))
                                                t.Email__c = newLead.Email__c;
                                            if(l.Project__c != null)
                                                t.Project__c = newLead.Project__c;
                                            if(String.isNotBlank(newLead.Lead_Identifier__c))
                                                t.Task_Created_From__c = newLead.Lead_Identifier__c;
                                            if(String.isNotBlank(Location))
                                                t.Location__c = Location;
                                            if(String.isNotBlank(callType))
                                                t.CallType = callType;
                                            if(String.isNotBlank(AgentName))
                                                t.AgentID__c = AgentName;
                                            if(String.isNotBlank(virtualNo))
                                                t.Virtual_Number__c = virtualNo;
                                            if(duration != null)
                                                t.CallDurationInSeconds = duration;
                                            if(String.isNotBlank(audioFile))
                                                t.Audio_File__c = audioFile;
                                            if(String.isNotBlank(callStatus))
                                                t.Call_Status__c = callStatus;  
                                            if(String.isNotBlank(subStage))
                                                t.Starconnect_Sub_stage__c = subStage;
                                            if(NextfollupDate != null){
                                                t.Next_Follow_up_Date__c = NextfollupDate;
                                            }
                                            if(proposedVisitDate != null){
                                                t.Date_of_Visit__c = proposedVisitDate;
                                            }
                                            if(String.isNotBlank(remarks))
                                                t.Description = remarks;
                                            
                                            t.Is_New_Lead_Created__c = true;
                                            if(!leadSet.isEmpty() && leadSet != null){
                                                List<Lead__c> getList = [Select Id, OwnerId from Lead__c where Id IN: leadSet Order By CreatedDate DESC];
                                                system.debug('getList: '+getList);
                                                if(!getList.isEmpty() && getList != null) {
                                                    t.ownerId = getList[0].OwnerId;
                                                }
                                            }
                                            insert t; 
                                            
                                            List<Lead__c> updateLead = new List<Lead__c>();
                                            List<Task> updateTask = new List<Task>();
                                            List<Task> getTaskList = [Select whatId, Starconnect_Stage__c, Starconnect_Sub_stage__c  from Task where whatId IN: leadSet Order By CreatedDate DESC];
                                            System.debug('getTaskList: '+getTaskList);
                                            if(getTaskList != null){
                                                for(Task getTask: getTaskList){
                                                    if(getTask.Starconnect_Stage__c != null){
                                                        l.Lead_Stage__c = getTask.Starconnect_Stage__c;
                                                        t.Stage__c = getTask.Starconnect_Stage__c;
                                                    }
                                                    if(getTask.Starconnect_Sub_stage__c != null){
                                                        l.Lead_Sub_Stages__c = getTask.Starconnect_Sub_stage__c;
                                                        t.Sub_Stage__c =  getTask.Starconnect_Sub_stage__c;
                                                    }
                                                    updateLead.add(l);
                                                    updateTask.add(t);
                                                }
                                            }
                                            
                                            r.returnCode = 0;
                                            r.message = 'Lead Created Successfully';
                                            r.recordId = sr.getId();
                                            return r;
                                        } catch(Exception ex) {
                                            system.debug('Error: '+ex.getMessage());
                                            r.returnCode = 1;
                                            r.message = 'Lead Creation Failed: '+ex.getMessage();
                                            return r;
                                        }
                                        
                                        
                                        
                                    } else {
                                        String msg = '';
                                        for(Database.Error err: sr.getErrors()) {
                                            msg = 'Lead Creation Failed: ' + err.getMessage();
                                        }
                                        system.debug('Error: '+msg);
                                        r.returnCode = 1;
                                        r.message = msg;
                                        return r;
                                    }
                                }
                            } catch(Exception ex) {
                                system.debug('Error: '+ex.getMessage());
                                r.returnCode = 1;
                                r.message = 'Lead Creation Failed: '+ex.getMessage();
                                return r;
                            }
                        } else {
                            Ex_DuplicationHandlerServices.duplicateWrapper dw = duplicateWrapperMap.get(newLead)[0];
                            if(dw.objectType.equalsIgnoreCase('Lead')) {
                                try {
                                    task t = new task();
                                    t.Status = 'Completed';
                                    t.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                                    t.Subject = callType + ' : '+ LeadIdentifier;
                                    t.whatId = dw.dupLead.Id;
                                    
                                    if(String.isNotBlank(newLead.Last_Name__c))
                                        t.Name__c = newLead.Last_Name__c;
                                    if(String.isNotBlank(newLead.Mobile__c))
                                        t.Mobile__c = newLead.Mobile__c;
                                    if(String.isNotBlank(newLead.Email__c))
                                        t.Email__c = newLead.Email__c;
                                    if(l.Project__c != null)
                                        t.Project__c = newLead.Project__c;
                                    if(String.isNotBlank(newLead.Lead_Identifier__c))
                                        t.Task_Created_From__c = newLead.Lead_Identifier__c;
                                    if(String.isNotBlank(Location))
                                        t.Location__c = Location;
                                    if(String.isNotBlank(callType))
                                        t.CallType = callType;
                                    if(String.isNotBlank(AgentName))
                                        t.AgentID__c = AgentName;
                                    if(String.isNotBlank(virtualNo))
                                        t.Virtual_Number__c = virtualNo;
                                    if(duration != null)
                                        t.CallDurationInSeconds = duration;
                                    if(String.isNotBlank(audioFile))
                                        t.Audio_File__c = audioFile;
                                    if(String.isNotBlank(callStatus))
                                        t.Call_Status__c = callStatus;
                                    if(String.isNotBlank(subStage))
                                        t.Starconnect_Sub_stage__c = subStage;
                                    if(NextfollupDate != null){
                                        t.Next_Follow_up_Date__c = NextfollupDate;
                                    }
                                    if(proposedVisitDate != null){
                                        t.Date_of_Visit__c = proposedVisitDate;
                                    }
                                    
                                    if(String.isNotBlank(remarks))
                                        t.Description = remarks;
                                    if(dw.dupLead != null && dw.dupLead.OwnerId != null)
                                        t.OwnerId = dw.dupLead.OwnerId;
                                    
                                    insert t;
                                    if(dw.dupLead.Id != null){
                                        Task getTask = [Select whatId, Starconnect_Stage__c, Starconnect_Sub_stage__c  from Task where whatId =: dw.dupLead.Id Order By CreatedDate DESC limit 1];
                                        System.debug('getTask: '+getTask);
                                        if(getTask != null){
                                            if(getTask.Starconnect_Stage__c != null){
                                                dw.dupLead.Lead_Stage__c = getTask.Starconnect_Stage__c;
                                                t.Stage__c = getTask.Starconnect_Stage__c;
                                            }
                                            if(getTask.Starconnect_Sub_stage__c != null){
                                                dw.dupLead.Lead_Sub_Stages__c = getTask.Starconnect_Sub_stage__c;
                                                t.Sub_Stage__c =  getTask.Starconnect_Sub_stage__c;
                                            }
                                            if(String.isNotBlank(AgentName)){
                                                dw.dupLead.Start_Connect_Agent_Name__c = AgentName;
                                            }
                                            
                                            try{
                                                update dw.dupLead;
                                                update t;
                                            }Catch(Exception ex){
                                                System.debug('Exception : '+ex.getMessage());
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                    r.returnCode = 0;
                                    r.message = 'Enquiry Created Successfully';
                                    r.recordId = dw.dupLead.Id;
                                    return r;
                                } catch(Exception ex) {
                                    system.debug('Error: '+ex.getMessage());
                                    r.returnCode = 1;
                                    r.message = 'Lead Creation Failed: '+ex.getMessage();
                                    return r;
                                }
                            } else if(dw.objectType.equalsIgnoreCase('Opportunity')) {
                                try {
                                    task t = new task();
                                    t.Status = 'Completed';
                                    t.RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
                                    t.Subject = callType + ' : '+ LeadIdentifier;
                                    t.WhoId = dw.dupOpp.Account__r.PersonContactId;
                                    t.whatId = dw.dupOpp.Id;
                                    
                                    if(String.isNotBlank(newLead.Last_Name__c))
                                        t.Name__c = newLead.Last_Name__c;
                                    if(String.isNotBlank(newLead.Mobile__c))
                                        t.Mobile__c = newLead.Mobile__c;
                                    if(String.isNotBlank(newLead.Email__c))
                                        t.Email__c = newLead.Email__c;
                                    if(l.Project__c != null)
                                        t.Project__c = newLead.Project__c;
                                    if(String.isNotBlank(newLead.Lead_Identifier__c))
                                        t.Task_Created_From__c = newLead.Lead_Identifier__c;
                                    if(String.isNotBlank(Location))
                                        t.Location__c = Location;
                                    if(String.isNotBlank(callType))
                                        t.CallType = callType;
                                    if(String.isNotBlank(AgentName))
                                        t.AgentID__c = AgentName;
                                    if(String.isNotBlank(virtualNo))
                                        t.Virtual_Number__c = virtualNo;
                                    if(duration != null)
                                        t.CallDurationInSeconds = duration;
                                    if(String.isNotBlank(audioFile))
                                        t.Audio_File__c = audioFile;
                                    if(String.isNotBlank(callStatus))
                                        t.Call_Status__c = callStatus;
                                    if(String.isNotBlank(subStage))
                                        t.Starconnect_Sub_stage__c = subStage;
                                    if(String.isNotBlank(remarks))
                                        t.Description = remarks;
                                    if(dw.dupOpp != null && dw.dupOpp.ownerId != null)
                                        t.OwnerId = dw.dupOpp.ownerId;
                                    if(NextfollupDate != null){
                                        t.Next_Follow_up_Date__c = NextfollupDate;
                                    }
                                    if(proposedVisitDate != null){
                                        t.Date_of_Visit__c = proposedVisitDate;
                                    }
                                    insert t;
                                    
                                    r.returnCode = 0;
                                    r.message = 'Enquiry Created Successfully Against that Opportunity';
                                    r.recordId = dw.dupOpp.Id;
                                    return r;
                                } catch(Exception ex) { 
                                    system.debug('Error: '+ex.getMessage());
                                    r.returnCode = 1;
                                    r.message = 'Lead Creation Failed: '+ex.getMessage();
                                    return r;
                                }
                            }
                        }
                    }
                } catch(Exception ex) {
                    system.debug('Error: '+ex.getMessage());
                    r.returnCode = 1;
                    r.message = 'Lead Creation Failed: '+ex.getMessage();
                    return r;
                }
            }
        } 
        return r;
    }
    
    private void updateLeadStage(Lead__c lead, Task task, String AgentName) {
        if(task.Starconnect_Stage__c != null)
            lead.Lead_Stage__c = task.Starconnect_Stage__c;
        if(task.Starconnect_Sub_stage__c != null)
            lead.Lead_Sub_Stages__c = task.Starconnect_Sub_stage__c;
        if(String.isNotBlank(AgentName)) 
            lead.Start_Connect_Agent_Name__c = AgentName;
    }

    
    global class REST_Result {
        webservice Integer returnCode;
        webservice String message;
        webservice String recordId;
    }
    
    public static String convertTo24HourFormat(String dateTimeStr) {
        String[] dateTimeParts = dateTimeStr.split(' ');
        String datePart = dateTimeParts[0];
        String timePart = dateTimeParts[1];
        String meridiemPart = dateTimeParts.size() > 2 ? dateTimeParts[2] : '';
        
        Integer hour = Integer.valueOf(timePart.substring(0, 2));
        String minutes = timePart.substring(3, 5);
        String seconds = timePart.length() > 5 ? timePart.substring(6) : '00';
        
        if (String.isNotBlank(meridiemPart)) {
            if (meridiemPart == 'PM' && hour != 12) {
                hour += 12;
            } else if (meridiemPart == 'AM' && hour == 12) {
                hour = 0;
            }
        }
        
        String hourStr = hour < 10 ? '0' + hour : String.valueOf(hour);
        String formattedTime = datePart + ' ' + hourStr + ':' + minutes + ':' + seconds;
        System.debug('Formatted Time: ' + formattedTime);
        return formattedTime;
    }
    
    
}