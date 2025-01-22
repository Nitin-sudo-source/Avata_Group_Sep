public class Ex_PrintBookingTermSheetController {
    public Id bId {get;set;}
    public List<Terms_Sheet__c> tslist {get;set;}
    public Boolean showCheckBoxSelf {get;set;}
    public Boolean showCheckBoxHome {get;set;}
    
    
    public Ex_PrintBookingTermSheetController(){
        tslist = new list<Terms_Sheet__c>();
        showCheckBoxSelf = false;
        showCheckBoxHome = false;
        
        bId = (Id)ApexPages.currentPage().getParameters().get('bId');
        if(bId != null){
            
            tslist = [select Id,Self_funding__c, Home_Loan__c, Amount__c, Token_Booking_Amount__c,
                      Token_Booking_Amount_Date__c, Own_Contribution_a__c, Own_Contribution_a_Date__c,
                      Own_Contribution_b__c, Own_Contribution_b_Date__c, Home_Loan_Contribution_Self_Funding__c, Home_Loan_Date__c,
                      GST_Amount__c, GST_Amount_Date__c, SDR_Amount__c, SDR_Amount_Date__c , Primary_Applicant_Name__c, Registration_Date__c,
                      Unit__c, Agreement_Value__c, Remarks__c, Self_Funding_Amount__c from Terms_Sheet__c where Booking__c =: bId]; 
            if(tslist != null &&  tsList[0].Amount__c != null){
                if(tslist[0].Self_funding__c == 'Yes'){
                    showCheckBoxSelf = true;
                }
                if(tslist[0].Home_Loan__c == 'Yes'){
                    showCheckBoxHome = true;
                }
            }
        }
    }
}