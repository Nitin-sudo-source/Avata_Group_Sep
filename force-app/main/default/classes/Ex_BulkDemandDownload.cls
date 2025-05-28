/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 28-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/

public class Ex_BulkDemandDownload {
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
    
    @AuraEnabled(cacheable=true)
    public static List<Construction_Stage__c> getCS(String TowerId){
        List<Construction_Stage__c> clist=[select Id, Name,Tower__c FROM Construction_Stage__c WHERE Tower__r.id =: TowerId
                                           ORDER BY Sequence_Number__c];
        return clist;
    }
    
    @AuraEnabled
    public static List<ContentDocumentLinkWrapper> fetchFiles(String objectName, String CSId, String TowerId,string Dtype) {
        List<ContentDocumentLinkWrapper> result = new List<ContentDocumentLinkWrapper>();
        Set<Id> processedContentDocumentIds = new Set<Id>();
        
        try {
            List<Demand__c> dList = new List<Demand__c>();
            if (CSId == 'All' && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Booking__r.Tower__c = :TowerId AND Total_Amount_Remaining__c <> 0 ORDER BY CreatedDate DESC
                ];
            } else if (CSId == 'All' && Dtype == 'Fresh') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Booking__r.Tower__c = :TowerId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }else if (CSId == 'Registration Linked' && Dtype == 'Fresh') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }else if (CSId == 'Registration Linked' && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            else if (CSId == 'Date Linked' && Dtype == 'Fresh') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            else if (CSId == 'Date Linked' && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            
            else if ((CSId != 'Date Linked' && CSId != 'All' && CSId != 'Registration Linked') && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c, Invoice_Date__c,Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Payment_Milestone__r.Construction_Stage__c = :CSId AND Payment_Milestone__r.Quotation__r.Tower__c = :TowerId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            else if ((CSId != 'Date Linked' && CSId != 'All' && CSId != 'Registration Linked') && Dtype == 'Fresh') {
               system.debug('TowerId:::'+TowerId  +' CSId::::'+CSId);
                
                dList = [
                    SELECT Id, Name, Booking__c, Milestone_Name__c,Invoice_Date__c, Customer_Name__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c
                    FROM Demand__c WHERE Payment_Milestone__r.Construction_Stage__c = :CSId AND Payment_Milestone__r.Construction_Stage__r.Tower__c  = :TowerId AND Total_Amount_Remaining__c <> 0 AND Is_Downloaded__c = FALSE ORDER BY CreatedDate DESC
                ];
              
            }
            system.debug('dList::::: '+dList);
            
            if (!dList.isEmpty()) {
                Set<Id> demandIds = new Set<Id>();
                for (Demand__c demand : dList) {
                    demandIds.add(demand.Id);
                }
                System.debug('demandIds: '+demandIds.size());
                String query = 'SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize, ContentDocument.LastModifiedDate, ContentDocument.CreatedDate, LinkedEntity.Type, LinkedEntity.Id FROM ContentDocumentLink WHERE LinkedEntityId IN :demandIds';
                if (String.isNotBlank(objectName)) {
                    query += ' AND LinkedEntity.Type = \'' + objectName + '\'';
                }
                List<ContentDocumentLink> contentDocumentLinks = Database.query(query);
                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    processedContentDocumentIds.add(cdl.ContentDocumentId);
                }
                System.debug('processedContentDocumentIds: '+processedContentDocumentIds.size());
                
                for (Demand__c demand : dList) {
                    if(demandIds.contains(demand.Id)) {
                        ContentDocumentLinkWrapper wrapper = new ContentDocumentLinkWrapper();
                        wrapper.demandName = demand.Name;
                        wrapper.demandId = demand.Id;
                        wrapper.milestoneName = demand.Milestone_Name__c;
                        wrapper.customerName = demand.Customer_Name__c;
                        wrapper.isDownloaded = demand.Is_Downloaded__c;
                        wrapper.invoiceDate = demand.Invoice_Date__c;
                        wrapper.isMailSent = demand.Email_Sent__c;
                        
                        for (ContentDocumentLink cdl : contentDocumentLinks) {
                            if (processedContentDocumentIds.contains(cdl.ContentDocumentId)) {
                                if (cdl.LinkedEntityId == demand.Id) {
                                    wrapper.contentDocumentId = cdl.ContentDocumentId;
                                    wrapper.title = cdl.ContentDocument.Title;
                                    wrapper.fileType = cdl.ContentDocument.FileType;
                                    wrapper.contentSize = cdl.ContentDocument.ContentSize;
                                    wrapper.lastModifiedDate = cdl.ContentDocument.LastModifiedDate;
                                    wrapper.createdDate = cdl.ContentDocument.CreatedDate;
                                    wrapper.linkedEntityType = cdl.LinkedEntity.Type;
                                    result.add(wrapper);
                                }
                            }
                        }
                    }
                }
            }
            
            System.debug('result: '+result.size());
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        return result;
    }
    
    public class ContentDocumentLinkWrapper {
        @AuraEnabled
        public Id contentDocumentId { get; set; }
        
        @AuraEnabled
        public String title { get; set; }
        
        @AuraEnabled
        public String fileType { get; set; }
        
        @AuraEnabled
        public Integer contentSize { get; set; }
        
        @AuraEnabled
        public Datetime lastModifiedDate { get; set; }
        
        @AuraEnabled
        public Datetime createdDate { get; set; }
        
        @AuraEnabled
        public String linkedEntityType { get; set; }
        
        @AuraEnabled
        public String demandName { get; set; }
        
        @AuraEnabled
        public String demandId { get; set; }
        
        @AuraEnabled
        public String milestoneName { get; set; }
        
        @AuraEnabled
        public String customerName { get; set; }
        
        @AuraEnabled
        public Boolean isDownloaded { get; set; }
        
        @AuraEnabled
        public date invoiceDate { get; set; }
        
        @AuraEnabled
        public Boolean isMailSent {get;set;}
    }    
    
    @AuraEnabled
    public static void updateIsDownloaded(List<ContentDocumentLinkWrapper> demandWrappers) {
        Set<Id> demandIds = new Set<Id>();
        
        for (ContentDocumentLinkWrapper wrapper : demandWrappers) {
            demandIds.add(wrapper.demandId);
        }
        
        List<Demand__c> demandsToUpdate = [SELECT Id, Is_Downloaded__c FROM Demand__c WHERE Id IN :demandIds];
        
        for (Demand__c demand : demandsToUpdate) {
            for (ContentDocumentLinkWrapper wrapper : demandWrappers) {
                if (wrapper.demandId == demand.Id) {
                    demand.Is_Downloaded__c = wrapper.isDownloaded;
                    break;
                }
            }
        }
        
        update demandsToUpdate; 
    }
    
    @AuraEnabled
    public static List<String> updateEmailSentOnDemandRecords(List<Id> demandIds) {
        System.debug('demandIdsSize: ' + demandIds.size());
        String msg = '';
        List<String> showResponse = new List<String>();
        Set<Id> getDemandIds = new Set<Id>();
        List<Demand__c> demandRecordsToUpdate = new  List<Demand__c>();
        List<Demand__c> demandList = new  List<Demand__c>();
        
        if (demandIds != null && !demandIds.isEmpty()) {
            getDemandIds.addAll(demandIds);
            System.debug('getDemandIds: '+getDemandIds);
        }
        if (getDemandIds != null && !getDemandIds.isEmpty()) {
            demandList = [SELECT Id, Name, Customer_Name__c,
            // Booking__r.Project__r.CC_Email_ID__c, 
            Email_sent__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,
                          Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c, Invoice_Date__c,Due_Date__c 
                          FROM Demand__c 
                          WHERE Id IN :getDemandIds 
                          AND Customer_Email__c != null];
            System.debug('demandList: '+demandList.size());            
            
            if(!demandList.isEmpty() && demandList != null){
                for (Demand__c demandRecord : demandList) {
                    if(demandRecord.Email_Sent__c == false){
                        
                        DateTime dueDateTime = demandRecord.Due_Date__c;
                        String formattedDate = dueDateTime.format('dd/MM/yyyy');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setUseSignature(false);
                        mail.setSubject(demandRecord.Booking__r.Tower__r.Name +'-' +demandRecord.Booking__r.Unit__r.Name+'-'+demandRecord.Booking__r.Project__r.Name +'-' +'Demand Letter-'+ demandRecord.Milestone_Name__c);
                        String[] toAddresses = new String[]{demandRecord.Customer_Email__c};
                        mail.setToAddresses(toAddresses);
                        if(!Test.isRunningTest()){
                        // String[] ccAddresses = new String[]{demandRecord.Booking__r.Project__r.CC_Email_ID__c};
                        //     if(ccAddresses !=null){
                        // mail.setCcAddresses(ccAddresses);
                        //     }
                        }
                        String Body = 'Dear Sir <Br/><Br/> We are pleased to inform you that we have now completed Slab '+ demandRecord.Milestone_Name__c +' in '+demandRecord.Booking__r.Project__r.Name +' <br/><br/>The payment for Slab '+ demandRecord.Milestone_Name__c +'is due by '+formattedDate+'<br/><br/>We have attached the Demand Letter for Slab '+ demandRecord.Milestone_Name__c +' specifying the details of the payment along with the Architect Certificate.<br/><br/>Please write to me in case you require any further clarification or information.';
                        mail.setHtmlBody(body);
                        system.debug(body);
                        List<ContentDocumentLink>  ContentDocumentLinklist =[SELECT LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE  LinkedEntityId = :demandRecord.Id];
                        List<ContentVersion> cvList = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :ContentDocumentLinklist[0].ContentDocumentId];
                        Blob fileData = cvList[0].VersionData; 
                        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                        emlAtt.setFilename('Demand PDF.' + cvList[0].FileExtension);
                        emlAtt.setBody(fileData);
                        OrgWideEmailAddress owea = new OrgWideEmailAddress();
                        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Aga Hall' Limit 1];
                        system.debug(owea);
                        if (owea != null) {
                            mail.setOrgWideEmailAddressId(owea.Id);
                        }
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { emlAtt });
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                        demandRecord.Email_sent__c = true;
                        msg = 'Mail Sending... for '+ demandRecord.Name +'-'+ demandRecord.Customer_Name__c;
                        showResponse.add(msg);
                        demandRecordsToUpdate.add(demandRecord);
                    }else{
                        msg = 'Mail Already Sent for '+ demandRecord.Name +'-'+ demandRecord.Customer_Name__c;
                        showResponse.add(msg);
                    }
                }
            }else{
                return null;
            }
        }else{
            return null;
        }
        if(!demandRecordsToUpdate.isEmpty() && demandRecordsToUpdate != null){
            update demandRecordsToUpdate;  
            return showResponse;
        }else{
            return showResponse;
        }
    }
}