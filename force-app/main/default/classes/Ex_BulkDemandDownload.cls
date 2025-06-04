/**
 * @description       :
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             :
 * @last modified on  : 02-06-2025
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
    public static User getProfileName(){
        try {
            List<User> u = new List<User>();
            u =  [SELECT ProfileId, Profile.Name FROM User
             WHERE Id =: UserInfo.getUserId() AND (Profile.Name =: 'System Administrator'
              OR Profile.Name =: 'RM Profile')];


              if(u != null && !u.isEmpty()){
                return u[0];
              }else{
                return null;
              }
           

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }

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
                
                
                for (Demand__c demand : dList) {
                    if (demandIds.contains(demand.Id)) {
                        ContentDocumentLinkWrapper wrapper = new ContentDocumentLinkWrapper();
                        wrapper.demandName = demand.Name;
                        wrapper.demandId = demand.Id;
                        wrapper.milestoneName = demand.Milestone_Name__c;
                        wrapper.customerName = demand.Customer_Name__c;
                        wrapper.isDownloaded = demand.Is_Downloaded__c;
                        wrapper.invoiceDate = demand.Invoice_Date__c;
                        wrapper.isMailSent = demand.Email_Sent__c;
                        // wrapper.contentDocumentId = cdl.ContentDocumentId;
                        wrapper.pdfPreviewUrl = '/apex/Ex_DemandPrint?dId=' + demand.Id + '&isPreview=true';
                        // wrapper.title = cdl.ContentDocument.Title;
                        // wrapper.fileType = cdl.ContentDocument.FileType;
                        // wrapper.contentSize = cdl.ContentDocument.ContentSize;
                        // wrapper.lastModifiedDate = cdl.ContentDocument.LastModifiedDate;
                        // wrapper.createdDate = cdl.ContentDocument.CreatedDate;
                        result.add(wrapper);
                    }
                }
            }
            System.debug('resultWrapper: '+result);
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
        public String pdfPreviewUrl {get;set;}
        
        @AuraEnabled
        public Boolean isDownloaded { get; set; }
        
        @AuraEnabled
        public date invoiceDate { get; set; }
        
        @AuraEnabled
        public Boolean isMailSent {get;set;}
    }
    
    @AuraEnabled
    public static void updateIsDownloaded(List<Id> demandIds) {
        Set<Id> getDemandIds = new Set<Id>();
        List<Demand__c> demandRecordsToUpdate = new  List<Demand__c>();
        List<Demand__c> demandList = new  List<Demand__c>();
        
        if (demandIds != null && !demandIds.isEmpty()) {
            getDemandIds.addAll(demandIds);
            System.debug('getDemandIds: '+getDemandIds);
        }
        if (getDemandIds != null && !getDemandIds.isEmpty()) {
            demandList = [SELECT Id, Is_Downloaded__c, Name, Customer_Name__c,
            // Booking__r.Project__r.CC_Email_ID__c, 
            Email_sent__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,
                          Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c, Invoice_Date__c,Due_Date__c 
                          FROM Demand__c 
                          WHERE Id IN :getDemandIds 
                          AND Is_Downloaded__c = false];
            System.debug('demandList: '+demandList.size());
            
            if(!demandList.isEmpty() && demandList != null){
                for (Demand__c demandRecord : demandList) {
                    if(!demandRecord.Is_Downloaded__c){
                        demandRecord.Is_Downloaded__c = true;
                    }
                    demandRecordsToUpdate.add(demandRecord);
                }
                
            }
            System.debug('demandRecordsToUpdate: '+demandRecordsToUpdate);
            update demandRecordsToUpdate;
        }
    }
    
    
    public class DemandWrapper {
        @AuraEnabled public String base64Pdf;
        @AuraEnabled public String demandName;
        @AuraEnabled public String customerName;
        @AuraEnabled public String bookingName;
        @AuraEnabled public String projectName;
    }
    
    @AuraEnabled
    public static List<DemandWrapper> getDemandPdf(List<Id> demandRecordIds) {
        List<DemandWrapper> responseList = new List<DemandWrapper>();
        Set<Id> demandIdsSet = new Set<Id>(demandRecordIds);
        
        Map<Id, Demand__c> demandMap = new Map<Id, Demand__c>([
            SELECT Id, Name, Is_Downloaded__c,
            Customer_Name__c, Booking__r.Name, Booking__r.Project__r.Name
            FROM Demand__c
            WHERE Id IN :demandIdsSet
        ]);
        
        try {
            for (Id demandId : demandIdsSet) {
                if (demandMap.containsKey(demandId)) {
                    Demand__c d = demandMap.get(demandId);
                    d.Is_Downloaded__c = true;
                    
                    PageReference pageRef = Page.Ex_PrintDemand;
                    pageRef.getParameters().put('dId', demandId);
                    Blob pdfBlob = Blob.valueOf('Dummy PDF Content');
                    if (!Test.isRunningTest()) {
                        pdfBlob = pageRef.getContentAsPDF();
                    }
                    
                    String base64EncodedPdf = EncodingUtil.base64Encode(pdfBlob);
                    DemandWrapper dw = new DemandWrapper();
                    dw.base64Pdf = base64EncodedPdf;
                    dw.demandName = d.Name;
                    dw.customerName = d.Customer_Name__c != null ? d.Customer_Name__c : '';
                    dw.bookingName = d.Booking__r != null ? d.Booking__r.Name : '';
                    dw.projectName = d.Booking__r.Project__r != null ? d.Booking__r.Project__r.Name : '';
                    
                    responseList.add(dw);
                }
            }
            system.debug('responseList :: ' + responseList);
            update demandMap.values();
            return responseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static DemandPdfWrapper getDemandSinglePdf(String dId) {
        DemandPdfWrapper wrapper = new DemandPdfWrapper();
        wrapper.base64PdfList = new List<String>();
        wrapper.demandList = new List<Demand__c>();
        
        Set<Id> demandIdsSet = new Set<Id>{dId};
        
        Map<Id, Demand__c> demandMap = new Map<Id, Demand__c>(
            [
                    SELECT Id, Name, Is_Downloaded__c,Customer_Name__c,Booking__r.Name,Booking__r.Project__r.Name
                    FROM Demand__c
                    WHERE Id IN :demandIdsSet 
                ]
            );
        
        system.debug('demandMap ::: ' + demandMap);
        
        try {
            for (Id demandId : demandIdsSet) {
                if (demandMap.containsKey(demandId)) {
                    Demand__c demand = demandMap.get(demandId);
                    demand.Is_Downloaded__c = true;
                    
                    PageReference pageRef = Page.Ex_PrintDemand;
                    pageRef.getParameters().put('dId', demandId);
                    
                    Blob pdfBlob = Blob.valueOf('Dummy PDF Content');
                    if (!Test.isRunningTest()) {
                        pdfBlob = pageRef.getContentAsPDF();
                    }
                    
                    String base64EncodedPdf = EncodingUtil.base64Encode(pdfBlob);
                    wrapper.base64PdfList.add(base64EncodedPdf);
                    wrapper.demandList.add(demand);
                }
            }
            update demandMap.values();
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class DemandPdfWrapper {
        @AuraEnabled public List<String> base64PdfList { get; set; }
        @AuraEnabled public List<Demand__c> demandList { get; set; }
    }
    
    public static String padLeft(String input, Integer length, String padChar) {
        while (input.length() < length) {
            input = padChar + input;
        }
        return input;
    }
    
    
    @AuraEnabled
    public static List<String> updateEmailSentOnDemandRecords(List<Id> demandIds) {
        String msg = '';
        
        List<String> showResponse = new List<String>();
        Set<Id> demandIdSet = new Set<Id>(demandIds);
        List<Demand__c> recordsToUpdate = new List<Demand__c>();
        
        
        if (demandIds == null || demandIds.isEmpty()) {
            showResponse.add('No demand IDs provided.');
            return showResponse;
        }
        System.debug('demandIdSet: '+  demandIdSet);
        
        List<Demand__c> demandList = new List<Demand__c>();
        demandList = [SELECT Id, Name, Customer_Name__c, Email_Sent__c,
               Booking__r.Primary_Applicant_Name__c,
               Booking__r.Project__r.Name,
               Booking__r.Tower__r.Name,
               Booking__r.Unit__r.Name,
               Milestone_Name__c, Customer_Email__c, Invoice_Date__c, Due_Date__c
       FROM Demand__c WHERE Id IN :demandIdSet];
        
        
        
        OrgWideEmailAddress owea;
        try {
            owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Avant Infra' LIMIT 1];
        } catch (Exception e) {
            showResponse.add('Error fetching Org-Wide Email Address: ' + e.getMessage());
            return showResponse;
        }
        
        System.debug('demandList: ' + demandList.size());
        
        for (Demand__c demand : demandList) {
            try {
                System.debug('demand: '+    demand);
                
                if(demand.Customer_Email__c == null){
                    msg = 'No email found for ' + demand.Name + ' - ' + demand.Customer_Name__c;
                    showResponse.add(msg);
                    continue;
                    //showResponse.add('No email found for ' + demand.Name + ' - ' + demand.Customer_Name__c);
                    //continue;
                }
                
                if(demand.Customer_Email__c  != null && demand.Email_Sent__c == false){
                    Date dueDate = demand.Due_Date__c;
                    String formattedDate = dueDate != null
                        ? padLeft(String.valueOf(dueDate.day()), 2, '0') + '/' +
                        padLeft(String.valueOf(dueDate.month()), 2, '0') + '/' +
                        String.valueOf(dueDate.year())
                        : 'N/A';
                    
                    String subject = String.join(new List<String>{
                        demand.Booking__r.Tower__r.Name,
                        demand.Booking__r.Unit__r.Name,
                        demand.Booking__r.Project__r.Name,
                        'Demand Letter',
                        demand.Milestone_Name__c
                    }, '-');
                    
                    String body = 'Dear Sir <br/><br/>We are pleased to inform you that we have now completed Slab ' +
                        demand.Milestone_Name__c + ' in ' + demand.Booking__r.Project__r.Name +
                        '.<br/><br/>The payment for Slab ' + demand.Milestone_Name__c +
                        ' is due by ' + formattedDate +
                        '.<br/><br/>We have attached the Demand Letter for Slab ' + demand.Milestone_Name__c +
                        ' specifying the details of the payment along with the Architect Certificate.<br/><br/>' +
                        'Please write to me in case you require any further clarification or information.';
                    
                    // Generate PDF
                    PageReference pageRef = Page.Ex_PrintDemand;
                    pageRef.getParameters().put('dId', demand.Id);
                    Blob pdfBlob = pageRef.getContentAsPDF();
                    
                    // Prepare attachment
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFilename('Demand_PDF_' + demand.Id + '.pdf');
                    attachment.setBody(pdfBlob);
                    
                    // Prepare email
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setUseSignature(false);
                    mail.setSubject(subject);
                    mail.setToAddresses(new String[] { demand.Customer_Email__c });
                    mail.setHtmlBody(body);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                    if (owea != null) {
                        mail.setOrgWideEmailAddressId(owea.Id);
                    }
                    
                    // Send email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                    // Mark as sent
                    demand.Email_Sent__c = true;
                    msg = 'Mail Sending... for '+ demand.Name +'-'+ demand.Customer_Name__c;
                    showResponse.add(msg);
                    
                    recordsToUpdate.add(demand);
                    
                    //showResponse.add('Email sent successfully for ' + demand.Name + ' - ' + demand.Customer_Name__c);
                    
                }else {
                    msg = 'Mail Already Sent for '+ demand.Name +'-'+ demand.Customer_Name__c;
                    showResponse.add(msg);
                }
                
                
            } catch (Exception ex) {
                String errorMsg = 'Error sending email for ' + demand.Name + ' - ' + demand.Customer_Name__c +
                    ': ' + ex.getMessage();
                System.debug('Exception: ' + ex.getStackTraceString());
                showResponse.add(errorMsg);
            }
        }
        
        if (!recordsToUpdate.isEmpty()) {
            try {
                update recordsToUpdate;
                
            } catch (Exception ex) {
                showResponse.add('Error updating demand records: ' + ex.getMessage());
                System.debug('Update Exception: ' + ex.getStackTraceString());
            }
        }
        
        return showResponse;
    }
    
}