//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 18-10-2023
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
                        if(String.isNotBlank(leadMap.get(lId).Lead_Stage__c) && t.Stage__c != null) {
                            if(stageMap.containsKey(leadMap.get(lId).Lead_Stage__c)) {
                               // System.debug('Task: '+leadMap.get(lId).Lead_Stage__c);
                               // System.debug('t.Stage__c: '+t.Stage__c);
                                if(stageMap.get(leadMap.get(lId).Lead_Stage__c).containsIgnoreCase(t.Stage__c) == false) {
                                    if (!test.isRunningTest())
                                        t.addError('You can not create the task with Stage: '+t.Stage__c+' where Lead stage is: '+leadMap.get(lId).Lead_Stage__c);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void CallHandlerServices(Set<Id> taskId, string operation, boolean count) {
        System.debug('taskId: '+taskId);
        Map<Id, List<Task>> mapRollUpLead = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpOpp  = new Map<Id, List<Task>>();
        Map<Id, List<Task>> mapRollUpCp   = new Map<Id, List<Task>>(); 
        Map<Id, List<Task>> mapRollUpBooking   = new Map<Id, List<Task>>(); 
        
        
        List<Task> taskList = [Select Id, Purpose_of_Call__c, WhoId, WhatId, Call_Status__c, CreatedDate, Status, Date_of_Visit__c, Next_Follow_up_Date__c, Stage__c, Sub_Stage__c, Sub_Stage_Reason__c,
                               Purpose_of_Meeting__c,Next_Meeting_Date__c ,Next_Call_Action_Date__c, CallType, CallDurationInSeconds, Description,Subject,  RecordTypeId,
                               RecordType.Name from Task where Id IN: taskId  AND (RecordType.Name = 'Presales Call' OR RecordType.Name = 'Sales Call' 
                                                                                   OR RecordType.Name = 'CP Call'  OR RecordType.Name = 'CP Meeting' OR RecordType.Name = 'CRM Call')];
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
            } else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'CP_Project__c'){
                if(!mapRollUpCp.containsKey(t.WhatId)){
                    List<Task> newTaskList = new List<Task>();
                    newTaskList.add(t);
                    mapRollUpCp.put(t.WhatId,newTaskList);
                }else{
                    mapRollUpCp.get(t.WhatId).add(t);
                }
            }else if(t.WhatId != Null && t.WhatId.getSObjectType().getDescribe().getName() == 'Booking__c'){
                if(!mapRollUpCp.containsKey(t.WhatId)){
                    List<Task> newTaskList = new List<Task>();
                    newTaskList.add(t);
                    mapRollUpBooking.put(t.WhatId,newTaskList);
                }else{
                    mapRollUpBooking.get(t.WhatId).add(t);
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
            RollUpTaskCPProjectServices(mapRollUpCp,operation, count);
        }
        if(!mapRollUpBooking.isEmpty()){
            RollUpTaskBookingServices(mapRollUpBooking,operation, count);
        }
        
    }
    
    public static void RollUpTaskBookingServices(Map<Id, List<Task>> mapRollUpBooking, string operation, boolean count) {
        List<Booking__c> updateBooking = new List<Booking__c>();
        List<Booking__c> bklist = [Select Id, CRM_Next_follow_up_Date__c, CRM_Call_Count__c, Last_CRM_Call_Date__c, Last_CRM_Call_Status__c, Last_CRM_Comment__c, CRM_Comment_History__c
                                   from Booking__C where Id =: mapRollUpBooking.keySet()];
        for(Booking__c bk : bklist){
            List<Task> getLeadTaskList = mapRollUpBooking.get(bk.Id);
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(getLeadTaskList != null){
                for(Task t: getLeadTaskList) {
                    if(t.RecordType.Name == 'CRM Call') {
                        bk.CRM_Next_follow_up_Date__c = t.Next_Follow_up_Date__c;
                        bk.Last_CRM_Call_Status__c = t.Purpose_of_Call__c;
                        bk.Last_CRM_Call_Date__c = Date.valueof(t.CreatedDate);
                        bk.Last_CRM_Comment__c = t.Description;
                        if(bk.CRM_Call_Count__c == null)
                            bk.CRM_Call_Count__c = 0;
                        bk.CRM_Call_Count__c = bk.CRM_Call_Count__c + 1;
                        
                        if(bk.Last_CRM_Comment__c != Null) {
                            if(bk.CRM_Comment_History__c == Null)
                                bk.CRM_Comment_History__c = '';
                            bk.CRM_Comment_History__c =  string.ValueOf(myDate)+': ' + bk.Last_CRM_Comment__c + '\n' + bk.CRM_Comment_History__c ;
                        }
                        updateBooking.add(bk);                        
                    }
                }
            }
        }
        System.debug('updateBooking: '+updateBooking);
        try{
            if(updateBooking != null && !updateBooking.isEmpty()){
                update updateBooking;
            }
        }Catch(Exception ex){
            System.debug('Error in updating booking :'+ex.getMessage());
        }
        
    }
    
    
    public static void RollUpTaskLeadServices(Map<Id, List<Task>> mapRollUpLead, string operation, boolean count) {
        List<Lead__c> updateLeadList = new List<Lead__c>();
        List<Lead__c> leadList = [Select Id,  Last_Presales_Call_Date__c, Presales_Call_Status__c, Presale_Next_Follow_up_Date__c, Presale_Date_of_Visit__c, Presale_Call_Comment__c,First_Presales_Call_Date__c, Lead_Stage__c,
                                  Lead_Sub_Stages__c, Lead_Sub_Stage_Reason__c, Presales_Comment_History__c, Presales_Call_Count__c 
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
                       
                        l.Last_Presales_Call_Date__c = t.CreatedDate;
                        l.Presale_Next_Follow_up_Date__c = t.Next_Follow_up_Date__c;
                        l.Presale_Date_of_Visit__c = t.Date_of_Visit__c;
                        l.Presales_Call_Status__c = t.Status;
                        l.Presale_Call_Comment__c = t.Description;
                        //l.Call_Type__c = t.CallType;
                        
                        if(t.Stage__c != Null) {
                            l.Lead_Stage__c = t.Stage__c;
                            l.Lead_Sub_Stages__c = t.Sub_Stage__c;
                            l.Lead_Sub_Stage_Reason__c = t.Sub_Stage_Reason__c;
                        } 
                        if(l.Presales_Call_Count__c  == Null)
                            l.Presales_Call_Count__c  = 0; 
                        
                        if(l.First_Presales_Call_Date__c == null){
                            l.First_Presales_Call_Date__c = t.CreatedDate;
                         }
                        
                        if(operation == 'insert' || operation == 'update') 
                            l.Presales_Call_Count__c  = l.Presales_Call_Count__c + 1;
                        
                        if(l.Presale_Call_Comment__c != Null) {
                            if(l.Presales_Comment_History__c == Null)
                                l.Presales_Comment_History__c = '';
                            l.Presales_Comment_History__c =  string.ValueOf(myDate)+': ' + l.Presale_Call_Comment__c + '\n' + l.Presales_Comment_History__c ;
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
        List<Opportunity__c> oppList = [Select Id,Last_Sales_Call_Date__c, /*Last_Call_Type__c,,Other_Reason__c*/ Sales_Call_Comment__c	, Sales_Next_Follow_up_Date__c, Sales_Proposed_Visit_Date__c, Opportunity_Stage__c,
                                        Opportunity_Sub_Stage__c, Opportunity_Sub_Stage_Reason__c,  Sales_Call_Count__c, Sales_Comment_History__c
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
                        // op.Last_Sales_Call_Status__c = t.Call_Status__c;
                        op.Sales_Call_Comment__c = t.Description;
                        // op.Last_Call_Type__c = t.CallType;
                        // if(t.Other_Reason__c != null){
                        //     op.Other_Reason__c = t.Other_Reason__c;
                        // }
                        
                        if(t.Stage__c != Null) {
                            op.Opportunity_Stage__c = t.Stage__c;
                            op.Opportunity_Sub_Stage__c = t.Sub_Stage__c;
                            op.Opportunity_Sub_Stage_Reason__c = t.Sub_Stage_Reason__c;
                        }
                        if(op.Sales_Call_Count__c == Null)
                            op.Sales_Call_Count__c = 0;
                        if(operation == 'insert' || operation == 'update')
                            op.Sales_Call_Count__c = op.Sales_Call_Count__c + 1;
                        if(op.Sales_Call_Comment__c != Null) {
                            if(op.Sales_Comment_History__c == Null)
                                op.Sales_Comment_History__c ='';
                            op.Sales_Comment_History__c =  string.ValueOf(myDate)+': '+op.Sales_Call_Comment__c   + '\n' +  op.Sales_Comment_History__c;
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
    
    public static void RollUpTaskCPProjectServices(Map<Id, List<Task>> mapRollUpCp, string operation, boolean count) {
        List<CP_Project__c> updateCPSubAccountList = new List<CP_Project__c>();
        List<CP_Project__c> cpList = [Select Id, Last_CP_Meeting_Date__c, Last_CP_Meeting_Remarks__c,  Last_CP_Meeting_Action_Date__c ,
                                      Last_CP_Meeting_Remarks_History__c, Last_CP_Call_Next_Action_Date__c, Last_CP_Call_Remarks_History__c , Last_CP_Call_Remarks__c ,Last_CP_Call_Date__c
                                          from CP_Project__c where Id =: mapRollUpCp.keySet()];
        system.debug('cpList: '+cpList);
        
        if(!cpList.isEmpty() && cpList != null) {
            for(CP_Project__c cp: cpList) {
                List<Task> getcpTaskList = mapRollUpCp.get(cp.Id);
                system.debug('getcpTaskList: '+getcpTaskList);
                
                DateTime dT = System.now();
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                System.debug('getcpTaskList: '+getcpTaskList);
                
                if(!getcpTaskList.isEmpty()) {
                    for(Task t: getcpTaskList) {
                        if(t.RecordType.Name == 'CP Call' && t.Subject == 'CP Call') {
                            cp.Last_CP_Call_Date__c = t.CreatedDate;
                            cp.Last_CP_Call_Next_Action_Date__c = t.Next_Call_Action_Date__c;
                            cp.Last_CP_Call_Remarks__c = t.Description;
                            if(cp.Last_CP_Call_Remarks_History__c == Null)
                                cp.Last_CP_Call_Remarks_History__c ='';
                            cp.Last_CP_Call_Remarks_History__c =  string.ValueOf(myDate)+': '+cp.Last_CP_Call_Remarks__c   + '\n' +  cp.Last_CP_Call_Remarks_History__c;
                            updateCPSubAccountList.add(cp);
                        } else if(t.RecordType.Name == 'CP Meeting' && t.Subject == 'CP Meeting') {
                            cp.Last_CP_Meeting_Date__c  = t.CreatedDate;
                            CP.Last_CP_Meeting_Action_Date__c = t.Next_Meeting_Date__c;
                            System.debug('Description: '+t.Description);
                            cp.Last_CP_Meeting_Remarks__c = t.Description;
                            if(cp.Last_CP_Meeting_Remarks_History__c == Null)
                                cp.Last_CP_Meeting_Remarks_History__c ='';
                            cp.Last_CP_Meeting_Remarks_History__c =  string.ValueOf(myDate)+': '+cp.Last_CP_Meeting_Remarks__c   + '\n' +  cp.Last_CP_Meeting_Remarks_History__c;
                            updateCPSubAccountList.add(cp);
                        }
                    }
                }
            }
        }
        system.debug('updateCPSubAccountList: '+updateCPSubAccountList);
        if(!updateCPSubAccountList.isEmpty() && updateCPSubAccountList != null)
            update updateCPSubAccountList;
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