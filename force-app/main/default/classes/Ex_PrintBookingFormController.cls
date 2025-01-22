public class Ex_PrintBookingFormController {
    public Id bId{get;set;}
    public List<Booking__c> bkList {get;set;}
    public  List<Applicant__c> apList {get;set;}
    public String name {get;set;}
    public String mobile {get;set;}//pripanNumber
    public String aadhar {get;set;}
    public String typeofApplicant {get;set;}
    public String permanentAddress {get;set;}
    public String agreementValue {get;set;}
    public String pan {get;set;}
    public String email {get;set;}//occupation
    public String occupation {get;set;}//
    public Date dob {get;set;}
    public List<applicantWrapper> viewAppList {get;set;}
    public List<Receipt__c> recpList {get;set;}
    public String tokenAmount {get;set;}
    public Boolean showMumbaiResident {get;set;}
    public Boolean showNonMumbaiResident {get;set;}
    public Boolean showNonMumbaiResidentIndian {get;set;}
    public String residentStatus {get;set;}
        public Boolean showSelfEmployed {get;set;}
        public Boolean showSalaried {get;set;}
    public Boolean showChannelPartner {get;set;}
    
    public Ex_PrintBookingFormController(){
        apList = new  List<Applicant__c>();
        recpList = new List<Receipt__c>();
        name = '';
        mobile = '';
        showMumbaiResident = false;
        showNonMumbaiResident = false;
        showNonMumbaiResidentIndian = false;
        showSelfEmployed = false;
        showSalaried = false;
        showChannelPartner = false;
        
        viewAppList = new List<applicantWrapper>();
        bklist = new list<Booking__c>();
        bId = (Id)ApexPages.currentPage().getParameters().get('bId');
        if(bId != null){
            
            bklist = [select Id, Project__r.Booking_form_Logo__c,Name,Primary_Applicant_Name__c ,Project__r.Name,CreatedDate, 
                      Bank_Name_Flat_Cost__c,Account_Number_Flat_Cost__c,Unit__r.RERA_Carpet_Area_Sq_Ft__c,Opportunity__r.Lead_Source__c,
                      Account_Number_Tax__c,IFSC_Code_Flat_Cost__c,Quotation__c,Unit__r.RERA_Carpet_Area_Sq_Mtr__c,Mode_of_Funding__c,
                      Registration_Date__c, Registration_Number__c,Unit__r.Name,Unit__r.Floor__c,Unit__r.Configuration__c,Project__r.Booking_Form_B_Image__c,

                      Booking_Date__c,Channel_partner__r.MahaRERA_Registration_No__c,Channel_partner__r.Name,Opportunity__r.Sales_Manager__r.Name,
                      Channel_partner__r.Owner_Mobile_No__c ,Unit__r.Tower__r.Name,Account_Name_Flat_Cost__c ,Agreement_Value__c,Opportunity__r.Buying_Purpose__c                 
                      from Booking__c where id =: bId]; 
            system.debug('bkList: '+bkList);
        }
        
        if(bkList[0].Agreement_Value__c != null && bkList[0].Agreement_Value__c != 0){
            agreementValue = Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Agreement_Value__c);
            
        }
        if(bkList[0].Opportunity__r.Lead_Source__c == 'Channel Partner'){
            showChannelPartner = true;
        }
        
        if(!bkList.isEmpty() && bkList != null){
            apList = [Select Id,Name,Applicant_Number__c,Applicant_Title__c,Mobile_Number__c,Email__c,
                      Occupation__c,DOB__c,Anniversary_Date__c,City__c,PIN__c,State__c, Booking__r.Project__r.Booking_form_Logo__c,Residential_Status__c,
                      PAN_Number__c, Aadhar_Number__c, Applicant_Email__c,Type_Of_Applicant__c,
                      Mailing_Address__c, Mailing_State__c, Mailing_City__c, Mailing_Pincode__c,Designation__c,
                      Permanent_Address__c  from Applicant__c where Booking__c =: bkList[0].Id];
            system.debug('apList: '+apList);
            
            if(!apList.isEmpty() && apList != null){
                if(apList[0].Residential_Status__c == 'Mumbai Resident')
                    showMumbaiResident = true;
                if(apList[0].Residential_Status__c == 'Non-Mumbai Resident')
                    showNonMumbaiResident = true;
                if(apList[0].Residential_Status__c == 'Non-Resident Indian')
                    showNonMumbaiResidentIndian = true;
                if(apList[0].Occupation__c == 'Self-Employed')
                    showSelfEmployed = true;
                 if(apList[0].Occupation__c != 'Self-Employed')
                     showSalaried = true;
            }
           
            if(!apList.isEmpty() && apList != null){
                for(Applicant__c ap: apList){
                    name = ap.Applicant_Title__c + ' ' + ap.Name  ;
                    dob = ap.DOB__c;
                    mobile = ap.Mobile_Number__c;
                    email = ap.Applicant_Email__c;
                    pan = ap.PAN_Number__c;
                    aadhar = ap.Aadhar_Number__c;
                    occupation = ap.Occupation__c;
                    typeofApplicant = ap.Type_Of_Applicant__c;
                    permanentAddress = ap.Permanent_Address__c;
                    residentStatus = ap.Residential_Status__c;
                    
                    viewAppList.add(new applicantWrapper(name,dob, mobile, email, pan, aadhar, occupation, typeofApplicant, permanentAddress,residentStatus ));
                    system.debug('viewAppList:'+viewAppList);
                }
            }
        }
    }
    public class applicantWrapper{
        public String name {get;set;}
        public Date dob {get;set;}
        public String mobile {get;set;} //email
        public String email {get;set;}
        public String pan {get;set;}
        public String aadhar {get;set;}
        public String occupation {get;set;}
        public String typeofApplicant {get;set;}
        public String permanentAddress {get;set;}
        public String residentStatus {get;set;}
        
        
        public applicantWrapper(String name,Date dob, String mobile,String email, String pan, String aadhar, String occupation, String typeofApplicant, String permanentAddress,String residentStatus) {
            this.name = name;
            this.dob = dob;
            this.mobile = mobile;
            this.email = email;
            this.occupation = occupation;
            this.pan = pan;
            this.aadhar = aadhar;
            this.typeofApplicant = typeofApplicant;
            this.permanentAddress = permanentAddress; 
            this.residentStatus= residentStatus;
            
        }
    }
}