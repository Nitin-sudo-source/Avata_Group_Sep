global without sharing class Ex_PossessionchecklistController {
    
    @AuraEnabled(cacheable = false)
    global static List<Master_Possession__c> getMasterPossession(Id bkId, Boolean isCRMHead, Boolean isAccManager , Boolean isRMUser) {
        List<Master_Possession__c> crmList = new List<Master_Possession__c>();
        List<Master_Possession__c> accList = new List<Master_Possession__c>();
        List<Master_Possession__c> rmList = new List<Master_Possession__c>();
        System.debug('isCRMHead: ' + isCRMHead);
        System.debug('isAccManager: ' + isAccManager);
        
        try {
            if (bkId != null) {
                Booking__c b = [SELECT Id, Name, Tower__c FROM Booking__c WHERE Id = :bkId];
                
                List<Master_Possession__c> mpList = [
                    SELECT Id, Sr_Number__c, Particulars__c, Tower__c, Section__c, Section_Number__c
                    FROM Master_Possession__c 
                    WHERE Tower__c = :b.Tower__c
                    ORDER BY Section_Number__c ASC, Sr_Number__c ASC
                ];
                
                for (Master_Possession__c mp : mpList) {
                    if (isCRMHead) {
                        crmList.add(mp);
                    } else if (isAccManager) {
                        accList.add(mp);
                    } else if (isRMUser) {
                        rmList.add(mp);
                    }
                    System.debug('CRM List: ' + crmList);
                    System.debug('Account List: ' + accList);
                }
            }
        } catch (Exception e) {
            System.debug('Error in getMasterPossession: ' + e.getMessage());
        }
        List<Master_Possession__c> finalList = new List<Master_Possession__c>();
        finalList.addAll(crmList);
        finalList.addAll(accList);
        finalList.addAll(rmList);
        return finalList;
    }
    
    @AuraEnabled(cacheable = false)
    global static List<Possession_checklist__c> getPossessionChecklist(Id bkId) {
        List<Possession_checklist__c> pcList = [SELECT Id, Name ,Remarks__c,Particulars__c,Section__c,
                                                Booking__c,FM_Status__c,RM_Status__c
                                                FROM Possession_checklist__c 
                                                WHERE Booking__c = :bkId AND Particulars__c != null Order By Name];
        return pcList;
    }
    
    @AuraEnabled(cacheable = true)
    global static Map<String, Object> getBookingDetails(Id bkId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        User u = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        boolean isRMUser = false;    
        boolean isAccManager = false;
        boolean isCRMHead = false;
        
        Booking__c b = [
            SELECT Id, Name,Account_Possession_Checklist__c,
            Tower__r.Customer_Relationship_Manager__c, Tower__c,RM_Possession_Checklist__c,
            Project__r.CRM_Head__c, /*,Project__r.Sales_Head__c,*/Tower__r.Name, Booking_Date__c, Opportunity__r.Name, Registration_Done__c,
            Unit__r.Name, Tower__r.Finance_Manager__c, Project__c, Primary_Applicant_Address__c, Possession_Approved_By_CRM_Head__c
            FROM Booking__c
            WHERE Id = :bkId
            LIMIT 1
        ];
        
        
        isCRMHead = isCRMHead(b.Project__c);
        isAccManager = isAccountsManager(b.Tower__c);
        isRMUser = isRMUser(b.Tower__c);
        
        System.debug('User: ' + u);
        System.debug('Booking: ' + b);
        
        resultMap.put('booking', b);
        resultMap.put('isRMUser', isRMUser);
        resultMap.put('isAccManager', isAccManager);
        resultMap.put('isCRMHead', isCRMHead);
        return resultMap;
    }
    
    private static Boolean isRMUser(String towerId){
        
        Boolean isRMUser = false;
        String loggedInUserId = UserInfo.getUserId();
        
        List<Tower__c> towers =  [SELECT Id, Name, RM_user__c
                                  FROM Tower__c
                                  WHERE Id = :towerId
                                 ];
        if(towers != null && !towers.isEmpty() && towers.size() == 1){
            if(towers[0].RM_user__c != null && towers[0].RM_user__c == loggedInUserId){
                isRMUser = true;
            }
        }
        
        return isRMUser;
    }
    
    private static Boolean isAccountsManager(String towerId){
        Boolean isAccountsManager = false;
        String loggedInUserId = UserInfo.getUserId();
                
        List<Tower__c> towers =  [SELECT Id, Name, Finance_Manager__c
                                  FROM Tower__c
                                  WHERE Id = :towerId
                                 ];
        if(towers != null && !towers.isEmpty() && towers.size() == 1){
            if(towers[0].Finance_Manager__c != null && towers[0].Finance_Manager__c == loggedInUserId){
                isAccountsManager = true;
            }
        }
        
        return isAccountsManager;
    }
    
    private static Boolean isCRMHead(String projectId){
        Boolean isCRMHead = false;
        String loggedInUserId = UserInfo.getUserId();
        
        List<Project__c> projects = [SELECT Id, Name, CRM_Head__c
                                     FROM Project__c
                                     WHERE Id = :projectId
                                    ];
        if(projects != null && !projects.isEmpty() && projects.size() == 1){
            if(projects[0].CRM_Head__c != null && projects[0].CRM_Head__c == loggedInUserId){
                isCRMHead = true;
            }
        }
        return isCRMHead;
    }
    
    @AuraEnabled(cacheable = false)
    global static void savePossessionCheckList(List<Possession_checklist__c> mpList, Id bkId, Boolean isAccManager, Boolean isCRMHead, Boolean isRMUser) {
        List<Possession_checklist__c> existingPCList = [
            SELECT Id, Particulars__c, Section__c, Booking__c, Remarks__c, FM_Status__c, RM_Status__c, Checklist_Identifier__c
            FROM Possession_checklist__c 
            WHERE Booking__c = :bkId AND Particulars__c != null
        ];
        
        Booking__c bookingRecord = [
            SELECT Id, Name, Unit__c, Tower__r.Finance_Manager__c, Tower__r.Customer_Relationship_Manager__c,
            Account_Possession_Checklist__c, Accounts_Verified__c, Possession_Checklist_Status__c, Possession_Status__c,
            RM_Possession_Checklist__c
            FROM Booking__c 
            WHERE Id = :bkId 
            LIMIT 1
        ];
        
        String unitID = bookingRecord.Unit__c;
        
        Map<String, Map<String, Possession_checklist__c>> existingPCMap = new Map<String, Map<String, Possession_checklist__c>>();
        for (Possession_checklist__c pc : existingPCList) {
            if (!existingPCMap.containsKey(pc.Section__c)) {
                existingPCMap.put(pc.Section__c, new Map<String, Possession_checklist__c>());
            }
            existingPCMap.get(pc.Section__c).put(pc.Particulars__c, pc);
        }
        
        List<Possession_checklist__c> recordsToInsert = new List<Possession_checklist__c>();
        List<Possession_checklist__c> recordsToUpdate = new List<Possession_checklist__c>();
        
        for (Possession_checklist__c mp : mpList) {
            if (existingPCMap.containsKey(mp.Section__c) && existingPCMap.get(mp.Section__c).containsKey(mp.Particulars__c)) {
                Possession_checklist__c existingPC = existingPCMap.get(mp.Section__c).get(mp.Particulars__c);
                if (mp.FM_Status__c != null) existingPC.FM_Status__c = mp.FM_Status__c;
                if (mp.RM_Status__c != null) existingPC.RM_Status__c = mp.RM_Status__c;
                if (mp.Checklist_Identifier__c != null) existingPC.Checklist_Identifier__c = mp.Checklist_Identifier__c;
                if (mp.Remarks__c != null) existingPC.Remarks__c = mp.Remarks__c;
                recordsToUpdate.add(existingPC);
            } else {
                Possession_checklist__c newPC = new Possession_checklist__c();
                newPC.Particulars__c = mp.Particulars__c;
                newPC.Section__c = mp.Section__c;
                newPC.RM_Status__c = mp.RM_Status__c;
                newPC.FM_Status__c = mp.FM_Status__c;
                newPC.Checklist_Identifier__c = mp.Checklist_Identifier__c;
                newPC.Remarks__c = mp.Remarks__c;
                newPC.Booking__c = bkId;
                recordsToInsert.add(newPC);
            }
        }
        
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
            if (isRMUser) {
                bookingRecord.Possession_Checklist_Status__c = 'Submitted for Approval';
            }
        }
        
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
        
        List<Possession_checklist__c> possessionChecklist = [
            SELECT Id, Checklist_Identifier__c, FM_Status__c, RM_Status__c 
            FROM Possession_checklist__c 
            WHERE Booking__c = :bkId
        ];
        
        Boolean allReceivedByRM = true;
        Boolean allReceivedByFM = true;
        
        for (Possession_Checklist__c checklist : possessionChecklist) {
            if (checklist.Checklist_Identifier__c == 'RM User' && checklist.RM_Status__c != 'Completed') {
                allReceivedByRM = false;
            }
            if (checklist.Checklist_Identifier__c == 'Account Manager' && checklist.FM_Status__c != 'Completed') {
                allReceivedByFM = false;
            }
        }
        
        Boolean bookingNeedsUpdate = false;
        
        if (allReceivedByRM && isRMUser) {
            bookingRecord.Possession_Status__c = 'Sent for CRM Head approval';
            bookingRecord.RM_Possession_Checklist__c = true;
            bookingNeedsUpdate = true;
        }
        
        if (allReceivedByFM && isAccManager) {
            bookingRecord.Account_Possession_Checklist__c = true;
            bookingRecord.Accounts_Verified__c = true;
            bookingNeedsUpdate = true;
        }
        
        if (bookingNeedsUpdate) {
            update bookingRecord;
        }
    }
    
    @AuraEnabled(cacheable = false)
    public static Boolean updatePossessionChecklistStatusFromCRMHead(String bookingId, String approvalStatus){
        try {
            List<Booking__c> bookings = [SELECT Id, Name, Possession_Checklist_Status__c,Account_Possession_Checklist__c, Possession_Status__c, Possession_Approved_By_CRM_Head__c
                                         FROM Booking__c
                                         WHERE Id =: bookingId ];
            
            if(bookings != null && !bookings.isEmpty()){
                if(approvalStatus != null && approvalStatus == 'Approved'){
                    bookings[0].Possession_Approved_By_CRM_Head__c = true;
                    bookings[0].Possession_Checklist_Status__c = 'Approved';
                    bookings[0].Possession_Status__c = 'Sent for FM approval';
                    
                }
                else if(approvalStatus != null && approvalStatus == 'Rejected'){
                    bookings[0].Possession_Approved_By_CRM_Head__c = false;
                    bookings[0].Possession_Checklist_Status__c = 'Rejected';
                    bookings[0].Possession_Status__c = 'Rejected by CRM Head';
                    bookings[0].Account_Possession_Checklist__c = false;
                }
            }
            update bookings;
            System.debug('update booking :  ' + bookings[0]);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}