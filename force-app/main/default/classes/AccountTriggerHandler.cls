//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class AccountTriggerHandler {
    public static void beforeInsert(List<Account> accountList) {
        List<Account> personAccountList = New List<Account>();
        
        for(Account a : accountList) {
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(a.RecordTypeId).getName() == 'Person Account')
                PersonAccountList.add(a);
        }
        if(!PersonAccountList.isEmpty() && PersonAccountList != null)
            AccountHandlerServices.duplicationCheck(accountList);
    }
    
    public static void beforeUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        List<Account> aList = new List<Account>();
        List<Account> CPList = new List<Account>();
        
        for(Account oldAccount: oldMap.values()) {
            Account newAccount = newMap.get(oldAccount.Id);
            
            if((oldAccount.PersonMobilePhone != newAccount.PersonMobilePhone || oldAccount.Phone != newAccount.Phone || oldAccount.PersonEmail != newAccount.PersonEmail 
                || oldAccount.Alternate_Email__c != newAccount.Alternate_Email__c) && Schema.SObjectType.Account.getRecordTypeInfosById().get(newAccount.RecordTypeId).getName() == 'Person Account')
            { 
                aList.add(newAccount);
            } 
        }        
        if(!aList.isEmpty() && aList != null)
            AccountHandlerServices.duplicationCheck(aList);
     }
}