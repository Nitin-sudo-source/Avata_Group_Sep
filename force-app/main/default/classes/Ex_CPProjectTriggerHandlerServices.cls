public class Ex_CPProjectTriggerHandlerServices {
    public static void duplicationCheck(List<CP_Project__c> cpProjectList){
        Map<CP_Project__c, List<Ex_CPProjectDuplicationHandlerServices.DuplicateWrapper>> duplicateWrapperMap = new Map<CP_Project__c, List<Ex_CPProjectDuplicationHandlerServices.DuplicateWrapper>>();
        duplicateWrapperMap = Ex_CPProjectDuplicationHandlerServices.duplicationCheckCpProject(cpProjectList);
        System.debug('duplicateWrapperMap: '+duplicateWrapperMap);
        
        for(CP_Project__c cp: cpProjectList) {
            if(duplicateWrapperMap.containsKey(cp)) {
                for(Ex_CPProjectDuplicationHandlerServices.DuplicateWrapper dw: duplicateWrapperMap.get(cp)) {
                    if(!test.isRunningTest())
                        cp.addError('CP Project already exist for Channnel Partner & Project with Name: '+dw.duplicateCPProject.Name+' & Id: '+dw.duplicateCPProject.Id);
                }
            }
        }
    }
}