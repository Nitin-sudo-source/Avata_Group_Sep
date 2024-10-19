/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 10-18-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Ex_WelcomeCallEmailController {
    
    public String bId { get; set; }
    public List<Booking__c> bkList { get; set; }
    public String unitName {get;set;}
    public String towerName {get;set;}
    public String reraArea {get;set;}
    public String floorNo {get;set;}
    public String tdsCompanyName {get;set;}
    public String tdsPan {get;set;}
    public String tdsEmail {get;set;}
    public String tdsCompanyAddress {get;set;}
    public String tdsContactNo {get;set;}
    public String crmName {get;set;}
    public DateTime welcomecallDate {get;set;}
    public List<ApplicantWrapper> ApplicantWrapperList { get; set; }
    public List<applicant__c> apList { get; set; }
    public String projName {get;set;}
    public String inventoryType {get;set;}
    public String configrationType {get;set;}
    
    
    
    public Ex_WelcomeCallEmailController() {
        bId = ApexPages.currentPage().getParameters().get('bId');
        apList = new List<Applicant__c>();
        ApplicantWrapperList = new List<ApplicantWrapper>();
        
        bkList = new List<Booking__c>();
        unitName = '';
        towerName = '';
        reraArea = '';
        floorNo = '';
        tdsCompanyName='';
        tdsPan='';
        tdsEmail='';
        tdsCompanyAddress='';
        tdsContactNo='';
        crmName = '';
        welcomecallDate = System.today();
        projName = '';
        inventoryType = '';
        configrationType = '';
        
        
        if (bId != null) {
            bkList = [SELECT Id, Primary_Applicant_Name__c, Primary_Applicant_Mobile__c, Primary_Applicant_Email__c, Tower__r.Name, Unit__r.Name, Unit__r.RERA_Carpet_Area_Sq_Ft__c, Unit__r.Floor__c,
                      Account_Name_Flat_Cost__c, Bank_Name_Flat_Cost__c, Branch_Name_Flat_Cost__c, Account_Number_Flat_Cost__c,  IFSC_Code_Flat_Cost__c, Account_Name_Tax__c, Bank_Name_Tax__c,
                      Branch_Name_Tax__c,  Account_Number_Tax__c, IFSC_Code_Tax__c, Project__r.Contact_No__c, Project__r.Company_Address__c, Project__r.Email_ID__c, Project__r.Pan_No__c, Project__r.Company_Name__c,
                      Welcome_Call_Done_DateTime__c, Project__r.Name, Unit__r.Inventory_Type__c, Unit__r.Configuration_Type__c,
                      CRM_Head__r.Name
                      FROM Booking__c  WHERE Id = :bId];
            System.debug('bkList: '+bkList);
            
            if (!bkList.isEmpty()) {
                Booking__c bk = bkList[0];
                unitName = bk.Unit__r.Name;
                towerName = bk.Tower__r.Name;
                reraArea = String.valueof(bk.Unit__r.RERA_Carpet_Area_Sq_Ft__c);
                floorNo = String.valueof(bk.Unit__r.Floor__c);
                tdsCompanyName= bk.Project__r.Company_Name__c;
                tdsPan=bk.Project__r.Pan_No__c;
                tdsEmail=bk.Project__r.Email_ID__c;
                tdsCompanyAddress=bk.Project__r.Company_Address__c;
                tdsContactNo=bk.Project__r.Contact_No__c;
                crmName = bk.CRM_Head__r.Name;
                welcomecallDate = bk.Welcome_Call_Done_DateTime__c;
                projName = bk.Project__r.Name;
                inventoryType = bk.Unit__r.Inventory_Type__c;
                configrationType = bk.Unit__r.Configuration_Type__c;
            }
        }
        
        // Fetch Applicants
        apList = [
            SELECT Id, Name, Applicant_Number__c, Applicant_Title__c, DOB__c, Anniversary_Date__c, 
            Occupation__c, Mobile__c, Email__c, PAN_Number__c, Permanent_Address__c, 
            Country__c, State__c, City__c, PIN__c
            FROM Applicant__c 
            WHERE Booking__c = :bId AND
            Applicant_Number__c != 'Primary Applicant'
            ORDER BY Applicant_Number__c ASC
        ];
        
        // Populate ApplicantWrapperList
        for (Applicant__c applicant : apList) {
            ApplicantWrapperList.add(new ApplicantWrapper(
                applicant.Applicant_Title__c,
                applicant.Applicant_Number__c,
                applicant.Name,
                null, // Gender (not available in the queried fields)
                applicant.DOB__c,
                applicant.Anniversary_Date__c,
                applicant.Occupation__c,
                applicant.Mobile__c,
                applicant.PAN_Number__c,
                applicant.Email__c,
                applicant.Permanent_Address__c,
                applicant.State__c,
                applicant.Country__c,
                applicant.City__c,
                applicant.PIN__c,
                '', // Permanent address fields can be adjusted if necessary
                applicant.State__c,
                applicant.Country__c,
                applicant.City__c,
                applicant.PIN__c
            ));
        }
        
    }
    
    public class ApplicantWrapper {
        public String apTitle { get; set; }
        public String applicantNumber { get; set; }
        public String applicantName { get; set; }
        public String applicantGender { get; set; }
        public Date applicantDOB { get; set; }
        public Date applicantAnivserD { get; set; }
        public String applicantOccupation { get; set; }
        public String applicantMobile { get; set; }
        public String applicantPAN { get; set; }
        public String applicantEmail { get; set; }
        public String commAddress { get; set; }
        public String commState { get; set; }
        public String commCountry { get; set; }
        public String commCity { get; set; }
        public String commPIN { get; set; }
        public String permAddress { get; set; }
        public String permState { get; set; }
        public String permCountry { get; set; }
        public String permCity { get; set; }
        public String permPIN { get; set; }
        
        public ApplicantWrapper(String apTitle, String applicantNumber, String applicantName, String applicantGender, 
                                Date applicantDOB, Date applicantAnivserD, String applicantOccupation, String applicantMobile, 
                                String applicantPAN, String applicantEmail, String commAddress, String commState, 
                                String commCountry, String commCity, String commPIN, String permAddress, String permState, 
                                String permCountry, String permCity, String permPIN) {
                                    this.apTitle = apTitle;
                                    this.applicantNumber = applicantNumber;
                                    this.applicantName = applicantName;
                                    this.applicantGender = applicantGender;
                                    this.applicantDOB = applicantDOB;
                                    this.applicantAnivserD = applicantAnivserD;
                                    this.applicantOccupation = applicantOccupation;
                                    this.applicantMobile = applicantMobile;
                                    this.applicantPAN = applicantPAN;
                                    this.applicantEmail = applicantEmail;
                                    this.commAddress = commAddress;
                                    this.commState = commState;
                                    this.commCountry = commCountry;
                                    this.commCity = commCity;
                                    this.commPIN = commPIN;
                                    this.permAddress = permAddress;
                                    this.permState = permState;
                                    this.permCountry = permCountry;
                                    this.permCity = permCity;
                                    this.permPIN = permPIN;
                                }
    }
}