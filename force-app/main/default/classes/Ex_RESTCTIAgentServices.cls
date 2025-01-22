@RestResource(urlMapping='/CTI/getAgent/')
global class Ex_RESTCTIAgentServices {
    @HttpPost
    global static Rest_result getAgentId(String mobileNo, String did) {
        Rest_result r = new Rest_result();
        String campaignId;
        String campaignCode;
        String campaignSource;
        String campaignLeadSource;
        String campaignLeadSubSource;
        String projectId;
        String virtualNumber;
        Boolean isOffline = false;
        List<Campaign__c> cList = new List<Campaign__c>();
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        List<User> userList = new List<User>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        Id ownerId = null;
        
        if(String.isNotBlank(did) && did != null) {
            cList = [Select Id, Virtual_Number__c, Source__c, Project__c, Offline_Campaign__c, Campaign_Code__c, Lead_Source__c, Lead_Sub_Source__c from Campaign__c
                     where IsActive__c = true AND Is_CTI_Campaign__c = true AND Virtual_Number__c =: did ];
            system.debug('cList: '+cList);
            
            if(!cList.isEmpty() && cList != null) {
                campaignId = cList[0].Id;
                campaignCode = cList[0].Campaign_Code__c;
                campaignSource = cList[0].Source__c;
                campaignLeadSource = cList[0].Lead_Source__c;
                campaignLeadSubSource = cList[0].Lead_Sub_Source__c;
                projectId = cList[0].Project__c;
                virtualNumber = cList[0].Virtual_Number__c;
                isOffline = cList[0].Offline_Campaign__c;   
            }
            
            if(String.isNotBlank(mobileNo) && mobileNo != null) {
                if(mobileNo.length() > 10) {
                    mobileNo = mobileNo.substring(mobileNo.length()-10);
                }
                oppList = [Select Id, Mobile__c, Phone__c,Project__c,ownerId from Opportunity__c where (Mobile__c =: mobileNo OR Phone__c =: mobileNo ) 
                           AND Project__c =: projectId AND Is_Active__c = true];
                System.debug('oppList: '+oppList);
                
                if(!oppList.isEmpty() && oppList != null) {
                    ownerId = oppList[0].OwnerId;
                } else {
                    leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c, Phone__c, ownerId,Virtual_Number__c from Lead__c where (Mobile__c =: mobileNo OR Phone__c =: mobileNo)
                                    AND Project__c =: projectId AND IsConverted__c = false ORDER BY LastModifiedDate DESC];
                    system.debug('leadList: '+leadList);
                    
                    if(!leadList.isEmpty() && leadList != null) {
                        ownerId = leadList[0].OwnerId;
                    } else {
                        Lead__c l = new Lead__c();
                        l.First_Name__c = 'Incoming';
                        l.Last_Name__c = 'Customer';
                        l.Mobile__c = mobileNo;
                        l.Campaign__c = campaignId;
                        l.Campaign_Code__c = campaignCode;
                        l.Project__c = projectId;
                        l.Lead_Created_From__c = 'CTI';
                        l.Apply_Round_Robin__c = true;
                        l.Source_Description__c = campaignSource;
                        l.Lead_Source__c = campaignLeadSource;
                        l.Lead_Sub_Source__c = campaignLeadSubSource;
                        l.Virtual_Number__c = virtualNumber;
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
                
                if(ownerId != null) {
                    userList = [Select Id, Ozonetel_AgentId__c, Ozontel_Phone__c from User where Id =: ownerId];
                    system.debug('userList: '+userList);
                    
                    if(!userList.isEmpty() && userList != null) {
                        if(userList[0].Ozonetel_AgentId__c != null && userList[0].Ozonetel_AgentId__c != '') {
                            r.agentId = userList[0].Ozonetel_AgentId__c;
                            if(isOffline){
                                r.agentNo = userList[0].Ozontel_Phone__c;
                            }
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
        webservice String agentId;
        webservice String agentNo;
    }
}