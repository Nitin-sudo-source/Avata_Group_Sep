public class Ex_BookingCancellationHandler {
    
    @AuraEnabled(cacheable=false)
    public static String fetchBooking(Booking__c dataVal, String ctype, decimal amt, string remarks){
        try{
            // Query Booking with related Project fields
            Booking__c bk = [SELECT Id, Unit__c, Booking_Stage__c, ownerId, 
                            Sales_Manager__r.ManagerId, Registration_Done__c, 
                            Opportunity__c, Project__c, 
                            Project__r.Sales_Head__c,
                            Project__r.CRM_Head__c,
                            Project__r.AVP__c,
                            Project__r.Booking_Cancellation_Approver__c
                            FROM Booking__c WHERE Id=:dataVal.Id];
            
            System.debug('Booking Record: '+ bk);
            
            if(bk != null){
                // Set cancellation details
                bk.Booking_Stage__c = 'Cancellation in-process';
                bk.Cancellation_Type__c = ctype;
                bk.Refund_Amount__c = amt;
                bk.Cancellation_Remark__c = remarks;
                
                System.debug('project Record: '+ bk.Project__c);
                // Set approval hierarchy from Project
                if(bk.Project__r != null){
                    // Level 1 Approver - Maintain existing logic but fall back to Project hierarchy
                    // if(!bk.Registration_Done__c){

                    //     System.debug('done Record: '+ bk.Registration_Done__c);
                    //     // If registration not done, use Sales Manager's Manager or fall back to Project Sales Head
                    //     bk.Level_1_Approver__c = bk.Sales_Manager__r.ManagerId != null ? 
                    //                                bk.Sales_Manager__r.ManagerId : 
                    //                                bk.Project__r.Sales_Head__c;

                    // } else {
                    //     // If registration done, use Owner or fall back to Project CRM Head
                    //     bk.Level_1_Approver__c = bk.ownerId != null ? 
                    //                              bk.ownerId : 
                    //                              bk.Project__r.CRM_Head__c;
                    // }

                    bk.Level_1_Approver__c = bk.Project__r.Sales_Head__c;
                    
                    // Level 2 Approver is always CRM Head from Project
                    bk.Level_2_Approver__c = bk.Project__r.CRM_Head__c;
                    
                    // Level 3 Approver is always AVP from Project
                    bk.Level_3_Approver__c = bk.Project__r.AVP__c;
                    
                    // Maintain backward compatibility with old approver field
                    if(bk.Project__r.Booking_Cancellation_Approver__c != null){
                        bk.Booking_Cancellation_Approver__c = bk.Project__r.Booking_Cancellation_Approver__c;
                    }
                }
                
                // Set all approval statuses to 'Pending For Approval'
                bk.Level_1_Approval_Status__c = 'Pending For Approval';
                bk.Level_2_Approval_Status__c = 'Pending For Approval';
                bk.Level_3_Approval_Status__c = 'Pending For Approval';
                
                update bk;
                
                return 'success';
            }
            else{
                return 'error: Booking record not found';
            }
        }
        catch(Exception ex){
            System.debug('Exception: '+ex.getMessage() + ' at line: '+ex.getLineNumber());
            return 'error: '+ex.getMessage();
        }
    }
}