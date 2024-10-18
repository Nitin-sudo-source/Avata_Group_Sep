public class Ex_BookingFormController {
    public Quotation__c q {get;set;}
    public Map<String, Object> data { get; set; }
    
    @AuraEnabled
    public static Quotation__c getQuotationDetails(String qId){
        List<Quotation__c> qList = new List<Quotation__c>();
         String[] types = new String[]{'Quotation__c'};
            string queryFields = '';
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Schema.DescribeSobjectResult res : results) {
            string sObjectname = res.getName();
            Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
            
            for(Schema.SObjectField sfield : fieldMap.Values()) { 
                schema.describefieldresult dfield = sfield.getDescribe();
                String fieldLabel = dfield.getLabel();
                
                if(queryFields == null || queryFields == '') {
                    queryFields = dField.getName();
                } else {
                    queryFields = queryFields + ', ' + dField.getName();
                }
            }
        }
        String soqlQuery = 'Select ' + queryFields  + ', Opportunity__r.Name, Project__r.Name, Tower__r.Name, Opportunity__r.Source__c, Opportunity__r.Sub_Source__c, Opportunity__r.Channel_Partner__c, Opportunity__r.CP_Project__c, Opportunity__r.OwnerId, Unit__r.Name, Unit__r.Floor__c, Unit__r.Total_carpet_Sq_Ft__c, Payment_Scheme__r.Name, Booking__r.Agreement_Value__c, Unit__r.Saleable_Area__c  from Quotation__c Where Id = \''+qId+'\''; 
        system.debug(soqlQuery);
        qList = Database.query(soqlQuery);
        
       /* List<Quotation__c> qList = new List<Quotation__c>();
        qList = [Select Id, Name, Opportunity__c, Opportunity__r.Name,
                 Project__r.Name, Tower__r.Name, Opportunity__r.Source__c, Opportunity__r.Sub_Source__c, Opportunity__r.Channel_Partner__c, Opportunity__r.CP_Project__c, Opportunity__r.OwnerId,
                 Tower__c, Unit__c, Unit__r.Name, Unit__r.Floor__c, Unit__r.Total_carpet_Sq_Ft__c, Quotation_Status__c
                 from Quotation__c Where Id =: qId];
        System.debug('qList: '+qList);*/
        if(!qList.isEmpty() && qList != null){
            return qList[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled(Cacheable=false)
    public static List<Legal_Entity__c> getLegalEntityDetails(String qId){
        List<Legal_Entity__c> legalEntities = new List<Legal_Entity__c>();
        List<Quotation__c> qList = [Select Id, Name, Unit__r.Name, Project__c, Tower__c, Tower__r.Name, Project__r.Name, Unit__r.Floor__c, Unit__r.Configuration_Type__c, Unit__r.Total_Carpet_Sq_Ft__c from Quotation__c where Id = :qId];
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
    
    @AuraEnabled(cacheable=false)
    public static BookWrapper getBookingWrapper(String oppId){
        Opportunity__c opp = [Select Id, Project__c,Project__r.CRM_Head__c, Project__r.CRM_Head__r.ManagerId from Opportunity__c Where Id =: oppId];
        BookWrapper bk = new BookWrapper();
        bk.bk.Booking_Date__c = System.today();
        if(opp.Project__r.CRM_Head__c != null){
           bk.bk.CRM_Head__c = opp.Project__r.CRM_Head__c;
           bk.bk.Level_1_Approver__c = opp.Project__r.CRM_Head__c;
           if(opp.Project__r.CRM_Head__r.ManagerId != null) 
           bk.bk.Level_2_Approver__c = opp.Project__r.CRM_Head__r.ManagerId;  
        }
        
        return bk;
    }
    

    public class BookWrapper{
        @AuraEnabled 
        public Booking__c bk { get; set; }
        
        public BookWrapper(){
            bk = new Booking__c();
        }
    }    
    
    @AuraEnabled(cacheable=false)
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
        public ReceiptWrapper(){
            
        }
    } 
    
    @AuraEnabled(cacheable=false)
    public static List<ApplicantWrapper> ApplicantdocumentDetails(String fieldValue, String oppId, String tabKey) {
        System.debug('tabKey: '+tabKey);
        System.debug('oppId: '+oppId);
        
        List<ApplicantWrapper> appList = new List<ApplicantWrapper>();
        List<Opportunity__c> opp = new List<Opportunity__c>();
        Applicant__c ap = new Applicant__c();
        if(oppId != null)
        {
            opp = [Select Id, Name, Account__r.Name, Account__r.Salutation, Mobile__c, Email__c, Account__r.Designation__c,
                   OwnerId, Account__r.Company_Name__c, Account__r.Residential_Address__c, Account__r.Locality__c,
                   Account__r.City__c, Account__r.Pincode__c from Opportunity__c where Id=: oppId];
            if(opp != null)
            {
                if(String.isNotBlank(tabKey) && tabKey.equalsIgnoreCase('Applicant 1'))
                {
                    ap.Applicant_Number__c = 'Primary Applicant';
                    if(opp[0].Name != null)
                        ap.Name = opp[0].Name;
                    if(opp[0].Mobile__c != null)
                        ap.Mobile__c = opp[0].Mobile__c;
                    if(opp[0].Email__c != null)
                        ap.Email__c = opp[0].Email__c; 
                    if(opp[0].Account__r.Designation__c != null)
                        ap.Designation__c = opp[0].Account__r.Designation__c; 
                    if(opp[0].Account__r.Company_Name__c != null)
                        ap.Company_Name__c = opp[0].Account__r.Company_Name__c;
                    if(opp[0].Account__r.Salutation != null)
                        ap.Applicant_Title__c = opp[0].Account__r.Salutation;
                    if(opp[0].Account__r.City__c != null)
                        ap.City__c = opp[0].Account__r.City__c;
                   // if(opp[0].Account__r.Country__c != null)
                        //ap.Country__c = opp[0].Account__r.Country__c;
                    if(opp[0].Account__r.Pincode__c != null)
                        ap.PIN__c = opp[0].Account__r.Pincode__c;
                   // if(opp[0].Account__r.Residence__c != null)
                       // ap.Residential_Status__c = opp[0].Account__r.Residence__c;
                    if(opp[0].Account__r.Residential_Address__c != null)
                        ap.Permanent_Address__c = opp[0].Account__r.Residential_Address__c;
                }
            }
        }
        appList.add(new ApplicantWrapper(ap));
        
        if(String.isNotBlank(fieldValue) && !(fieldValue.equalsIgnoreCase('No'))){            
            List<Applicant_Document__c> documents = [SELECT Name, Document_Upload_Required__c FROM Applicant_Document__c Where Document_Upload_Required__c =: fieldValue]; 
            for (Applicant_Document__c document : documents) {
                ApplicantWrapper wrapper = new ApplicantWrapper(document);
                wrapper.fileUploader = '';
                wrapper.fileName = document.Name;
                appList.add(wrapper);
            }
        }else{
            if(String.isNotBlank(fieldValue) && (fieldValue.equalsIgnoreCase('No'))){            
                List<Applicant_Document__c> documents = [SELECT Name, Document_Upload_Required__c FROM Applicant_Document__c Where Document_Upload_Required__c =: fieldValue]; 
                System.debug('documents: ' + documents);
                for (Applicant_Document__c document : documents) {
                    ApplicantWrapper wrapper = new ApplicantWrapper(document);
                    wrapper.fileUploader = '';
                    wrapper.fileName = document.Name;
                    appList.add(wrapper);
                }
            }
        }
        System.debug('ApplicantDocumentlist: ' + appList);
        return appList;
    }
    
    public class ApplicantWrapper {
        @AuraEnabled public Applicant__c ap { get; set; }
        @AuraEnabled public Applicant_Document__c documents { get; set; }
        @AuraEnabled public String fileUploader { get; set; }
        @AuraEnabled public String fileName { get; set; }        
        
        public ApplicantWrapper(Applicant_Document__c documents) {
            this.documents = documents;
            this.fileUploader = '';
            this.fileName = '';
        }
        public ApplicantWrapper(Applicant__c ap) {
            this.ap = ap;
            this.documents = null;
            this.fileUploader = '';
            this.fileName = '';
        }
    }
    
    public class ApplicantDocumentWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String docupload;
        @AuraEnabled public String fileUploader;
        @AuraEnabled public String fileName;
        
        public ApplicantDocumentWrapper(Applicant_Document__c document) {
            this.name = document.Name;
            this.docupload = document.Document_Upload_Required__c;
            this.fileUploader = '';
            this.fileName = '';
        }
    }
    
    @AuraEnabled
    public static Id createBookingRecord(BookWrapper bkWrapper, String applicantData, Quotation__c quotationDetails, String receiptData, List<Legal_Entity__c> bookingAccount){
        System.debug('bookingAccount: '+bookingAccount);
        Decimal agreementValue = 0;
        Decimal agreementValueTax = 0;
        Decimal SDRValue = 0;
        Decimal SDRTax = 0;
        List<Object> applicantDataList = (List<Object>) JSON.deserializeUntyped(applicantData); 
        List<Object> receiptList = (List<Object>) JSON.deserializeUntyped(receiptData);
        List<Receipt__c> InsertReceipt = new List<Receipt__c>();
        List<Document__c> documentsToInsert = new List<Document__c>();
        List<Applicant__c> applicantRecords = new List<Applicant__c>();
        Quotation__c quotation = quotationDetails;
        quotation = getQuotationDetails(quotation.Id);
        System.debug('bkWrapper: '+bkWrapper);
        system.debug('quotation: '+quotation);
        
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
        if (quotation.Id != null) {
            booking.Quotation__c = quotation.Id;
        }
        if (quotation.Project__c != null) {
            booking.Project__c = quotation.Project__c;
        }
        if (quotation.Tower__c != null) {
            booking.Tower__c = quotation.Tower__c;
        }
        if (quotation.Unit__c != null) {
            booking.Unit__c = quotation.Unit__c;
        }
        if (quotation.Opportunity__c != null) {
            booking.Opportunity__c = quotation.Opportunity__c;
        }
        
        if (bkWrapper.bk.Any_Other_Offers__c != null) {
            booking.Any_Other_Offers__c = bkWrapper.bk.Any_Other_Offers__c;
        }
        if (bkWrapper.bk.Booking_Date__c != null) {
            booking.Booking_Date__c = bkWrapper.bk.Booking_Date__c;
        }
        if (bkWrapper.bk.Mode_of_Funding__c != null) {
            booking.Mode_of_Funding__c = bkWrapper.bk.Mode_of_Funding__c;
        }
        if(bkWrapper.bk.CRM_Head__c != null){
            booking.CRM_Head__c = bkWrapper.bk.CRM_Head__c;
        }
        if(bkWrapper.bk.Level_1_Approver__c != null){
            booking.Level_1_Approver__c = bkWrapper.bk.Level_1_Approver__c;
        }
        if(bkWrapper.bk.Level_2_Approver__c != null){
           booking.Level_2_Approver__c =  bkWrapper.bk.Level_2_Approver__c;
        }
        if (bkWrapper.bk.Remarks__c != null) {
            booking.Remarks__c = bkWrapper.bk.Remarks__c;
        }
        booking.Agreement_Value__c = agreementValue;
        booking.Agreement_Value_Tax__c = agreementValueTax;
        booking.SDR_Value__c = SDRValue;
        booking.SDR_Tax__c = SDRTax;
        booking.Updated_Agreement_Value__c = agreementValue;

        booking.Booking_Stage__c = 'Booking In-Process';
        
        if(!bookingAccount.isEmpty() && bookingAccount != null){
            booking.Account_Name_Flat_Cost__c = bookingAccount[0].Account_Name_Flat_Cost__c;
            booking.Account_Name_Tax__c = bookingAccount[0].Account_Name_Tax__c;
            booking.Account_Number_Flat_Cost__c = bookingAccount[0].Account_Number_Flat_Cost__c;
            booking.Account_Number_Tax__c = bookingAccount[0].Account_Number_Tax__c;
            booking.Bank_Name_Flat_Cost__c = bookingAccount[0].Bank_Name_Flat_Cost__c;
            booking.Branch_Name_Flat_Cost__c = bookingAccount[0].Branch_Name_Flat_Cost__c;
            booking.Branch_Name_Tax__c = bookingAccount[0].Branch_Name_Tax__c;
            booking.Bank_Name_Tax__c = bookingAccount[0].Bank_Name_Tax__c;
            booking.IFSC_Code_Flat_Cost__c = bookingAccount[0].IFSC_Code_Flat_Cost__c;
            booking.IFSC_Code_Tax__c = bookingAccount[0].IFSC_Code_Tax__c;
        }
        try {
            insert booking;
            System.debug('Booking record inserted successfully : ' + booking.Id);
        }catch(Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
        
        
        //update Opportunity after Booking creation
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        if (String.isNotBlank(quotation.Opportunity__c)) {
            oppList = [SELECT Stage__c, CP_Project__c, Sourcing_Manager__c, Sub_Stage__c, Sub_Stage_Reason__c,  Booking__c, OwnerId, Channel_Partner__c, Source__c, Sub_Source__c, Referrer_Name__c, Amount__c FROM Opportunity__c WHERE Id = :quotation.Opportunity__c];
        }
        System.debug('oppList'+ oppList);
        
        if (oppList != null && !oppList.isEmpty()) {
            if (booking.Id != null) {
                oppList[0].Booking__c = booking.Id;
                oppList[0].Stage__c = 'Booking In-Process';
                oppList[0].Sub_Stage__c = '';
                oppList[0].Sub_Stage_Reason__c = '';
            }
            
            if (oppList[0].Channel_Partner__c != null) {
                booking.Channel_Partner__c = oppList[0].Channel_Partner__c;
            }
            if (oppList[0].CP_Project__c != null) {
                booking.CP_Project__c = oppList[0].CP_Project__c;
            }
            if (oppList[0].Sourcing_Manager__c != null) {
                booking.Sourcing_Manager__c = oppList[0].Sourcing_Manager__c;
            }                    
            if (oppList[0].Source__c != null) {
                booking.Source__c = oppList[0].Source__c;
            }
            if (oppList[0].Sub_Source__c != null) {
                booking.Sub_Source__c = oppList[0].Sub_Source__c;
            }
            if (oppList[0].Referrer_Name__c != null) {
                booking.Referrer_Name__c = oppList[0].Referrer_Name__c;
            }
            if (oppList[0].OwnerId != null) {
                booking.Sales_Manager__c = oppList[0].OwnerId;
            }
            /*if(quotation.Modified_AV_Value__c != null){
                oppList[0].Amount__c = quotation.Modified_AV_Value__c;
            }*/
        }
        
        try {
            if (oppList != null && !oppList.isEmpty()) {
                update oppList;
            }
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
        
        
        if (String.isNotBlank(quotation.Id)) {
            Quotation__c qList = [SELECT Booking__c FROM Quotation__c WHERE ID = :quotation.Id];
            if (qList != null) {
                qList.Booking__c = booking.Id;
                update qList;
            }
        }
        
        if (String.isNotBlank(quotation.Unit__c)) {
            Unit__c uniList = [SELECT Sales_Status__c FROM Unit__c WHERE ID = :quotation.Unit__c];
            
            if (uniList != null) {
                if (String.isNotBlank(uniList.Sales_Status__c)) {
                    uniList.Sales_Status__c = 'Booking-In-Process';
                }
                
                if(booking != null && booking.Id != null){
                    uniList.Booking__c = booking.Id;  
                }
                if (oppList != null && !oppList.isEmpty()) {
                    uniList.Opportunity__c = oppList[0].Id;
                }
                update uniList;
            }
        }
        
        if(!receiptList.isEmpty() && receiptList!=null){
            for (Object dataObj : receiptList) {
                Map<String, Object> data = (Map<String, Object>) dataObj;
                Map<String, Object> apData = (Map<String, Object>) data.get('rc');
                
                if(!apData.isEmpty() && apData !=null && apData.containsKey('Receipt_Type__c') && apData.get('Receipt_Type__c') != null){
                    Receipt__c Receipt = new Receipt__c();
                    Receipt.Mode_Of_Payment__c = (String) apData.get('Mode_Of_Payment__c');
                    if(apData.get('Is_Token_Amount_Received__c') != null){
                        Receipt.Is_Token_Amount_Received__c = (Boolean) apData.get('Is_Token_Amount_Received__c');
                    }  
                    Receipt.Receipt_Type__c = (String) apData.get('Receipt_Type__c');
                    // Receipt.Receipt_Status__c = (String) apData.get('Receipt_Status__c');
                    String dateString = (String)apData.get('Receipt_Date__c');
                    if (dateString != null) {
                        Date receiptdate;
                        receiptdate = Date.valueOf(dateString);
                        Receipt.Receipt_Date__c = receiptdate;
                    }    
                    if(apData.get('Amount__c') != null){
                        Receipt.Amount__c = Decimal.valueOf((String) apData.get('Amount__c'));    
                    }
                    Receipt.Transaction_ID__c = (String) apData.get('Transaction_ID__c');
                    Receipt.Booking__c  = booking.id;
                    Receipt.Payment_Status__c = (String) apData.get('Payment_Status__c');
                    Receipt.Bank_Name__c = (String) apData.get('Bank_Name__c');
                    String InstrumentdateString = (String)apData.get('Instrument_Date__c');
                    Receipt.Payment_Type__c = (String) apData.get('Payment_Type__c');
                    if (InstrumentdateString != null) {
                        Date Instrumentdate;
                        Instrumentdate = Date.valueOf(InstrumentdateString);
                        Receipt.Instrument_Date__c = Instrumentdate;
                    }    
                    InsertReceipt.add(Receipt);
                }    
            }
        }  
        try {
            insert InsertReceipt;
            System.debug('InsertReceipt: ' + InsertReceipt);
        } catch (DmlException e) {
            System.debug('An error occurred when inserting records: ' + e.getMessage());
        }
        
        
        if(!applicantDataList.isEmpty() && applicantDataList!=null){
            for (Object dataObj : applicantDataList) {
                Map<String, Object> getAllData = (Map<String, Object>) dataObj;
                system.debug('getAllData::' + getAllData);
                Map<String, Object> apData = (Map<String, Object>) getAllData.get('ap');
                List<Object> documentsList = (List<Object>) getAllData.get('documents');
                
                Applicant__c applicant = new Applicant__c();
               // Booking.Is_Send_For_Approval__c = true;
                if (apData.get('Name') != null) {
                    applicant.Name = (String) apData.get('Name');
                }
                if (apData.get('Applicant_Title__c') != null) {
                    applicant.Applicant_Title__c = (String) apData.get('Applicant_Title__c');
                }
                if (apData.get('Applicant_Number__c') != null) {
                    applicant.Applicant_Number__c = (String) apData.get('Applicant_Number__c');
                }
                if (apData.get('Type_of_Applicant__c') != null) {
                    applicant.Type_of_Applicant__c = (String) apData.get('Type_of_Applicant__c');
                }
                if (apData.get('Permanent_Address__c') != null) {
                    applicant.Permanent_Address__c = (String) apData.get('Permanent_Address__c');
                }
                if (apData.get('City__c') != null) {
                    applicant.City__c = (String) apData.get('City__c');
                }
                if (apData.get('State__c') != null) {
                    applicant.State__c = (String) apData.get('State__c');
                }
                if (apData.get('Country__c') != null) {
                    applicant.Country__c = (String) apData.get('Country__c');
                }
                if (apData.get('PIN__c') != null) {
                    applicant.PIN__c = (String) apData.get('PIN__c');
                }
                if (apData.get('Designation__c') != null) {
                    applicant.Designation__c = (String) apData.get('Designation__c');
                }
                if (apData.get('Document_Upload_Required__c') != null) {
                    applicant.Document_Upload_Required__c = (String) apData.get('Document_Upload_Required__c');
                }
                String anniversaryDate = (String)apData.get('Anniversary_Date__c');
                if(String.isNotBlank(anniversaryDate)){
                    applicant.Anniversary_Date__c = Date.valueof(anniversaryDate);
                }
                String dobString = (String)apData.get('DOB__c');
                if (String.isNotBlank(dobString)){
                    Date dobDate;
                    dobDate = Date.valueOf(dobString);
                    applicant.DOB__c = dobDate;
                } 
                if (apData.get('Residential_Status__c') != null) {
                    applicant.Residential_Status__c = (String) apData.get('Residential_Status__c');
                }
                if (apData.get('Email__c') != null) {
                    applicant.Email__c = (String) apData.get('Email__c');
                }
                if (apData.get('Mobile__c') != null) {
                    applicant.Mobile__c = (String) apData.get('Mobile__c');
                }
                if (apData.get('PAN_Number__c') != null) {
                    applicant.PAN_Number__c = (String) apData.get('PAN_Number__c');
                }
                if (apData.get('Aadhar_Number__c') != null) {
                    applicant.Aadhar_Number__c = (String) apData.get('Aadhar_Number__c');
                }
                if (apData.get('Nationality__c') != null) {
                    applicant.Nationality__c = (String) apData.get('Nationality__c');
                }
                if (booking.Id != null) {
                    applicant.Booking__c = booking.Id;   
                }
                if (apData.get('Company_Name__c') != null) {
                    applicant.Company_Name__c = (String) apData.get('Company_Name__c');
                }
                Boolean mailingAddressSameAsPermanentAddressStr = (Boolean) apData.get('Mailing_Address_Same_as_PermanentAddress__c');
                System.debug('mailingAddressSameAsPermanentAddressStr:'+mailingAddressSameAsPermanentAddressStr);
                //Boolean mailingAddressSameAsPermanentAddress;
                if (mailingAddressSameAsPermanentAddressStr != null && mailingAddressSameAsPermanentAddressStr) {
                    mailingAddressSameAsPermanentAddressStr = true;
                    System.debug('mailingAddressSameAsPermanentAddress'+mailingAddressSameAsPermanentAddressStr);
                } else {
                    mailingAddressSameAsPermanentAddressStr = false;
                }
                applicant.Mailing_Address_Same_as_PermanentAddress__c = mailingAddressSameAsPermanentAddressStr;
                if (apData.get('Mailing_Country__c') != null) {
                    applicant.Mailing_Country__c = (String) apData.get('Mailing_Country__c');
                }
                if (apData.get('Mailing_State__c') != null) {
                    applicant.Mailing_State__c = (String) apData.get('Mailing_State__c');
                }
                if (apData.get('Mailing_City__c') != null) {
                    applicant.Mailing_City__c = (String) apData.get('Mailing_City__c');
                }
                if (apData.get('Mailing_Pincode__c') != null) {
                    applicant.Mailing_Pincode__c = (String) apData.get('Mailing_Pincode__c');
                }
                if (apData.get('Mailing_Address__c') != null) {
                    applicant.Mailing_Address__c = (String) apData.get('Mailing_Address__c');
                }
                if (mailingAddressSameAsPermanentAddressStr == true) {
                    if (apData.get('Permanent_Address__c') != null) {
                        applicant.Mailing_Address__c = (String) apData.get('Permanent_Address__c');
                    }
                    if (apData.get('City__c') != null) {
                        applicant.Mailing_City__c = (String) apData.get('City__c');
                    }
                    if (apData.get('State__c') != null) {
                        applicant.Mailing_State__c = (String) apData.get('State__c');
                    }
                    if (apData.get('Country__c') != null) {
                        applicant.Mailing_Country__c = (String) apData.get('Country__c');
                    }
                    String mailingPincodeStr = '';
                    if (apData.get('PIN__c') != null) {
                        mailingPincodeStr = (String) apData.get('PIN__c');   
                    }
                    if (mailingPincodeStr != '') {
                        Integer mailingPincode = Integer.valueOf(mailingPincodeStr);
                        system.debug('mailingPincode: '  +mailingPincode);
                        applicant.Mailing_Pincode__c = mailingPincodeStr;
                    }
                }
                try{
                    insert applicant;
                }catch(exception e){
                    system.debug('Exception on insert applicant :'+ e.getMessage());
                }
                if(applicant.Applicant_Number__c != null && applicant.Applicant_Number__c == 'Primary Applicant'){
                   // booking.Aadhar_Number__c = applicant.Aadhar_Number__c;
                   // booking.PAN_Number__c = applicant.PAN_Number__c;
                    booking.Primary_Applicant_Title__c = applicant.Applicant_Title__c;
                    booking.Primary_Applicant_Name__c = applicant.Name;
                    booking.Primary_Applicant_Mobile__c = applicant.Mobile__c;
                    booking.Primary_Applicant_Email__c = applicant.Email__c;
                    if (!mailingAddressSameAsPermanentAddressStr) {
                        if (applicant.Mailing_Address__c == null) {
                            applicant.Mailing_Address__c = '';
                        }
                        if (applicant.Mailing_City__c == null) {
                            applicant.Mailing_City__c = '';
                        }
                        if (applicant.Mailing_State__c == null) {
                            applicant.Mailing_State__c = '';
                        }
                        if (applicant.Mailing_Country__c == null) {
                            applicant.Mailing_Country__c = 'India'; //if null then default
                        }
                        if (applicant.Mailing_Pincode__c == null) {
                            applicant.Mailing_Pincode__c = '';
                        }
                        
                        booking.Primary_Applicant_Address__c = applicant.Mailing_Address__c + ', ' +
                            applicant.Mailing_City__c + ', ' +
                            applicant.Mailing_State__c + ', ' +
                            applicant.Mailing_Country__c + ', - ' +
                            applicant.Mailing_Pincode__c;
                    } else {
                        if (applicant.Permanent_Address__c == null) {
                            applicant.Permanent_Address__c = '';
                        }
                        if (applicant.City__c == null) {
                            applicant.City__c = '';
                        }
                        if (applicant.State__c == null) {
                            applicant.State__c = '';
                        }
                        if (applicant.Country__c == null) {
                            applicant.Country__c = 'India'; //if null then default
                        }
                        if (applicant.PIN__c == null) {
                            applicant.PIN__c = '';
                        }
                        booking.Primary_Applicant_Address__c = 
                            applicant.Permanent_Address__c + ', ' +
                            applicant.City__c + ', ' +
                            applicant.State__c + ', ' +
                            applicant.Country__c + ', - ' +
                            applicant.PIN__c;
                    }
                }
                try{
                    update booking; 
                    system.debug('Update:'+booking);
                }catch(exception e){
                    system.debug('Exception on update Booking :'+ e.getMessage());
                }
                
                if (documentsList != null && !documentsList.isEmpty()) {
                    for (Object document1 : documentsList) {
                        if (document1 instanceof Map<String, Object>) {
                            Map<String, Object> documentMap = (Map<String, Object>) document1;
                            system.debug('documentMap::' +documentMap);
                            Document__c document = new Document__c();
                            if (documentMap.get('Name') != null) {
                                document.Name__c = (String) documentMap.get('Name');
                            }
                            if (documentMap.get('Document_Upload_Required__c') != null) {
                                document.Document_Upload_Required__c = (String) documentMap.get('Document_Upload_Required__c');
                            }
                            if (documentMap.get('Type_of_Applicant__c') != null) {
                                document.Type_of_Applicant__c = (String) documentMap.get('Type_of_Applicant__c');
                            }
                            if (documentMap.get('Residential_Status__c') != null) {
                                document.Residential_Status__c = (String) documentMap.get('Residential_Status__c');
                            }
                            string Isbase64 ='';
                            if(documentMap.containsKey('base64') && documentMap.get('base64')!= null){
                                Isbase64 = (string)documentMap.get('base64');
                            }
                            if(documentMap.get('type') != null){
                                System.debug('document type/////////'+documentMap.get('type'));
                                String docType = (String) documentMap.get('type');
                                if(docType.contains('Aadhar Card')){
                                    if(!String.isBlank(Isbase64)){
                                        document.uploaded__c =true;
                                    }
                                    document.Document_Type__c = 'Aadhar Card';
                                }else if(docType.contains('Pan Card')){
                                    if(!String.isBlank(Isbase64)){
                                        document.uploaded__c =true;
                                    }
                                    document.Document_Type__c = 'Pan Card';
                                }
                            }
                            if(applicant.Id != null){
                                document.Applicant__c = applicant.Id;        
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
                            
                            if (base64 != null && filename != null) {
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
        cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        
        
        ContentDistribution cd = new ContentDistribution();
        if(cdl.ContentDocumentId != null) {
            cd.Name = recordId;
            cd.ContentVersionId = contentVersionId;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            cd.PreferencesAllowOriginalDownload = true;
            insert cd;   
            system.debug('cd: '+cd);
            
            cd = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE Id =: cd.Id LIMIT 1];
            system.debug('DistributionPublicUrl: '+cd.DistributionPublicUrl);
        }
        try {
            insert cdl;
            
            List<Document__c> docList = new List<Document__c>();
            List<Document__c> updateDocList = new List<Document__c>();
            
            docList = [Select Id, Name, Document_Type__c, Document_View_Link__c from Document__c where Id =: recordId];
            for(Document__c doc: docList){
                if(String.isNotBlank(cd.DistributionPublicUrl)){
                    doc.Document_View_Link__c = cd.DistributionPublicUrl;
                    updateDocList.add(doc);
                }
            }
            if(!updateDocList.isEmpty()){
                update updateDocList;
            }
            
            
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
        
        
        
        
    } 
    
}