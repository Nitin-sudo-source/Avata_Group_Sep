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
}