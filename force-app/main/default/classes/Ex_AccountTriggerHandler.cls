//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_AccountTriggerHandler {
	public static void beforeInsert(List<Account> accList) {
        List<Account> personAccountList = New List<Account>();
        List<Account> cpAccList = new List<Account>();
        
        for(Account a : accList) {
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(a.RecordTypeId).getName() == 'Person Account')
                personAccountList.add(a);
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(a.RecordTypeId).getName() == 'Channel Partner')
                cpAccList.add(a);
        }
        if(!personAccountList.isEmpty() && personAccountList != null)
            Ex_AccountHandlerServices.duplicationCheck(personAccountList);
        if(!cpAccList.isEmpty() && cpAccList != null)
            Ex_AccountHandlerServices.duplicationCheckOnCP(cpAccList);
    }
    
    public static void beforeUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        List<Account> accList = new List<Account>();
        List<Account> cpAccList = new List<Account>();
        
        for(Account oldAccount: oldMap.values()) {
            Account newAccount = newMap.get(oldAccount.Id);
            
            if((oldAccount.PersonMobilePhone != newAccount.PersonMobilePhone || oldAccount.Phone != newAccount.Phone || oldAccount.PersonEmail != newAccount.PersonEmail || oldAccount.Alternate_Email__c != newAccount.Alternate_Email__c)
               && Schema.SObjectType.Account.getRecordTypeInfosById().get(newAccount.RecordTypeId).getName() == 'Person Account')
            { 
                accList.add(newAccount);
            }
            if(oldAccount.Phone != null && oldAccount.Phone != newAccount.Phone && Schema.SObjectType.Account.getRecordTypeInfosById().get(newAccount.RecordTypeId).getName() == 'Channel Partner') {
                cpAccList.add(newAccount); 
            }
        }        
        if(!accList.isEmpty() && accList != null)
            Ex_AccountHandlerServices.duplicationCheck(accList);
        if(!cpAccList.isEmpty() && cpAccList != null)
            Ex_AccountHandlerServices.duplicationCheckOnCP(cpAccList);
    }
    
    public static void afterInsert(List<Account> accountlist) {
        List<Account> accList = new List<Account>();
        List<Account> cAccountList = new List<Account>();
        
        for(Account a: accountlist) {
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(a.RecordTypeId).getName() == 'Channel Partner')
                accList.add(a);
        }
        //if(!accList.isEmpty() && accList != null)
            //Ex_AccountHandlerServices.insertDocument(accList);
    } 
    
    public static void afterUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        List<Account> accList = new List<Account>();
        List<Account> cAccountList = new List<Account>();
        
        for(Account oldAccount: oldMap.values()) {
            Account newAccount = newMap.get(oldAccount.Id);
            
            /*if(oldAccount.RERA_Available__c != newAccount.RERA_Available__c && newAccount.RERA_Available__c == 'Yes' && Schema.SObjectType.Account.getRecordTypeInfosById().get(newAccount.RecordTypeId).getName() == 'Channel Partner')
            { 
                accList.add(newAccount);
            }*/
        }
        //if(!accList.isEmpty() && accList != null)
            //Ex_AccountHandlerServices.updateDocument(accList);
    }
}