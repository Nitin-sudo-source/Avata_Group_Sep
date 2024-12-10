//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 12-09-2024
//  Author: Sarjerao
//-------------------------------------------//
@RestResource(urlMapping='/CTI/routeCall/')
global class Ex_RESTCTIAgentServices {
    @HttpPOST
    global static Rest_result getAgentId() {
        Rest_result r = new Rest_result();
        String campaignId;
        String fromnumber;
        String landingnumber;
        String IVRSelection;
        String campaignCode;
        String campaignSource;
        String campaignLeadSource;
        String campaignLeadSubSource;
        String SourceDescription;
        String projectId;
        String cpProjectId;
        String cpId;
        String virtualNumber;
        String mcubeURL = '';
        String recordId = '';
        Boolean isOffline = false;
        List<Campaign__c> cList = new List<Campaign__c>();
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        List<User> userList = new List<User>();
        List<CP_Project__c>cpprList = new List<CP_Project__c>();
        List<CP_Lead__c> cpleadList = new List<CP_Lead__c>();
        
        Id ownerId = null;
        
        fromnumber = RestContext.request.params.get('fromnumber');
        landingnumber = RestContext.request.params.get('landingnumber');
        System.debug('fromnumber::::::'+fromnumber);
        System.debug('landingnumber:::::::::'+landingnumber);
        
        if(String.isNotBlank(landingnumber) && landingnumber != null){  
            //check if cp project exist with DID && CP lead exist fromnumber 
            cpprList = [SELECT Id,DID_1__c, DID_2__c, Project_Name__c, Channel_Partner__c,Sourcing_Manager__c, OwnerId FROM CP_Project__c
                        WHERE Project_Name__c != null AND (DID_1__c =: landingnumber OR DID_2__c=:landingnumber) order by CreatedDate];
            System.debug('cpprList '+cpprList);
            
            if(cpprList != null && cpprList.size()>0){
                if(fromnumber.length() > 10){
                    fromnumber = fromnumber.substring(fromnumber.length()-10);
                }
                cpleadList = [Select Id , Name, Mobile__c, Sourcing_Manager__c,OwnerId FROM CP_Lead__c
                              Where CP_Project__c =:cpprList[0].Id AND ((Mobile__c =:fromnumber  OR Phone__c =:fromnumber))];
                
                system.debug('cpleadList '+cpleadList);
                if(cpleadList != null && !cpleadList.isEmpty()){
                    /*if(cpleadList[0].Sourcing_Manager__c != null)
                        ownerId = cpleadList[0].Sourcing_Manager__c;
                    else*/
                        ownerId = cpleadList[0].OwnerId;
                        recordId = cpleadList[0].Id;
                }else{
                    //if no cp lead then create new
                    if(cpprList[0].Id!= null)
                        cpProjectId = cpprList[0].Id;
                    if(cpprList[0].Project_Name__c!= null)
                        projectId = cpprList[0].Project_Name__c;
                    if(cpprList[0].Channel_Partner__c!=null)
                        cpId = cpprList[0].Channel_Partner__c;
                    virtualNumber = landingnumber;
                    
                    CP_Lead__c cl = new CP_Lead__c();
                    cl.First_Name__c = 'Incoming';
                    cl.Last_Name__c = 'Customer';
                    cl.Mobile__c = fromnumber;
                    cl.CP_Project__c = cpProjectId;
                    cl.Project__c = projectId;
                    cl.Channel_Partner_Name__c = cpId;
                    if(cpprList[0].Sourcing_Manager__c != null){
                        cl.Sourcing_Manager__c = cpprList[0].Sourcing_Manager__c;
                        cl.OwnerId = cpprList[0].Sourcing_Manager__c; 
                    }
                    else 
                        cl.OwnerId = cpprList[0].OwnerId;
                    
                    try{
                        insert Cl;
                        List<CP_Lead__c> getCPLeadList = [Select Id, OwnerId from CP_Lead__c where Id =: Cl.Id];
                        system.debug('getCPLeadList: '+getCPLeadList);
                        if(!getCPLeadList.isEmpty() && getCPLeadList != null){
                            ownerId = getCPLeadList[0].OwnerId;
                            recordId = getCPLeadList[0].Id;
                        }
                    } catch(Exception ex) {
                        system.debug('Error: '+ex.getMessage());
                    }
                }
                
            }
            else{
                //if no cp project with DID then find Campaign
                cList = [Select Id, Virtual_Number__c, Lead_Source__c, Lead_Sub_Source__c, Source_Description__c, Project__c, Campaign_Code__c, Active__c from Campaign__c
                         where Active__c = true AND Is_CTI_Campaign__c = true AND Virtual_Number__c =: landingnumber];
                system.debug('cList: '+cList);
                
                if(!cList.isEmpty() && cList != null) {
                    campaignId = cList[0].Id;
                    campaignCode = cList[0].Campaign_Code__c;
                    campaignSource = cList[0].Lead_Source__c;
                    campaignLeadSource = cList[0].Lead_Sub_Source__c;
                    SourceDescription = cList[0].Source_Description__c;
                    projectId = cList[0].Project__c;
                    virtualNumber = cList[0].Virtual_Number__c;
                }
                
                if(String.isNotBlank(fromnumber) && fromnumber != null) {
                    if(fromnumber.length() > 10) {
                        fromnumber = fromnumber.substring(fromnumber.length()-10);
                    }
                    accList = [Select Id, Name, OwnerId from Account where (PersonMobilePhone =: fromnumber OR Phone =: fromnumber) AND RecordType.DeveloperName = 'PersonAccount'];
                    System.debug('accList: '+accList);
                    if(!accList.isEmpty() && accList != null) {
                        ownerId = accList[0].OwnerId;
                        recordId = accList[0].Id;
                    } else {
                        
                        leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, OwnerId from Lead__c where ((Mobile__c =:fromnumber  OR Alternate_Mobile__c =:fromnumber))
                                    AND IsConverted__c  = false ORDER BY LastModifiedDate DESC];
                        system.debug('leadList: '+leadList);
                        
                        if(!leadList.isEmpty() && leadList != null) {
                            ownerId = leadList[0].OwnerId;
                            recordId = leadList[0].Id;
                        }else{
                            Lead__c l = new Lead__c();
                            l.First_Name__c = 'Incoming';
                            l.Last_Name__c = 'Customer';
                            l.Mobile__c = fromnumber;
                            l.Campaign__c = campaignId;
                            l.Campaign_Code__c = campaignCode;
                            l.Project__c = projectId;
                            l.Lead_Created_From__c = 'CTI';
                            l.Apply_Round_Robin__c = true;
                            l.Source_Description__c = SourceDescription;
                            l.Lead_Source__c = campaignSource;
                            l.Lead_Sub_Source__c = campaignLeadSource;
                            try {
                                insert l;
                                List<Lead__c> getList = [Select Id, OwnerId from Lead__c where Id =: l.Id];
                                system.debug('getList: '+getList);
                                
                                
                                if(!getList.isEmpty() && getList != null) {
                                    ownerId = getList[0].OwnerId;
                                    recordId = getList[0].Id;
                                }
                            } catch(Exception ex) {
                                system.debug('Error: '+ex.getMessage());
                            }
                        }
                    }
                }
            }
        }
        
        if(ownerId != null) {
            userList = [Select Id, Agent_Id__c, Agent_Phone__c,MobilePhone from User where Id =: ownerId];
            system.debug('userList: '+userList);
            
            if(!userList.isEmpty() && userList != null) {
                if(userList[0].Agent_Id__c != null && userList[0].Agent_Id__c != '' && userList[0].MobilePhone != null && userList[0].MobilePhone != '') {
                    r.agentId = userList[0].Agent_Id__c;
                    r.agentNo = userList[0].MobilePhone;
                    if(String.isNotBlank(recordId))
                        r.recordId = recordId;
                } else {
                    r.agentId = null;
                    r.agentNo = null;
                    r.recordId = null;
                }
            } else {
                r.agentId = null;
                r.agentNo = null;
                r.recordId = null;
            }
        } else {
            r.agentId = null;
            r.agentNo = null;
            r.recordId = null;
        }
        return r;
    }
    global class REST_result{
        webservice String AgentId;
        webservice String AgentNo;
        webservice String recordId;
        
    }
}