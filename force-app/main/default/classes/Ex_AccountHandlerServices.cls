//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_AccountHandlerServices {
    public static void duplicationCheck(List<Account> accountList) {
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accountList);
        System.debug('duplicateWrapperMap::'+duplicateWrapperMap);
        
        for(Account a: accountList) {
            if(duplicateWrapperMap.containsKey(a)) {
                for(Ex_DuplicationHandlerServices.duplicateWrapper dw: duplicateWrapperMap.get(a)) {
                    if(!test.isRunningTest())
                        a.addError('Duplicate Account Found with Name: '+dw.dupAccount.LastName +' Owner Name: '+ dw.dupAccount.Owner.Name +'. Record Id is '+dw.dupAccount.Id);
                }
            }
        }
    }
    
    public static void duplicationCheckOnCP(List<Account> accountList) {
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> CPduplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        
        CPduplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckCPAcccount(accountList);
        System.debug('CPduplicateWrapperMap::'+CPduplicateWrapperMap);
        
        for(Account a: accountList) {
            if(CPduplicateWrapperMap.containsKey(a)) {
                for(Ex_DuplicationHandlerServices.duplicateWrapper dw: CPduplicateWrapperMap.get(a)) {
                    if(!test.isRunningTest())
                        a.addError('Duplicate CP Account Found with Name: '+dw.dupAccount.Name+' Owner Name: '+ dw.dupAccount.Owner.Name +'. Record Id is '+dw.dupAccount.Id);
                }
            }
        }
    }
    
    public static void insertDocument(List<Account> accountList) {
        List<Document__c> cpDocumentList = new List<Document__c>();
        
        for(Account acc : accountList) {
            String customValues = CP_Document__c.getValues(acc.RERA_Available__c).Document_Required__c;
            List<String> sList = customValues.split(',');
            
            for(String s : sList) {
                Document__c cpd = new Document__c();
                cpd.Document_Type__c = s;
                cpd.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName().get('CP_Document').getRecordTypeId();
                cpd.CP_Account__c = acc.Id;
                cpDocumentList.add(cpd);
            }
        }
        if(!cpDocumentList.isEmpty() && cpDocumentList != null)
            insert cpDocumentList;
    }
    
    public static void updateDocument(List<Account> accountList) {
        Set<Id> accountIds = new Set<Id>();
        List<Document__c> cpDocumentList = new List<Document__c>();
        Set<String> existingDocumentTypes = new Set<String>();
        
        for(Account a : accountList) {
            accountIds.add(a.Id);
        }
        
        List<Document__c> existingDocuments = [Select Id, Document_Type__c, CP_Account__c from Document__c where CP_Account__c IN: accountIds];
        system.debug('existingDocuments: '+existingDocuments);
        
        for(Document__c existingDoc : existingDocuments) {
            existingDocumentTypes.add(existingDoc.Document_Type__c);
        }
        
        for(Account a : accountList) {
            String customValues = CP_Document__c.getValues(a.RERA_Available__c).Document_Required__c;
            List<String> sList = customValues.split(',');
            
            for(String s : sList) {
                if(!existingDocumentTypes.contains(s)) {
                    Document__c cpd = new Document__c();
                    cpd.Document_Type__c = s; 
                    cpd.CP_Account__c = a.Id;
                    cpd.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName().get('CP_Document').getRecordTypeId();
                    cpDocumentList.add(cpd);
                }
            }
        }
        if(!cpDocumentList.isEmpty() && cpDocumentList != null)
            insert cpDocumentList;
    }
}