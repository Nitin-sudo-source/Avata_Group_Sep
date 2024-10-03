public class Ex_PrintBookingPDF {
    public string bId{get;set;}
    public Booking__c bk{get;set;}
    public List<Booking__c> bkList {get;set;}
    public List<applicant__c> apList {get;set;}
    public List<Receipt__c> rtList{get;set;}
    public List<Car_Park__c> carList{get;set;}
    
    public String amountInWords {get;set;}
    public decimal countOfIds {get;set;}
    public string stringCar {get;set;}
    
    public List<ApplicantWrapper> ApplicantWrapperlist {get;set;}
    public decimal apserialno{get;set;}
    public string typeofap{get;set;}
    public string numberofap{get;set;}
    public string apTitle{get;set;}
    public string apPan {get;set;}
    public string apMobile {get;set;}
    public string apEmail {get;set;}
    public string firstapname{get;set;}
    public string firstapgender{get;set;}
    public Date firstapdob{get;set;}
    public Date firstapanivd{get;set;}
    public string firstapoccupation{get;set;}
    public string commAddress{get;set;}
    public string commstate{get;set;} 
    public string commCountry{get;set;}
    public string commCity{get;set;}
    public string commPIN{get;set;}
    public string permAddress{get;set;} 
    public string permstate{get;set;}
    public string permCountry{get;set;}
    public string permCity{get;set;}
    public string permPIN{get;set;}
    
    public Ex_PrintBookingPDF(){
        
        bId=ApexPages.currentPage().getParameters().get('bId');
        bk=new Booking__c();
        bkList = new List<Booking__c>();
        carList = new List<Car_Park__c>();
        apList=new List<Applicant__C>();
        rtList = new List<Receipt__c>();
        
        
        ApplicantWrapperlist = new List<ApplicantWrapper>();
        apserialno = 0;
        typeofap = '';
        numberofap ='';
        apTitle = '';
        apPan = '';
        apMobile = '';
        apEmail = '';
        firstapname ='';
        firstapgender='';
        firstapoccupation='';
        permAddress = '';
        commAddress = '';
        commstate = '';
        commCountry = '';
        commCity = '';
        commPIN = '';
        permstate = '';
        permCountry = '';
        permCity = '';
        permPIN = '';
        
        amountInWords='';
        countOfIds = 0;
        stringCar = '';
        
        
        if(bId!=null){
            bkList =[select Id,Name,Quotation__c,Mode_of_Funding__c,Source__c,Project__r.Name,Quotation__r.CreatedDate,Quotation__r.Name,Opportunity__r.Name,Project__r.Project_Logo__c,
                     Tower__r.RERA_No__c,Booking_Date__c,Tower__r.Name,Tower__r.Terms_and_Conditions__c,
                     Unit__r.Name,Unit__r.Floor__c,Unit__c,Unit__r.Configuration_Type__c,Agreement_Value__c,Channel_Partner__c,Channel_Partner__r.Name,Channel_Partner__r.Phone,
                     Channel_Partner__r.Email__c,Channel_Partner__r.MahaRERA_Registration_No__c,Referrer_Name__c, /*Referrer_Name__r.Name,*/ 
                     Remarks__c,
                     Unit__r.Total_Carpet_Sq_Ft__c,Unit__r.RERA_Carpet_Area_Sq_Ft__c,Unit__r.Saleable_Area__c,Quotation__r.Project__r.Project_Logo__c
                     from Booking__c where Id =:bId];
            system.debug('bkList::'+bkList);
            
            if(bkList[0].Agreement_Value__c != null){
                amountInWords = Ex_NumberToWord.convertNumbertoWords(Integer.valueOf(bkList[0].Agreement_Value__c));
            }
            
            carList = [Select Id,Booking__c from Car_Park__c Where Booking__c=:bId];
            system.debug('carList is::'+carList);
            if(!carList.isEmpty() && carList != null){
                countOfIds = carList.size();
            }
            if(countOfIds != null){
                stringCar = Ex_NumberToWord.convertNumbertoWords(Integer.valueOf(countOfIds));
            }
            
            rtList = [Select Id,Name, Receipt_Date__c, Transaction_ID__c from Receipt__c where Booking__c =:bkList[0].Id ORDER BY Receipt_Date__c,CreatedDate ASC];
            system.debug('rtList::'+rtList);
            
            apList =[select id,Name,Type_of_Applicant__c,Applicant_Number__c,DOB__c,Anniversary_Date__c,Occupation__c,Company_Name__c,
                     Permanent_Address__c,Country__c,State__c,City__c,Mobile__c, Email__c,
                     Aadhar_Number__c,PAN_Number__c,PIN__c,Applicant_Title__c
                     from Applicant__c 
                     where Booking__c =:bId ORDER BY Applicant_Number__c ASC];
            system.debug('apList::'+apList); 
            
            if(apList!=null){
                for(Applicant__c ap:apList){
                    apTitle = ap.Applicant_Title__c;
                    apMobile = ap.Mobile__c;
                    apPan = ap.PAN_Number__c;
                    apEmail = ap.Email__c;
                    numberofap = ap.Applicant_Number__c	;
                    firstapname = ap.Name;
                    //firstapgender =ap.Gender__c;
                    firstapdob =ap.DOB__c;
                    firstapanivd =ap.Anniversary_Date__c;
                    firstapoccupation =ap.Occupation__c;
                    // commAddress = ap.Corresponding_Street_Address__c;
                    commstate = ap.State__c;
                    commCountry = ap.Country__c;
                    commCity = ap.City__c;
                    commPIN = ap.PIN__c;
                    permAddress = ap.Permanent_Address__c;
                    permstate = ap.State__c;
                    permCountry = ap.Country__c;
                    permCity = ap.City__c;
                    // permPIN = ap.Permanent_Pin_Code__c;
                    
                    if(numberofap!=null || apTitle != null || firstapname!=null || firstapgender!=null || firstapdob!=null || firstapanivd!=null || firstapoccupation!=null || apMobile != null || apPan != null || apEmail != null || commAddress != null || permAddress != null || commstate != null || commCountry != null || commCity != null || commPIN != null || permstate != null || permCountry != null || permCity != null || permPIN != null){
                        apserialno++;
                        ApplicantWrapperList.add(new ApplicantWrapper(apTitle,numberofap,firstapname,firstapgender,firstapdob,firstapanivd,firstapoccupation,apMobile,apPan,apEmail,commAddress,commstate,commCountry,commCity,commPIN,permAddress,permstate,permCountry,permCity,permPIN));
                        
                    }
                }
            }
        }
    }
    
    
    public class ApplicantWrapper{
        public String apTitle {get;set;}
        public String applicantnumber{get;set;}
        public String applicantname {get;set;}
        public String applicantgender {get;set;}
        public date applicantdob{get;set;}
        public date applicantanivserD {get;set;}
        public String applicantoccupation {get;set;}
        public String applicantMobile {get;set;}
        public String applicantPAN {get;set;}
        public String applicantEmail {get;set;}
        public string commAddress{get;set;} 
        public string commstate{get;set;}
        public string commCountry{get;set;}
        public string commCity{get;set;}
        public string commPIN{get;set;}
        public string permAddress{get;set;}
        public string permstate{get;set;}
        public string permCountry{get;set;}
        public string permCity{get;set;}
        public string permPIN{get;set;}  
        
        public ApplicantWrapper(String apTitle,String applicantnumber,String applicantname,String applicantgender,date applicantdob, date applicantanivserD,
                                string applicantoccupation,string applicantMobile,string applicantPAN,string applicantEmail,string commAddress,string commstate,
                                string commCountry, string commCity, string commPIN, string permAddress,string permstate, string permCountry,string permCity,string permPIN){
                                    this.apTitle = apTitle;
                                    this.applicantnumber = applicantnumber;
                                    this.applicantname = applicantname;
                                    this.applicantgender = applicantgender;
                                    this.applicantdob = applicantdob;
                                    this.applicantanivserD = applicantanivserD;
                                    this.applicantoccupation = applicantoccupation;
                                    this.applicantMobile = applicantMobile;
                                    this.applicantPAN = applicantPAN;
                                    this.applicantEmail = applicantEmail; 
                                    this.commAddress = commAddress;
                                    this.commstate = commstate;
                                    this.commCountry = commCountry;
                                    this.commCity = commCity;
                                    this.commPIN = commPIN;
                                    this.permAddress = permAddress;
                                    this.permstate = permstate;
                                    this.permCountry = permCountry;
                                    this.permCity = permCity;
                                    this.permPIN = permPIN;
                                }
    }
    
}