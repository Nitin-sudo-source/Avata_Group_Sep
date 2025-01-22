public class Ex_BookingFormBController {
    public Id bId{get;set;}
    public List<Booking__c> bkList {get;set;}
    public  List<Applicant__c> apList {get;set;}
    public List<applicantWrapper> viewAppList {get;set;}
    public List<ReceiptWrapper> receiptWrapperList {get;set;}
    public List<Receipt__c> recpList {get;set;}
    public  List<Charge_Detail__c> chargeList {get;set;}
    public String name{get;set;}
    public Date dob{get;set;}
    public String pan{get;set;}
    public String aadhar{get;set;}
    public String receiptAmount {get;set;}
    public Decimal totalReceiptAmount {get;set;}
    public String showReceiptAmount {get;set;}
    public String showpaymode {get;set;}
    public String age {get;set;}
    public String showRegistrationAmount {get;set;}//showgetFloorRiseAmount
    public String showgetlegalAmount {get;set;}
    public String showStampAmount {get;set;}
    public String showAv {get;set;}
    public Date recDate {get;set;}
    public Date receiptDate {get;set;}
    public String receiptBankName {get;set;}
    public String show2ndApplicantName {get;set;}
    public String showSanctionedAmount {get;set;}//showAdvanceMaintenance
    public String showAdvanceMaintenance {get;set;}
    Public Decimal getpercentageasperLedger {get;set;}
    public String showGst {get;set;}
    
    public Ex_BookingFormBController(){
        bId = (Id)ApexPages.currentPage().getParameters().get('bId');
        apList = new  List<Applicant__c>();
        recpList = new List<Receipt__c>();
        //recpList = null;
        viewAppList = new List<applicantWrapper>();
        receiptWrapperList = new List<ReceiptWrapper>();
        // receiptWrapperList = null;
        chargeList  = new List<Charge_Detail__c>();
        name = '';
        dob = null;
        pan = '';
        aadhar = '';
        receiptAmount = null;
        totalReceiptAmount = 0;
        showRegistrationAmount = '';
        showgetlegalAmount = '';
        showStampAmount = '';
        showAv = '';
        receiptDate = null;    
        recDate = null;
        showpaymode = null;
        receiptBankName = '';
        show2ndApplicantName = null;
        showSanctionedAmount = '';
        showAdvanceMaintenance = '';
        getpercentageasperLedger = 0;
        showGst = '';
        bklist = new list<Booking__c>();
        System.debug('bId: '+bId);
        if(bId != null){
            bklist = [select Id, Project__r.Booking_form_Logo__c,Name,Primary_Applicant_Name__c ,Project__r.Name,CreatedDate, 
                      Bank_Name_Flat_Cost__c,Account_Number_Flat_Cost__c,Unit__r.RERA_Carpet_Area_Sq_Ft__c,Opportunity__r.Lead_Source__c,
                      Account_Number_Tax__c,IFSC_Code_Flat_Cost__c,Quotation__c,Unit__r.RERA_Carpet_Area_Sq_Mtr__c,Mode_of_Funding__c,
                      Registration_Date__c, Registration_Number__c,Unit__r.Name,Unit__r.Floor__c,Unit__r.Configuration__c, Project__r.Booking_Form_B_Image__c,
                      Booking_Date__c,Channel_partner__r.MahaRERA_Registration_No__c,Channel_partner__r.Name,Opportunity__r.Sales_Manager__r.Name,Unit__r.Deck_Area__c,Unit__r.Car_Park_Count_1__c,
                      Channel_partner__r.Owner_Mobile_No__c ,Unit__r.Tower__r.Name,Unit__r.Tower__r.Phase__c,Account_Name_Flat_Cost__c ,Agreement_Value__c,Opportunity__r.Buying_Purpose__c,
                      Type_of_Booking__c,Preferred_Bank_for_Home_loan__c,Loan_Sanction_Status__c,Sanctioned_Loan_Amount__c,Advance_maintenance_24_months_GST_18__c,SDR_Payment_Status__c,Photographs_6_copy__c,
                      ROC_Required__c,Total_Amount_Paid__c, Legal_Charges__c, GST__c
                      from Booking__c where id =: bId]; 
            system.debug('bkList: '+bkList);
        }
        if(!bkList.isEmpty() && bkList != null){
            if(bkList[0].Agreement_Value__c != null && bkList[0].Agreement_Value__c != 0){
                showAv = 'Rs.'+Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Agreement_Value__c);
            }
            if(bkList[0].Sanctioned_Loan_Amount__c != null && bkList[0].Sanctioned_Loan_Amount__c != 0){
                showSanctionedAmount =  'Rs.'+Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Sanctioned_Loan_Amount__c);
            }
            if(bkList[0].Advance_maintenance_24_months_GST_18__c != null && bkList[0].Advance_maintenance_24_months_GST_18__c != 0){
                showAdvanceMaintenance =  Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Advance_maintenance_24_months_GST_18__c);
            }
            if(bkList[0].Total_Amount_Paid__c != null && bkList[0].Agreement_Value__c != null){
                getpercentageasperLedger = ((bkList[0].Total_Amount_Paid__c / bkList[0].Agreement_Value__c)*100).setscale(0,RoundingMode.HALF_UP);
            }
            if(bkList[0].Legal_Charges__c != null){
                showgetlegalAmount = bkList[0].Legal_Charges__c;
            }
            if(bkList[0].GST__c != null){
                showGst = String.valueof(bkList[0].GST__c);
            }
            
            
        }
        if(!bkList.isEmpty() && bkList != null){
            apList = [Select Id,Name,Applicant_Number__c,Applicant_Title__c,Mobile_Number__c,Email__c,
                      Occupation__c,DOB__c,Anniversary_Date__c,City__c,PIN__c,State__c, Booking__r.Project__r.Booking_form_Logo__c,Residential_Status__c,
                      PAN_Number__c, Aadhar_Number__c, Applicant_Email__c,Type_Of_Applicant__c,
                      Mailing_Address__c, Mailing_State__c, Mailing_City__c, Mailing_Pincode__c,Designation__c,
                      Permanent_Address__c from Applicant__c where Booking__c =: bkList[0].Id AND Applicant_Number__c != '']; 
            system.debug('apList: '+apList.size());
            if(!apList.isEmpty() && apList != null){
                for(Applicant__c ap: apList){
                    if(apList.size() == 1){
                        name = null;
                        dob = null;
                        age = null;
                        pan = null;
                        aadhar = null;
                    }else{
                        name = ap.Applicant_Title__c + ' ' + ap.Name;
                        dob = ap.DOB__c ;
                        age = '('+calculateAge(dob) + 'Yrs)' + ',' ;
                        if(ap.PAN_Number__c != null)
                        pan = ap.PAN_Number__c + ',';
                        aadhar = ap.Aadhar_Number__c + ',';
                    }
                        viewAppList.add(new applicantWrapper(name,dob,age, pan, aadhar ));
                    	System.debug('viewAppList : '+viewAppList);
                    
                }
                if(!viewAppList.isEmpty() && viewAppList != null){
                    System.debug('viewAppList : '+viewAppList.size());
                    for(applicantWrapper showApp: viewAppList) {
                        if(viewAppList.size() > 1){
                            showApp = viewAppList[viewAppList.size() - apList.size()];
                            system.debug('showApp: '+showApp);
                            showApp.name = null;
                            showApp.age = null;
                            showApp.pan = null;
                            showApp.aadhar = null;
                        }
                       // system.debug('show2ndApplicantName: '+show2ndApplicantName);
                    }
                }
                system.debug('viewAppList:'+viewAppList);
            }
        }
        
        if(!bkList.isEmpty() && bkList != null && String.isNotBlank(bId)){
            recpList = [Select Id,Booking__c,Amount__c,Payment_Mode__c,Receipt_Date__c,Transaction_Id__c,Bank_Name__c from Receipt__c where Booking__c =: bId];
            system.debug('recpList: '+recpList);
            
            if(!recpList.isEmpty() && recpList != null){
                if(recpList[0].Receipt_Date__c != null)
                    receiptDate = recpList[0].Receipt_Date__c;
                if(recpList[0].Bank_Name__c != null)
                    receiptBankName = recpList[0].Bank_Name__c;
                if(!recpList.isEmpty() && recpList != null){
                    for(Receipt__c r:recpList){
                        if(r.Amount__c != null && r.Amount__c != 0){
                            receiptAmount = 'Rs.'+Ex_InventoryPriceManagementServices.currencyFormat(r.Amount__c)+','+'';
                        }
                        if(r.Transaction_Id__c != null){
                            showpaymode = r.Transaction_Id__c+','+'';
                        }
                        if(r.Amount__c != null && r.Amount__c != 0){
                            totalReceiptAmount += r.Amount__c;
                        }
                        if(r.Receipt_Date__c != null){
                            recDate = r.Receipt_Date__c;
                        }
                        receiptWrapperList.add(new ReceiptWrapper(receiptAmount,showpaymode,recDate));
                        
                    }
                }
                if(totalReceiptAmount  != null && totalReceiptAmount != 0)
                    showReceiptAmount = '(Total Rs.'+Ex_InventoryPriceManagementServices.currencyFormat(totalReceiptAmount)+')';
                
            }
            
        }
        if(!bkList.isEmpty() && bkList != null && bkList[0].Quotation__c != null){
            chargeList = [Select Id ,Name, Charge_Amount__c from Charge_Detail__c where Quotation__c =: bkList[0].Quotation__c ];
            if(!chargeList.isEmpty() && chargeList != null){                
                for(Charge_Detail__c cd : chargeList){
                    if(cd.Name == 'Registration Charges' && cd.Charge_Amount__c != null){
                        // getRegistrationAmount =  cd.Charge_Amount__c;
                        showRegistrationAmount = Ex_InventoryPriceManagementServices.currencyFormat(cd.Charge_Amount__c);
                    }
                    if(cd.Name == 'Stamp Duty' && cd.Charge_Amount__c != null){
                        //getStampDutyAmount =  cd.Charge_Amount__c;
                        showStampAmount = Ex_InventoryPriceManagementServices.currencyFormat(cd.Charge_Amount__c);
                    }
                    /*if(cd.Name == 'Legal Charges' && cd.Charge_Amount__c != null){
                        //getFloorRise =  cd.Charge_Amount__c;
                        showgetlegalAmount = Ex_InventoryPriceManagementServices.currencyFormat(cd.Charge_Amount__c);
                    }*/
                }
            }
        }
    }
    public class applicantWrapper{
        public String name {get;set;}
        public Date dob {get;set;}
        public String age {get;set;}
        public String pan {get;set;}
        public String aadhar {get;set;}
        
        
        public applicantWrapper(String name,Date dob,String age, String pan, String aadhar) {
            this.name = name;
            this.dob = dob;
            this.age = age;
            this.pan = pan;
            this.aadhar = aadhar;
        }
    }
    public class ReceiptWrapper{
        public String receiptAmount{get;set;}
        public String showPaymode {get;set;}
        public Date recDate {get;set;}
        
        public ReceiptWrapper(String receiptAmount,String showPaymode,Date recDate) {
            this.receiptAmount = receiptAmount;
            this.showPaymode = showPaymode;
            this.recDate = recDate;
            
        }
    }
    public static String calculateAge(Date birthDate) {
        Date currentDate = Date.today();
        Integer birthYear = birthDate.year();
        Integer currentYear = currentDate.year();
        Integer age = currentYear - birthYear;
        String ageStr = String.valueof(age);
        if (currentDate.month() < birthDate.month() ||
            (currentDate.month() == birthDate.month() && currentDate.day() < birthDate.day())) {
                age--; 
            }
        return ageStr;
    }
}