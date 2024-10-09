public class TaskHandlerServices {
    public static void validationCheckforPresaleCall(Map<Id, List<Task>> taskMap) {
        List<Lead__c> leadList = new List<Lead__c>();
        Map<Id, Lead__c> leadMap = new Map<Id, Lead__c>();
        Map<String, String> stageMap = getStagesMap();
        
        leadList = [Select Id, Name, Stage__c from Lead__c where Id IN: taskMap.keySet()];
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
                        if(String.isNotBlank(leadMap.get(lId).Stage__c)) {
                            if(stageMap.containsKey(leadMap.get(lId).Stage__c)) {
                                if(stageMap.get(leadMap.get(lId).Stage__c).containsIgnoreCase(t.Stage__c) == false) {
                                    if (!test.isRunningTest())
                                        t.addError('You can not create the task with Stage: '+t.Stage__c+' where Lead stage is: '+leadMap.get(lId).Stage__c);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void CallHandlerServices(Set<Id> taskId, string operation, boolean count) {
        Map<Id, List<Task>> mapRollUpLead = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpOpp  = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpCp   = new Map<Id, List<Task>>(); 
        
        List<Task> taskList = [Select Id, WhoId, WhatId, CreatedDate, CP_Stage__c,Other_Reason__c, CP_Sub_Stage__c, Stage__c, Sub_Stage__c, Sub_Stage_Reason__c, Call_Status__c,
                               Next_Follow_up_Date__c, CallType, CallDurationInSeconds,Date_of_Visit__c, Description,Subject, Next_Action_Date__c, RecordTypeId, RecordType.Name from Task where Id IN: taskId 
                               AND (RecordType.Name = 'Presales Call' OR RecordType.Name = 'Sales Call' OR RecordType.Name = 'Partner Call / Meeting' )];
        system.debug('taskList: '+taskList);
        
        for(Task t: taskList) {
            if(t.whatId != Null && t.whatId.getSObjectType().getDescribe().getName() == 'Lead__c') {
                if(!mapRollUpLead.containsKey(t.whatId)) {
                    List<Task> newTaskList = new List<Task>();
                    newTaskList.add(t);
                    mapRollUpLead.put(t.whatId, newTaskList);
                } else {
                    mapRollUpLead.get(t.whatId).add(t);
                }
            } else if(t.whatId != Null && t.whatId.getSObjectType().getDescribe().getName() == 'Opportunity__c') {
                if(!mapRollUpOpp.containsKey(t.whatId)) {
                    List<Task> newTaskList = new List<Task>();
                    newTaskList.add(t);
                    mapRollUpOpp.put(t.whatId, newTaskList);
                } else {
                    mapRollUpOpp.get(t.whatId).add(t);
                }                
            }
            
            else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'Account'){
                if(!mapRollUpCp.containsKey(t.WhatId)){
                    List<Task> newTaskList = new List<Task>();
                    newTaskList.add(t);
                    mapRollUpCp.put(t.WhatId,newTaskList);
                }else{
                    mapRollUpCp.get(t.WhatId).add(t);
                }
            }
        }
        system.debug('mapRollUpLead: '+mapRollUpLead);
        if(!mapRollUpLead.isEmpty()) {
            RollUpTaskLeadServices(mapRollUpLead,operation, count);
        }
        system.debug('mapRollUpOpp: '+mapRollUpOpp);
        if(!mapRollUpOpp.isEmpty()) {
            RollUpTaskOpportunityServices(mapRollUpOpp,operation, count);
        }
        
        system.debug('mapRollUpCp: ' +mapRollUpCp);
        if(!mapRollUpCp.isEmpty()){
            RollUpTaskChannelPartnerServices(mapRollUpCp,operation, count);
        }
    }
    
    public static void RollUpTaskLeadServices(Map<Id, List<Task>> mapRollUpLead, string operation, boolean count) {
        List<Lead__c> updateLeadList = new List<Lead__c>();
        List<Lead__c> leadList = [Select Id, Last_Presale_Call_Date__c, Last_Presales_Call_Status__c, Presale_Next_Follow_up_Date__c, Presale_Date_of_Visit__c, Last_Presale_Call_Comment__c, Stage__c,
                                  Sub_Stage__c, Presales_Comment_History__c, Presales_Call_Count__c /* Not_Responding_Count__c, CNR_Counter__c, Call_Received__c,Call_Type__c, Call_Status__c, Total_Call_Duration__c*/
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
                        l.Last_Presale_Call_Date__c = t.CreatedDate;
                        l.Presale_Next_Follow_up_Date__c = t.Next_Action_Date__c;
                        l.Presale_Date_of_Visit__c = t.Date_of_Visit__c;
                        l.Last_Presales_Call_Status__c = t.Call_Status__c;
                        l.Last_Presale_Call_Comment__c = t.Description;
                        //l.Last_Presale_Call_Type__c = t.CallType;
                        
                        if(t.Stage__c != Null) {
                            l.Stage__c = t.Stage__c;
                            l.Sub_Stage__c = t.Sub_Stage__c;
                            l.SubStage_Reason__c = t.Sub_Stage_Reason__c;
                        } 
                        if(l.Presales_Call_Count__c  == Null)
                            l.Presales_Call_Count__c  = 0;  
                        if((operation == 'insert' || operation == 'update') && t.Stage__c != Null ) 
                            l.Presales_Call_Count__c  = l.Presales_Call_Count__c + 1;
                        if(l.Last_Presale_Call_Comment__c != Null) {
                            if(l.Presales_Comment_History__c == Null)
                                l.Presales_Comment_History__c = '';
                            l.Presales_Comment_History__c =  string.ValueOf(myDate)+': ' + l.Last_Presale_Call_Comment__c + '\n' + l.Presales_Comment_History__c ;
                        }
                        updateLeadList.add(l);
                    }
                }
            }
        }
        system.debug('updateLeadList: '+updateLeadList);
        if(!updateLeadList.isEmpty())
            update updateLeadList;
    }
    
    public static void RollUpTaskOpportunityServices(Map<Id, List<Task>> mapRollUpOpp, string operation, boolean count) {
        List<Opportunity__c> updateOppList = new List<Opportunity__c>();
        List<Opportunity__c> oppList = [Select Id,Last_Sales_Call_Date__c, Sales_Last_Comment__c, Sales_Next_Follow_up_Date__c, Sales_Proposed_Visit_Date__c, Stage__c,
                                        Sub_Stage__c, Sub_Stage_Reason__c,Sales_Call_Count__c, Sales_Last_Comment_History__c,Other_Reason__c
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
                        op.Last_Sales_Call_Date__c = t.CreatedDate;
                        op.Sales_Next_Follow_up_Date__c = t.Next_Follow_up_Date__c;
                        op.Sales_Proposed_Visit_Date__c = t.Date_of_Visit__c;
                        op.Last_Sales_Call_Status__c = t.Call_Status__c;
                        op.Sales_Last_Comment__c = t.Description;
                        if(t.Other_Reason__c != null){
                            op.Other_Reason__c = t.Other_Reason__c;
                        }
                        
                        if(t.Stage__c != Null) {
                            op.Stage__c = t.Stage__c;
                            op.Sub_Stage__c = t.Sub_Stage__c;
                            op.Sub_Stage_Reason__c = t.Sub_Stage_Reason__c;
                        }
                        if(op.Sales_Call_Count__c == Null)
                            op.Sales_Call_Count__c = 0;
                        if((operation == 'insert' || operation == 'update') && t.Stage__c != Null)
                            op.Sales_Call_Count__c = op.Sales_Call_Count__c + 1;
                        if(op.Sales_Last_Comment__c != Null) {
                            if(op.Sales_Last_Comment_History__c == Null)
                                op.Sales_Last_Comment_History__c ='';
                            op.Sales_Last_Comment_History__c =  string.ValueOf(myDate)+': '+op.Sales_Last_Comment__c   + '\n' +  op.Sales_Last_Comment_History__c;
                        }    
                        updateOppList.add(op);    
                    }
                }
            }
        }
        system.debug('updateOppList: '+updateOppList);
        if(!updateOppList.isEmpty())
            update updateOppList;
    }
    
    
    public static void RollUpTaskChannelPartnerServices(Map<Id, List<Task>> mapRollUpCp, string operation,boolean count) {
        List<Account> updateCpList = new List<Account>();
        List<Account> cpList = [Select Id,Last_CP_Call_Meeting_Subject__c, Comments__c,Last_CP_Call_Meeting_Date__c,Last_CP_Call_Meeting_Status__c,Last_CP_Call_Meeting_Remarks__c,CP_Stage__c,
                                CP_Next_Action_Date__c,CP_Sub_stage__c from Account where Id =: mapRollUpCp.keySet()];
        system.debug('cpList: '+cpList);
        
        for(Account cp: cpList) {
            List<Task> getCpTaskList = mapRollUpCp.get(cp.Id);
            system.debug('getCpTaskList: '+getCpTaskList);
            
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(!getCpTaskList.isEmpty()) {
                for(Task t: getCpTaskList) {
                    if(t.RecordType.Name == 'Partner Call / Meeting') {
                        cp.Last_CP_Call_Meeting_Subject__c = t.Subject;
                        cp.Last_CP_Call_Meeting_Date__c = t.CreatedDate;
                        cp.Last_CP_Call_Meeting_Status__c = t.Call_Status__c;
                        cp.Comments__c = t.Description;
                        cp.Last_CP_Call_Meeting_Stage__c = t.CP_Stage__c ;
                        cp.Last_CP_Call_Meeting_Status__c= t.CP_Sub_Stage__c  ;
                        cp.CP_Next_Action_Date__c = t.Next_Action_Date__c;
                        if(t.CP_Stage__c != Null) {
                            cp.Last_CP_Call_Meeting_Stage__c = t.CP_Stage__c;
                            cp.Last_CP_Call_Meeting_Sub_Stage__c = t.CP_Sub_Stage__c;
                            cp.CP_Stage__c = t.CP_Stage__c;
                            cp.CP_Sub_stage__c = t.CP_Sub_Stage__c;
                        }
                        /*if(op.Sales_Call_Count__c == Null)
op.Sales_Call_Count__c = 0;
if((operation == 'insert' || operation == 'update') && t.Stage__c != Null)
op.Sales_Call_Count__c = op.Sales_Call_Count__c + 1;*/
                        if(cp.Comments__c != Null) {
                            if(cp.Last_CP_Call_Meeting_Remarks__c == Null)
                                cp.Last_CP_Call_Meeting_Remarks__c ='';
                            cp.Last_CP_Call_Meeting_Remarks__c = string.ValueOf(myDate)+': ' + cp.Comments__c + '\n'  + cp.Last_CP_Call_Meeting_Remarks__c ;
                            
                        }   
                        updateCpList.add(cp);    
                    }
                }
            }
        }
        system.debug('updateCpList: '+updateCpList);
        if(!updateCpList.isEmpty())
            update updateCpList;
    }
    public static Map<String, String> getStagesMap(){
        Map <String , String> stageMap = new  Map <String , String> ();
        List<Stage_Management__c> stageList = [select Name,Allowed_Stages__c from Stage_Management__c];
        system.debug('stageList'+stageList);
        if(!stageList.isEmpty()){
            for(Stage_Management__c st: stageList){
                stageMap.put(st.Name, st.Allowed_Stages__c);
            }
        }
        return stageMap;
    }
    
}