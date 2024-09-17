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
        String virtualNumber;
        String mcubeURL = '';
        Boolean isOffline = false;
        List<Campaign__c> cList = new List<Campaign__c>();
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        List<User> userList = new List<User>();
        
        Id ownerId = null;
        
        fromnumber = RestContext.request.params.get('fromnumber');
        landingnumber = RestContext.request.params.get('landingnumber');
        System.debug('fromnumber::::::'+fromnumber);
        System.debug('landingnumber:::::::::'+landingnumber);
        
        if(String.isNotBlank(landingnumber) && landingnumber != null) {            
            
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
                } else {
                    
                    leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, OwnerId from Lead__c where ((Mobile__c =:fromnumber  OR Alternate_Mobile__c =:fromnumber))
                                AND IsConverted__c  = false ORDER BY LastModifiedDate DESC];
                    system.debug('leadList: '+leadList);
                    
                    if(!leadList.isEmpty() && leadList != null) {
                        ownerId = leadList[0].OwnerId;
                    } else {
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
                            }
                        } catch(Exception ex) {
                            system.debug('Error: '+ex.getMessage());
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
                } else {
                    r.agentId = null;
                    r.agentNo = null;
                }
            } else {
                r.agentId = null;
                r.agentNo = null;
            }
        } else {
            r.agentId = null;
            r.agentNo = null;
        }
        return r;
    }
    global class REST_result{
        webservice String AgentId;
        webservice String AgentNo;
    }
}