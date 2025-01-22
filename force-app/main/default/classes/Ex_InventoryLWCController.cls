//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 27-10-2023 // updated on 12-02-2024
//-------------------------------------------//
public class Ex_InventoryLWCController {
    
    @AuraEnabled(Cacheable = true)
    public static Opportunity__c getOppDetails(Id oppId) {
        Opportunity__c opp = [SELECT Id , Name, Project__c,  Project__r.Name FROM Opportunity__c where Id =: oppId] ;
        System.debug('opp: '+opp);
        return opp ;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<Project__c> getProjectListDetails() {
        List<Project__c> pList = [Select Id, Name, Project_Logo__c from Project__c ORDER BY Name ASC];
        system.debug('pList: '+pList);
        return pList;
    }
    
    
    @AuraEnabled(Cacheable = true)
    public static List<Tower__c> getTowerListDetails(Id projectId) {
        List<Tower__c> towerList=new List<Tower__c>();
        towerList = [Select Id,Name,Tower_Image__c from Tower__c where project__c =:projectId order by Name ASC];
        system.debug('towerList :'+towerList);
        return towerList;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, List<Unit__c>> getUnitFloorMapDetails(Id tId) {
        Map<String, List<Unit__c>> unitFloorMap = new Map<String, List<Unit__c>>();
        List<Unit__c> uList = [Select Id,Name,Floor__c, Unit_Info__c, Sale_Status__c,Configuration__c,Total_Carpet_Area_Sq_Ft__c,Booking__r.Quotation__r.Charge_Bucket_1_Amount__c, Booking__r.Quotation__r.Charge_Bucket_2_Amount__c,Booking__r.Quotation__r.Charge_Bucket_3_Amount__c
                               from Unit__c where Tower__c = :tId  ORDER BY Floor__c DESC,Name ASC];
        system.debug('uList::' + uList);
        
        
        if(uList != null) {
            for(Unit__c u: uList) {
                if(!unitFloorMap.containsKey('Floor: '+u.Floor__c)) {
                    List<Unit__c> newList = new List<Unit__c>();
                    newList.add(u);
                    unitFloorMap.put('Floor: '+u.Floor__c, newList);
                } else {
                    unitFloorMap.get('Floor: '+u.Floor__c).add(u);
                }
            }
        }
        return unitFloorMap;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Integer> getUnitConfigurationMapDetails(Id tId) {
        Map<String, Integer> unitConfigurationMap = new Map<String, Integer>();
        List<Unit__c> uList = [Select Id,Name,Floor__c, Unit_Info__c, Sale_Status__c,Configuration__c,Total_Carpet_Area_Sq_Ft__c,Booking__r.Quotation__r.Charge_Bucket_1_Amount__c, Booking__r.Quotation__r.Charge_Bucket_2_Amount__c,Booking__r.Quotation__r.Charge_Bucket_3_Amount__c
                               from Unit__c
                               where Configuration__c != null AND Tower__c =: tId  ORDER BY Configuration__c ASC, Name ASC];
        system.debug('uList: '+uList);
        
        if(uList != null) {
            for(Unit__c u: uList) {
                if(!unitConfigurationMap.containsKey(u.Configuration__c)) {
                    unitConfigurationMap.put(u.Configuration__c, 1);
                } else {
                    unitConfigurationMap.put(u.Configuration__c, unitConfigurationMap.get(u.Configuration__c) + 1);
                }
            }
        }
        return unitConfigurationMap;
    }
}