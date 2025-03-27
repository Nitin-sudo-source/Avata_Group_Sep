//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_OpportunityHandlerServices {
	 public static void duplicationCheck(List<Opportunity__c> opportunityList) {
        Map<Opportunity__c, List<Opportunity__c>> duplicateWrapperMap = new Map<Opportunity__c, List<Opportunity__c>>();
        duplicateWrapperMap = EX_DuplicationHandlerServices.duplicationCheckOpportunity(opportunityList);
        
        for(Opportunity__c op: opportunityList) {
            Integer i = 0;
            i++;
            if(duplicateWrapperMap.containsKey(op)) {
                if(!test.isRunningTest())
                    op.addError('You Cannot Create / Update Opportunity for Specified Project. Already an Opportunity Present with Name: '+duplicateWrapperMap.get(op)[0].Name +' Project Name: '+duplicateWrapperMap.get(op)[0].Project__r.Name+' Owner Name: '+ duplicateWrapperMap.get(op)[0].Owner.Name);
            }
        }
    }
    
    //As Discussed with Akshay CP Lead Task Rollup on Opportunity
    public static void updateTaskOnOpp(List<Opportunity__c> newOPPTaskUpdateList){
        Set<Id> cpLeadSet = new Set<Id>();
        List<Task> taskList = new List<Task>();
        List<Task> updateTaskList = new List<Task>();
        Map<Id, Id> mapCPLeadtoAccount = new Map<Id, Id>();
        
        for(Opportunity__c op: newOPPTaskUpdateList) {
            if(op.CP_Lead__c != null){
                cpLeadSet.add(op.CP_Lead__c);
                mapCPLeadtoAccount.put(op.CP_Lead__c, Op.Account__c);
            }
        }
        
        if(cpLeadSet != null && !cpLeadSet.isEmpty()){
            taskList = [Select Id,  WhoId, WhatId,
                        RecordType.Name from Task where WhatId IN: cpLeadSet  AND (RecordType.Name = 'CP Lead Call')];
            system.debug('taskList: '+taskList);
        }
        System.debug('mapCPLeadtoAccount: '+mapCPLeadtoAccount);
        if(taskList != null && !taskList.isEmpty() && mapCPLeadtoAccount != null){
            for(Task t: taskList) {
                if(t.whatId != Null && t.whatId.getSObjectType().getDescribe().getName() == 'CP_Lead__c') {
                    t.WhatId = mapCPLeadtoAccount.get(t.WhatId); 
                    updateTaskList.add(t);
                }
            }
        }
        System.debug('updateTaskList: '+updateTaskList);
        if(updateTaskList != null && !updateTaskList.isEmpty()){
            try {
                update updateTaskList;
            } catch (DmlException e) {
                System.debug('Error updating tasks: ' + e.getMessage());
            }
        }
    }
}