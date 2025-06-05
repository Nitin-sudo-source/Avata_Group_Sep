/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 05-06-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
public class Ex_ConstructionStageUpdate {
 
    @AuraEnabled(cacheable= true)
    public static list<Construction_Stage__c> Cosnstructionupdate (String recordID, date ActualDate,date ExpectedDate){
        //system.debug('recordID First Method---->'+recordID);
        list<Construction_Stage__c> listget2 = [SELECT id, Name,Unit_Wise_Milestone__c,Tower__r.Name,Is_Completed__c,Actual_Completion_Date__c,
                                                Expected_Completion_Date__c,Stage_Description__c,Tower__r.Project__r.Name from Construction_Stage__c
                                                WHERE Tower__c =: recordID AND Is_Completed__c = false
                                                ORDER BY Sequence_Number__c ASC];
        
        //System.debug('listget2 is::'+listget2);
        return listget2;
    }
    
    @AuraEnabled
    public static list<Construction_Stage__c> getCosnstructionStage (String recordID){
        //system.debug('recordID Second Method---->'+recordID);
        list<Construction_Stage__c> listget2 = [SELECT id, Name,Unit_Wise_Milestone__c,Tower__r.Name,Is_Completed__c,Actual_Completion_Date__c,
                                                Expected_Completion_Date__c,Stage_Description__c,Tower__r.Project__r.Name from Construction_Stage__c
                                                WHERE id =: recordID];
        
        //System.debug('listget2'+listget2);
        return listget2;
    }
    
    @AuraEnabled(cacheable = true)
    public static list<Construction_Stage__c> getcons(string Twid,date ActualDate,date ExpectedDate){
        list<Construction_Stage__c> getcs =[Select Id, Name,Actual_Completion_Date__c,Stage_Description__c,Unit_Wise_Milestone__c,
                                            Expected_Completion_Date__c from Construction_Stage__c where Tower__c =:Twid Order By Sequence_Number__c ASC];
        
        return getcs;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<Decimal, List<Unit__c>> getFloor(String recordID) {
        Map<Decimal, List<Unit__c>> floorUnitsMap = new Map<Decimal, List<Unit__c>>();
        List<Unit__c> unitList = [SELECT Id, Name, Floor__c, Tower__c FROM Unit__c WHERE Tower__c = :recordID ORDER BY Floor__c];
        //System.debug('unitList=' + unitList);
        for (Unit__c unit : unitList) {
            if (!floorUnitsMap.containsKey(unit.Floor__c)) {
                floorUnitsMap.put(unit.Floor__c, new List<Unit__c>());
            }
            floorUnitsMap.get(unit.Floor__c).add(unit);
        }
        //System.debug('floorUnitsMap=' + floorUnitsMap);
        return floorUnitsMap;
    }
    
    @AuraEnabled
    public static boolean saveMethod(String options, Date d, Id recordId, List<String> floors, String base64, String filename) {
        //system.debug('options: '+options);
        //system.debug('d: '+d);
        system.debug('recordId: '+recordId);
        //system.debug('floors: '+floors);
        Set<Decimal> floorIdSet = new Set<Decimal>();
        Construction_Stage__c cs = new Construction_Stage__c();
        Set<Id> qIdSet = new Set<Id>();
       // List<Construction_Stage_History__c> csCreateList = new List<Construction_Stage_History__c>();
        List<Unit__c> unitList = new List<Unit__c>();
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> pmListForUpdate = new List<Payment_Milestone__c>();
        
        cs = [Select Id, Name, Is_Completed__c, Actual_Completion_Date__c,CA_Certificate__c,Unit_Wise_Milestone__c,Tower__c,Tower__r.Project__c, 
              Tower__r.Project__r.CRM_Head__c,
              Expected_Completion_Date__c from Construction_Stage__c
              where Id =: recordId];
        system.debug('cs: '+cs);
        if(cs != null) {
            if(options.equalsIgnoreCase('Expected Completion Date')) {
                cs.Expected_Completion_Date__c = d;
            } else if(options.equalsIgnoreCase('Actual Completion Date')) {
                if (!cs.Unit_Wise_Milestone__c) {
                    cs.Actual_Completion_Date__c = d;
                    cs.CA_Certificate__c = true;
                    cs.Milestone_Status__c = 'Completed';
                    cs.Is_Completed__c = true;
                }
            }
            
            String queryForUnit = 'SELECT Id, Name, Booking__c, Booking__r.Quotation__c from Unit__c where Booking__c != null AND Project__c = \''
                + cs.Tower__r.Project__c + '\' AND Sales_Status__c =\'Booked\' AND Tower__c = \'' + cs.Tower__c + '\'';
            
            if(floorIdSet != null && !floorIdSet.isEmpty()) {
                queryForUnit += ' AND Floor__c IN: floorIdSet';
            }
            
            unitList = Database.query(queryForUnit);
            system.debug('unitList: '+unitList);
            
            if(!unitList.isEmpty()) {
                for(Unit__c u : unitList) {
                    qIdSet.add(u.Booking__r.Quotation__c);
                }    
            }
            System.debug('qIdSet::'+qIdSet);
            
            if(!qIdSet.isEmpty()) {
                pmList = [Select Id, Name, Quotation__c, Construction_Stage__c, Milestone_Type__c, Milestone_Complete_At_Booking__c, Is_Raised__c, Is_Due__c, Due_Date__c from Payment_Milestone__c
                          where Construction_Stage__c =: cs.Id AND Milestone_Type__c = 'Construction Linked' AND Is_Raised__c = false AND Quotation__c IN: qIdSet];
            }
            system.debug('pmList ::'+pmList);
            
            if(!pmList.isEmpty()) {
                for(Payment_Milestone__c pm : pmList) {
                    if(options.equalsIgnoreCase('Actual Completion Date')) {
                        pm.Due_Date__c = d;
                        pm.Is_Due__c = true;
                        pmListForUpdate.add(pm);
                    } else if (options.equalsIgnoreCase('Expected Completion Date')) {
                        pm.Due_Date__c = d;
                        pmListForUpdate.add(pm);
                    }
                }                        
            }
            
            try {
                update cs;
               
                if(!pmListForUpdate.isEmpty() && pmListForUpdate != null)
                    update pmListForUpdate;
                
                if (base64 != null && filename != null) {
                    ContentVersion cv = createContentVersion(base64, filename);
                    ContentDocumentLink cdl = createContentLink(cv.Id, cs.Id); 
                    if (cv == null || cdl == null) {
                        return null;
                    }
                } else {
                    return true;
                }
                return true;
            } catch(Exception ex) {
                return false;
            }
        } else {
            return false;
        }
    }
    
    @testvisible
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @testvisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }    
}