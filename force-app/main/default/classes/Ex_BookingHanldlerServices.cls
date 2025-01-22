//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 30-10-2023
//-------------------------------------------//
public class Ex_BookingHanldlerServices {
    public static void insertWelcomeCallChecklist(List<Booking__c> bookingList) {
        Set<Id> bIdSet = new Set<Id>();
        Map<Id, List<Receipt__c>> bookingReceiptMap = new Map<Id, List<Receipt__c>>();
        Map<Id, Unit__c> bookingUnitMap = new Map<Id, Unit__c>();
        List<Welcome_Call_Checklist__c> welcomeCallCheckList = new List<Welcome_Call_Checklist__c>();
        List<Welcome_Call_Checklist_Master__c> welcomeCallMasterList = Welcome_Call_Checklist_Master__c.getall().values();
        
        for(Booking__c b : bookingList) {
            bIdSet.add(b.Id);
        }
        system.debug('bIdSet: '+bIdSet);
        
        if(!bIdSet.isEmpty() && bIdSet != null) {
            bookingReceiptMap = getBookingReceiptMap(bIdSet);
            bookingUnitMap = getBookingUnitMap(bIdSet);
        }
        
        for(Booking__c b: BookingList) {
            if(!welcomeCallMasterList.isEmpty() && welcomeCallMasterList != null) {   
                for(Welcome_Call_Checklist_Master__c checklistMaster : welcomeCallMasterList) {
                    Welcome_Call_Checklist__c checklist = new Welcome_Call_Checklist__c();
                    checklist.Category__c = checklistMaster.Category_Name__c	;
                    checklist.Description__c = checklistMaster.Description__c;
                    checklist.Booking__c = b.Id;
                    String fieldValue = getFieldDynamicValue(b, checklistMaster.Value__c, bookingUnitMap, bookingReceiptMap);
                    checklist.Values__c = fieldValue; 
                    welcomeCallCheckList.add(checklist);
                }
            }
        }
        if(!welcomeCallCheckList.isEmpty() && welcomeCallCheckList != null)
            insert welcomeCallCheckList;
    }
    
    public static String getFieldDynamicValue(Booking__c b, String fieldName, Map<Id, Unit__c> bookingUnitMap, Map<Id, List<Receipt__c>> bookingReceiptMap) {
        if (fieldName == 'Token Amount' && bookingReceiptMap.containsKey(b.Id)) {
            Decimal amount = 0;
            for(Receipt__c r: bookingReceiptMap.get(b.Id)) {
                //amount += r.Total_Amount__c;
            }
            return String.valueOf(amount);
        } else if (fieldName == 'Unit Floor' && bookingUnitMap.containsKey(b.Id)) { 
            return String.valueOf(bookingUnitMap.get(b.Id).Floor__c);
        } else if (fieldName == 'Tower Name' && bookingUnitMap.containsKey(b.Id)) {
            return bookingUnitMap.get(b.Id).Tower__r.Name;
        } else if (fieldName == 'Unit Configuration' && bookingUnitMap.containsKey(b.Id)) {
            return bookingUnitMap.get(b.Id).Configuration__c;
        } else if (fieldName == 'Unit Name' && bookingUnitMap.containsKey(b.Id)) {
            return bookingUnitMap.get(b.Id).Name;
        } else if (fieldName == 'Unit Carpet Area' && bookingUnitMap.containsKey(b.Id)) {
            return String.valueOf(bookingUnitMap.get(b.Id).Total_Carpet_Area_Sq_Ft__c);
        } else if (fieldName == 'All Inclusive' && b != null) {
            return String.valueOf(b.All_Inclusive_Amount__c);
        } else if (fieldName == 'Applicant Name' && b != null) {
            return b.Primary_Applicant_Name__c;
        } else if (fieldName == 'Applicant Mobile' && b != null) {
            return b.Primary_Applicant_Mobile__c;
        } else if (fieldName == 'Applicant Email' && b != null) {
            return b.Primary_Applicant_Email__c;
        } else if (fieldName == 'Booking Date' && b != null) {
            String dateStr = b.Booking_Date__c.day() + '-' + b.Booking_Date__c.month() + '-' + b.Booking_Date__c.year();
            return dateStr;
        } else if (fieldName == 'Payment Scheme' && b != null) {
            return String.valueOf(b.Payment_Scheme__c);
        } 
        return null; 
    }
    
    
    public static Map<Id, List<Receipt__c>> getBookingReceiptMap(Set<Id> bIdSet) {
        Map<Id, List<Receipt__c>> bookingReceiptMap = new Map<Id, List<Receipt__c>>();
        
        List<Receipt__c> receiptList = [Select Id, Token_Amount_Received__c, /*Total_Amount__c,*/ Booking__c from Receipt__c 
                                        where Booking__c IN :bIdSet AND Token_Amount_Received__c = true];
        if(receiptList != null) {
            for(Receipt__c r: receiptList) {
                if(!bookingReceiptMap.containsKey(r.Booking__c)) {
                    List<Receipt__c> newList = new List<Receipt__c>();
                    newList.add(r);
                    bookingReceiptMap.put(r.Booking__c, newList);
                } else {
                    bookingReceiptMap.get(r.Booking__c).add(r);
                }
            }
        }
        return bookingReceiptMap;
    }
    
    public static Map<Id, Unit__c> getBookingUnitMap(Set<Id> bIdSet) {
        Map<Id, Unit__c> bookingUnitMap = new Map<Id, Unit__c>();
        
        List<Unit__c> unitList = [Select Id, Name, Floor__c, Booking__c, Configuration__c, Tower__r.Name, Total_Carpet_Area_Sq_Ft__c from Unit__c
                                  where Booking__c IN: bIdSet];
        system.debug('unitList: '+unitList);
        
        if(unitList != null) {
            for(Unit__c u: unitList) {
                bookingUnitMap.put(u.Booking__c, u);
            }            
        }
        return bookingUnitMap;
    }
    
    public static void updatePaymentMilestoneDueDate(Map<Id, Booking__c> quotationBookingMap, Set<Id> towerIdSet) {
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> updatePMList = new List<Payment_Milestone__c>();
        Map<Id, Map<String, Construction_Stage__c>> towerConStageMap = new Map<Id, Map<String, Construction_Stage__c>>();
        
        if(!towerIdSet.isEmpty()) {
            List<Construction_Stage__c> csList = [Select Id, Name, Expected_Completion_Date__c, Actual_Completion_Date__c from Construction_Stage__c
                                                  where Tower__c IN: towerIdSet];
            for(Id tId: towerIdSet) {
                Map<String, Construction_Stage__c> cMap = new Map<String, Construction_Stage__c>();
                for(Construction_Stage__c cs: csList) {
                    cMap.put(cs.Id, cs);
                }
                towerConStageMap.put(tId, cMap);
            }
        }
        
        if(quotationBookingMap != null) {
            pmList = [Select Id, Name, Milestone_Type__c, Milestone_Name__c, No_of_Days__c, Due_Date__c, Quotation__c, Construction_Stage__c from Payment_Milestone__c
                      where Quotation__c IN: quotationBookingMap.keyset()];
            system.debug('pmList: '+pmList);
            
            if(!pmList.isEmpty()) {
                for(id qId: quotationBookingMap.keyset()) {
                    DateTime dtm = quotationBookingMap.get(qId).Booking_Date__c;
                    Date dt = date.newinstance(dtm.year(), dtm.month(), dtm.day());
                    
                    for(Payment_Milestone__c pm: pmList) {
                        if(pm.Quotation__c == qId) {
                            if(String.isNotBlank(pm.Milestone_Type__c) && pm.Milestone_Type__c.equals('Date Linked')) {
                                if(pm.No_of_Days__c != null) {
                                    pm.Due_Date__c = dt.addDays(Integer.valueOf(pm.No_of_Days__c));
                                }
                            } else if(String.isNotBlank(pm.Milestone_Type__c) && pm.Milestone_Type__c.equals('Construction Linked')) {
                                Date completionDate = null;
                                Boolean IsMilestoneAchieved = False;
                                Map<String, Construction_Stage__c> conStageMap = towerConStageMap.get(quotationBookingMap.get(qId).Tower__c);
                                Construction_Stage__c cStage = conStageMap.get(pm.Construction_Stage__c);
                                
                                if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c > dt) {
                                    completionDate = cStage.Actual_Completion_Date__c;
                                } else if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c <= dt) {
                                    completionDate = dt.addDays(60);
                                    IsMilestoneAchieved = true;
                                } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c > dt) {
                                    completionDate = cStage.Expected_Completion_Date__c;
                                } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c <= dt) {
                                    completionDate = dt;
                                }
                                if(completionDate == null) {
                                    completionDate = dt.addDays(365);
                                }
                                pm.Due_Date__c = completionDate.addDays(Integer.valueOf(pm.No_Of_Days__c));
                                
                                if(IsMilestoneAchieved) {
                                    pm.Milestone_Complete_At_Booking__c = true;
                                } else {
                                    pm.Milestone_Complete_At_Booking__c = false;
                                }
                            }
                            updatePMList.add(pm);
                        }
                    }
                }
            }
        }
        if(!updatePMList.isEmpty() && updatePMList != null)
            update updatePMList;
    }
}