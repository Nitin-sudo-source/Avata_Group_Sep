/**
* @File Name : Ex_CPDocumentUploadController.cls
* @Description : for CP Document Upload 
* @Author : Nitin Choudhary
* @Last Modified By : Nitin Choudhary
* @Last Modified On : September 18, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 18, 2024 |   | Initial Version
**/

public class Ex_CPDocumentUploadController {
	@AuraEnabled
    public static List<Document__c> getCPDocumentDetails(string id ){
        List<Document__c> sList = new List<Document__c>(); 
        
        List<Document__c> dhList = [SELECT ID, Name, Document_Type__c, CP_Account__c, Uploaded__c FROM Document__c where CP_Account__r.Id=:id];
        return dhList;
    }
    
    @AuraEnabled
    public static Id uploadFile(String cpDocumentList ){ 
        System.debug('cpDocumentList' +cpDocumentList);
        Document__c cpDocument = new Document__c();
        List<Object> documentsList = (List<Object>) JSON.deserializeUntyped(cpDocumentList);   
        if (documentsList != null && !documentsList.isEmpty()) {
            for (Object document1 : documentsList) {
                if (document1 instanceof Map<String, Object>) {
                    Map<String, Object> documentMap = (Map<String, Object>) document1;
                    system.debug('documentMap  ' +documentMap);
                    cpDocument.Uploaded__c = (Boolean) documentMap.get('Uploaded__c');
                    cpDocument.Id = (Id) documentMap.get('Id');
                    update cpDocument;
                    String base64 = (string) documentMap.get('base64');
                    String filename = (string) documentMap.get('filename');
                    
                    if (base64 != null && filename != null) {
                        ContentVersion cv = createContentVersion(base64, filename);
                        ContentDocumentLink cdl = createContentLink(cv.Id, cpDocument.Id);
                        if (cv == null || cdl == null) {
                            return null;
                        }
                    }
                }
            }
        }
        return cpDocument.Id;
    }
    
    @testvisible
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    @testvisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
}