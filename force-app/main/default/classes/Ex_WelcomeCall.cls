//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 30-10-2023
//-------------------------------------------//
public class Ex_WelcomeCall {   
   @AuraEnabled(cacheable=true)
    public static List<Booking__c> checkGenerateWelcomeCallChecklist(String recId){
        List<Booking__c> checkList = [select Id,Total_Amount_Received__c,Payment_Scheme__c,Generate_Welcome_Call_Checklist_Master__c 
                                      from Booking__c 
                                      where Id=:recId AND Generate_Welcome_Call_Checklist_Master__c = False];
        return checkList; 
    }
    
    @AuraEnabled
    public static String changeGenarateCheckBoxValue(String rId){ 
        try{
            List<Booking__c> bookList = [select Id,Total_Amount_Received__c,Payment_Scheme__c,
                                         Generate_Welcome_Call_Checklist_Master__c from Booking__c where Id=:rId]; 
            system.debug('booking is::'+bookList);
            for(Booking__c b:bookList){
                b.Id = b.Id;
                b.Generate_Welcome_Call_Checklist_Master__c = True;
                update b;
            }
            return 'Generate Welcome Call Checklist Master changed to True';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Welcome_Call_Checklist__c> getWelcomCallDetails(string bId){
       
        try {
            List<Welcome_Call_Checklist__c> WelcomeCallCheckList = new List<Welcome_Call_Checklist__c>();
            WelcomeCallCheckList = [select Booking__c, Category__c, Description__c, Values__c, Decision__c, Accepted__c from Welcome_Call_Checklist__c 
                                    where Booking__c =: bId AND (Decision__c = '' OR Decision__c = 'Rejected') ];
            
            return WelcomeCallCheckList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }
       
    @AuraEnabled
    public static Id updateRecords(List<Welcome_Call_Checklist__c> records, List<Welcome_Call_Checklist__c> finalList, String bookId, String rem) {
        system.debug('records is::'+records);
        system.debug('finalList is::'+finalList);
        system.debug('bookId is::'+bookId);
        system.debug('rem is::'+rem);
        List<Charge_Detail__c> chargeList = new List<Charge_Detail__c>();
        Decimal getRegistrationAmount = 0;
        Decimal getStampDutyAmount = 0;
        
        try {
            if (rem == null) {
                if (!records.isEmpty() && records != null) {
                    update records;
                }
                if (!finalList.isEmpty() && finalList != null) {
                    update finalList;
                }
            } else {
                if (!records.isEmpty() && records != null) {
                    update records;
                }
                if (!finalList.isEmpty() && finalList != null) {
                    update finalList;
                }
                List<Booking__c> bookingList = [SELECT Id, Welcome_call_comments__c,Quotation__c,/*Quotation__r.Stamp_Duty_Paid_By__c,
                                                 Quotation__r.Original_Stamp_duty__c,Quotation__r.Registration_Amount__c,*/
                                                 Welcome_Call_Done__c,Booking_Stage__c,/*Unit__r.Unit_Status__c,*/Unit__c,Opportunity__r.Opportunity_Stage__c,Opportunity__c,Registration_Status__c,Booking_Registered__c, 
                                                 Welcome_Call_Completion_Date__c, Welcome_Call_Status__c,Registration_Date__c,Tower__r.CRM_Manager__c,Sales_Head_Booking_From_B__c,Director__c,
                                                 Total_Amount_Received__c,Project__c,Project__r.Booking_1_Approver__c,project__r.Booking_2_Approver__c,Payment_Scheme__c,CRM_Head__c,Project__r.CRM_Head__c,
                                                 Project__r.Sales_Head_Booking_From_B__c,Project__r.Director__c

                                                FROM Booking__c WHERE Id = :bookId]; 
                System.debug('bookingList is::' + bookingList);
                
                List<Welcome_Call_Checklist__c> welcomeList = [SELECT Id, Booking__c, Accepted__c, LastModifiedDate FROM Welcome_Call_Checklist__c WHERE Booking__c = :bookId];
                System.debug('welcomeList is::' + welcomeList);
                
                boolean hasRejectedRecord = false; 
                
                for (Welcome_Call_Checklist__c wcc : welcomeList) {
                        if (wcc.Booking__c == bookingList[0].Id) {
                            bookingList[0].Welcome_call_comments__c = rem;
                            
                            if (wcc.Accepted__c == true) {
                                bookingList[0].Welcome_Call_Status__c = 'Welcome Call Completed';
                                bookingList[0].Welcome_Call_Completion_Date__c = System.now();
                                bookingList[0].Welcome_Call_Done__c = true;
                               /* if( bookingList[0].Welcome_Call_Done__c == true){
                                    if(bookingList[0].Tower__r.CRM_Manager__c != null && bookingList[0].Project__r.CRM_Head__c != null){
                                        bookingList[0].CRM_Head__c = bookingList[0].Project__r.CRM_Head__c;
                                        bookingList[0].Level_1_Approver__c =bookingList[0].Tower__r.CRM_Manager__c;
                                        bookingList[0].Sales_Head_Booking_From_B__c = bookingList[0].Project__r.Sales_Head_Booking_From_B__c;
                                        bookingList[0].Director__c =bookingList[0].Project__r.Director__c;

                                    }
                                }*/
                                update bookingList[0];
                                system.debug('booking updates are::' + bookingList[0]);
                            } else {
                                hasRejectedRecord = true;
                                break;
                            }
                          
                        }
                 }
               
                
                if (hasRejectedRecord) { 
                    bookingList[0].Welcome_Call_Status__c = 'Welcome Call Pending';
                  //  bookingList[0].Welcome_Call_Completion_Date__c = System.now();
                    bookingList[0].Welcome_Call_Done__c = false;
                    update bookingList[0];
                }
            }
            return bookId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}