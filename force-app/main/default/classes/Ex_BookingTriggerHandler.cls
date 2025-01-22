/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 20-01-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 30-10-2023
//-------------------------------------------//
public class Ex_BookingTriggerHandler {
    public static void afterInsert(List<Booking__c> bList) {
        Map<Id, Booking__c> quotationBookingMap = new Map<Id, Booking__c>();
        Set<Id> towerIdSet = new Set<Id>();
        
        for(Booking__c b: bList) {
            if(b.Booking_Date__c != null && b.Tower__c != null) {
                quotationBookingMap.put(b.Quotation__c, b);
                towerIdSet.add(b.Tower__c);
            }
        }
        if(quotationBookingMap != null && !towerIdSet.isEmpty())
            Ex_BookingHanldlerServices.updatePaymentMilestoneDueDate(quotationBookingMap, towerIdSet);
    }
    public static void afterUpdate(Map<Id, Booking__c> oldMap, Map<Id, Booking__c> newMap) {
        List<Booking__c> newBookingList = new List<Booking__c>();
        Map<Id, Date> quotationRegistrationMap = new Map<Id,Date>();
        Boolean isBatchReq2 = false;
        
        
        for(Booking__c oldBooking: oldMap.values()) {
            Booking__c newBooking = newMap.get(oldBooking.Id);
            
            if(oldBooking.Generate_Welcome_Call_Checklist_Master__c != newBooking.Generate_Welcome_Call_Checklist_Master__c && newBooking.Generate_Welcome_Call_Checklist_Master__c == True) {
                newBookingList.add(newBooking);
            }
            if(oldBooking.Welcome_Call_Done__c != newBooking.Welcome_Call_Done__c && newBooking.Welcome_Call_Done__c) {
                isBatchReq2 = true;
                system.debug('Inside Batch Call: ');
            }
            if(oldBooking.Booking_Registered__c != newBooking.Booking_Registered__c && newBooking.Booking_Registered__c) {
                if(newBooking.Registratio_Date__c != null){
                    if(!quotationRegistrationMap.containsKey(newBooking.Quotation__c)){
                        quotationRegistrationMap.put(newBooking.Quotation__c,newBooking.Registratio_Date__c);
                    }else{
                        quotationRegistrationMap.get(newBooking.Quotation__c);
                    }
                }
                
            }
            if(oldBooking.By_Pass_Registration_Done__c != newBooking.By_Pass_Registration_Done__c && newBooking.Booking_Registered__c) {
                isBatchReq2 = true;
                system.debug('Inside Batch Call: ');
            }
        }
        if(!quotationRegistrationMap.isEmpty() && quotationRegistrationMap != null)
            Ex_UpdatePaymentMilestone.updateDueDate(quotationRegistrationMap);
        if(!newBookingList.isEmpty() && newBookingList != null) {
            Ex_BookingHanldlerServices.insertWelcomeCallChecklist(newBookingList);
        }
        if(isBatchReq2) {
            system.debug('Inside Batch Call: ');
            Database.executeBatch(new Ex_DemandRaiseBatch()); // Calling Batch Class
        }
    }
}