public with sharing class Ex_WelcomeCallChecklistController {
    
    @AuraEnabled(cacheable=true)
    public static List<Booking_Checklist__c> getRejectedChecklist(String recId) {
        Decimal agreementValue = 0;
        Decimal agreementValueTax = 0;
        Decimal SDRValue = 0;
        Decimal SDRTax = 0;
        Decimal OCValue = 0;
        Decimal OCTax = 0;
        
        system.debug('recId::'+recId);
        List<Booking_Checklist__c> checkListToBeReturn  = new List<Booking_Checklist__c>();
        List<Applicant__c> appList = new List<Applicant__c>();
        Booking__c booking = new Booking__c();
        Quotation__c quote = new Quotation__c();
        List<Receipt__c> rLst = new List<Receipt__c>();
        Decimal totalTokenAmount = 0;
        
        List<Booking_Checklist__c> checklist = [SELECT Id, Section__c, Item__c, Action__c,Booking__c FROM Booking_Checklist__c 
                                                WHERE Booking__c = :recId AND Action__c = 'Reject'];
        system.debug('checklist is::'+checklist);
        
        appList = [SELECT Id, Booking__c, Applicant_Number__c, Name, Aadhar_Number__c, PAN_Number__c, Mobile__c,Email__c
                   FROM Applicant__c 
                   WHERE Booking__c = :recId];
        system.debug('appList is::' + appList);
        
        booking = [SELECT Id, Source__c, Quotation__c FROM Booking__c WHERE Id = :recId LIMIT 1];
        system.debug('booking is::' + booking);
        
        quote = Ex_BookingFormController.getQuotationDetails(booking.Quotation__c);
        
        
        if(String.isNotBlank(quote.Quotation_Status__c) && (quote.Quotation_Status__c.equalsIgnoreCase('Valid') || quote.Quotation_Status__c.equalsIgnoreCase('Approved'))) {
            for(Integer i = 1; i <= 3; i++) {
                if(String.isNotBlank((String)quote.get('Charge_Bucket_'+i+'__c')) && ((String)quote.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                    agreementValue = (Decimal)quote.get('Charge_Bucket_'+i+'_Amount__c');
                    agreementValueTax = (Decimal)quote.get('Charge_Bucket_'+i+'_Total_Tax__c');
                }
                if(String.isNotBlank((String)quote.get('Charge_Bucket_'+i+'__c')) && ((String)quote.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Statutory Charges')) {
                    SDRValue = (Decimal)quote.get('Charge_Bucket_'+i+'_Amount__c');
                    SDRTax = (Decimal)quote.get('Charge_Bucket_'+i+'_Total_Tax__c');
                }
                if(String.isNotBlank((String)quote.get('Charge_Bucket_'+i+'__c')) && ((String)quote.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Other Charges')) {
                    OCValue = (Decimal)quote.get('Charge_Bucket_'+i+'_Amount__c');
                    OCTax = (Decimal)quote.get('Charge_Bucket_'+i+'_Total_Tax__c');
                }
            }
        }
        System.debug('agreementValue: '+agreementValue);
        System.debug('agreementValueTax: '+agreementValueTax);
        System.debug('SDRValue: '+SDRValue);
        System.debug('SDRTax: '+SDRTax);
        System.debug('OCValue: '+OCValue);
        System.debug('OCTax: '+OCTax);
        
        rLst = [Select Id, Booking__c, Amount__c from Receipt__c where Booking__c = :recId];
        system.debug('rLst is::'+rLst);
        for(Receipt__c r : rLst){
            totalTokenAmount += r.Amount__c;
        }
        
        
        Map<String, Applicant__c> applicantMap = new Map<String, Applicant__c>();
        for (Applicant__c applicant : appList) {
            applicantMap.put(applicant.Applicant_Number__c, applicant);
        }
        system.debug('applicantMap is::' + applicantMap);
        
        Map<String, String> labelMapping = new Map<String, String>{
            'Applicant 1' => 'Primary Applicant',
                'Applicant 2' => 'Second Applicant',
                'Applicant 3' => 'Third Applicant',
                'Applicant 4' => 'Fourth Applicant',
                'Applicant 5' => 'Fifth Applicant'
                };  
                    for (Booking_Checklist__c item : checklist) {
                        String[] parts = item.Item__c.split(' - ');
                        if (parts.size() > 1) {
                            String applicantLabel = parts[0].trim();
                            String applicantName = parts[1].trim();
                            
                            String mappedLabel = labelMapping.get(applicantLabel);
                            
                            if (mappedLabel != null && applicantMap.containsKey(mappedLabel)) {
                                Applicant__c app = applicantMap.get(mappedLabel);
                                String updatedItem = applicantLabel + ' - ' + app.Name;
                                
                                if (item.Section__c == 'Mobile Number and Email Id') {
                                    for (Integer i = 2; i < parts.size(); i++) {
                                        if (parts[i].contains('Mobile Number:') && app.Mobile__c != null && !app.Mobile__c.equals(parts[i].split(':')[1].trim())) {
                                            system.debug('Mobile Number');
                                            updatedItem += ' - Mobile Number:' + app.Mobile__c;
                                            system.debug('updatedItem is::' + updatedItem);
                                        } else if (parts[i].contains('Email Id:') && app.Email__c != null && !app.Email__c.equals(parts[i].split(':')[1].trim())) {
                                            system.debug('Email Id');
                                            updatedItem += ' - Email Id:' + app.Email__c;
                                            system.debug('updatedItem is::' + updatedItem);
                                        } else {
                                            updatedItem += ' - ' + parts[i].trim();
                                        }
                                    }
                                }
                                
                                if (item.Section__c == 'KYC of all applicants') {
                                    for (Integer i = 2; i < parts.size(); i++) {
                                        if (parts[i].contains('PAN Number:') && app.PAN_Number__c != null && !app.PAN_Number__c.equals(parts[i].split(':')[1].trim())) {
                                            updatedItem += ' - PAN Number:' + app.PAN_Number__c;
                                        } else if (parts[i].contains('Adhaar Number:') && app.Aadhar_Number__c != null && !app.Aadhar_Number__c.equals(parts[i].split(':')[1].trim())) {
                                            updatedItem += ' - Adhaar Number:' + app.Aadhar_Number__c;
                                        } else {
                                            updatedItem += ' - ' + parts[i].trim();
                                        }
                                    }
                                }
                                
                                if (!updatedItem.equals(item.Item__c)) {
                                    item.Item__c = updatedItem;
                                    system.debug('Updated item.Item__c is::' + item.Item__c);
                                }
                            }
                        }
                        if (item.Section__c == 'Source of Booking' && booking.Source__c != null) {
                            String[] sourceParts = item.Item__c.split(' - ');
                            if (sourceParts.size() > 1) {
                                String bookingSource = sourceParts[1].trim();
                                if (!booking.Source__c.equals(bookingSource)) {
                                    item.Item__c = 'Booking Source - ' + booking.Source__c;
                                }
                            }
                        }
                        if (item.Section__c == 'Tower/Building Name and Unit Details' && quote.Tower__r.Name != null) {
                            if (parts[0].contains('Tower Name')) {
                                String towerName = parts[1].trim();
                                if (!quote.Tower__r.Name.equals(towerName)) {
                                    item.Item__c = 'Tower Name - ' + quote.Tower__r.Name;
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Tower/Building Name and Unit Details' && quote.Unit__r.Name != null) {
                            if (parts[0].contains('Unit Name')) {
                                String unitName = parts[1].trim();
                                if (!quote.Unit__r.Name.equals(unitName)) {
                                    item.Item__c = 'Unit Name - ' + quote.Unit__r.Name;
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && agreementValue != null){
                            if (parts[0].contains('Agreement Value')) {
                                String agrvalue = parts[1].trim();
                                String formattedValue = agreementValue.format();
                                if (!formattedValue.equals(agrvalue)) {
                                    item.Item__c = 'Agreement Value - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && SDRValue != null){
                            if (parts[0].contains('SDR')) {
                                String sdrvalueq = parts[1].trim();
                                String formattedValue = SDRValue.format();
                                if (!formattedValue.equals(sdrvalueq)) {
                                    item.Item__c = 'SDR - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && OCValue != null){
                            if (parts[0].contains('Other Charges')) {
                                String otherchargesvalue = parts[1].trim();
                                String formattedValue = OCValue.format();
                                if (!formattedValue.equals(otherchargesvalue)) {
                                    item.Item__c = 'Other Charges - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && agreementValueTax != null){
                            if (parts[0].contains('GST on Agreement Value')) {
                                String gstonotherchargevalue = parts[1].trim();
                                String formattedValue = agreementValueTax.format();
                                if (!formattedValue.equals(gstonotherchargevalue)) {
                                    item.Item__c = 'GST on Agreement Value - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && agreementValue != null){
                            if (parts[0].contains('Total Agreement Value Bucket')) {
                                String totalagrvaluebucket = parts[1].trim();
                                String formattedValue = (agreementValue + agreementValueTax).format();
                                if (!formattedValue.equals(totalagrvaluebucket)) {
                                    item.Item__c = 'Total Agreement Value Bucket - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && OCTax != null){
                            if (parts[0].contains('GST on Other Charges')) {
                                String gstonothercharges = parts[1].trim();
                                String formattedValue = OCTax.format();
                                if (!formattedValue.equals(gstonothercharges)) {
                                    item.Item__c = 'GST on Other Charges - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && OCValue != null){
                            if (parts[0].contains('Total Other Charges')) {
                                String totalOtherCharges = parts[1].trim();                                
                                String formattedValue = (OCValue+ OCTax).format();
                                if (!formattedValue.equals(totalOtherCharges)) {
                                    item.Item__c = 'Total Other Charges - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Agreement Value and Total Cost of the Unit' && quote.Car_Park_Required_Count__c != null){
                            if (parts[0].contains('Total Car Park Count')) {
                                String totalOtherCharges = parts[1].trim();
                                String formattedValue = quote.Car_Park_Required_Count__c.format();
                                if (!formattedValue.equals(totalOtherCharges)) {
                                    item.Item__c = 'Total Car Park Amount - ' + formattedValue + '/-';
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Payment Schedules' && quote.Payment_Scheme__r.Name != null){
                            if (parts[0].contains('Payment Schedule')) {
                                String svchemeName = parts[1].trim();
                                if (!quote.Payment_Scheme__r.Name.equals(svchemeName)) {
                                    item.Item__c = 'Payment Schedule - ' + quote.Payment_Scheme__r.Name;
                                }
                            }
                        }
                        
                        if (item.Section__c == 'Token Amount Payment Details' && totalTokenAmount != null){
                            system.debug(' totalTokenAmountis::'+ totalTokenAmount);
                            System.debug('parts.size() .: '+parts.size());
                            if (parts[0].contains('Token Amount')  && parts.size() >= 1) {
                                String tokenAmount = parts[0].trim();
                                System.debug('tokenAmount .: ' +tokenAmount);
                                String formattedValue = totalTokenAmount.format();
                                item.Item__c = 'Total Amount Received - ' + formattedValue + '/-';
                            }
                        }
                        
                        
                    }
        
        system.debug('Updated checklist is::' + checklist);
        return checklist;
    }
    
    @AuraEnabled
    public static void updateChecklistAction(List<Booking_Checklist__c> bcList) {
        try {
            system.debug('checklistId is::'+bcList);
            system.debug('actionValue is::'+bcList);
            update bcList;
            system.debug('Checklist updated: ' + bcList);
        } catch (Exception e) {
            system.debug('Error updating checklist: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Applicant__c> getApplicants(String recId){
        List<Applicant__c> aapList = [SELECT Id, Booking__c, Applicant_Number__c, Name, Aadhar_Number__c, PAN_Number__c, Mobile__c,Email__c
                                      FROM Applicant__c  
                                      where Booking__c=:recId];
        if(!aapList.isEmpty() && aapList != null){
            return aapList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AttachmentWrapper> getApplicantDocuments(String appId) {
        System.debug('appId: '+appId);
        List<Document__c> docList = [
            SELECT Id, Name, Document_Type__c, RecordTypeId, Document_View_Link__c
            FROM Document__c
            WHERE Applicant__c = :appId
        ];
        System.debug('docList: ' + docList);
        
        List<AttachmentWrapper> attachmentList = new List<AttachmentWrapper>();
        Map<Id, Map<String, String>> documentTypeMap = new Map<Id, Map<String, String>>();
        Map<Id, Id> documentToContentDocumentMap = new Map<Id, Id>();
        Map<Id, String> documentViewLinkMap = new Map<Id, String>(); 
        
        if (!docList.isEmpty()) {
            for (Document__c doc : docList) {
               
                String recordTypeName = Schema.SObjectType.Document__c.getRecordTypeInfosById().get(doc.RecordTypeId).getName();
                if (recordTypeName == 'Applicant Document') {
                    Map<String, String> docMap = new Map<String, String>();
                    if(!documentTypeMap.containsKey(doc.Id)) {
                        if(!docMap.containsKey(doc.Document_View_Link__c)) {
                            docMap.put(doc.Document_View_Link__c, doc.Document_Type__c);
                        } else {
                            docMap.get(doc.Document_View_Link__c);
                        }
                        documentTypeMap.put(doc.Id, docMap);
                    } else {
                        documentTypeMap.get(doc.Id);
                    }
                    //docMap.put(doc.Document_View_Link__c, doc.Document_Type__c);
                   // documentTypeMap.put(doc.Id, docMap);
                    documentViewLinkMap.put(doc.Id, doc.Document_View_Link__c); 
                }
            }
        }
        
        System.debug('documentTypeMap: '+documentTypeMap);
         System.debug('documentTypeMapKey: '+documentTypeMap.keySet());
        
        List<ContentDocumentLink> contentLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :documentTypeMap.keySet()
        ];
        System.debug('contentLinks: ' + contentLinks);
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : contentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
            documentToContentDocumentMap.put(link.ContentDocumentId, link.LinkedEntityId);
        }
        
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, ContentDocumentId , ContentUrl
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        System.debug('contentVersions: ' + contentVersions);
        
        for (ContentVersion content : contentVersions) {
            Id documentId = documentToContentDocumentMap.get(content.ContentDocumentId);
            Map<String, String> innerMap = documentTypeMap.get(documentId);
            String docType = innerMap != null && !innerMap.isEmpty() ? innerMap.values().iterator().next() : null;
            String documentViewLink = documentViewLinkMap.get(documentId); 
            System.debug('docType: ' + docType);
            
            AttachmentWrapper wrapper = new AttachmentWrapper(content, docType, documentViewLink);
            attachmentList.add(wrapper);
        }
        
        System.debug('attachmentList is: ' + attachmentList);
        return attachmentList;
    }
    
    public class AttachmentWrapper {
        @AuraEnabled public String fileName { get; set; }
        @AuraEnabled public String documentType { get; set; }
        @AuraEnabled public Id fileId { get; set; }
        @AuraEnabled public String documentViewLink { get; set; } 
        
        public AttachmentWrapper(ContentVersion content, String documentType, String documentViewLink) {
            this.fileName = content.Title;
            this.documentType = documentType;
            this.fileId = content.ContentDocumentId;
            this.documentViewLink = documentViewLink; 
        }
    }    
    
    @AuraEnabled(cacheable=true)
    public static List<Quotation__c> getQuotationDetails(String recId){
        Booking__c book = [Select Id,Quotation__c FROM Booking__c where Id=:recId];
        List<Quotation__c> quoteList = new List<Quotation__c>();
        Quotation__c q = Ex_BookingFormController.getQuotationDetails(book.Quotation__c);
        quoteList.add(q);
        if(!quoteList.isEmpty() && quoteList != null){
            return quoteList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getTokenAmount(String recId){
        Decimal totalTokenAmount = 0;
        List<Receipt__c> rLst = [Select Id, Booking__c, Amount__c from Receipt__c where Booking__c = :recId];
        system.debug('rLst is::'+rLst);
        for(Receipt__c r : rLst){
            totalTokenAmount += r.Amount__c;
        }
        system.debug('totalTokenAmount is::'+totalTokenAmount);
        return totalTokenAmount;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getSourceDetails(String recId){
        List<Booking__c> bookList = [Select Id, Source__c , Referrer_Name__r.Name, Channel_Partner__r.Name FROM Booking__c where Id=:recId];
        System.debug('bookList is::'+bookList);
        if(!bookList.isEmpty() && bookList != null){
            return bookList;    
        }else{
            return null;
        }
    }    
    
    @AuraEnabled(cacheable=false)
    public static string save(List<Booking_Checklist__c> bChecklist){
        System.debug('bChecklist is::'+bChecklist);
        
        insert bChecklist;
        return 'Record insert successfully' ;
    }    
    
}