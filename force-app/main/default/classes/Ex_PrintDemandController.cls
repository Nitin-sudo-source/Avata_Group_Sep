//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 15-11-2023
//-------------------------------------------//

public class Ex_PrintDemandController {
    
    public Id dId {get;set;}
    public List<Demand__c> demandList {get;set;}
    public String CustomerPrimaryName {get; set;} 
    public String CustomerPrimaryTitle {get; set;} 
    public String CustomerMailingAddress {get; set;} 
    public String CustomerMobilePhone {get; set;}  
    public String CustomerEmail {get; set;}
    public String UnitName {get; set;}
    public String totalApportionedAmt {get;set;}
    public String amountInWords {get;set;}
    public String towerName {get;set;}
    public decimal TotalAmount{get;set;}
    public decimal totalDuetax{get;set;} 
    public decimal totalDue{get;set;} 
    public String CustomerAddress {get;set;}
    public Decimal TotalOutstanding {get;set;}
    public Decimal TotalOutstandinggst {get;set;}
    public String projectAddress {get;set;}
    public String surveyNumber {get;set;}
    public List<Applicant__c> apList {get;set;}
    public String getCityStatePin {get;set;}
    public Decimal getTotalper {get;set;}

    public Ex_PrintDemandController() {
        demandList = new List<Demand__c>();
        apList = new List<Applicant__c>();
        TotalAmount=0 ;
        amountInWords='';
        getCityStatePin = '';
        getTotalper = 0;
        
        dId = ApexPages.currentPage().getParameters().get('dId');
        system.debug('dId: '+dId);
        
        if(dId != null) {
            demandList = [Select Id, Name,Booking__r.Primary_Applicant_Name__c,Booking__r.Primary_Applicant_Mobile__c,
                          Booking__r.Primary_Applicant_Email__c,Invoice_Date__c,Booking__r.Unit__r.Name,Booking__r.Unit__r.Floor__c,
                          Booking__r.Unit__r.Tower__r.Name,Booking__r.Project__r.Name,Booking__r.Agreement_Value__c,Total_Amount_Paid__c,
                          Booking__r.Account_Name_Flat_Cost__c,Booking__r.Bank_Name_Flat_Cost__c,Booking__r.Account_Number_Flat_Cost__c,
                          Booking__r.IFSC_Code_Flat_Cost__c,Booking__r.Account_Name_Tax__c,Booking__r.IFSC_Code_Tax__c,Milestone_Name__c,
                          Booking__r.Account_Number_Tax__c,Booking__r.Bank_Name_Tax__c,Booking__r.Agreement_Value_Tax__c,
                          Total_Amount_Demanded__c,Total_Tax_Demanded__c,Total_Tax_Paid__c, Booking__r.Applicant_Address__c,
                          Total_Tax_Remaining__c,Booking__r.Project__r.Project_Address__c,Booking__r.Primary_Applicant_Title__c,Booking__r.Total_Amount_Paid__c,Booking__r.Total_Tax_Demanded__c,Booking__r.Total_Tax_On_Interest_Amount__c,
                          Booking__r.Tower__r.Survey_No__c,Total_Interest_Amount__c,Booking__r.Total_Amount_Received__c,Total_Tax_On_Interest_Amount__c,Booking__r.Total_Amount_Demanded__c,Booking__r.Total_Interest_Amount__c,Booking__r.Total_Tax_Paid__c,Booking__r.Total_Tax_Remaining__c

                          from Demand__c where Id =: dId];
            system.debug('demandList: '+demandList);
            
            if(!demandList.isEmpty() && demandList != null) {
                CustomerPrimaryName = demandList[0].Booking__r.Primary_Applicant_Name__c;
                CustomerPrimaryTitle = demandList[0].Booking__r.Primary_Applicant_Title__c;
                CustomerMobilePhone = demandList[0].Booking__r.Primary_Applicant_Mobile__c;
                CustomerAddress = demandList[0].Booking__r.Applicant_Address__c;
                UnitName = demandList[0].Booking__r.Unit__r.Name;
                towerName = demandList[0].Booking__r.Unit__r.Tower__r.Name;
                projectAddress = demandList[0].Booking__r.Project__r.Project_Address__c;
                surveyNumber = demandList[0].Booking__r.Tower__r.Survey_No__c;
                CustomerEmail = demandList[0].Booking__r.Primary_Applicant_Email__c;
                //TotalOutstanding = (demandList[0].Total_Amount_Demanded__c - demandList[0].Total_Amount_Paid__c);
                TotalOutstanding = (demandList[0].Booking__r.Total_Amount_Demanded__c + demandList[0].Booking__r.Total_Interest_Amount__c) - (demandList[0].Booking__r.Total_Amount_Paid__c);
                TotalOutstandinggst = (demandList[0].Total_Tax_Demanded__c - demandList[0].Total_Tax_Paid__c );
                totalDue = (demandList[0].Booking__r.Total_Amount_Demanded__c + demandList[0].Booking__r.Total_Interest_Amount__c);
                totalDuetax = (demandList[0].Booking__r.Total_Tax_Demanded__c + demandList[0].Booking__r.Total_Tax_On_Interest_Amount__c);
            }
            if(!demandList.isEmpty() && demandList != null) {
               apList = [Select Id,City__c,State__c,PIN__c,Booking__c,Applicant_Number__c from Applicant__c where Booking__c =: demandList[0].Booking__c];
                if(!apList.isEmpty() && apList != null){
                   if(apList[0].Applicant_Number__c == 'Primary Applicant')
                   getCityStatePin = apList[0].City__c + ' '+ apList[0].State__c + ' '+apList[0].PIN__c ;
                }
            }
            if(!demandList.isEmpty() && demandList != null) {
                getTotalper = (((demandList[0].Booking__r.Total_Amount_Demanded__c) / (demandList[0].Booking__r.Agreement_Value__c))*100).setScale(2, RoundingMode.HALF_UP) ;
               // getTotalper.setScale(2, RoundingMode.HALF_UP);
                System.debug('getTotalper: '+getTotalper);
            }
        }
    }

}