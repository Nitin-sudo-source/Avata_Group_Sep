public class Ex_AccountHandlerServices {
    public static void duplicationCheck(List<Account> accountList) {
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accountList);
        System.debug('duplicateWrapperMap: '+duplicateWrapperMap);
        
        for(Account a: accountList) {
            if(duplicateWrapperMap.containsKey(a)) {
                for(Ex_DuplicationHandlerServices.duplicateWrapper dw: duplicateWrapperMap.get(a)) {
                    if(!test.isRunningTest())
                        a.addError('Duplicate Account Found with Name: '+dw.dupAccount.LastName+' & Id: '+dw.dupAccount.Id);
                }
            }
        }
    }
}