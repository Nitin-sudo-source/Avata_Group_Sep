/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 26-03-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 24-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_InventoryMatrix {
    // // public Ex_InventoryMatrix() {
    
    // // }
    // @AuraEnabled(cacheable=false)
    // public static Opportunity__c getOppDetails(String oppId){
    //     try {
    //         Opportunity__c op = [SELECT Id, Name, Project__c, Project__r.Name, Project__r.Id FROM Opportunity__c WHERE Id = :oppId LIMIT 1];
    //         System.debug('op: ' + op);
    //         if (op != null && op.Project__c != null) {
    //             return op;
    //         } else {
    //             return null;
    //         }
    //     } catch (Exception e) {
    //         System.debug('An error occurred: ' + e.getMessage());
    //         return null;
    //     }
    // }
    
    // @AuraEnabled(cacheable=false)
    // public static List<Project__c> getProjectList() {
    //     try {
    //         List<Project__c> pList = [SELECT Id, Name FROM Project__c];
    //         System.debug('Project List .: ' + pList);
    //         if (!pList.isEmpty()) {
    //             return pList;
    //         } else {
    //             return null;
    //         }
    //     } catch (Exception e) {
    //         System.debug('An error occurred: ' + e.getMessage());
    //         return null;
    //     }
    // }
    
    // @AuraEnabled
    // public static List<Tower__c> getTower(String projId) {
    //     try {
    //         System.debug('Project Id: ' + projId);
    //         List<Tower__c> tList = [SELECT Id, Name, Project__c, Project__r.Name FROM Tower__c 
    //                                 WHERE Project__c = :projId];
    //         System.debug('Tower List .:' +tList);
    //         if (!tList.isEmpty()) {
    //             return tList;
    //         } else {
    //             return null;
    //         }
    //     } catch (Exception e) {
    //         System.debug('An error occurred: ' + e.getMessage());
    //         return null;
    //     }
    // }
    
    // @AuraEnabled
    // public static List<Unit__c> getUnit(string towerId) {
    //     try {
    //         System.debug('Tower Id: ' + towerId);
    //         List<Unit__c> uList = [SELECT Name, Configuration_Type__c, Sales_Status__c FROM Unit__c 
    //                                WHERE Tower__c = :towerId];
    //         System.debug('Unit List .:' +uList);
    //         if (uList != null && !uList.isEmpty()) {
    //             return uList;
    //         } else {
    //             return null;
    //         }
    //     } catch (Exception e) {
    //         System.debug('An error occurred: ' + e.getMessage());
    //         return null;
    //     }
    // }
    
    // @AuraEnabled
    // public static Map<String, Integer> getUnitConfigurationMapDetails(String towerId){
    //     Map<String, Integer> unitConfigurationMap = new Map<String, Integer>();
    //     List<Unit__c> uList = [Select Id, Name, Floor__c, Sales_Status__c, Configuration_Type__c, 
    //                            Total_carpet_Sq_Ft__c, Purpose__c from Unit__c
    //                            where Configuration_Type__c != null 
    //                            AND Tower__c =: towerId  
    //                            ORDER BY Configuration_Type__c ASC, Name ASC];
    //     System.debug('Unit List .:' +uList);
        
    //     if(uList != null){
    //         for(Unit__c u : uList){
             
    //             if(!unitConfigurationMap.containsKey(u.Configuration_Type__c)){
    //                 unitConfigurationMap.put(u.Configuration_Type__c, 1);
    //                 System.debug('unitConfigurationMap if .: '+unitConfigurationMap);
    //             }else{
    //                 unitConfigurationMap.put(u.Configuration_Type__c, unitConfigurationMap.get(u.Configuration_Type__c) + 1);
    //                 System.debug('unitConfigurationMap else .: '+unitConfigurationMap);
    //             }
    //         }
    //     }
    //     System.debug('Unit Configuration Map .: '+unitConfigurationMap);
    //     if(unitConfigurationMap != null &&!unitConfigurationMap.isEmpty()){
    //         return unitConfigurationMap;
    //     }else{
    //         return null;
    //     }
    // }
    
    // @AuraEnabled
    // public static Map<String, List<Unit__c>> getUnitFloorMapDetails(String towerId){
    //     Map<String, List<Unit__c>> unitFloorMap = new Map<String, List<Unit__c>>();
    //     List<Unit__c> uList = [Select Id, Name, Floor__c, Sales_Status__c, Configuration_Type__c, 
    //                            Total_carpet_Sq_Ft__c from Unit__c
    //                            where Tower__c =: towerId  ORDER BY Floor__c DESC, Name ASC];
    //     system.debug('uList: '+uList);
        
    //     if(uList != null){
    //         for(Unit__c u : uList){
               
    //             if(!unitFloorMap.containsKey('Floor: '+u.Floor__c)) {
    //                 List<Unit__c> newList = new List<Unit__c>();
    //                 newList.add(u);
    //                 unitFloorMap.put('Floor: '+u.Floor__c, newList);
    //             } else{
    //                   unitFloorMap.get('Floor: '+u.Floor__c).add(u);
    //                 }
    //         }
    //     }
    //     System.debug('unitFloorMap: '+unitFloorMap);
    //     if(unitFloorMap != null && !unitFloorMap.isEmpty()){
    //     return unitFloorMap;
    //     }else{
    //         return null;
    //     }
        
    // }
    @AuraEnabled(cacheable = true)
    public static List<Project__c> getProject(string oppId) {
        try {
            System.debug('Opportunity Id: ' + oppId);
            
            Opportunity__c op = [SELECT Id, Name, Project__c, Project__r.Name FROM Opportunity__c 
                                 WHERE Id = :oppId LIMIT 1];
            System.debug('Project Id: ' + op.Project__c);
            if (op != null && op.Project__c != null) {
                List<Project__c> pList = [SELECT Id, Name FROM Project__c WHERE Id = :op.Project__c];
                return pList;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Project__c> getProjectList() {
        try {
            List<Project__c> pList = [SELECT Id, Name FROM Project__c];
            System.debug('Project List .: ' + pList);
            if (!pList.isEmpty()) {
                return pList;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }

    
    // @AuraEnabled
    // public static List<Sector__c> getSector(string projId){
    //     List<Sector__c> sectorList = new List<Sector__c>();
    //     sectorList = [Select Id,Name,Project__c From Sector__c 
    //                   where Project__c=:projId];
    //     system.debug('sectorList is::'+sectorList);
    //     if(!sectorList.isEmpty() && sectorList != null){
    //         return sectorList;
    //     }else{
    //         return null;
    //     }
    // }
    
    // Modified By Priyanshu Agarkar
    @AuraEnabled
    public static List<Tower__c> getTower(string projId) {
        try {
            System.debug('Project Id: ' + projId);
            
            List<Tower__c> tList = [SELECT Id, Name, Project__c, Project__r.Name FROM Tower__c 
                                    WHERE Project__c=:projId];
            System.debug('Tower List .:' +tList);
            if (!tList.isEmpty()) {
                return tList;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }
    // Modified By Priyanshu Agarkar
    
    @AuraEnabled
    public static List<Unit__c> getUnit(string towerId) {
        try {
            System.debug('Tower Id: ' + towerId);
            
            List<Unit__c> uList = [SELECT Configuration_Type__c, Tower__c, Project__c FROM Unit__c 
                                   WHERE Tower__c = :towerId];
            System.debug('Unit List .:' +uList);
            if (!uList.isEmpty()) {
                return uList;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static Map<String, Integer> getUnitConfigurationMapDetails(String towerId){
        Map<String, Integer> unitConfigurationMap = new Map<String, Integer>();
        List<Unit__c> uList = [Select Id, Name, Floor__c, Sales_Status__c, Configuration_Type__c, 
                               Total_carpet_Sq_Ft__c,Booking__r.Primary_Applicant_Name__c, 
                               Saleable_Area__c
                               from Unit__c
                               where Configuration_Type__c != null 
                               AND Tower__c =: towerId  
                               ORDER BY Configuration_Type__c ASC, Name ASC];
        System.debug('Unit List .:' +uList);
        
        if(uList != null){
            for(Unit__c u : uList){
                if(!unitConfigurationMap.containsKey(u.Configuration_Type__c)){
                    unitConfigurationMap.put(u.Configuration_Type__c, 1);
                    System.debug('unitConfigurationMap if .: '+unitConfigurationMap);
                }else{
                    unitConfigurationMap.put(u.Configuration_Type__c, unitConfigurationMap.get(u.Configuration_Type__c) + 1);
                    System.debug('unitConfigurationMap else .: '+unitConfigurationMap);
                }
            }
        }
        System.debug('Unit Configuration Map .: '+unitConfigurationMap);
        return unitConfigurationMap;
        
    }
    
    @AuraEnabled
    public static Map<String, List<Unit__c>> getUnitFloorMapDetails(String towerId){
        Map<String, List<Unit__c>> unitFloorMap = new Map<String, List<Unit__c>>();
        List<Unit__c> uList = [Select Id, Name, Floor__c, Sales_Status__c, Configuration_Type__c, 
                                Total_carpet_Sq_Ft__c,Booking__c,Booking__r.Primary_Applicant_Name__c, Booking__r.Primary_Applicant_Title__c,
                                Saleable_Area__c,Opportunity__c 
                               from Unit__c
                               where Tower__c =: towerId  ORDER BY Floor__c DESC, Name ASC];
        system.debug('uList: '+uList);
        
        if(uList != null){
            for(Unit__c u : uList){
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
    
    @AuraEnabled
    public static void handleblockunit(string selectedunit, string oppId){
        system.debug('selectedunit::'+selectedunit);
        system.debug('oppId::'+oppId);
        List<Unit__c> selectedunitlist = new List<Unit__c>();
        List<Unit__c> updateselectedunitlist = new List<Unit__c>();
        If(selectedunit!=null){
            selectedunitlist = [Select id, Last_Unit_Blocking_Date__c, Unit_Blocked_By__c, Name,Sales_Status__c,Opportunity__c from Unit__c where Id=:selectedunit];
            system.debug('selectedunitlist::'+selectedunitlist);
            if(selectedunitlist!=null && !selectedunitlist.isEmpty()){
                for(Unit__c u:selectedunitlist){
                    if(u.Sales_Status__c != 'Blocked'){
                        u.Sales_Status__c = 'Blocked';
                        u.Opportunity__c = oppId;
                        u.Last_Unit_Blocking_Date__c = System.now();
                        u.Unit_Blocked_By__c = userInfo.getUserId();
                        updateselectedunitlist.add(u);
                    }
                    update updateselectedunitlist;
                }
                system.debug('updateselectedunitlist::'+updateselectedunitlist);
            }
        }
    }
    
    @AuraEnabled
    public static void handleunblockunit(string selectedunit, string oppId){
        system.debug('selectedunit::'+selectedunit);
        List<Unit__c> selectedunitlist = new List<Unit__c>();
        List<Unit__c> updateselectedunitlist = new List<Unit__c>();
        If(selectedunit!=null){
            selectedunitlist = [Select id,Name,Sales_Status__c,Opportunity__c from Unit__c where Id=:selectedunit];
            system.debug('selectedunitlist::'+selectedunitlist);
            if(selectedunitlist!=null && !selectedunitlist.isEmpty()){
                for(Unit__c u:selectedunitlist){
                    if(u.Sales_Status__c =='Blocked'){
                        u.Sales_Status__c = 'Vacant';
                        // u.Manually_Unblock_Date_Time__c = system.now();
                        updateselectedunitlist.add(u);
                    }
                    update updateselectedunitlist;
                    
                }
                system.debug('updateselectedunitlist::'+updateselectedunitlist);
            }
            
        }
    }
    
}