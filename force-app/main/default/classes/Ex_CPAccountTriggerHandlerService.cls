//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 03-11-2023
//-------------------------------------------//
public class Ex_CPAccountTriggerHandlerService {
    public static void InsertDocument(List<Account> accountlist){
        List<Document__c> dlist = new List<Document__c>();
        
        for(Account acc:accountlist){
            String customValues = CP_Document__c.getValues('Yes').Document_Required__c;
            system.debug('customValues::'+customValues);
            List<String> slist = customValues.split(',');
            System.debug('string list=' + slist);
            for (String s : slist) {
                System.debug('document type=' + s);
                Document__c d = new Document__c();
			    d.Document_Type__c = s; 
                d.CP_Account__c = acc.Id;
                dlist.add(d);
                System.debug('dlist' + dlist);
            }
        }
        if (!dlist.isEmpty() && dlist != null) {
            insert dlist;
        }
    }
    
    Public Static Void Check_MAHARERADuplication(List<Account> accList){
        System.debug('Account value In Handler Services Check_MAHARERADuplicatio '+ accList);
        map<String,Account>  mapOfacc = new map<String, Account>();
        List<Account> acList =  new List<Account>();
        acList=[Select Id,Name,MahaRERA_Registration_No__c from Account where RecordType.DeveloperName = 'CP_Account'];
        System.debug('acList: '+acList);
        if (!acList.isEmpty() && acList!=null){
            for (Account ac:acList){
                if(ac.MahaRERA_Registration_No__c!=null ){
                    mapOfacc.put(ac.MahaRERA_Registration_No__c,ac);
                }
            }
            for(Account acc:accList){
                If(acc.MahaRERA_Registration_No__c !=null )
                    if(mapOfacc.containsKey(acc.MahaRERA_Registration_No__c)){
                        acc.addError('CP Account with same MahaRera Number already exists');
                    }
            }
        }              
    } 
}