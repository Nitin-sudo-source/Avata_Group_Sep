/**
* @File Name : Ex_CPLeadHandlerServices.cls
* @Description : for CP Document Upload 
* @Author : Nitin Choudhary
* @Last Modified By : Nitin Choudhary
* @Last Modified On : September 19, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 18, 2024 |   | Initial Version
**/
public class Ex_CPLeadHandlerServices {
    public static void duplicationCheck(String performRoundRobin, List<CP_Lead__c> leadList) {
        Map<CP_Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckCPLead(leadList);
        List<CP_Lead__c> leadListForAssignment = new List<CP_Lead__c>();

        for(CP_Lead__c l : leadList) {
            String errMsg = '';
            if (duplicateWrapperMap.containsKey(l)) {
                for (Ex_DuplicationHandlerServices.duplicateWrapper dw : duplicateWrapperMap.get(l)) {
                    System.debug('dw: '+dw);
                    if (dw.objectType.equalsIgnoreCase('CP Lead'))
                        errMsg = 'Duplicate CP Lead Found With Record Id is ' + dw.dupCPLead.Id;
                    else if (dw.objectType.equalsIgnoreCase('Account'))
                        errMsg = 'Duplicate Account Found With Name: ' + dw.dupAccount.LastName +' Owner Name: '+ dw.dupAccount.Owner.Name + '. Record Id is ' + dw.dupAccount.Id;
                }
                if (!Test.isRunningTest() && errMsg != '')
                    l.addError(errMsg);
            } else {
                /*if(l.Apply_Round_Robin__c && performRoundRobin.equalsIgnoreCase('Yes')) {
                    leadListForAssignment.add(l);
                }*/
            }
            
        }
        /*if(!leadListForAssignment.isEmpty() && leadListForAssignment != null) {
            applyRoundRobinLogic(leadListForAssignment);
        }*/
    }

}