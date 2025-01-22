public class Ex_BulkDemandDashboard {
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
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Booking__r.Tower__c = :TowerId 
                    AND Total_Amount_Remaining__c <> 0 AND Is_Checked__c =: true AND Approval_Status__c =: 'Approved'
                    ORDER BY 
                    CreatedDate DESC
                ];
            } else if (CSId == 'All' && Dtype == 'Fresh') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Booking__r.Tower__c = :TowerId AND Is_Checked__c =: True AND Approval_Status__c =: 'Approved'
                    AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }else if (CSId == 'Registration Linked' && Dtype == 'Fresh') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Is_Checked__c =: True AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE
                    AND Approval_Status__c =: 'Approved' ORDER BY CreatedDate DESC
                ];
                
            }else if (CSId == 'Registration Linked' && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Is_Checked__c =: True  AND Approval_Status__c =: 'Approved' AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            else if (CSId == 'Date Linked' && Dtype == 'Fresh') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Is_Checked__c =: True AND Approval_Status__c =: 'Approved' AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            else if (CSId == 'Date Linked' && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Payment_Milestone__r.Milestone_Type__c =: CSId AND Is_Checked__c =: True AND Approval_Status__c =: 'Approved' AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            
            else if ((CSId != 'Date Linked' && CSId != 'All' && CSId != 'Registration Linked') && Dtype == 'All Demands') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Payment_Milestone__r.Construction_Stage__c = :CSId AND Is_Checked__c =: True AND Approval_Status__c =: 'Approved' AND Payment_Milestone__r.Quotation__r.Tower__c = :TowerId AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            else if ((CSId != 'Date Linked' && CSId != 'All' && CSId != 'Registration Linked') && Dtype == 'Fresh') {
                system.debug('TowerId:::'+TowerId  +' CSId::::'+CSId);
                
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c WHERE Payment_Milestone__r.Construction_Stage__c = :CSId AND Is_Checked__c =: True AND Approval_Status__c =: 'Approved' AND Payment_Milestone__r.Construction_Stage__r.Tower__c  = :TowerId AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE ORDER BY CreatedDate DESC
                ];
                
            }
            // New Reminders logic
            else if(CSId.equalsIgnoreCase('All') && Dtype.equalsIgnoreCase('Reminder 1')){
                System.debug ('All Demands Reminder 1');
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c,Reminder_1__c, Approval_Status__c
                    FROM Demand__c
                    WHERE Booking__r.Tower__c = :TowerId AND Is_Checked__c =: True  AND Approval_Status__c =: 'Approved'
                    AND Total_Amount_Remaining__c <> 0 AND Email_1_Sent__c = FALSE AND Reminder_1__c = TRUE ORDER BY CreatedDate DESC
                ];
                
            }
            else if (CSId == 'All' && Dtype.equalsIgnoreCase('Reminder 2')) {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Reminder_2__c,Email_2_Sent__c, Approval_Status__c
                    FROM Demand__c
                    WHERE Booking__r.Tower__c = :TowerId AND Is_Checked__c =: True  AND Approval_Status__c =: 'Approved'
                    AND Total_Amount_Remaining__c <> 0 AND Email_2_Sent__c = FALSE AND Reminder_2__c = TRUE ORDER BY CreatedDate DESC
                ];
                
            }else if (CSId == 'All' && Dtype == 'Reminder 3') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Reminder_2__c,Email_3_Sent__c, Approval_Status__c
                    FROM Demand__c
                    WHERE Booking__r.Tower__c = :TowerId AND Is_Checked__c =: True AND Approval_Status__c =: 'Approved'
                    AND Total_Amount_Remaining__c <> 0 AND Email_3_Sent__c = FALSE AND Reminder_3__c = TRUE ORDER BY CreatedDate DESC
                ]; 
                
            }else if (CSId == 'Registration Linked' && Dtype == 'Reminder 1') {
                dList = [
                    SELECT Id, Name, Customer_Name__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,Is_Checked__c,
                    Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Milestone_Name__c, Customer_Email__c,Due_Date__c ,
                    Booking__r.Name, Booking__c,Invoice_Date__c, Payment_Milestone__c,Is_Downloaded__c,Email_Sent__c, Approval_Status__c
                    FROM Demand__c 
                    WHERE Payment_Milestone__r.Milestone_Type__c =: CSId 
                    AND Is_Checked__c =: True AND Total_Amount_Remaining__c <> 0 AND Email_sent__c = FALSE AND Approval_Status__c =: 'Approved' AND  Reminder_1__c = TRUE ORDER BY CreatedDate DESC
                ];
                
            }
            
            
            //------------------------------------------------------------------------------------------------------//
            system.debug('dList::::: '+dList);
            if (!dList.isEmpty()) {
                Set<Id> demandIds = new Set<Id>();
                for (Demand__c demand : dList) {
                    demandIds.add(demand.Id);
                }
                
                System.debug('demandIds: '+demandIds.size());
                
                for (Demand__c demand : dList) {
                    if(demandIds.contains(demand.Id)) {
                        ContentDocumentLinkWrapper wrapper = new ContentDocumentLinkWrapper();
                        wrapper.demandName = demand.Name;
                        wrapper.demandId = demand.Id;
                        wrapper.unitName = String.valueOf(demand.Booking__r.Unit__r.Name);
                        wrapper.milestoneName = demand.Milestone_Name__c;
                        wrapper.customerName = demand.Customer_Name__c;
                        wrapper.isDownloaded = demand.Is_Downloaded__c;
                        wrapper.invoiceDate = demand.Invoice_Date__c;
                        wrapper.isEmailSend = demand.Email_Sent__c;
                        result.add(wrapper);
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
        public String UnitName { get; set; }
        
        @AuraEnabled
        public String milestoneName { get; set; }
        
        @AuraEnabled
        public String customerName { get; set; }
        
        @AuraEnabled
        public Boolean isDownloaded { get; set; }
        
        @AuraEnabled
        public date invoiceDate { get; set; }
        
        @AuraEnabled
        public Boolean isEmailSend {get;set;}
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
    public static List<String> updateEmailSentOnDemandRecords(List<Id> demandIds, String reminderType) {
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
            demandList = [SELECT Id, Name, Customer_Name__c, Email_sent__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__r.Name,
                          Booking__r.Tower__r.Name, Booking__r.Unit__r.Name, Booking__r.Unit__r.Floor__c, Milestone_Name__c, Customer_Email__c, Invoice_Date__c,Due_Date__c ,
                          Booking__r.Name, Booking__c,Is_Checked__c, Booking__r.Project__c, Booking__r.Project__r.From_Email__c, Previous_Mail_Sent_Date__c
                          FROM Demand__c 
                          WHERE Id IN :getDemandIds 
                          AND Customer_Email__c != null];
            System.debug('demandList: '+demandList.size());            
            System.debug('reminderType' + reminderType);
            
            if(!demandList.isEmpty() && demandList != null){
                for (Demand__c demandRecord : demandList) {
                    
                    String project =  demandRecord.Booking__r.Project__r.Name;                             
                    String tower = demandRecord.Booking__r.Tower__r.Name;    
                    String floor = String.valueOf(demandRecord.Booking__r.Unit__r.Floor__c);
                    String flat = demandRecord.Booking__r.Unit__r.Name;
                    String fromEmail = demandRecord.Booking__r.Project__r.From_Email__c;
                    
                    if(reminderType != null && reminderType != ''){
                        if(reminderType == 'Reminder 1'){
                            
                            System.debug('Remind 1');
                            
                            String[] toAddresses = new String[]{demandRecord.Customer_Email__c};
                                String subject = 'Reminder Letter 1';
                            String body = getReminderEmailTemplate(flat, floor, tower, project);
                            String demandId = String.valueOf(demandRecord.Id);
                            String BookingId = String.valueOf(demandRecord.Booking__r.Id);
                            String reminderNo = String.valueOf('1');
                            
                            Boolean mailSentStatus = sendReminderEmail(demandId,BookingId, reminderNo, fromEmail, toAddresses, subject, body);
                            if(mailSentStatus){
                                demandRecord.Email_1_Sent__c = true;
                                demandRecord.Previous_Mail_Sent_Date__c = System.today();
                                demandRecordsToUpdate.add(demandRecord);
                            }
                        }
                        else if(reminderType == 'Reminder 2'){
                            System.debug('Remind 2');
                            
                            String[] toAddresses = new String[]{demandRecord.Customer_Email__c};
                                String subject = 'Reminder Letter 2';
                            String body = getReminderEmailTemplate(flat, floor, tower, project);
                            String demandId = String.valueOf(demandRecord.Id);
                            String BookingId = String.valueOf(demandRecord.Booking__r.Id);
                            String reminderNo = String.valueOf('2');
                            
                            Boolean mailSentStatus = sendReminderEmail(demandId,BookingId,reminderNo, fromEmail, toAddresses, subject, body);
                            if(mailSentStatus){
                                demandRecord.Email_2_Sent__c = true;
                                demandRecord.Previous_Mail_Sent_Date__c = System.today();
                                demandRecordsToUpdate.add(demandRecord);
                            }
                        }
                        else if(reminderType == 'Reminder 3'){
                            System.debug('Remind 3');
                            
                            String[] toAddresses = new String[]{demandRecord.Customer_Email__c};
                                String subject = 'Reminder Letter 3';
                            String body = getReminderEmailTemplate(flat, floor, tower, project);
                            String demandId = String.valueOf(demandRecord.Id);
                            String BookingId = String.valueOf(demandRecord.Booking__r.Id);
                            String reminderNo = String.valueOf('3');
                            
                            Boolean mailSentStatus = sendReminderEmail(demandId,BookingId,reminderNo, fromEmail, toAddresses, subject, body);
                            if(mailSentStatus){
                                demandRecord.Email_3_Sent__c = true;
                                demandRecord.Previous_Mail_Sent_Date__c = System.today();
                                demandRecordsToUpdate.add(demandRecord);
                            }
                        }
                    }
                    else{
                        
                        if(demandRecord.Email_Sent__c == false){
                            
                            DateTime dueDateTime = demandRecord.Due_Date__c;
                            String formattedDate = dueDateTime.format('dd/MM/yyyy');
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setUseSignature(false);
                            mail.setSubject(demandRecord.Booking__r.Tower__r.Name +'-' +demandRecord.Booking__r.Unit__r.Name+'-'+demandRecord.Booking__r.Project__r.Name +'-' +'Demand Letter-'+ demandRecord.Milestone_Name__c);
                            String[] toAddresses = new String[]{demandRecord.Customer_Email__c};
                                mail.setToAddresses(toAddresses);
                            
                            String Body = 'Dear Sir <Br/><Br/> We are pleased to inform you that we have now completed Slab '+ demandRecord.Milestone_Name__c +' in '+demandRecord.Booking__r.Project__r.Name +' <br/><br/>The payment for Slab '+ demandRecord.Milestone_Name__c +' is due by '+formattedDate+'<br/><br/>We have attached the Demand Letter for Slab '+ demandRecord.Milestone_Name__c +' specifying the details of the payment along with the Architect Certificate.<br/>'+ demandRecord.Name +'<br/>Please write to me in case you require any further clarification or information.';
                            mail.setHtmlBody(body);
                            system.debug(body);
                            // List<ContentDocumentLink>  ContentDocumentLinklist =[SELECT LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE  LinkedEntityId = :demandRecord.Id];
                            // List<ContentVersion> cvList = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :ContentDocumentLinklist[0].ContentDocumentId];
                            // Blob fileData = cvList[0].VersionData; 
                            Blob fileData = null;
                            PageReference pageRef2 = new PageReference('/apex/Ex_PrintDemand');
                            pageRef2.getParameters().put('bId', demandRecord.Booking__c);
                            pageRef2.getParameters().put('dId',demandRecord.Id);    
                            
                            try {
                                // returns the output of the page as a PDF
                                if (!test.isRunningTest()) {
                                    fileData = pageRef2.getContentAsPDF();
                                    //body = Blob.valueOf('Some Text');
                                } else {
                                    fileData = Blob.valueOf('Some Text');
                                }
                            } catch (VisualforceException e) {
                                system.debug('Error: ' + e.getMessage());
                                fileData = Blob.valueOf('Some Text');
                            }
                            Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                            emlAtt.setFilename('Demand of ' + demandRecord.Booking__r.Primary_Applicant_Name__c + ' for ' + demandRecord.Booking__r.Unit__r.Name + ' from ' + demandRecord.Booking__r.Project__r.Name + ' - ' + demandRecord.Booking__r.Tower__r.Name +'.pdf');
                            emlAtt.setBody(fileData);
                            if(!Test.isRunningTest()){
                                OrgWideEmailAddress owea = new OrgWideEmailAddress();
                                owea = [SELECT Id, DisplayName,Address FROM OrgWideEmailAddress WHERE Address = :demandRecord.Booking__r.Project__r.From_Email__c LIMIT 1];
                                system.debug(owea);
                                if (owea != null) {
                                    mail.setOrgWideEmailAddressId(owea.Id);
                                }
                            }
                            
                            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { emlAtt });
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                            demandRecord.Email_sent__c = true;
                            msg = 'Mail Sending... for '+ demandRecord.Name +'-'+ demandRecord.Customer_Name__c;
                            showResponse.add(msg);
                            demandRecordsToUpdate.add(demandRecord);
                        }
                        else{
                            msg = 'Mail Already Sent for '+ demandRecord.Name +'-'+ demandRecord.Customer_Name__c;
                            showResponse.add(msg);
                        }
                        
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
    
    
    public static String getReminderEmailTemplate(String flat, String floor, String tower, String project){
        String HTMLTemplateBody = ''
            + '<html>'
            + '<body>'
            + 'Dear Sir/Madam, <br/>'
            + 'Greetings from Satyam Group!'
            + '<br/> <br/>'
            + 'Please find the attachment of reminder letter regarding Flat No ' + flat + ',' + floor + 'th floor, in Tower ' + tower + ' in '
            + 'the Phase I housing project to be known as "' + project + '"'
            + '<br/><br/>'
            + '<b>Regards, </b><br/>'
            + 'Demand Team <br/>'
            + 'CRM Department <br/>'
            + 'Satyam Group Builders and Developers'
            + '</body>    '
            + '</html>';
        
        System.debug(HTMLTemplateBody);
        return HTMLTemplateBody;
    }
    
    public static Boolean sendReminderEmail(String demandId,String BookingId, String reminderNo, String fromEmail, String[] toAddresses, String subject, String body){
        
        System.debug('Content recie :: ' + demandId + reminderNo + String.valueOf(toAddresses) + body);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setToAddresses(toAddresses);
        
        // Set orgOrgWideEmailAddress
        OrgWideEmailAddress orgWideEmail;
        try{
            orgWideEmail = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address = :fromEmail LIMIT 1];
        }
        catch(Exception e){
            System.debug('Error in getting OrgWideEmailAddress');
        }
        if(orgWideEmail != null){
            mail.setOrgWideEmailAddressId(orgWideEmail.Id);
        }
        
        // Retrive the PDF receipt and Attach as document
        Blob reminderLetterPDF = Blob.valueOf('Random Initialization Data');
        PageReference reminderLetterPDFPage = new PageReference('/apex/Ex_DemandReminderLetter');
        reminderLetterPDFPage.getParameters().put('demandId', demandId);
        reminderLetterPDFPage.getParameters().put('reminderNo', reminderNo);
        try {
            if(!Test.isRunningTest()){
                System.debug('reminderLetterPDFPage Beofore:::');
                reminderLetterPDF = reminderLetterPDFPage.getContentAsPDF();
                System.debug('reminderLetterPDFPage AFTER:::');
            }
        } catch (Exception e) {
            System.debug('Error in getting PDF');
        }
        
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.setFileName('Reminder_Letter.pdf');
        fileAttachment.setBody(reminderLetterPDF);
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {fileAttachment});
        System.debug('mail : ' + mail);
        
        Messaging.SendEmailResult[] sendEmailResult;
        
        sendEmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        System.debug('sendEmailResult : ' + sendEmailResult);
        
        
        // Store sent message in System 
        if(sendEmailResult != null && !sendEmailResult.isEmpty() && sendEmailResult[0].success){
            
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.RelatedToId = BookingId;
            emailMessage.FromAddress = fromEmail;
            emailMessage.toAddress = toAddresses[0];
            emailMessage.Subject = subject;
            emailMessage.HtmlBody = body;
            emailMessage.MessageDate =  System.now();
            emailMessage.Status = '3';
            insert emailMessage;
            
            System.debug('em : ' + emailMessage);
            System.debug('em : ' + emailMessage.Id);
            
            PageReference demandPdf = Page.Ex_PrintDemand;
            System.debug('PDF page .: '+demandPdf);
            demandPdf.getParameters().put('bId', BookingId);
            demandPdf.getParameters().put('dId', demandId);
            if(!Test.isRunningTest()){
                Blob pdfBlobB1 = demandPdf.getContent();
                System.debug('pdfBlobB1::: '+pdfBlobB1);
                
                Attachment attachment = new Attachment();
                attachment.ParentId = emailMessage.Id;
                attachment.Name = 'Demand.pdf';
                attachment.Body = pdfBlobB1; 
                attachment.ContentType = 'application/pdf';
                insert attachment;
            }
            
            return true;
        }
        else {
            return false;
        }
        
    }
    
}