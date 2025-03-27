public class Ex_CPDocumentUploadController {
    @AuraEnabled
    public static List<Document__c> getCPDocumentDetails(string id) {
        List<Document__c> sList = new List<Document__c>(); 
        
        List<Document__c> dList = [SELECT ID, Name, Document_Type__c, Channel_Partner__c, Uploaded__c FROM Document__c 
                                   where Channel_Partner__r.Id = :id];
        return dList; 
    }

    @AuraEnabled
    public static Id uploadFile(String cpDocumentList) { 
        System.debug('cpDocumentList: ' + cpDocumentList);
        Document__c cpDocument = new Document__c();
        List<Object> documentsList = (List<Object>) JSON.deserializeUntyped(cpDocumentList);   

        if (documentsList != null && !documentsList.isEmpty()) {
            for (Object document1 : documentsList) {
                if (document1 instanceof Map<String, Object>) {
                    Map<String, Object> documentMap = (Map<String, Object>) document1;
                    System.debug('documentMap: ' + documentMap);
                    
                    if (documentMap.containsKey('Id') && documentMap.get('Id') != null) {
                        cpDocument.Uploaded__c = (Boolean) documentMap.get('Uploaded__c');
                        cpDocument.Id = (Id) documentMap.get('Id');
                        update cpDocument;
                    } else {
                        System.debug('Document Id is null, skipping update');
                    }
                    
                    String base64 = (String) documentMap.get('base64');
                    String filename = (String) documentMap.get('filename');

                    if (base64 != null  && filename != null) {
                        ContentVersion cv = createContentVersion(base64, filename);
                        ContentDocumentLink cdl = createContentLink(cv.Id, cpDocument.Id);
                        if (cv == null || cdl == null) {
                            return null;
                        }
                    } else {
                        System.debug('Base64 or filename is null, skipping file creation');
                    }
                }
            }
        }
        return cpDocument.Id;
    }

    @testvisible
    private static ContentVersion createContentVersion(String base64, String filename) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = filename;
            cv.PathOnClient = filename;
            cv.FirstPublishLocationId = UserInfo.getUserId();
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug('Error inserting ContentVersion: ' + e.getMessage());
            return null;
        }
    }

    @testvisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        try {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;
            return cdl;
        } catch (DMLException e) {
            System.debug('Error inserting ContentDocumentLink: ' + e.getMessage());
            return null;
        } catch (Exception e) {
            System.debug('Unexpected Error: ' + e.getMessage());
            return null;
        }
    }
}