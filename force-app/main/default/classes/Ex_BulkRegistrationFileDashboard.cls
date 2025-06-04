/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 30-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
public with sharing class Ex_BulkRegistrationFileDashboard {
    public Ex_BulkRegistrationFileDashboard() {
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProject(){
        List<Project__c> plist=[select Id, Name FROM Project__c];
        return plist;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Tower__c> getTower(String ProjectId){
        List<Tower__c> tlist=[select Id, Name,Project__c FROM Tower__c WHERE Project__r.id =: ProjectId];
        return tlist;
    }
    
    
    // @AuraEnabled
    // public static List<registrationWrapper> getRegistrationData(){
        //     try {
            
            
        //     } catch (Exception e) {
            //         throw new AuraHandledException(e.getMessage());
        //     }
    // }
    
    
    @AuraEnabled
    public static List<ContentDocumentLinkWrapper> fetchFiles(String objectName, String documentType, String towerId, String projectId) {
        List<ContentDocumentLinkWrapper> result = new List<ContentDocumentLinkWrapper>();
        Map<Id, Id> demandToDocumentsMap = new Map<Id, Id>();
        Set<String> docSet = new Set<String>();
        Map<Id, String> contentDocMap = new Map<Id, String>();
        if(String.isNotBlank(documentType)){
            documentType.toUpperCase();
        }
        
        try {
            // Fetch Registration Data
            List<Registration__c> getRegistrationData = [ 
                SELECT Id, Name, 
                Is_Final_Agreement_uploaded__c, Is_Index_Page_Uploded__c, Final_Agreement_Uploded_FileName__c, Index_Page_Uploded_File_Name__c, createdDate, Booking__r.Name, Registration_Date__c, 
                Booking__r.Booking_Stage__c, Booking__r.Unit__r.Name, Booking__r.Project__c, 
                Booking__r.Tower__c, Verified_By_MIS__c, Verified_By_RM__c
                FROM Registration__c 
                WHERE Booking__r.Project__c =: projectId 
                AND Booking__r.Tower__c =: towerId 
                AND Booking__c != null
            ];
            
            if (!getRegistrationData.isEmpty()) {
                Set<Id> rIds = new Set<Id>();
                
                for (Registration__c reg : getRegistrationData) {
                    List<String> docNames = new List<String>();
                    
                    //if(!documentType.equalsIgnoreCase('ALL')){
                        if (String.isNotBlank(reg.Final_Agreement_Uploded_FileName__c)) {
                            docNames.addAll(new List<String>(reg.Final_Agreement_Uploded_FileName__c.split('#')));
                        }
                        if (String.isNotBlank(reg.Index_Page_Uploded_File_Name__c)) {
                            docNames.addAll(new List<String>(reg.Index_Page_Uploded_File_Name__c.split('#')));
                        }
                        
                        
                        for (String docName : docNames) {
                            docName = docName.trim();
                            if (docName.contains(documentType)) {
                                docSet.add(docName);
                            }
                        }
                    // }
                    
                    
                    
                    
                    rIds.add(reg.Id);
                }
                
                String query = 'SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize, ContentDocument.LastModifiedDate, ContentDocument.CreatedDate, LinkedEntity.Type, LinkedEntity.Id FROM ContentDocumentLink WHERE LinkedEntityId IN :rIds';
                if (String.isNotBlank(objectName)) {
                    query += ' AND LinkedEntity.Type = \'' + objectName + '\'';
                }
                
                List<ContentDocumentLink> contentDocumentLinks = Database.query(query);
                
                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    if (!demandToDocumentsMap.containsKey(cdl.LinkedEntityId)) {
                        demandToDocumentsMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                    demandToDocumentsMap.get(cdl.LinkedEntityId);
                }
                
                Map<Id, ContentDocumentLink> registrationToDocumentMap = new Map<Id, ContentDocumentLink>();
                Set<Id> contentDocumentIds = new Set<Id>();
                
                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    registrationToDocumentMap.put(cdl.LinkedEntityId, cdl);
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                Map<Id, Id> contentDocumentToVersionMap = new Map<Id, Id>();
                
                if (!contentDocumentIds.isEmpty()) {
                    List<ContentVersion> contentVersions = [
                        SELECT Id, ContentDocumentId 
                        FROM ContentVersion 
                        WHERE ContentDocumentId IN :contentDocumentIds 
                        ORDER BY CreatedDate DESC
                    ];
                    
                    for (ContentVersion cv : contentVersions) {
                        if (!contentDocumentToVersionMap.containsKey(cv.ContentDocumentId)) {
                            contentDocumentToVersionMap.put(cv.ContentDocumentId, cv.Id);
                        }
                    }
                }
                
                if(docSet != null && !docSet.isEmpty()){
                    for (ContentDocumentLink doc : contentDocumentLinks) {
                        for (String docName : docSet) {
                            if (!contentDocMap.containsKey(doc.LinkedEntityId)) {
                                contentDocMap.put(doc.LinkedEntityId, docName);
                            }
                            contentDocMap.get(doc.LinkedEntityId);
                        }
                    }
                    System.debug('contentDocMap: '+contentDocMap);
                }
                
                for (Registration__c reg : getRegistrationData) {
                    if (contentDocMap.containsKey(reg.Id) && contentDocMap.get(reg.Id).contains(documentType)) {
                        if(demandToDocumentsMap.containsKey(reg.Id)){
                            if (registrationToDocumentMap.containsKey(reg.Id)) {
                                ContentDocumentLink cdl = registrationToDocumentMap.get(reg.Id);
                                
                                ContentDocumentLinkWrapper wrapper = new ContentDocumentLinkWrapper();
                                wrapper.registrationName = reg.Name;
                                wrapper.fileType = documentType;
                                wrapper.bookingId = reg.Booking__c;
                                wrapper.regId = reg.Id;
                                wrapper.UnitName = reg.Booking__r.Unit__r.Name;
                                wrapper.bookingNo = reg.Booking__r.Name;
                                wrapper.isDownloaded = false;
                                wrapper.createdDate = reg.CreatedDate;
                                wrapper.bookingStatus = reg.Booking__r.Booking_Stage__c;
                                wrapper.registrationDate = reg.Registration_Date__c;
                                wrapper.contentDocumentId = cdl.ContentDocumentId;
                                wrapper.isverifiedBYMIS = reg.Verified_By_MIS__c;
                                wrapper.isverifiedBYRM = reg.Verified_By_RM__c;
                                if(reg.Verified_By_MIS__c){
                                    wrapper.verifiedBYMIS = 'Verified';
                                }else{
                                    wrapper.verifiedBYMIS = 'Not Verified';
                                }
                                 if(reg.Verified_By_RM__c){
                                    wrapper.verifiedBYRM = 'Verified';
                                }else{
                                    wrapper.verifiedBYRM = 'Not Verified';
                                }
                                                                
                                // Assign the latest ContentVersionId
                                if (contentDocumentToVersionMap.containsKey(cdl.ContentDocumentId)) {
                                    wrapper.contentVersionId = contentDocumentToVersionMap.get(cdl.ContentDocumentId);
                                }
                                
                                result.add(wrapper);
                                
                                /*ContentDocumentLinkWrapper wrapper = new ContentDocumentLinkWrapper();
                                wrapper.registrationName = reg.Name;
                                wrapper.fileType = documentType;
                                wrapper.bookingId = reg.Booking__c;
                                wrapper.regId = reg.Id;
                                wrapper.unitName = String.valueOf(reg.Booking__r.Unit__r.Name);
                                wrapper.bookingNo = reg.Booking__r.Name;
                                wrapper.isDownloaded = false;
                                wrapper.createdDate = reg.createdDate;
                                wrapper.bookingStatus = reg.Booking__r.Booking_Stage__c;
                                wrapper.registrationDate = reg.Registration_Date__c;
                                wrapper.contentDocumentId = demandToDocumentsMap.get(reg.Id);
                                wrapper.contentVersionId = demandToDocumentsMap.get(reg.Id);
                                result.add(wrapper);*/
                            }
                            
                        }
                    }
                }
                
            }
        }catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        if(result != null){
            System.debug('result: '+result);
            return result;
        }else{
            return null;
        }
        
        
    }
    
    
    
    public class ContentDocumentLinkWrapper {
        @AuraEnabled
        public Id contentDocumentId { get; set; }
        
        
        @AuraEnabled
        public Integer contentSize { get; set; }
        
        @AuraEnabled
        public Datetime registrationDate { get; set; }
        
        @AuraEnabled
        public Datetime createdDate { get; set; }
        
        @AuraEnabled
        public String linkedEntityType { get; set; }
        
        @AuraEnabled
        public String registrationName { get; set; }
        
        @AuraEnabled
        public String regId { get; set; }
        
        @AuraEnabled
        public String UnitName { get; set; }
        
        @AuraEnabled
        public String bookingNo { get; set; }
        
        @AuraEnabled
        public String bookingStatus { get; set; }
        
        @AuraEnabled
        public Boolean isDownloaded { get; set; }
        
        @AuraEnabled
        public String fileType { get; set; }
        
        @AuraEnabled
        public String bookingId {get;set;}
        
        @AuraEnabled
        public String contentVersionId {get;set;}

         @AuraEnabled
        public String verifiedBYMIS {get;set;}

         @AuraEnabled
        public String verifiedBYRM {get;set;}

         @AuraEnabled
        public Boolean isverifiedBYMIS {get;set;}

         @AuraEnabled
        public Boolean isverifiedBYRM {get;set;}
    }
    
    
    
}