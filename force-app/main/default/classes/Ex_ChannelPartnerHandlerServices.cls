public class Ex_ChannelPartnerHandlerServices {
    
    public static void duplicationCheckOnCP(List<Channel_Partner__c> accountList) {
        Map<Channel_Partner__c, List<Ex_CPDuplicationHandlerServices.duplicateWrapper>> cpduplicateWrapperMap = new Map<Channel_Partner__c, List<Ex_CPDuplicationHandlerServices.duplicateWrapper>>();
        cpduplicateWrapperMap = Ex_CPDuplicationHandlerServices.duplicationCheckCPAcccount(accountList);
        System.debug('CPduplicateWrapperMap::'+cpduplicateWrapperMap);
        
        for(Channel_Partner__c cp: accountList) {
            if(cpduplicateWrapperMap.containsKey(cp)) {
                for(Ex_CPDuplicationHandlerServices.duplicateWrapper dw: cpduplicateWrapperMap.get(cp)) {
                    if(!test.isRunningTest())
                        cp.addError('Duplicate CP Account Found with Name: '+dw.dupAccount.Name + ' & MahaRERA Registration No. '+ dw.dupAccount.MahaRERA_Registration_No__c);
                }
            }
        }
    }
    
    public static void insertDocument(List<Channel_Partner__c> newCpList) {
        List<Document__c> cpDocumentList = new List<Document__c>();
        String customValues = '';
        Id recordTypeId = null;
        List<String> sList = new List<String>();
        
        if (!newCpList.isEmpty() && newCpList != null) {
            for (Channel_Partner__c cp : newCpList) {
                if(cp.RERA_Available__c != null){
                customValues = CP_Document__c.getValues(cp.RERA_Available__c).Document_Required__c;
                }
                System.debug('customValues::' + customValues);
                
                if (String.isNotBlank(customValues)) {
                    sList = customValues.split(',');
                    System.debug('string list=' + sList);
                }
                
                if (!sList.isEmpty() && sList != null) {
                    for (String s : sList) {
                        System.debug('document type :' + s);
                        Document__c cpd = new Document__c();
                        cpd.Document_Type__c = s;
                        cpd.RecordTypeId = Schema.SObjectType.Document__c
                            .getRecordTypeInfosByDeveloperName()
                            .get('CP_Documents')
                            .getRecordTypeId();
                        cpd.Channel_Partner__c = cp.Id;
                        cpDocumentList.add(cpd);
                        System.debug('cpDocumentList' + cpDocumentList);
                    }
                }
            }
        }
        
        if (!cpDocumentList.isEmpty() && cpDocumentList != null) {
            insert cpDocumentList;
        }
    }
    
    public static void updateDocument(List<Channel_Partner__c> accountList) {
        Set<Id> accountIds = new Set<Id>();
        List<Document__c> cpDocumentList = new List<Document__c>();
        Set<String> existingDocumentTypes = new Set<String>();
        String customValues = '';
        
        for (Channel_Partner__c a : accountList) {
            accountIds.add(a.Id);
        }
        
        List<Document__c> existingDocuments = [SELECT Id, Document_Type__c, Channel_Partner__c
                                               FROM Document__c
                                               WHERE Channel_Partner__c IN :accountIds];
        
        for (Document__c existingDoc : existingDocuments) {
            existingDocumentTypes.add(existingDoc.Document_Type__c);
        }
        
        for (Channel_Partner__c a : accountList) {
            if(a.RERA_Available__c != null)
            customValues = CP_Document__c.getValues(a.RERA_Available__c).Document_Required__c;
            
            List<String> sList = customValues.split(',');
            System.debug('string list=' + sList);
            
            for (String s : sList) {
                System.debug('document type=' + s);
                if (!existingDocumentTypes.contains(s)) {
                    Document__c cpd = new Document__c();
                    cpd.Document_Type__c = s; 
                    cpd.Channel_Partner__c = a.Id;
                    cpd.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName().get('CP_Documents').getRecordTypeId();
                    
                    cpDocumentList.add(cpd);
                    System.debug('cpDocumentList' + cpDocumentList);
                }
            }
        }
        
        if (!cpDocumentList.isEmpty() && cpDocumentList != null) {
            insert cpDocumentList;
        }
    }
}