/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Ex_WelcomeCallEmailController {
    public String bId { get; set; }
    public Booking__c bk { get; set; }
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
    //  public List<Applicant__c> apList { get; set; }
    // public String currentDate { get; set; }
    //public List<ApplicantWrapper> ApplicantWrapperList { get; set; }
    
    public Ex_WelcomeCallEmailController() {
        bId = ApexPages.currentPage().getParameters().get('bId');
        bk = new Booking__c();
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
    
        //ApplicantWrapperList = new List<ApplicantWrapper>();
        //apList= new List<Applicant__c>();
        
        if (bId != null) {
            // Fetch Booking details
            bkList = [SELECT Id, Primary_Applicant_Name__c, 
                      Primary_Applicant_Mobile__c,
                      Primary_Applicant_Email__c,
                      Tower__r.Name,
                      Unit__r.Name,
                      Unit__r.RERA_Carpet_Area_Sq_Ft__c,
                      Unit__r.Floor__c,
                      Account_Name_Flat_Cost__c, 
                      Bank_Name_Flat_Cost__c, 
                      Branch_Name_Flat_Cost__c, 
                      Account_Number_Flat_Cost__c, 
                      IFSC_Code_Flat_Cost__c,
                      Account_Name_Tax__c,
                      Bank_Name_Tax__c,
                      Branch_Name_Tax__c,
                      Account_Number_Tax__c,
                      IFSC_Code_Tax__c
                      FROM Booking__c 
                      WHERE Id = :bId];
            System.debug('bkList: '+bkList);
            
            if (!bkList.isEmpty()) {
                unitName = bkList[0].Unit__r.Name;
                towerName = bkList[0].Tower__r.Name;
                reraArea = String.valueof(bkList[0].Unit__r.RERA_Carpet_Area_Sq_Ft__c);
                floorNo = String.valueof(bkList[0].Unit__r.Floor__c);
                bk = bkList[0]; // Set the first booking record to bk
            }
        }
        
        // Initialize current date
        //currentDate = String.valueOf(Date.today());
    }
    
    // Wrapper class to hold Applicant details
    public class ApplicantWrapper {
        public String applicantName { get; set; }
        public String applicantMobile { get; set; }
        public String applicantEmail { get; set; }
        public String buildingname {get;set;}
        public String unitno { get; set; }
        public String typeofunit { get; set; }
        public String reracarpetarea { get; set; }
        public String floor { get; set; } 
        public String companynameandaccountname { get; set; }
        public String bankandbranchname { get; set; }
        public String accountno { get; set; }
        public String ifsccode { get; set; }
        
        public String companynameandaccountname1 { get; set; }
        public String bankandbranchname1 { get; set; }
        public String accountno1 { get; set; }
        public String ifsccode1 { get; set; }
        
        public String companyname { get; set; }
        public String panno { get; set; }
        public String emailid { get; set; }
        public String companyaddress { get; set; }
        public String contactno { get; set; }
        
        
        
        
        public ApplicantWrapper(String name, String mobile, String email,String buildingname,String unitno,String typeofunit, String reracarpetarea,String floor ,
                                String companynameandaccountname,String bankandbranchname,String accountno ,String ifsccode,
                                String companynameandaccountname1, String bankandbranchname1, String accountno1,String ifsccode1 ,
                                String companyname ,String panno,String emailid,String companyaddress,String contactno ) {
                                    this.applicantName = name;
                                    this.applicantMobile = mobile;
                                    this.applicantEmail = email;
                                    
                                    this.buildingname= buildingname;
                                    this.unitno= unitno;
                                    this.typeofunit= typeofunit;
                                    this.reracarpetarea= reracarpetarea;
                                    this.floor= floor;
                                    this.companynameandaccountname= companynameandaccountname;
                                    this.bankandbranchname= bankandbranchname;
                                    this.accountno= accountno;
                                    this.ifsccode= ifsccode;
                                    
                                    this.companynameandaccountname1= companynameandaccountname1;
                                    this.bankandbranchname1= bankandbranchname1;
                                    this.accountno1= accountno1;             
                                    this.ifsccode1= ifsccode1;
                                    
                                    this.companyname= companyname;
                                    this.panno= panno;
                                    this.emailid= emailid;
                                    this.companyaddress= companyaddress;
                                    this.contactno= contactno;
                                    
                                    
                                    
                                }
    }
}