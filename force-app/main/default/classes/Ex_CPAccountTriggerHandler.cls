//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 03-11-2023
//-------------------------------------------//
public class Ex_CPAccountTriggerHandler {
    public static void AfterInsert(List<Account> accountlist){
        List<Account> accList = new List<Account>();
        for(Account a: accountlist){
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(a.RecordTypeId).getName() == 'CP Account'){
                accList.add(a);
            }
        }
        if(!accList.isEmpty() && accList != null){
            Ex_CPAccountTriggerHandlerService.InsertDocument(accList);   
        }
    }
    public static void BeforeInsert(List<Account> accList){
        if(!accList.isEmpty() && accList != null){
            Ex_CPAccountTriggerHandlerService.Check_MAHARERADuplication(accList);
        }
    }
    
    public static void BeforeUpdate(Map<Id,Account> oldMap , Map<Id,Account> newMap){
        List<Account> accList = new List<Account>();
        
        for(account oldAcc:oldMap.Values()){
            account newAcc= newMap.get(oldAcc.id);
            
            if(oldAcc.MahaRERA_Registration_No__c != null && oldAcc.MahaRERA_Registration_No__c != newAcc.MahaRERA_Registration_No__c){
                accList.add(newAcc); 
            }
        }
        If(accList!= null && !accList.isEmpty()){
            Ex_CPAccountTriggerHandlerService.Check_MAHARERADuplication(accList);            
        }
    }
}