//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 30-10-2023
//-------------------------------------------//
public without sharing class Ex_BookingPageControllerLwc {
    public Quotation__c q {get;set;}
    public Map<String, Object> data { get; set; }
    
    @AuraEnabled(Cacheable=true)
    public static List<Quotation__c> getQuotationDetails(String qId){
        Legal_Entity__c le;
        List<Quotation__c> qList = new List<Quotation__c>();{
            qList = [Select Id, Name, Unit__r.Name, Project__c, Tower__c,Tower__r.Name,Project__r.Name, Quotation_Status__c,
                     Project__r.Sales_Head__c, Unit__r.Floor__c, Unit__r.Configuration__c, Unit__r.Total_Carpet_Area_Sq_Ft__c from Quotation__c where Id =: qId ];
            if(!qList.isEmpty() && qList != null){
                le =  EX_InventoryPriceManagementServices.getLegalEntityDetails(qList[0].Unit__r.id,qList[0].Tower__r.id,qList[0].Project__r.id);
                System.Debug('le:::::::'+le);
            }
            return qlist;
        }
    }  
    
    @AuraEnabled(Cacheable=true)
    public static List<Legal_Entity__c> getLegalEntityDetails(String qId){
        List<Legal_Entity__c> legalEntities = new List<Legal_Entity__c>();
        List<Quotation__c> qList = [Select Id, Name, Unit__r.Name, Project__c, Tower__c, Tower__r.Name, Project__r.Name, Unit__r.Floor__c, Unit__r.Configuration__c, Unit__r.Total_Carpet_Area_Sq_Ft__c from Quotation__c where Id = :qId];
        if (!qList.isEmpty() && qList != null) {
            for (Quotation__c quote : qList) {
                Legal_Entity__c le = EX_InventoryPriceManagementServices.getLegalEntityDetails(quote.Unit__r.id, quote.Tower__r.id, quote.Project__r.id);
                if (le != null) {
                    legalEntities.add(le);
                }
            }
        }
        return legalEntities;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ApplicantWrapper> ApplicantdocumentDetails(string fieldValue) {
        List<ApplicantWrapper> appList = new List<ApplicantWrapper>();
        Applicant__c ap = new Applicant__c();
        appList.add(new ApplicantWrapper(ap));
        
        List<Applicant_Document__c> documents = [SELECT Name,  Type_Of_Applicant__c,Residential_Status__c FROM Applicant_Document__c WHERE Residential_Status__c = :fieldValue  ORDER BY Sequence_Number__c]; 
        for (Applicant_Document__c document : documents) {
            ApplicantWrapper wrapper = new ApplicantWrapper(document);
            wrapper.fileUploader = '';
            wrapper.fileName = '';
            //  wrapper.doctypeNo = '';
            appList.add(wrapper);
        }
        System.debug('ApplicantDocumentlist:::::::::::' + appList);
        return appList;
    }
    public class ApplicantWrapper {
        @AuraEnabled public Applicant__c ap { get; set; }
        @AuraEnabled public Applicant_Document__c documents { get; set; }
        @AuraEnabled public String fileUploader { get; set; }
        @AuraEnabled public String fileName { get; set; }
        //  @AuraEnabled public String doctypeNo { get; set; }
        
        
        public ApplicantWrapper(Applicant_Document__c documents) {
            this.documents = documents;
            this.fileUploader = '';
            this.fileName = '';
            // this.doctypeNo = '';
        }
        
        public ApplicantWrapper(Applicant__c ap) {
            this.ap = ap;
            this.documents = null;
            this.fileUploader = '';
            this.fileName = '';
            // this.doctypeNo = '';
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ReceiptWrapper> getReceipts() {
        List<ReceiptWrapper> rcList = new List<ReceiptWrapper>();
        Receipt__c rc = new Receipt__c();
        rcList.add(new ReceiptWrapper(rc));
        return rcList;
    }
    
    public class ReceiptWrapper{
        @AuraEnabled public Receipt__c rc;
        
        public ReceiptWrapper(Receipt__c rc) {
            this.rc = rc;
        }
    }   
    
    public class ApplicantDocumentWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String typeOfApplicant;
        @AuraEnabled public String ResidentialStatus;
        @AuraEnabled public String fileUploader;
        @AuraEnabled public String fileName;
        
        public ApplicantDocumentWrapper(Applicant_Document__c document) {
            this.name = document.Name;
            this.typeOfApplicant = document.Type_Of_Applicant__c;
            this.ResidentialStatus   =  document.Residential_Status__c;
            this.fileUploader = '';
            this.fileName = '';
        }
    }
    
    public class BookingWrapper{
        @AuraEnabled public Booking__c bk {get;set;}
        public BookingWrapper(){
            bk = new Booking__c();
        }
    } 
    
    public class termSheetWrapper{
        @AuraEnabled public Terms_Sheet__c ts {get;set;}
        
        public termSheetWrapper(){
            ts = new Terms_Sheet__c();
            ts.Self_funding__c = 'Yes';
        }
        
    }
    
    @AuraEnabled
    public static termSheetWrapper getTermSheetWrapper(){
        termSheetWrapper ts = new termSheetWrapper();
        
        return ts;
    }
    
    @AuraEnabled
    public static BookingWrapper getBookingWrapper(){
        BookingWrapper bk = new BookingWrapper();
        bk.bk.Booking_Date__c = System.today();
        bk.bk.Registration_Date__c = System.today().addDays(10);
        System.debug('Initialized bkWrapper: ' + JSON.serialize(bk.bk));
        return bk;
    }
    
    @AuraEnabled
    public static Project__c projectImage(String pid){
        List<Project__c> project = [Select Id, Name, Project_Logo__c, Master_OTP__c from Project__c where Id =: pid];
        if(!project.isEmpty() && project != null){
            return project[0];
        }else{
            return null;
        }
        // String imageData = project[0].Project_Logo__c;
        //system.debug('imageData is::'+imageData);
        //return imageData;
    }
    
    
    
    
    @AuraEnabled
    public static Id createBookingRecord(List<Quotation__c> quotationDetails, String applicantData, List<Legal_Entity__c> bookingAccount, BookingWrapper BookingWrapper, termSheetWrapper termSheetWrapper ){
        System.debug('quotationDetails: '+quotationDetails);
        System.debug('applicantData: '+applicantData);
        System.debug('BookingWrapper: '+BookingWrapper);
        System.debug('termSheetWrapper: '+termSheetWrapper);
        Decimal agreementValue;
        Decimal agreementValueTax;
        Decimal SDRValue;
        Decimal SDRTax;
        List<Object> dataList = (List<Object>) JSON.deserializeUntyped(applicantData);      
        List<Document__c> documentsToInsert = new List<Document__c>();
        List<Applicant__c> applicantRecords = new List<Applicant__c>();
        List<Receipt__c> InsertReceipt = new List<Receipt__c>();
        List<Terms_Sheet__c> tsList = new List<Terms_Sheet__c>();
        Quotation__c quotation = quotationDetails[0];
        
        quotation = EX_InventoryPriceManagementServices.getQuotationInfo(quotation.id);
        List<Quotation__c> Quotationdata = new List<Quotation__c>();
        
        system.debug('Quotationdata::::::::::'+Quotationdata);
        if(String.isNotBlank(quotation.Quotation_Status__c) && (quotation.Quotation_Status__c.equalsIgnoreCase('Valid') || quotation.Quotation_Status__c.equalsIgnoreCase('Approved'))) {
            for(Integer i = 1; i <= 3; i++) {
                if(String.isNotBlank((String)quotation.get('Charge_Bucket_'+i+'__c')) && ((String)quotation.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                    agreementValue = (Decimal)quotation.get('Charge_Bucket_'+i+'_Amount__c');
                    agreementValueTax = (Decimal)quotation.get('Charge_Bucket_'+i+'_Total_Tax__c');
                }
                if(String.isNotBlank((String)quotation.get('Charge_Bucket_'+i+'__c')) && ((String)quotation.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Statutory Charges')) {
                    SDRValue = (Decimal)quotation.get('Charge_Bucket_'+i+'_Amount__c');
                    SDRTax = (Decimal)quotation.get('Charge_Bucket_'+i+'_Total_Tax__c');
                }
            }
        }
        
        Booking__c booking = new Booking__c();
        booking.Quotation__c = quotation.Id;
        booking.Project__c = quotation.Project__c;
        booking.Unit__c = quotation.Unit__c;
        booking.Tower__c = quotation.Tower__c;
        booking.Booking_Stage__c = 'Booking In-Process';
        booking.Opportunity__c = quotation.Opportunity__c;
        booking.Agreement_Value__c = agreementValue;
        booking.Agreement_Value_Tax__c = agreementValueTax;
        booking.SDR_Value__c    = SDRValue;
        booking.SDR_Tax__c = SDRTax;
        
        if(BookingWrapper.bk.Mode_of_Funding__c != null || BookingWrapper.bk.Mode_of_Funding__c != '')
            booking.Mode_of_Funding__c = BookingWrapper.bk.Mode_of_Funding__c;
        if(BookingWrapper.bk.Payment_Remarks__c != null || BookingWrapper.bk.Payment_Remarks__c != '')
            booking.Payment_Remarks__c = BookingWrapper.bk.Payment_Remarks__c;
        if(BookingWrapper.bk.Any_Other_Offers__c != null || BookingWrapper.bk.Any_Other_Offers__c != '')
            booking.Any_Other_Offers__c = BookingWrapper.bk.Any_Other_Offers__c;
        if(BookingWrapper.bk.Remarks__c != null || BookingWrapper.bk.Remarks__c != '')
            booking.Remarks__c = BookingWrapper.bk.Remarks__c;
        if(BookingWrapper.bk.Booking_Date__c != null)
            booking.Booking_Date__c = BookingWrapper.bk.Booking_Date__c;
        if(BookingWrapper.bk.Registration_Date__c != null)
            booking.Registration_Date__c = BookingWrapper.bk.Registration_Date__c;
        
        
        
        /*if(quotation.Project__c != null && quotation.Project__r.Booking_1_Approver__c != null)
            booking.Booking_1_Approver__c = quotation.Project__r.Booking_1_Approver__c;
        if(quotation.Project__c != null && quotation.Project__r.Booking_2_Approver__c != null)
            booking.Booking_2_Approver__c = quotation.Project__r.Booking_2_Approver__c;
        if(quotation.Project__c != null && quotation.Project__r.Booking_3_Approver__c != null)
            booking.Booking_3_Approver__c = quotation.Project__r.Booking_3_Approver__c;*/
        
        
        
        if(!bookingAccount.isEmpty() && bookingAccount != null){
            booking.Account_Name_Flat_Cost__c = bookingAccount[0].Account_Name_Flat_Cost__c;
            booking.Account_Name_Tax__c = bookingAccount[0].Account_Name_Tax__c;
            booking.Account_Number_Flat_Cost__c = bookingAccount[0].Account_Number_Flat_Cost__c;
            booking.Account_Number_Tax__c = bookingAccount[0].Account_Number_Tax__c;
            booking.Bank_Name_Flat_Cost__c = bookingAccount[0].Bank_Name_Flat_Cost__c;
            booking.Bank_Name_Tax__c = bookingAccount[0].Bank_Name_Tax__c;
            booking.IFSC_Code_Flat_Cost__c = bookingAccount[0].IFSC_Code_Flat_Cost__c;
            booking.IFSC_Code_Tax__c = bookingAccount[0].IFSC_Code_Tax__c;
        }
        
        try {
            insert booking;
            System.debug('Booking record inserted successfully.'+booking.Id);
        }catch(Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
        
        Opportunity__c oppList = [SELECT Opportunity_Stage__c ,OwnerId, Project__r.Sales_Head__c, Project__r.CRM_Head__c,  Channel_Partner__c, CP_Project__c  FROM Opportunity__c where ID = : quotation.Opportunity__c];
        
        Tower__c tw = [Select Id, CRM_Manager__c from Tower__c where Id =: quotation.Tower__c];
        
        if(tw != null && tw.CRM_Manager__c != null){
            booking.Level_1_Approver__c = tw.CRM_Manager__c;
        }
        if(booking.Id != null){
            oppList.Booking__c = booking.Id;
            oppList.Opportunity_Stage__c = 'Booking In-Process' ;
        }
        
        if(oppList.Channel_Partner__c != null){
            booking.Channel_Partner__c = oppList.Channel_Partner__c;
        }
        if(oppList.Project__r.Sales_Head__c != null){
            booking.Booking_Approver__c = oppList.Project__r.Sales_Head__c;
        }
        /*if(oppList.Project__r.CRM_Head__c != null){
            booking.CRM_Head__c = oppList.Project__r.CRM_Head__c;
        }
        if (oppList.Project__r != null && oppList.Project__r.Tower__r != null && oppList.Project__r.Tower__r.CRM_Manager__c != null) {
            booking.Level_1_Approver__c = oppList.Project__r.Tower__r.CRM_Manager__c;
        }*/

        if(oppList.CP_Project__c != null){
            booking.CP_Project__c = oppList.CP_Project__c;
        }
        if(oppList.OwnerId != null){
            booking.Sales_Manager__c = oppList.OwnerId;
        }
        try {
            if(oppList!=null){
                update oppList ;
            }
        }catch(Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
        
        // Create a new Terms_Sheet__c record
        Terms_Sheet__c ts = termSheetWrapper.ts;
        
        // Set the Booking__c field after extracting termSheetWrapper.ts
        if (booking != null) {
            ts.Booking__c = booking.Id;  // Make sure booking.Id is used here
        }
        
        // Add the Terms_Sheet__c record to the list
        tsList.add(ts);
        
        // Debug the terms sheet list before insertion
        System.debug('tsList: ' + tsList);
        
        // Insert if the list is not empty
        if (!tsList.isEmpty()) {
            try {
                insert tsList;
                System.debug('Terms_Sheet__c records inserted successfully.');
            } catch (Exception ex) {
                System.debug('An error occurred while inserting Terms_Sheet__c: ' + ex.getMessage());
            }
        }

        
        Quotation__c qList = [SELECT Booking__c FROM Quotation__c where ID = : quotation.Id];
        qList.Booking__c = booking.Id ;
        if(qList!=null){
            update qList ;
        }
        
        Unit__c uniList = [SELECT Sale_Status__c FROM Unit__c where ID = : quotation.Unit__c];
        uniList.Sale_Status__c = 'Booked' ;
        uniList.Booking__c = booking.id;
        uniList.Opportunity__c = oppList.id;
        if(uniList!=null){
            update uniList ;
        }
        
        
        if(!dataList.isEmpty() && dataList!=null){
            for (Object dataObj : dataList) {
                Map<String, Object> data = (Map<String, Object>) dataObj;
                system.debug('data' + data);
                Map<String, Object> apData = (Map<String, Object>) data.get('ap');
                List<Object> documentsList = (List<Object>) data.get('documents');
                
                Applicant__c applicant = new Applicant__c();
                applicant.Name = (String) apData.get('Name');
                applicant.Applicant_Title__c = (String) apData.get('Applicant_Title__c');
                applicant.Applicant_Number__c = (String) apData.get('Applicant_Number__c');
                String anniversaryDate = (String)apData.get('Anniversary_Date__c');
                if(anniversaryDate != null){
                    applicant.Anniversary_Date__c = Date.valueof(anniversaryDate);
                }
                applicant.Type_Of_Applicant__c = (String) apData.get('Type_Of_Applicant__c');
                applicant.Permanent_Address__c = (String) apData.get('Permanent_Address__c');
                applicant.City__c = (String) apData.get('City__c');
                applicant.State__c = (String) apData.get('State__c');
                applicant.Country__c = (String) apData.get('Country__c');
                applicant.PIN__c     = (String) apData.get('PIN__c');
                applicant.Mobile_Number__c = (String) apData.get('Mobile_Number__c');
                //  applicant.Landline_Number__c = (String) apData.get('Landline_Number__c');
                applicant.Designation__c = (String) apData.get('Designation__c');
                String dobString = (String)apData.get('DOB__c');
                
                
                if (dobString != null) {
                    Date dobDate;
                    dobDate = Date.valueOf(dobString);
                    applicant.DOB__c = dobDate;
                }    
                applicant.Designation__c = (String) apData.get('Designation__c');
                applicant.Residential_Status__c = (String) apData.get('Residential_Status__c');
                applicant.Applicant_Email__c = (String) apData.get('Applicant_Email__c');
                applicant.PAN_Number__c = (String) apData.get('PAN_Number__c');
                applicant.Aadhar_Number__c = (String) apData.get('Aadhar_Number__c');
                applicant.Nationality__c = (String) apData.get('Nationality__c');
                applicant.Booking__c = booking.Id;
                applicant.Company_Name__c = (String) apData.get('Company_Name__c');
                Boolean mailingAddressSameAsPermanentAddressStr = (Boolean) apData.get('Mailing_Address_same_as_PermanentAddress__c');
                Boolean mailingAddressSameAsPermanentAddress;
                if (mailingAddressSameAsPermanentAddressStr != null && mailingAddressSameAsPermanentAddressStr) {
                    mailingAddressSameAsPermanentAddress = true;
                } else {
                    mailingAddressSameAsPermanentAddress = false;
                }
                applicant.Mailing_Address_same_as_PermanentAddress__c = mailingAddressSameAsPermanentAddress;
                if(applicant.Mailing_Address_same_as_PermanentAddress__c == true){
                    applicant.Mailing_Country__c = applicant.Country__c;
                    applicant.Mailing_State__c =  applicant.State__c;
                    applicant.Mailing_City__c =   applicant.City__c;
                    applicant.Mailing_Pincode__c =  applicant.PIN__c;
                    applicant.Mailing_Address__c = applicant.Permanent_Address__c;
                }else{
                    applicant.Mailing_Country__c = (String) apData.get('Mailing_Country__c');
                    applicant.Mailing_State__c = (String) apData.get('Mailing_State__c');
                    applicant.Mailing_City__c = (String) apData.get('Mailing_City__c');
                    String mailingPincodeStr = (String) apData.get('Mailing_Pincode__c');
                    if (mailingPincodeStr != null) {
                        String mailingPincode = String.valueOf(mailingPincodeStr);
                        applicant.Mailing_Pincode__c = mailingPincode;
                    }
                    applicant.Mailing_Address__c = (String) apData.get('Mailing_Address__c');
                }
                applicantRecords.add(applicant);
                System.debug('applicantRecords: '+applicantRecords.size());
                
                insert applicant;
                
                booking.Primary_Applicant_Title__c = applicant.Applicant_Title__c;
                booking.Primary_Applicant_Name__c = applicant.Name;
                booking.Primary_Applicant_Mobile__c = applicant.Mobile_Number__c;
                booking.Primary_Applicant_Email__c = applicant.Applicant_Email__c;
                booking.Applicant_Address__c = applicant.Permanent_Address__c;
                
                String AllApplicantName = '';
                System.debug('applicantRecords : '+applicantRecords);
                // update Applicant Name to Capture All Applicant Name on Single Field on Booking Changes By Nitin 
                for(Applicant__c ap: applicantRecords){
                    AllApplicantName += ap.Applicant_Title__c + ' '+ ap.Name ; 
                    if(applicantRecords.indexOf(ap) < applicantRecords.size() - 1){
                        AllApplicantName += ', ';
                    }
                    
                }
                System.debug('AllApplicantName: '+AllApplicantName);
                booking.All_Applicant_Name__c = AllApplicantName;
                try{
                    update booking; 
                }catch(exception e){
                    
                }
                
                if (documentsList != null && !documentsList.isEmpty()) {
                    for (Object document1 : documentsList) {
                        if (document1 instanceof Map<String, Object>) {
                            Map<String, Object> documentMap = (Map<String, Object>) document1;
                            system.debug('documentMap  ' +documentMap);
                            Document__c document = new Document__c();
                            document.Name__c = (String) documentMap.get('Name');
                            document.Type_Of_Applicant__c = (String) documentMap.get('Type_Of_Applicant__c');
                            document.Residential_Status__c = (String) documentMap.get('Residential_Status__c');
                            // System.debug('Before: '+(String) documentMap.get('doctypeNo'));
                            //// document.Document_No__c = (String) documentMap.get('doctypeNo');
                            // System.debug('document.Document_No__c: '+document.Document_No__c);
                            if(applicant.id != null){
                                document.Applicant__c = applicant.id;        
                            }
                            Id recordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName().get('Applicant_Document').getRecordTypeId();
                            System.debug('recordTypeId: '+ recordTypeId);
                            if(recordTypeId != null){
                                document.RecordTypeId = recordTypeId;   
                            }
                            documentsToInsert.add(document);
                            insert document;
                            
                            String base64 = (string) documentMap.get('base64');
                            String filename = (string) documentMap.get('filename');
                            
                            if (String.isNotBlank(base64) && base64 != null && String.isNotBlank(filename) && filename != null) {
                                ContentVersion cv = createContentVersion(base64, filename);
                                ContentDocumentLink cdl = createContentLink(cv.Id, document.Id);
                                if (cv == null || cdl == null) {
                                    return null;
                                }
                            }
                        }
                    }
                }
                
            }
        }    
        return booking.Id;
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