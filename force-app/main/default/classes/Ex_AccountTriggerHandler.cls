public class Ex_AccountTriggerHandler {
    public static void beforeInsert(List<Account> accountList) {
        List<Account> personAccountList = New List<Account>();
        List<Account> cpList = New List<Account>();
        
        for(Account a : accountList) {
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(a.RecordTypeId).getName() == 'Person Account')
                personAccountList.add(a);
        }
        if(!personAccountList.isEmpty() && personAccountList != null)
            Ex_AccountHandlerServices.duplicationCheck(personAccountList);
    }
    
    public static void beforeUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        List<Account> personAccountList = new List<Account>();
        List<Account> cpList = New List<Account>();
        
        for(Account oldAccount: oldMap.values()) {
            Account newAccount = newMap.get(oldAccount.Id);
            
            if((oldAccount.PersonMobilePhone != newAccount.PersonMobilePhone || oldAccount.Phone != newAccount.Phone ||
                oldAccount.PersonEmail != newAccount.PersonEmail || oldAccount.Alternate_Email__c != newAccount.Alternate_Email__c) 
               && Schema.SObjectType.Account.getRecordTypeInfosById().get(newAccount.RecordTypeId).getName() == 'Person Account')
            { 
                personAccountList.add(newAccount);
            }
        }        
        if(!personAccountList.isEmpty() && personAccountList != null)
            Ex_AccountHandlerServices.duplicationCheck(personAccountList);
    }
    
  }