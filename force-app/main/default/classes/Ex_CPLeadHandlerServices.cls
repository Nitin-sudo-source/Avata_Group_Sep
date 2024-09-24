/**
* @File Name : Ex_CPLeadHandlerServices.cls
* @Description : for CP Document Upload 
* @Author : Nitin Choudhary
* @Last Modified By : Nitin Choudhary
* @Last Modified On : September 19, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 18, 2024 |   | Initial Version
**/
public class Ex_CPLeadHandlerServices {
    public static void duplicationCheck(String performRoundRobin, List<CP_Lead__c> leadList) {
        Map<CP_Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckCPLead(leadList);
        List<CP_Lead__c> CPProjectForAssignment = new List<CP_Lead__c>();
        
        for(CP_Lead__c l : leadList) {
            String errMsg = '';
            if (duplicateWrapperMap.containsKey(l)) {
                for (Ex_DuplicationHandlerServices.duplicateWrapper dw : duplicateWrapperMap.get(l)) {
                    System.debug('dw: '+dw);
                    if (dw.objectType.equalsIgnoreCase('CP Lead'))
                        errMsg = 'Duplicate CP Lead Found With Record Id is ' + dw.dupCPLead.Id;
                    else if (dw.objectType.equalsIgnoreCase('Account'))
                        errMsg = 'Duplicate Account Found With Name: ' + dw.dupAccount.LastName +' Owner Name: '+ dw.dupAccount.Owner.Name + '. Record Id is ' + dw.dupAccount.Id;
                }
                if (!Test.isRunningTest() && errMsg != '')
                    l.addError(errMsg);
            } else {
                if(l.Channel_Partner_Name__c != null && l.Project__c != null/* && performRoundRobin.equalsIgnoreCase('Yes')*/) {
                    CPProjectForAssignment.add(l);
                }
            }
            
        }
        if(!CPProjectForAssignment.isEmpty() && CPProjectForAssignment != null) {
            AssignCPProject(CPProjectForAssignment);
        }
    }
    
    public static void AssignCPProject(List<CP_Lead__c> CPProjectForAssignment) {
        Map<String, CP_Project__c> cpProjectMap = new Map<String, CP_Project__c>();
        Set<Id> channelPartnerIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        List<CP_Project__c> cpProjects = new List<CP_Project__c>();
        
        
        for (CP_Lead__c lead : CPProjectForAssignment) {
            if (lead.Channel_Partner_Name__c != null) {
                channelPartnerIds.add(lead.Channel_Partner_Name__c);
            }
            if (lead.Project__c != null) {
                projectIds.add(lead.Project__c);
            }
        }
        
        if(!channelPartnerIds.isEmpty() && projectIds != null){
            cpProjects = [SELECT Id, Channel_Partner__c, Project_Name__c FROM CP_Project__c
                          WHERE Channel_Partner__c IN :channelPartnerIds AND Project_Name__c IN :projectIds
                         ];
        }
        System.debug('cpProjects: '+cpProjects);
        
        if(!cpProjects.isEmpty() && cpProjects != null){
            for (CP_Project__c cpProject : cpProjects) {
                if(!cpProjectMap.containsKey(cpProject.Channel_Partner__c + '-' + cpProject.Project_Name__c)) {
                    cpProjectMap.put(cpProject.Channel_Partner__c + '-' + cpProject.Project_Name__c, cpProject);
                } else {
                    cpProjectMap.get(cpProject.Channel_Partner__c + '-' + cpProject.Project_Name__c);
                }
            }
        }
        System.debug('cpProjectMap: '+cpProjectMap);
        if(!cpProjectMap.isEmpty() && cpProjectMap != null){
            for (CP_Lead__c lead : CPProjectForAssignment) {
                if(!cpProjectMap.containsKey(lead.Channel_Partner_Name__c + '-' + lead.Project__c)) {
                    lead.CP_Project__c = cpProjectMap.get(lead.Channel_Partner_Name__c + '-' + lead.Project__c).Id; 
                } else {
                    lead.CP_Project__c = cpProjectMap.get(lead.Channel_Partner_Name__c + '-' + lead.Project__c).Id; 
                }
            }
        }
    } 
}