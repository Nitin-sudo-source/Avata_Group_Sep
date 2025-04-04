//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 04-09-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_TaskTriggerHandler {
    public static void beforeInsert(List<Task> taskList) {
        Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
        
        for(Task t: taskList) {
            if(Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'Presales Call') {
                if(t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Lead__c') { 
                    if(!taskMap.containsKey(t.WhatId)) {
                        List<Task> tList = new List<Task>();
                        tList.add(t);
                        taskMap.put(t.WhatId, tList);
                    } else {
                        taskMap.get(t.WhatId).add(t);
                    }
                }
            }
        }
        if(!taskMap.isEmpty() && taskMap != null)
            Ex_TaskHandlerServices.validationCheckforPresaleCall(taskMap);
    }
    
    public static void afterInsert(List<Task> taskList) {
        Set<Id> taskIdSet = new Set<Id>();
        List<Task> enqList = new List<Task>();
        Set<Id> leadIdSet = new Set<Id>();
        
        for(Task t: taskList) {
            if(/*t.Stage__c != null &&*/ t.Status.equalsIgnoreCase('Completed') &&
               (Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'Presales Call' || 
                Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'Sales Call' ||
                Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'CP Call' ||
                Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'CP Meeting' ||
               Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'CP Lead Call'||
               Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'Registration Call'
               ))
            {
                taskIdSet.add(t.Id);
            }
            if(Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'Enquiry' && t.Campaign__c != null)
                enqList.add(t);  
            if (Schema.SObjectType.Task.getRecordTypeInfosById().get(t.RecordTypeId).getName() == 'Presales Call' && 
                t.Stage__c == 'Prospects' && 
                t.Sub_Stage__c == 'Hot' &&
                t.Status.equalsIgnoreCase('Completed')) {
                    leadIdSet.add(t.WhatId);
            }
            
        }
        if(!taskIdSet.isEmpty() && taskIdSet != null){
            Ex_TaskHandlerServices.CallHandlerServices(taskIdSet, 'insert', true);
        }
        if(!enqList.isEmpty() && enqList != null)
            Ex_CampaignHandlerServices.calculateCampaignPerformance('Task', null, enqList);
        
        // Send Project Brochure Email to Customer
        if(leadIdSet != null && !leadIdSet.isEmpty()){
            Ex_TaskHandlerServices.sendProjectBrochureEmail(leadIdSet);
        }
        
    }
    
    public static void beforeUpdate(Map<Id, Task> oldMap, Map<Id, Task> newMap) {
        Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
        
        for(Task oldTask: oldMap.values()) {
            Task newTask = newMap.get(oldTask.Id);
            
            if(oldTask.Stage__c != newTask.Stage__c && newTask.Stage__c != null) {
                if(Schema.SObjectType.Task.getRecordTypeInfosById().get(newTask.RecordTypeId).getName() == 'Presales Call') {
                    if(newTask.WhatId != null && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Lead__c') {
                        if(!taskMap.containsKey(newTask.WhatId)) {
                            List<Task> tList = new List<Task>();
                            tList.add(newTask);
                            taskMap.put(newTask.WhatId, tList);
                        } else {
                            taskMap.get(newTask.WhatId).add(newTask);
                        }
                    }
                }
            }
        }
        if(!taskMap.isEmpty() && taskMap != null)
            Ex_TaskHandlerServices.validationCheckforPresaleCall(taskMap);
    }
    
    public static void afterUpdate(Map<Id, Task> oldMap, Map<Id, Task> newMap) {
        Set<Id> taskIdSet = new Set<Id>(); 
        Set<Id> taskIdSetAPI = new Set<Id>(); 
        
        for(Task oldTask: oldMap.values()) {
            Task newTask = newMap.get(oldTask.Id);
            
            if(oldTask.Status != newTask.Status && newTask.Status == 'Completed' && newTask.Stage__c != null)
                taskIdSet.add(newTask.Id);
            if(oldTask.Call_Status__c != newTask.Call_Status__c && newTask.Call_Status__c == 'NOANSWER' && Schema.SObjectType.Task.getRecordTypeInfosById().get(newTask.RecordTypeId).getName() == 'Presales Call'){
                taskIdSetAPI.add(newTask.WhatId);
            }
        }
        //if(!taskIdSetAPI.isEmpty() && taskIdSetAPI != null){
            //Ex_SMSTriggerHandlerServices.sendBulkMessage('Task__c', taskIdSetAPI);
        //}
        if(!taskIdSet.isEmpty() && taskIdSet != null)
            Ex_TaskHandlerServices.CallHandlerServices(taskIdSet, 'update', true);
    }
}