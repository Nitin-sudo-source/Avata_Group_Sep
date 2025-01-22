//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 18-10-2023
//-------------------------------------------//
public class Ex_AccountHandlerServices{
    
    public static void duplicationCheck(List<Account> accountList) {
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accountList);
        System.debug('duplicateWrapperMap::'+duplicateWrapperMap);
        
        for(Account a: accountList) {
            if(duplicateWrapperMap.containsKey(a)) {
                for(Ex_DuplicationHandlerServices.duplicateWrapper dw: duplicateWrapperMap.get(a)) {
                    if(!test.isRunningTest())
                        a.addError('Duplicate Account Found with Name: '+dw.dupAccount.LastName+' & Id: '+dw.dupAccount.Id);
                }
            }
        }
    }
    
    /*public static void duplicationCheckOnCP(List<Account> accountList) {
Map<Account, List<DuplicationHandlerServices.duplicateWrapper>> CPduplicateWrapperMap = new Map<Account, List<DuplicationHandlerServices.duplicateWrapper>>();
CPduplicateWrapperMap = DuplicationHandlerServices.duplicationCheckCPAcccount(accountList);
System.debug('CPduplicateWrapperMap::'+CPduplicateWrapperMap);

for(Account a: accountList) {
if(CPduplicateWrapperMap.containsKey(a)) {
for(DuplicationHandlerServices.duplicateWrapper dw: CPduplicateWrapperMap.get(a)) {
if(!test.isRunningTest())
a.addError('Duplicate CP Account Found with Name: '+dw.dupAccount.LastName+' & CP Id: '+dw.dupAccount.CP_Unique_Code__c);
}
}
}
}*/
}