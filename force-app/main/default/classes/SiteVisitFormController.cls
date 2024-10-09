//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class SiteVisitFormController {
    
    public List<Account> accList1 {get;set;}
    public List<Opportunity__c> oppList1 {get;set;}
    public List<Lead__c> leadList1 {get;set;}
    public List<Project__c> pList {get;set;}
    public Site_Visit__c sv {get;set;}
    public SMS__c sms {get;set;}
    public boolean isAccount {get;set;}
    public boolean isLead {get;set;}
    public boolean isOpp {get;set;}
    public String project {get;set;}
    public String projectName {get;set;}
    public String mobile {get;set;}
    public String email {get;set;}
    public Boolean isRunError {get;set;}
    public Boolean isSuccess {get;set;}
    public Boolean valError {get;set;}
    public String message {get;set;}
    public String refName {get;set;}
    public boolean isAccountFound {get;set;}
    public boolean isLeadFound {get;set;}
    public boolean isOppFound {get;set;}
    public boolean isSourceNotEditable {get;set;}
    public boolean flagqrs {get;set;}
    public string flagQR {get;set;}
    public boolean qrCode {get;set;}
    public Date lastSourceChanged {get;set;}
    public Date TodayDate {get;set;}
    public String enterOtp { get; set; }
    public String generatedOtp { get; set; }
    public Boolean isVerified { get; set; }
    public String errorMessage { get; set; }
    public Boolean isOTPdone {get;set;}
	public Boolean hidesendOtp {get;set;}
    public Boolean show {get;set;}
    public Boolean resend {get;set;}
    public String SiteVisitName {get;set;}

    
    
    public SiteVisitFormController() {
        accList1 = new List<Account>();
        oppList1 = new List<Opportunity__c>();
        leadList1 = new List<Lead__c>();
        pList = new List<Project__c>();
        sv = new Site_Visit__c();
        isSuccess = false;
        isRunError = false;
        isAccount = false;
        isLead = false;
        isOpp = false;
        isAccountFound = false;
        isLeadFound = false;
        isOppFound = false;
        project = '';
        projectName = '';
        mobile = '';
        email = '';
        message = '';
        refName = '';
        isSourceNotEditable = false;
        flagQR = '';
        flagqrs = false;
        qrCode = true;
        isVerified = false;
        enterOtp = '';
        generatedOtp = '';
        errorMessage = '';
        isOTPdone = true;
        hidesendOtp = false;
        show = true;
        resend = false;
       // SiteVisitName = getSiteVisitName();
        
        project = ApexPages.currentPage().getParameters().get('project'); 
        mobile = ApexPages.currentPage().getParameters().get('mobile');
        email = ApexPages.currentPage().getParameters().get('email');
        flagQR = ApexPages.currentPage().getParameters().get('QR');
        system.debug('project: '+project+ ' mobile: '+mobile+ ' email: '+email+' QR: '+flagQR);
        
        if(project != Null && !String.isBlank(project)) {
            pList = [Select Id, Name, Site_Visit_QR_Assignment__c, Default_Owner_For_CP__c from Project__c where Id =: project];
            system.debug('pList: '+pList);
            
            if(!pList.isEmpty()) {
                if(flagQR == 'true') {
                    flagqrs = true;
                    qrCode = false;
                    system.debug('flag: '+ qrCode);
                    sv.created_from_QR_Code__c = true;
                }
                sv.Project__c = pList[0].Id;
                projectName = pList[0].Name;
            }
        }
        
        if(mobile != Null && !String.isBlank(mobile)) {
            sv.Mobile__c = mobile;
        }
        if(email != Null && !String.isBlank(email)) {
            sv.Email__c = email;
        }
        
        
        
        List<Account> accList = new List<Account>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        List<Lead__c> leadList = new List<Lead__c>();
        List<Site_Visit__c> svList = new List<Site_Visit__c>();
        
        if(mobile != Null && !String.isBlank(mobile)) {
            accList = [Select Id, Salutation, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, 
                       House_No__c, Building__c, BillingStreet, Locality__c, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                       Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c ,  Martial_Status__c, Age__c, Gender__c
                       from Account
                       where (PersonMobilePhone =: mobile OR Phone =: mobile) AND IsPersonAccount = true];
            system.debug('accList: '+accList);
            
            if(!accList.isEmpty()) {
                isAccount = true;
                isOTPdone = false;
                
                oppList = [Select Id, Name, Project__c, Last_SV_Date__c, Site_Visit_Count__c, Presales_Manager__c,Last_Source_Changed_By__c,Is_SourceChanged__c,
                           Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, OwnerId,Last_SV_attended_by__c, 
                           Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                           Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c,  Project_Type__c, Source_of_Finance_Source_of_Finance__c,
                           Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name,Management_Name__c,
                           Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c,  Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c, Mobile2__c, Departments__c, Locations__c,Comments__c 
                           from Opportunity__c
                          where Account__c =: accList[0].Id AND Project__c =: pList[0].Id AND Is_Active__c = true];
                system.debug('oppList: '+oppList);
                
                if(!oppList.isEmpty()) {
                    isOpp = true;
                    isOTPdone = false;
                    if(oppList[0].Last_Source_Changed_By__c != null){
                    Date lastSourceChanged = oppList[0].Last_Source_Changed_By__c.addDays(45) ;
                    Date TodayDate = System.today();
                    if (lastSourceChanged != null && lastSourceChanged < TodayDate) {
                        oppList[0].Last_Source_Changed_By__c =  lastSourceChanged;
                        system.debug('InsideLastSourceCHanged' + oppList[0].Last_Source_Changed_By__c);
                        isSourceNotEditable = false;
                    } else {
                        isSourceNotEditable = true;
                    }
                  }
                    
                    svList = [Select Id, Master_Source__c,Name, EOI__c, Management_Name__c,Site_Visit_Done__c, Sales_Kit_Provided__c, Background_Verification_Done__c, Is_Source_Conflict__c, AV_video_shown__c  from Site_Visit__c where Opportunity__c =: oppList[0].Id];
                    system.debug('svList: '+svList);
                    
                    /*if (!svList.isEmpty()) {
system.debug('InsideLastSourceCHanged');
} */
                }
            } else {
                if(email != Null && !String.isBlank(email)) {
                    accList = [Select Id, Salutation, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, 
                               House_No__c, Building__c, BillingStreet, Locality__c, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                               Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c, Martial_Status__c, Age__c, Gender__c
                               from Account
                               where (PersonEmail =: email OR Alternate_Email__c =: email) AND IsPersonAccount = true];
                    system.debug('accList: '+accList);
                    
                    if(!accList.isEmpty()) {
                        
                        system.debug('accountlist' +accList);
                        isAccount = true;
                        
                        oppList = [Select Id, Name, Project__c, Last_SV_Date__c, Site_Visit_Count__c, Presales_Manager__c,Last_Source_Changed_By__c,Is_SourceChanged__c,
                                   Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, OwnerId,Last_SV_attended_by__c,
                                   Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                                   Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c,  Project_Type__c, Source_of_Finance_Source_of_Finance__c,
                                   Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name,Management_Name__c,
                                   Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c ,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c, Mobile2__c, Departments__c, Locations__c,Comments__c 
                                   from Opportunity__c
                                   where Account__c =: accList[0].Id AND Project__c =: pList[0].Id AND Is_Active__c = true];
                        system.debug('oppList: '+oppList);
                        
                        if(!oppList.isEmpty()) {
                            isOpp = true;
                            if(oppList[0].Last_Source_Changed_By__c != null){
                            Date lastSourceChanged = oppList[0].Last_Source_Changed_By__c.addDays(45) ;
                            Date TodayDate = System.today();
                            if (lastSourceChanged != null && lastSourceChanged < TodayDate) {
                                oppList[0].Last_Source_Changed_By__c =  lastSourceChanged;
                                system.debug('InsideLastSourceCHanged' + oppList[0].Last_Source_Changed_By__c);
                                isSourceNotEditable = false;
                            } else {
                                isSourceNotEditable = true;
                            }
                                
                           }
                            
                            svList = [Select Id, Master_Source__c,Lead_Source__c, Name, EOI__c, Site_Visit_Done__c, Sales_Kit_Provided__c, Background_Verification_Done__c, Is_Source_Conflict__c, AV_video_shown__c  from Site_Visit__c where Opportunity__c =: oppList[0].Id ORDER BY Name DESC];
                            system.debug('svList: '+svList);
                            
                            /* if (!svList.isEmpty()) {
						system.debug('InsideLastSourceCHanged');
							} */
                        }
                    }
                }
            }
            
            if(oppList.isEmpty()) {
                leadList = [Select Id, Name, Salutation__c, Campaign_Code__c,First_Name__c, Last_Name__c, Mobile__c, Phone__c, Email__c, Alternate_Email_Id__c, Project__c, Campaign_Custom__c,
                            House_No__c, Building__c, Street__c, Locality__c, City__c, State__c, Country__c, PostalCode__c,Age__c,Gender__c,Management_Name__c,
                            Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c,Martial_Status__c,Actual_Budget_in_Lakhs__c,
                            Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, Stage__c, Sub_Stage__c, Substage_Reason__c, OwnerId,
                            Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                            Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c, Presales_Call_Count__c, Presale_Date_of_Visit__c,Presale_Next_Follow_up_Date__c,Last_Presales_Call_Status__c, Presales_Comment_History__c,
                            Last_Presale_Call_Date__c,UTM_Medium__c,UTM_Source__c, Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name, Last_Presale_Call_Comment__c,
                            Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c,Mobile2__c, Departments__c, Locations__c ,Comments__c
                            from Lead__c
                            where (Mobile__c =: mobile OR Phone__c =: mobile) AND Project__c =: pList[0].Id AND IsConverted__c = false];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty()) {
                    isLead = true;
                } else {
                    if(email != Null && !String.isBlank(email)) {
                        leadList = [Select Id, Name, Salutation__c, Campaign_Code__c,First_Name__c, Last_Name__c, Mobile__c, Phone__c, Email__c, Alternate_Email_Id__c, Project__c, Campaign_Custom__c,
                                    House_No__c, Building__c, Street__c, Locality__c, City__c, State__c, Country__c, PostalCode__c,Age__c,Gender__c,Management_Name__c,
                                    Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c,Martial_Status__c,Actual_Budget_in_Lakhs__c,
                                    Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, Stage__c, Sub_Stage__c, Substage_Reason__c, OwnerId,
                                    Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                                    Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c, Presales_Call_Count__c, Presale_Date_of_Visit__c,Presale_Next_Follow_up_Date__c,Last_Presales_Call_Status__c, Presales_Comment_History__c,
                                    Last_Presale_Call_Date__c,UTM_Medium__c,UTM_Source__c, Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name, Last_Presale_Call_Comment__c,
                                    Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c ,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c,Mobile2__c, Departments__c, Locations__c ,Comments__c 
                                    from Lead__c
                                    where (Email__c =: email OR Alternate_Email_Id__c =: email) AND Project__c =: pList[0].Id AND IsConverted__c = false];
                        system.debug('leadList: '+leadList);
                        
                        if(!leadList.isEmpty()) {
                            isLead = true;  
                        }
                    }
                }
            }
        }
        
        if(isAccount) {
            if(accList[0].Salutation != '' && accList[0].Salutation != Null)
                sv.Salutation__c = accList[0].Salutation;
            if(accList[0].FirstName != '' && accList[0].FirstName != Null)
                sv.First_Name__c = accList[0].FirstName;
            if(accList[0].LastName != '' && accList[0].LastName != Null)
                sv.Last_Name__c = accList[0].LastName;
            if(sv.Email__c == null && accList[0].PersonEmail != '' && accList[0].PersonEmail != null)
                sv.Email__c = accList[0].PersonEmail;
            if(accList[0].House_No__c != '' && accList[0].House_No__c != null)
                sv.House_No__c = accList[0].House_No__c;
            if(accList[0].Building__c != '' && accList[0].Building__c != null)
                sv.Building__c = accList[0].Building__c;
            if(accList[0].BillingStreet != '' && accList[0].BillingStreet != null)
                sv.Street_1__c = accList[0].BillingStreet;
            if(accList[0].Locality__c != '' && accList[0].Locality__c != null)
                sv.Locality__c = accList[0].Locality__c;
            if(accList[0].BillingCity != '' && accList[0].BillingCity != null)
                sv.City__c = accList[0].BillingCity;
            if(accList[0].BillingState != '' && accList[0].BillingState != null)
                sv.State__c = accList[0].BillingState;
            if(accList[0].BillingPostalCode != '' && accList[0].BillingPostalCode != null)
                sv.Pincode__c = accList[0].BillingPostalCode;
            if(accList[0].Occupation__c != '' && accList[0].Occupation__c != null)
                sv.Occupation__c = accList[0].Occupation__c;
            if(accList[0].Company_Name__c != '' && accList[0].Company_Name__c != null)
                sv.Company_Name__c = accList[0].Company_Name__c;
            if(accList[0].Designation__c != '' && accList[0].Designation__c != null)
                sv.Designation__c = accList[0].Designation__c;
            if(accList[0].Age__c != null){
                sv.Age__c = accList[0].Age__c;
            }
            if(accList[0].Gender__c != '' && accList[0].Gender__c != null){
                sv.Gender__c = accList[0].Gender__c;
            }
            if(accList[0].Martial_Status__c != '' && accList[0].Martial_Status__c != null){
                sv.Martial_Status__c = accList[0].Martial_Status__c;
            }
            
            if(isOpp) {
                if(oppList[0].Master_Source__c != '' && oppList[0].Master_Source__c != null)
                    sv.Master_Source__c = oppList[0].Master_Source__c	;
                system.debug('Master_Source__c:'+ sv.Master_Source__c);
                if(oppList[0].Lead_Source__c != '' && oppList[0].Lead_Source__c != null){
                    sv.Lead_Source__c = oppList[0].Lead_Source__c;
                    if(oppList[0].Name__c != '' && oppList[0].Name__c != null)
                        sv.Name__c = oppList[0].Name__c;
                    if(oppList[0].Mobile2__c != '' && oppList[0].Mobile2__c != null)
                        sv.Mobile2__c = oppList[0].Mobile2__c;
                    if(oppList[0].Email2__c != '' && oppList[0].Email2__c != null)
                        sv.Email2__c = oppList[0].Email2__c;
                    if(oppList[0].Current_Project_Name__c != '' && oppList[0].Current_Project_Name__c != null)
                        sv.Current_Project_Name__c = oppList[0].Current_Project_Name__c;
                    if(oppList[0].Departments__c != '' && oppList[0].Departments__c != null)
                        sv.Departments__c = oppList[0].Departments__c;
                     if(oppList[0].Staff_Name__c != '' && oppList[0].Staff_Name__c != null)
                        sv.Staff_Name__c = oppList[0].Staff_Name__c; 
                     if(oppList[0].Vendor_Company__c != '' && oppList[0].Vendor_Company__c != null)
                        sv.Vendor_Company__c = oppList[0].Vendor_Company__c;  
                    if(oppList[0].Locations__c != '' && oppList[0].Locations__c != null)
                        sv.Location__c = oppList[0].Locations__c;
                   if(oppList[0].Comments__c != '' && oppList[0].Comments__c != null)
                        sv.Comments__c = oppList[0].Comments__c;
                }                
                if(oppList[0].Channel_Partner__c != null) {
                    sv.Channel_Partner__c = oppList[0].Channel_Partner__c;
                    sv.CP_Name__c = oppList[0].Channel_Partner__r.Name;
                    sv.Firm_Name__c = oppList[0].Channel_Partner__r.Firm_Name__c;
                    sv.RERA_Number__c = oppList[0].Channel_Partner__r.MahaRERA_Registration_No__c;
                    sv.CP_Unique_Code__c = oppList[0].Channel_Partner__r.CP_Code__c;
                    sv.CP_Mobile__c = oppList[0].Channel_Partner__r.Mobile__c;
                }
                if(oppList[0].Referrer_Name__c != null) {
                    sv.Referrer_Name__c = oppList[0].Referrer_Name__c;
                    refName = oppList[0].Referrer_Name__r.Name +'-'+oppList[0].Referrer_Name__r.PersonMobilePhone;
                }
                if(oppList[0].Management_Name__c != null){
                    sv.Management_Name__c = oppList[0].Management_Name__c;
                }
                if(oppList[0].Current_Residence_Configuration__c != '' && oppList[0].Current_Residence_Configuration__c != null)
                    sv.Current_Residence_Configuration__c = oppList[0].Current_Residence_Configuration__c;
                if(oppList[0].Configuration_Required__c != '' && oppList[0].Configuration_Required__c != null)
                    sv.Configuration_Required__c = oppList[0].Configuration_Required__c;
                if(oppList[0].Budget__c != '' && oppList[0].Budget__c != null)
                    sv.Budget__c = oppList[0].Budget__c;
                if(oppList[0].Buying_Purpose__c != '' && oppList[0].Buying_Purpose__c != null)
                    sv.Buying_Purpose__c = oppList[0].Buying_Purpose__c;
                if(oppList[0].Possession_Timeframe_Required__c != '' && oppList[0].Possession_Timeframe_Required__c != null)
                    sv.Possession_Timeframe_Required__c = oppList[0].Possession_Timeframe_Required__c;
                if(oppList[0].Presales_Manager__c != null) {
                    sv.Presales_Manager__c = oppList[0].Presales_Manager__c;
                    sv.Sourcing_Manager__c = oppList[0].Presales_Manager__c;    
                }
                if(oppList[0].Project_Type__c != '' &&  oppList[0].Project_Type__c != null){
                    sv.Project_Type__c = oppList[0].Project_Type__c;
                }
                if(oppList[0].Source_of_Finance_Source_of_Finance__c != '' &&  oppList[0].Source_of_Finance_Source_of_Finance__c != null){
                    sv.Source_of_Finance__c = oppList[0].Source_of_Finance_Source_of_Finance__c;
                }
                if(isSourceNotEditable){
                    if(!svList.isEmpty() && svList != null){
                    sv.EOI__c = svList[0].EOI__c;
                    sv.Site_Visit_Done__c = svList[0].Site_Visit_Done__c;
                    sv.Sales_Kit_Provided__c = svList[0].Sales_Kit_Provided__c;
                    sv.Background_Verification_Done__c = svList[0].Background_Verification_Done__c;
                    sv.AV_video_shown__c =  svList[0].AV_video_shown__c;
                    sv.Is_Source_Conflict__c = svList[0].Is_Source_Conflict__c;
                    }
                }
            } else if(isLead) {
                //if(leadList[0].Master_Source__c != '' && leadList[0].Master_Source__c != null)
                   // sv.Master_Source__c = leadList[0].Master_Source__c	;
                if(leadList[0].Channel_Partner__c != null) {
                    sv.Channel_Partner__c = leadList[0].Channel_Partner__c;
                    sv.CP_Name__c = leadList[0].Channel_Partner__r.Name;
                    sv.Firm_Name__c = leadList[0].Channel_Partner__r.Firm_Name__c;
                    sv.RERA_Number__c = leadList[0].Channel_Partner__r.MahaRERA_Registration_No__c;
                    sv.CP_Unique_Code__c = leadList[0].Channel_Partner__r.CP_Code__c;
                    sv.CP_Mobile__c = leadList[0].Channel_Partner__r.Mobile__c;
                }
                if(leadList[0].Referrer_Name__c != null) {
                    sv.Referrer_Name__c = leadList[0].Referrer_Name__c;
                    refName = leadList[0].Referrer_Name__r.Name +'-'+leadList[0].Referrer_Name__r.PersonMobilePhone;
                }
             /*   if(leadList[0].Current_Residence_Configuration__c != '' && leadList[0].Current_Residence_Configuration__c != null)
                    sv.Current_Residence_Configuration__c = leadList[0].Current_Residence_Configuration__c;
                if(leadList[0].Configuration_Required__c != '' && leadList[0].Configuration_Required__c != null)
                    sv.Configuration_Required__c = leadList[0].Configuration_Required__c;
                if(leadList[0].Budget__c != '' && leadList[0].Budget__c != null)
                    sv.Budget__c = leadList[0].Budget__c;
                if(leadList[0].Buying_Purpose__c != '' && leadList[0].Buying_Purpose__c != null)
                    sv.Buying_Purpose__c = leadList[0].Buying_Purpose__c;
                if(leadList[0].Possession_Timeframe_Required__c != '' && leadList[0].Possession_Timeframe_Required__c != null)
                    sv.Possession_Timeframe_Required__c = leadList[0].Possession_Timeframe_Required__c;*/
                if(leadList[0].OwnerId != null) {
                    sv.Presales_Manager__c = leadList[0].OwnerId;
                    sv.Sourcing_Manager__c = leadList[0].OwnerId;
                }
            }
        } else if(isLead) {
            if(leadList[0].Salutation__c != '' && leadList[0].Salutation__c != Null)
                sv.Salutation__c = leadList[0].Salutation__c;
            if(leadList[0].First_Name__c != '' && leadList[0].First_Name__c != Null)
                sv.First_Name__c = leadList[0].First_Name__c;
            system.debug('leadList[0].First_Name__c' + leadList[0].First_Name__c);
            if(leadList[0].Last_Name__c != '' && leadList[0].Last_Name__c != Null)
                sv.Last_Name__c = leadList[0].Last_Name__c;
            system.debug('leadList[0].Last_Name__c' + leadList[0].Last_Name__c);
            if(sv.Email__c == null && leadList[0].Email__c != '' && leadList[0].Email__c != null)
                sv.Email__c = leadList[0].Email__c;
            if(leadList[0].House_No__c != '' && leadList[0].House_No__c != null)
                sv.House_No__c = leadList[0].House_No__c;
            if(leadList[0].Building__c != '' && leadList[0].Building__c != null)
                sv.Building__c = leadList[0].Building__c;
            if(leadList[0].Street__c != '' && leadList[0].Street__c != null)
                sv.Street_1__c = leadList[0].Street__c;
            if(leadList[0].Locality__c != '' && leadList[0].Locality__c != null)
                sv.Locality__c = leadList[0].Locality__c;
            if(leadList[0].City__c != '' && leadList[0].City__c != null)
                sv.City__c = leadList[0].City__c;
            if(leadList[0].State__c != '' && leadList[0].State__c != null)
                sv.State__c = leadList[0].State__c;
            if(leadList[0].PostalCode__c != '' && leadList[0].PostalCode__c != null)
                sv.Pincode__c = leadList[0].PostalCode__c;
            if(leadList[0].Occupation__c != '' && leadList[0].Occupation__c != null)
                sv.Occupation__c = leadList[0].Occupation__c;
            if(leadList[0].Company_Name__c != '' && leadList[0].Company_Name__c != null)
                sv.Company_Name__c = leadList[0].Company_Name__c;
            if(leadList[0].Designation__c != '' && leadList[0].Designation__c != null)
                sv.Designation__c = leadList[0].Designation__c;
           // if(leadList[0].Master_Source__c != '' && leadList[0].Master_Source__c != null)
              //  sv.Master_Source__c = leadList[0].Master_Source__c	;
            if(leadList[0].Channel_Partner__c != null) {
                sv.Channel_Partner__c = leadList[0].Channel_Partner__c;
                sv.CP_Name__c = leadList[0].Channel_Partner__r.Name;
                sv.Firm_Name__c = leadList[0].Channel_Partner__r.Firm_Name__c;
                sv.RERA_Number__c = leadList[0].Channel_Partner__r.MahaRERA_Registration_No__c;
                sv.CP_Unique_Code__c = leadList[0].Channel_Partner__r.CP_Code__c;
                sv.CP_Mobile__c = leadList[0].Channel_Partner__r.Mobile__c;
            }
            if(leadList[0].Referrer_Name__c != null) {
                sv.Referrer_Name__c = leadList[0].Referrer_Name__c;
                refName = leadList[0].Referrer_Name__r.Name +'-'+leadList[0].Referrer_Name__r.PersonMobilePhone;
            }
            if(leadList[0].Management_Name__c != null){
                sv.Management_Name__c = leadList[0].Management_Name__c;
                
            }
            /*if(leadList[0].Current_Residence_Configuration__c != '' && leadList[0].Current_Residence_Configuration__c != null)
                sv.Current_Residence_Configuration__c = leadList[0].Current_Residence_Configuration__c;
            if(leadList[0].Configuration_Required__c != '' && leadList[0].Configuration_Required__c != null)
                sv.Configuration_Required__c = leadList[0].Configuration_Required__c;
            if(leadList[0].Budget__c != '' && leadList[0].Budget__c != null)
                sv.Budget__c = leadList[0].Budget__c;
            if(leadList[0].Buying_Purpose__c != '' && leadList[0].Buying_Purpose__c != null)
                sv.Buying_Purpose__c = leadList[0].Buying_Purpose__c;
            if(leadList[0].Possession_Timeframe_Required__c != '' && leadList[0].Possession_Timeframe_Required__c != null)
                sv.Possession_Timeframe_Required__c = leadList[0].Possession_Timeframe_Required__c;*/
            if(leadList[0].OwnerId != null) {
                sv.Presales_Manager__c = leadList[0].OwnerId;
                sv.Sourcing_Manager__c = leadList[0].OwnerId;
            }
        }
    }
    
    public void generateOTP() {
        
        hidesendOtp = true;
        system.debug('Show:::'+show);
        message = '';
        // String Passcode = '3011';
        system.debug('generatedOtp::'+generatedOtp);
        if(mobile != Null && !String.isBlank(mobile)) {
            generatedOtp = String.valueOf((Math.random() * 9000) + 1000).substring(0, 4);
            system.debug('generatedOtp::'+generatedOtp);
            
            try{
                SMS__c sms = new SMS__c();
                sms.Name = 'SMS From '+mobile;
                sms.Sender_Mobile_No__c = mobile;
                //system.debug('mobile:::'+sms.Sender_Mobile_No__c);
                sms.Template_Id__c = '1707168836639080158';
                // system.debug('Template Id'+sms.Template_Id__c);
                sms.Message__c = 'Dear User, For form fill-up, Your One Time Password(OTP) is ' + generatedOtp +' Please do not share this OTP.Regards,NDREAL';
                system.debug('Message::'+sms.Message__c);
                insert sms;
                message = 'OTP sent successfully';
                show = false;
                resend = true;
            } catch(Exception ex){
                system.debug('Error: '+ex.getMessage());
                message = 'Error occured while sending OTP. Please contact system administrator.';
            }
        }
    }
    
    public void verifyOTP() {
        isVerified = false;
        message = '';
        errorMessage = '';
        system.debug('Inside VerifyOtp');
        String MasterOtp = '3011';
        
        if (enterOtp == generatedOtp && !String.isBlank(enterOtp) && enterOtp != null) {
            system.debug('Otp Verify Successfully');
            message = 'OTP Verified Successfully.';
            isVerified = true;
        } else if (enterOtp == masterOtp) {
            system.debug('Master OTP Verified Successfully');
            message = 'Master OTP Verified Successfully.';
            isVerified = true;
        } else{
            system.debug('OTP verification failed');
            message = 'OTP Verification Failed.';
            isVerified = false;
            system.debug('show::::::::'+show);
           // show = true;
        }
    }
    
    public PageReference validateInput() {
        valError = False;
      
        String p = Apexpages.currentPage().getParameters().get('currentTab');
        system.debug('Page: '+p);
        
        if(Integer.valueOf(p) == 0) {
            if(String.isBlank(sv.Mobile__c)) {
                valError = True;
                message = 'Please fill Mobile.';
            }
            if(sv.Mobile__c.Length() != 10) {
                valError = True;
                message = 'Please enter valid mobile number';
            }
            if(String.isBlank(enterotp) && isAccount == false ) {
                valError = True;
                message = 'Please Enter OTP';
                
            }else if(isVerified == false && isAccount == false){
                valError = True;
                message = 'Please Verify Your OTP';
            }     	
            if(String.isBlank(sv.Last_Name__c)) {
                valError = True;
                message = 'Please fill Last Name.';
            }
            if(String.isBlank(sv.First_Name__c)) {
                valError = True;
                message = 'Please fill First Name.';
            }
            if(String.isBlank(sv.Salutation__c)) {
                valError = True;
                message = 'Please fill Salutation.'; 
            }
        }
        
        if(Integer.valueOf(p) == 1) {
            if(String.isBlank(sv.Locality__c)) {
                valError = True;
                message = 'Please Enter Locality.'; 
            }
            if(String.isBlank(sv.City__c)) {
                valError = True;
                message = 'Please Enter City.'; 
            }
        }
        if(Integer.valueOf(p) == 2) {
            if(sv.Other_Occupation__c == 'Others' && String.isBlank(sv.Other_Occupation__c)) {
                valError = True;
                message = 'Please Enter Other Occupation.'; 
            }else if(String.isBlank(sv.Occupation__c)){
                valError = True;
                message = 'Please Enter Occupation.'; 
                
            }else if(String.isBlank(sv.Company_Name__c)){
                valError = True;
                message = 'Please Enter Company Name.'; 
                
            }else if(String.isBlank(sv.Designation__c)){
                valError = True;
                message = 'Please Enter Designation'; 
                
            }
        }
        
        if(Integer.valueOf(p) == 3) {
            if(String.isBlank(sv.Master_Source__c)) {
                valError = True;
                message = 'Please fill where did you hear about us?';
            }else if(sv.Master_Source__c == 'Management Reference') {
               if(String.isBlank(sv.Management_Name__c)) {
                    valError = True;
                    message = 'Please fill Management Name.';
                }
            }
            else if(sv.Master_Source__c == 'Marketing Partner') {
                if(String.isBlank(sv.RERA_Number__c)) {
                    valError = True;
                    message = 'Please fill RERA Number.';
                }
                if(String.isBlank(sv.CP_Mobile__c)) {
                    valError = True;
                    message = 'Please fill CP Mobile.';
                }
                if(String.isBlank(sv.Firm_Name__c)) {
                    valError = True;
                    message = 'Please fill Firm Name.';
                }
                if(String.isBlank(sv.CP_Name__c)) {
                    valError = True;
                    message = 'Please fill Channel Partner Name.';
                } 
            } else if(sv.Master_Source__c == 'Recommended by Friends/Relatives') {
                if(String.isBlank(refName)) {
                    valError = True;
                    message = 'Please fill Customer Referrer Name.';
                } 
            }else if(sv.Master_Source__c == 'Referral and Loyalty Programme'){
                if(String.isBlank(sv.Lead_Source__c)){
                    valError = True;
                    message = 'Please Select Category';
                }if(sv.Lead_Source__c == 'Existing Clients'){
                    if(String.isBlank(sv.Name__c) &&  String.isBlank(sv.Mobile2__c) && String.isBlank(sv.Email2__c) && String.isBlank(sv.Current_Project_Name__c)){
                        valError = True;
                        message = 'Please fill required details';
                    }else if(String.isBlank(sv.Name__c)){
                        valError = True;
                        message = 'Please fill Name';
                    }else if(String.isBlank(sv.Mobile2__c)){
                         valError = True;
                        message = 'Please fill Mobile ';
                    }else if(sv.Mobile2__c.length() != 10){
                         valError = True;
                        message = 'Please fill valid mobile number ';
                    }else if(String.isBlank(sv.Email2__c)){
                        valError = True;
                        message = 'Please fill Email';
                    }else if(String.isBlank(sv.Current_Project_Name__c)){
                         valError = True;
                        message = 'Please fill Current Project ';
                    }
                }
                else if(sv.Lead_Source__c == 'Existing Tenants'){
                    if(String.isBlank(sv.Name__c) && String.isBlank(sv.Email2__c) && String.isBlank(sv.Mobile2__c ) && String.isBlank(sv.Current_Project_Name__c)){
                        valError = True;
                        message = 'Please fill required details';
                    }else if(String.isBlank(sv.Name__c)){
                        valError = True;
                        message = 'Please fill Name';
                    }else if(String.isBlank(sv.Email2__c)){
                        valError = True;
                        message = 'Please fill Email';
                    }else if(String.isBlank(sv.Mobile2__c)){
                         valError = True;
                        message = 'Please fill Mobile ';
                    }else if(sv.Mobile2__c.length() != 10){
                         valError = True;
                        message = 'Please fill valid mobile number ';
                    }else if(String.isBlank(sv.Current_Project_Name__c)){
                         valError = True;
                        message = 'Please fill Current Project ';
                    }
                }
                else if(sv.Lead_Source__c == 'NonSales Staff'){
                    if(String.isBlank(sv.Name__c) && String.isBlank(sv.Mobile2__c ) && String.isBlank(sv.Departments__c)){
                        valError = True;
                        message = 'Please fill required details';
                    }else if(String.isBlank(sv.Name__c)){
                        valError = True;
                        message = 'Please fill Name';
                    }else if(String.isBlank(sv.Mobile2__c)){
                         valError = True;
                        message = 'Please fill Mobile ';
                    }else if(sv.Mobile2__c.length() != 10){
                         valError = True;
                        message = 'Please fill valid mobile number ';
                    }else if(String.isBlank(sv.Departments__c)){
                         valError = True;
                        message = 'Please fill Department ';
                    }
                }
               else if(sv.Lead_Source__c == 'Sales Staff'){
                   if(String.isBlank(sv.Name__c) && String.isBlank(sv.Email2__c) && String.isBlank(sv.Mobile2__c ) && String.isBlank(sv.Departments__c)){
                        valError = True;
                        message = 'Please fill required details';
                    }else if(String.isBlank(sv.Name__c)){
                        valError = True;
                        message = 'Please fill Name';
                    }else if(String.isBlank(sv.Mobile2__c)){
                         valError = True;
                        message = 'Please fill Mobile ';
                    }else if(sv.Mobile2__c.length() != 10){
                         valError = True;
                        message = 'Please fill valid mobile number ';
                    }else if(String.isBlank(sv.Location__c)){
                         valError = True;
                        message = 'Please Select Location ';
                    }
                }else if(sv.Lead_Source__c == 'Vendor Reference'){
                    if(String.isBlank(sv.Name__c) && String.isBlank(sv.Email2__c) && String.isBlank(sv.Mobile2__c) && String.isBlank(sv.Departments__c) && String.isBlank(sv.Vendor_Company__c) && String.isBlank(sv.Staff_Name__c)){
                        valError = True;
                        message = 'Please fill required details';
                    }else if(String.isBlank(sv.Name__c)){
                        valError = True;
                        message = 'Please fill Vendor Name';
                    }else if(String.isBlank(sv.Mobile2__c)){
                         valError = True;
                        message = 'Please fill Mobile ';
                    }else if(sv.Mobile2__c.length() != 10){
                         valError = True;
                        message = 'Please fill valid mobile number ';
                    }else if(String.isBlank(sv.Email2__c)){
                         valError = True;
                        message = 'Please fill Email ';
                    }else if(String.isBlank(sv.Vendor_Company__c)){
                        valError = True;
                        message = 'Please fill Vendor Company ';
                    }else if(String.isBlank(sv.Staff_Name__c)){
                        valError = True;
                        message = 'Please fill Staff Name ';
                    }else if(String.isBlank(sv.Departments__c)){
                        valError = True;
                        message = 'Please fill Department ';
                    }
                }
            }
        }
        
        if(Integer.valueOf(p) == 4) {
            if(String.isBlank(sv.Budget__c)) {
                valError = True;
                message = 'Please state the budget for purchasing a house?';
            }
            if(String.isBlank(sv.Configuration_Required__c)) {
                valError = True;
                message = 'Please state the configuration you are interested in ?';
            }
        }
        return null;
    }
    
    public void submit() {
        Account cpAccount = new Account();
        isAccountFound = false;
        isLeadFound = false;
        isOppFound = false;
        
        if(!isSourceNotEditable && sv.Master_Source__c.equalsIgnoreCase('Marketing Partner')) {
            cpAccount = getCPAccount(sv.CP_Name__c, sv.CP_Mobile__c, sv.Firm_Name__c, sv.CP_Unique_Code__c, sv.RERA_Number__c, pList[0].Default_Owner_For_CP__c);
            if(cpAccount != null)
                sv.Channel_Partner__c = cpAccount.Id;
        }
        
        if(String.isNotBlank(refName) && refName != '') {
            List<Account> refList = new List<Account>();
            String[] tokens = refName.split('-');
            Integer tokenCount = tokens.size();
            for (Integer j = 0; j < tokenCount; j++) {
                System.debug('tokens-'+j+': '+tokens[j]);
            }
            refList = [Select Id, Name, PersonMobilePhone, OwnerId from Account where IsPersonAccount = true AND Name =: tokens[0] AND PersonMobilePhone =: tokens[1]];
            system.debug('refList: '+refList);
            
            if(!refList.isEmpty() && refList != null) {
                sv.Referrer_Name__c = refList[0].Id;
            }
        }
        
        if(mobile != Null && !String.isBlank(mobile)) {
            accList1 = [Select Id, Salutation, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, 
                        House_No__c, Building__c, BillingStreet, Locality__c, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                        Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c,Current_Residence_Configuration__c ,  Martial_Status__c, Age__c, Gender__c
                        from Account
                        where (PersonMobilePhone =: mobile OR Phone =: mobile) AND IsPersonAccount = true];
            system.debug('accList1: '+accList1);
            
            if(!accList1.isEmpty()) {
                isAccountFound = true;
                
                oppList1 = [Select Id, Name, Project__c, Last_SV_Date__c, Site_Visit_Count__c, Presales_Manager__c,Is_SourceChanged__c,
                            Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, OwnerId,Last_SV_attended_by__c,Last_Source_Changed_By__c,
                            Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                            Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c, Management_Name__c,
                            Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name, Project_Type__c, Source_of_Finance_Source_of_Finance__c,
                            Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c ,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c,Mobile2__c, Departments__c, Locations__c ,Comments__c
                            from Opportunity__c
                            where Account__c =: accList1[0].Id AND Project__c =: pList[0].Id AND Is_Active__c = true];
                system.debug('oppList1: '+oppList1);
                
                if(!oppList1.isEmpty()) {
                    isOppFound = true;
                }
            } else {
                if(email != Null && !String.isBlank(email)) {
                    accList1 = [Select Id, Salutation, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, 
                                House_No__c, Building__c, BillingStreet, Locality__c, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                                Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c,Current_Residence_Configuration__c, Martial_Status__c, Age__c, Gender__c
                                from Account
                                where (PersonEmail =: email OR Alternate_Email__c =: email) AND IsPersonAccount = true];
                    system.debug('accList1: '+accList1);
                    
                    if(!accList1.isEmpty()) {
                        isAccountFound = true;
                        
                        oppList1 = [Select Id, Name, Project__c, Last_SV_Date__c, Site_Visit_Count__c, Presales_Manager__c,Is_SourceChanged__c,Management_Name__c,
                                    Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, OwnerId,Last_Source_Changed_By__c,
                                    Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                                    Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c, Last_SV_attended_by__c,
                                    Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name, Project_Type__c, Source_of_Finance_Source_of_Finance__c,
                                    Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c ,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c, Mobile2__c, Departments__c, Locations__c ,Comments__c
                                    from Opportunity__c
                                    where Account__c =: accList1[0].Id AND Project__c =: pList[0].Id AND Is_Active__c = true];
                        system.debug('oppList1: '+oppList1);
                        
                        if(!oppList1.isEmpty()) {
                            isOppFound = true;
                        }
                    }
                }
            }
            
            if(oppList1.isEmpty()) {
                leadList1 = [Select Id, Name, Salutation__c, Campaign_Code__c,First_Name__c, Last_Name__c, Mobile__c, Phone__c, Email__c, Alternate_Email_Id__c, Project__c, Campaign_Custom__c,
                             House_No__c, Building__c, Street__c, Locality__c, City__c, State__c, Country__c, PostalCode__c,Age__c,Gender__c,Management_Name__c,
                             Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c,Martial_Status__c,Actual_Budget_in_Lakhs__c,
                             Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, Stage__c, Sub_Stage__c, Substage_Reason__c, OwnerId,
                             Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                             Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c, Presales_Call_Count__c, Presale_Date_of_Visit__c,Presale_Next_Follow_up_Date__c,Last_Presales_Call_Status__c, Presales_Comment_History__c,
                             Last_Presale_Call_Date__c,UTM_Medium__c,UTM_Source__c, Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name, Last_Presale_Call_Comment__c,
                             Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c ,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c, Mobile2__c, Departments__c, Locations__c,Comments__c
                             from Lead__c
                             where (Mobile__c =: mobile OR Phone__c =: mobile) AND Project__c =: pList[0].Id AND IsConverted__c = false];
                system.debug('leadList1: '+leadList1);
                
                if(!leadList1.isEmpty()) {
                    isLeadFound = true;
                } else {
                    if(email != Null && !String.isBlank(email)) {
                        leadList1 = [Select Id, Name, Salutation__c, Campaign_Code__c,First_Name__c, Last_Name__c, Mobile__c, Phone__c, Email__c, Alternate_Email_Id__c, Project__c, Campaign_Custom__c,
                                     House_No__c, Building__c, Street__c, Locality__c, City__c, State__c, Country__c, PostalCode__c,Age__c,Gender__c,Management_Name__c,
                                     Designation__c, Occupation__c, Other_Occupation__c, Company_Name__c,Martial_Status__c,Actual_Budget_in_Lakhs__c,
                                     Master_Source__c, Lead_Source__c, Sub_Source__c, Sub_Source_Details__c, Stage__c, Sub_Stage__c, Substage_Reason__c, OwnerId,
                                     Channel_Partner__c, Channel_Partner__r.Name, Channel_Partner__r.Mobile__c, Channel_Partner__r.CP_Code__c,
                                     Channel_Partner__r.Firm_Name__c, Channel_Partner__r.MahaRERA_Registration_No__c, Presales_Call_Count__c, Presale_Date_of_Visit__c,Presale_Next_Follow_up_Date__c,Last_Presales_Call_Status__c, Presales_Comment_History__c,
                                     Last_Presale_Call_Date__c,UTM_Medium__c,UTM_Source__c, Referrer_Name__c, Referrer_Name__r.PersonMobilePhone, Referrer_Name__r.Name, Last_Presale_Call_Comment__c,
                                     Current_Residence_Configuration__c, Configuration_Required__c, Budget__c, Buying_Purpose__c, Possession_Timeframe_Required__c ,Vendor_Company__c, Name__c, Staff_Name__c, Current_Project_Name__c, Email2__c,Mobile2__c, Departments__c, Locations__c ,Comments__c
                                     from Lead__c
                                     where (Email__c =: email OR Alternate_Email_Id__c =: email) AND Project__c =: pList[0].Id AND IsConverted__c = false];
                        system.debug('leadList1: '+leadList1);
                        
                        if(!leadList1.isEmpty()) {
                            isLeadFound = true;
                        }
                    }
                }
            }
        }
        
        if(isAccountFound) {
            if(isOppFound && !isLeadFound) {
                try {
                    //Create Site Visit
                    sv.Opportunity__c = oppList1[0].Id;
                    //sv.Opportunity__r.Last_sv_attended_By__c = UserInfo.getUserId();
                    sv.Site_Visit_Date__c = system.now();
                    
                    if(oppList1[0].Site_Visit_Count__c == Null || oppList1[0].Site_Visit_Count__c == 0) {
                        sv.Site_Visit_Count__c = 1;
                        if(oppList1[0].Master_Source__c != sv.Master_Source__c) {
                            sv.Is_Source_Conflict__c = 'Yes';
                        }
                    } else {
                        sv.Site_Visit_Count__c = oppList1[0].Site_Visit_Count__c + 1;
                    }
                    insert sv;
                    
                    //Update Opportunity
                    oppList1[0].Site_Visit_Count__c = oppList1[0].Site_Visit_Count__c + 1;
                    oppList1[0].Last_SV_Date__c = system.now();
                    
                    if (isSourceNotEditable == false) {
                        oppList1[0].Last_Source_Changed_By__c = System.today();
                        
                        if (isSourceNotEditable == false && oppList1[0].Master_Source__c != sv.Master_Source__c || oppList1[0].Channel_Partner__c != sv.Channel_Partner__c || oppList1[0].Referrer_Name__c != sv.Referrer_Name__c ) {
                            oppList1[0].Is_SourceChanged__c = true;
                        } else {
                            oppList1[0].Is_SourceChanged__c = false;
                        }
                    }
                    
                    
                    system.debug('Is_SourceChanged__c'+oppList1[0].Is_SourceChanged__c);
                    system.debug('Last_Source_Changed_By__c'+oppList1[0].Last_Source_Changed_By__c);

                    // system.debug('svOwnerId'+sv.OwnerId);
                    // oppList1[0].Last_sv_attended_By__c = sv.OwnerId;
                    // system.debug('OwnerIdSV:::'+oppList1[0].Last_sv_attended_By__c );
                    update oppList1[0];
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    message = 'Your token number for this visit '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                } catch(Exception ex) {
                    system.debug('Error: '+ex);
                    isRunError = true;
                    message = 'Error ' +ex.getMessage(); 
                }
            } else if(!isOppFound && isLeadFound) {
                try {
                    //Update Lead
                    leadList1[0].Salutation__c = sv.Salutation__c;
                    leadList1[0].First_Name__c = sv.First_Name__c;
                    leadList1[0].Last_Name__c = sv.Last_Name__c;
                    leadList1[0].Stage__c = 'Visit Done';
                    update leadList1[0];
                    
                    //Convert Lead & Tag to Existing Account
                    List<Lead__c> lList = new List<Lead__c>();
                    lList.add(leadList1[0]);
                    LeadConversionServices.convertLead(lList);
                    
                    Lead__c convertedLead = [Select /*ConvertedAccountId__c, ConvertedOpportunityId__c*/Account__c,Opportunity__c from Lead__c where Id =: leadList1[0].Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp =  [SELECT Id, Name, Site_Visit_Count__c,Last_SV_attended_by__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Opportunity
                    sv.Opportunity__c = convertedLead.Opportunity__c;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    insert sv;
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    if(flagQR == 'true') {
                        lstSV[0].ownerId = pList[0].Site_Visit_QR_Assignment__c;
                        system.debug('SV ownerId: '+ lstSV[0].ownerId);
                        
                        update lstSV[0];
                    }
                    isSuccess = true;
                    message = 'Your token number for this visit '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                } catch(Exception ex) {
                    system.debug('Error: '+ex);
                    isRunError = true;
                    message = 'Error ' +ex.getMessage();  
                }
            } else if(!isOppFound && !isLeadFound) {
                Lead__c l = new Lead__c();
                l.Salutation__c = sv.Salutation__c;
                l.First_Name__c = sv.First_Name__c;
                l.Last_Name__c = sv.Last_Name__c;
                l.Mobile__c = sv.Mobile__c;
                l.Email__c = sv.Email__c;
                l.Project__c = pList[0].Id;
                l.House_No__c = sv.House_No__c;
                l.Building__c = sv.Building__c;
                l.Street__c = sv.Street_1__c;
                l.Locality__c = sv.Locality__c;
                l.City__c = sv.City__c;
                l.State__c = sv.State__c;
                l.Country__c = sv.Country__c;
                l.PostalCode__c = sv.Pincode__c;
                l.Occupation__c = sv.Occupation__c;
                l.Other_Occupation__c = sv.Other_Occupation__c;
                l.Designation__c = sv.Designation__c;
                l.Company_Name__c = sv.Company_Name__c;
                l.Master_Source__c = sv.Master_Source__c; 
                if(sv.Master_Source__c == 'Recommended by Friends/Relatives')
                    l.Referrer_Name__c = sv.Referrer_Name__c;
                else if(sv.Master_Source__c == 'Marketing Partner')
                    l.Channel_Partner__c = sv.Channel_Partner__c;
                else if(sv.Master_Source__c == 'Management Reference')
                    l.Management_Name__c = sv.Management_Name__c;
                else if(sv.Master_Source__c == 'Referral and Loyalty Programme')
                    l.Lead_Source__c = sv.Lead_Source__c;
                if(sv.Lead_Source__c == 'NonSales Staff'){
                     l.Name__c = sv.Name__c;
					 l.Mobile2__c = sv.Mobile2__c;
                     l.Departments__c = sv.Departments__c;
                }else if(sv.Lead_Source__c == 'Sales Staff'){
                    l.Name__c = sv.Name__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Locations__c = sv.Location__c;
                }else if(sv.Lead_Source__c == 'Vendor Reference'){
                    l.Name__c = sv.Name__c;
                    l.Vendor_Company__c = sv.Vendor_Company__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Email2__c = sv.Email2__c;
                    l.Staff_Name__c = sv.Staff_Name__c;
                    l.Departments__c = sv.Departments__c;
                }else if(sv.Lead_Source__c == 'Existing Clients'){
                    l.Name__c = sv.Name__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Email2__c = sv.Email2__c;
                    l.Current_Project_Name__c = sv.Current_Project_Name__c;
                }else if(sv.Lead_Source__c == 'Existing Tenants'){
                    l.Name__c = sv.Name__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Email2__c = sv.Email2__c;
                    l.Current_Project_Name__c = sv.Current_Project_Name__c;
                }
                if(sv.Comments__c != null && sv.Comments__c != '')
                    l.Comments__c = sv.Comments__c;
                l.Current_Residence_Configuration__c = sv.Current_Residence_Configuration__c;
                l.Configuration_Required__c = sv.Configuration_Required__c;
                l.Budget__c = sv.Budget__c;
                l.Buying_Purpose__c = sv.Buying_Purpose__c;
                l.Possession_Timeframe_Required__c = sv.Possession_Timeframe_Required__c;
                l.Stage__c = 'Visit Done';
                l.OwnerId = UserInfo.getUserId();
                
                try {
                    insert l;
                    if(flagQR == 'true') {
                        l.OwnerId = pList[0].Site_Visit_QR_Assignment__c;
                        update l;
                    }
                    
                    
                    //Convert Lead & Tag to Existing Account
                    List<Lead__c> lList = new List<Lead__c>();
                    lList.add(l);
                    LeadConversionServices.convertLead(lList);
                    
                    Lead__c convertedLead = [Select /*ConvertedAccountId__c, ConvertedOpportunityId__c*/ Account__c,Opportunity__c from Lead__c where Id = :l.Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp = [Select Id, Name, Site_Visit_Count__c,Last_SV_attended_by__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Converted Opportunity
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    insert sv;
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    // system.debug('svOwner'+sv.OwnerId);
                    // convertedOpp.Last_SV_attended_by__c = sv.OwnerId;
                    // system.debug('OwnerId::'+convertedOpp.Last_SV_attended_by__c);
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name, OwnerId from Site_Visit__c where Id =: sv.Id];
                    if(flagQR == 'true') {
                        lstSV[0].ownerId = pList[0].Site_Visit_QR_Assignment__c;
                        system.debug('SV ownerId: '+ lstSV[0].ownerId);
                        update lstSV[0];
                    }
                    isSuccess = true;
                    message = 'Your token number for this visit '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                } catch(Exception ex) {
                    system.debug('Exception: '+ex);
                    isRunError = true;
                    message = 'Error ' +ex.getMessage();    
                }
            }
        } else {
            if(isLeadFound) {
                try {
                    //Update Lead
                    leadList1[0].Stage__c = 'Visit Done';
                    update leadList1[0];
                    
                    //Convert Lead
                    List<Lead__c> lList = new List<Lead__c>();
                    lList.add(leadList1[0]);
                    LeadConversionServices.convertLead(lList);
                    
                    Lead__c convertedLead = [Select /*ConvertedAccountId__c, ConvertedOpportunityId__c*/Account__c,Opportunity__c from Lead__c where Id =: leadList1[0].Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp =  [SELECT Id, Name, Site_Visit_Count__c, Master_Source__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Opportunity
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    //sv.Opportunity__r.Last_sv_attended_By__c = UserInfo.getUserId();
                    insert sv;
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name,ownerId from Site_Visit__c where Id =: sv.Id];
                    if(flagQR == 'true') {
                        lstSV[0].ownerId = pList[0].Site_Visit_QR_Assignment__c;
                        system.debug('SV ownerId: '+ lstSV[0].ownerId);
                        update lstSV[0];
                    }
                    isSuccess = true;
                    message = 'Your token number for this visit '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                } catch(Exception ex) {
                    system.debug('Error: '+ex);
                    isRunError = true;
                    message = 'Error ' +ex.getMessage();    
                }
            } else {
                Lead__c l = new Lead__c();
                l.Salutation__c = sv.Salutation__c;
                l.First_Name__c = sv.First_Name__c;
                l.Last_Name__c = sv.Last_Name__c;
                l.Mobile__c = sv.Mobile__c;
                l.Email__c = sv.Email__c;
                l.Project__c = pList[0].Id;
                l.House_No__c = sv.House_No__c;
                l.Building__c = sv.Building__c;
                l.Street__c = sv.Street_1__c;
                l.Locality__c = sv.Locality__c;
                l.City__c = sv.City__c;
                l.State__c = sv.State__c;
                l.Country__c = sv.Country__c;
                l.PostalCode__c = sv.Pincode__c;
                l.Occupation__c = sv.Occupation__c;
                l.Other_Occupation__c = sv.Other_Occupation__c;
                l.Designation__c = sv.Designation__c;
                l.Company_Name__c = sv.Company_Name__c;
                l.Master_Source__c = sv.Master_Source__c;
                if(sv.Master_Source__c == 'Recommended by Friends/Relatives')
                    l.Referrer_Name__c = sv.Referrer_Name__c;
                else if(sv.Master_Source__c == 'Marketing Partner')
                    l.Channel_Partner__c = sv.Channel_Partner__c;
                else if(sv.Master_Source__c == 'Management Reference')
                    l.Management_Name__c = sv.Management_Name__c;
                 else if(sv.Master_Source__c == 'Referral and Loyalty Programme')
                    l.Lead_Source__c = sv.Lead_Source__c;
                if(sv.Lead_Source__c == 'NonSales Staff'){
                     l.Name__c = sv.Name__c;
					 l.Mobile2__c = sv.Mobile2__c;
                     l.Departments__c = sv.Departments__c;
                }else if(sv.Lead_Source__c == 'Sales Staff'){
                    l.Name__c = sv.Name__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Locations__c = sv.Location__c;
                }else if(sv.Lead_Source__c == 'Vendor Reference'){
                    l.Name__c = sv.Name__c;
                    l.Vendor_Company__c = sv.Vendor_Company__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Email2__c = sv.Email2__c;
                    l.Staff_Name__c = sv.Staff_Name__c;
                    l.Departments__c = sv.Departments__c;
                }else if(sv.Lead_Source__c == 'Existing Clients'){
                    l.Name__c = sv.Name__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Email2__c = sv.Email2__c;
                    l.Current_Project_Name__c = sv.Current_Project_Name__c;
                }else if(sv.Lead_Source__c == 'Existing Tenants'){
                    l.Name__c = sv.Name__c;
                    l.Mobile2__c = sv.Mobile2__c;
                    l.Email2__c = sv.Email2__c;
                    l.Current_Project_Name__c = sv.Current_Project_Name__c;
                }
                l.Current_Residence_Configuration__c = sv.Current_Residence_Configuration__c;
                l.Configuration_Required__c = sv.Configuration_Required__c;
                l.Budget__c = sv.Budget__c;
                l.Buying_Purpose__c = sv.Buying_Purpose__c;
                l.Possession_Timeframe_Required__c = sv.Possession_Timeframe_Required__c;
                l.Stage__c = 'Visit Done';
                l.OwnerId = UserInfo.getUserId();
                system.debug('UserInfo'+l.OwnerId );
                
                try {
                    insert l;
                    if(flagQR == 'true') {
                        l.OwnerId = pList[0].Site_Visit_QR_Assignment__c;
                        update l;
                    }
                    //Convert Lead & Tag to Existing Account
                    List<Lead__c> lList = new List<Lead__c>();
                    lList.add(l);
                    LeadConversionServices.convertLead(lList);
                    
                    Lead__c convertedLead = [Select /*ConvertedAccountId__c, ConvertedOpportunityId__c*/Account__c,Opportunity__c from Lead__c where Id = :l.Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp = [SELECT Id, Name, Site_Visit_Count__c,Last_SV_attended_by__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Converted Opportunity
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    insert sv;
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    if(flagQR == 'true') {
                        lstSV[0].ownerId = pList[0].Site_Visit_QR_Assignment__c;
                        system.debug('SV ownerId: '+ lstSV[0].ownerId);
                        update lstSV[0];
                    }
                    isSuccess = true;
                    message = 'Your token number for this visit '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                } catch(Exception ex) {
                    system.debug('Exception: '+ex);
                    isRunError = true;
                    message = 'Error ' +ex.getMessage();    
                }
            }
        }
    }
    
    @RemoteAction
    public static List<String> getReferrerName(String refName) {
        List<String> refNameList = new List<String>();
        List<Account> refList = new List<Account>();
        String QueryString =  'Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone from Account where IsPersonAccount = true AND (FirstName LIKE \'' + refName + '%\' OR LastName LIKE \'' + refName + '%\' OR PersonMobilePhone LIKE \'' + refName + '%\' OR Phone LIKE \'' + refName + '%\')';
        refList = Database.query(QueryString);
        system.debug('refList: '+refList);
        
        if(!refList.isEmpty() && refList != null){
            for(Account a : refList){
                refNameList.add(a.Name+'-'+a.PersonMobilePhone);
            }
        }
        return refNameList;
    }
    
    public Account getCPAccount(String cpName, String cpMobile, String firmName, String CPCode, String RERANumber, Id ownerId) {
        Id cpRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Marketing Partner Account').getRecordTypeId();
        system.debug('cpRecordTypeId: '+cpRecordTypeId);
        List<Account> cpList = new List<Account>();
        
        if(String.isNotBlank(CPCode)) {
            cpList = [Select Id, Name, CP_Code__c, MahaRERA_Registration_No__c from Account where CP_Code__c =: CPCode AND RecordTypeId =: cpRecordTypeId];
            system.debug('cpList: '+cpList);
        }
        if(cpList.isEmpty() && String.isNotBlank(RERANumber)) {
            cpList = [Select Id, Name, CP_Code__c, MahaRERA_Registration_No__c from Account where MahaRERA_Registration_No__c =: RERANumber AND RecordTypeId =: cpRecordTypeId];
            system.debug('cpList: '+cpList);
        }
        
        if(!cpList.isEmpty() && cpList != null) {
            return cpList[0];
        } else {
            Account a = new Account();
            a.OwnerId = ownerId;
            a.RecordTypeId = cpRecordTypeId;
            a.Name = cpName;
            a.Mobile__c = cpMobile;
            a.Firm_Name__c = firmName;
            a.MahaRERA_Registration_No__c = RERANumber;
            insert a;
            return a;
        }
    } 
   

    
    public Pagereference closeForm() {
        Pagereference pg = new Pagereference('/'+sv.id);
        pg.setredirect(true);
        return pg;
    }
}