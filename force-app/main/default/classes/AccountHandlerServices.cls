//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class AccountHandlerServices {
	public static void duplicationCheck(List<Account> accountList) {
        Map<Account, List<DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = DuplicationHandlerServices.duplicationCheckAcccount(accountList);
        System.debug('duplicateWrapperMap::'+duplicateWrapperMap);
       
        for(Account a: accountList) {
            if(duplicateWrapperMap.containsKey(a)) {
                for(DuplicationHandlerServices.duplicateWrapper dw: duplicateWrapperMap.get(a)) {
                    if(!test.isRunningTest())
                    	a.addError('Duplicate Account Found with Name: '+dw.dupAccount.LastName+' & Id: '+dw.dupAccount.Account_Id__c);
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