/**
 * @description       :
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             :
 * @last modified on  : 08-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
 **/
public with sharing class Ex_UserInfoController {
    public Ex_UserInfoController() {
        
    }
    
    @AuraEnabled(cacheable=false)
    public static Booking__c getBooking(String recordId){
        Booking__c booking = [SELECT Id, Name FROM Booking__c WHERE Id =: recordId];
        return booking;
    }
    
    public class BookingWrapper {
        @AuraEnabled public Booking__c bookingRecord {get;set;}
        @AuraEnabled public Boolean success {get;set;}
        @AuraEnabled public String message {get;set;}
    }
    
    @AuraEnabled(cacheable=false)
    public static BookingWrapper updateBooking(String recordId, String profileName){
        BookingWrapper result = new BookingWrapper();
        try {
            Booking__c booking = [
                SELECT Id, Name, Send_Approval_To_Sales_Head__c, Sent_Approval_to_CRM_Head__c 
                FROM Booking__c 
                WHERE Id =: recordId
                LIMIT 1
            ];
            
            if(profileName == 'Sales Head'){
                booking.Sent_Approval_to_CRM_Head__c = true;
                result.success = true;
            } else if(profileName == 'CRM Head'){
                booking.Send_Approval_To_Sales_Head__c = true;
                result.success = true;
            }else{
                result.success = false;
            }
            
            if(result.success){
                update booking;
                result.bookingRecord = booking;
                result.message = 'Booking Send For Approver successfully.';
            }else{
                result.message = 'You do not have access to do this operation. Only CRM Head and Sales Head can approve the booking.';

            }
            
            
        } catch (Exception ex) {
            result.success = false;
            result.message = 'Error while updating booking: ' + ex.getMessage();
            result.bookingRecord = null;
        }
        
        return result;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCurrentUserDetails() {
        User currentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return new Map<String, String>{
            'userName' => currentUser.Name,
            'profileName' => currentUser.Profile.Name
        };
    }
    
    
}