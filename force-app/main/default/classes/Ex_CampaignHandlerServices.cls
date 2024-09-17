//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 30-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_CampaignHandlerServices {
    public static void createCampaignPerformance(Set<Id> cIdSet){
        List<Campaign_Performance__c> cpList = new List<Campaign_Performance__c>();
        List<Campaign__c> CampaignsToUpdate = new List<Campaign__c>();
        
        List<Campaign__c> cList = [Select Id, Name, Active__c, Campaign_Code__c, Start_Date__c, End_Date__c from Campaign__c
                                   where Id IN: cIdSet];
        system.debug('cList: '+cList);
        
        if(!cList.isEmpty()) {
            for(Campaign__c c : cList) {
                Campaign_Performance__c cp = new Campaign_Performance__c();
                cp.Campaign__c = c.Id;
                cp.Date__c = system.today();
                cpList.add(cp);
                
                c.Campaign_Code__c = c.Id;
                CampaignsToUpdate.add(c);
            }
        }
        if(!cpList.isEmpty() && cpList != null)
            insert cpList;
        if(!CampaignsToUpdate.isEmpty() && CampaignsToUpdate != null)
            update CampaignsToUpdate;
    }
    
    public static void updateCampaignDetails(Set<Id> cIdSet, String objectType) {
        List<Campaign__c> cList = new List<Campaign__c>();
        Map<Id, Campaign__c> campaignMap = new Map<Id, Campaign__c>();
        List<AggregateResult> objectList = new List<AggregateResult>();
        List<Campaign__c> updateCampaignList = new List<Campaign__c>();
        
        cList = [Select Id, Name, Actual_Opportunities__c, Campaign_Code__c, Actual_Visits__c, Actual_Bookings__c, Actual_Revenue__c from Campaign__c
                 where Id IN: cIdSet];
        system.debug('cList: '+cList);
        
        if(!cList.isEmpty() && cList != null) {
            for(Campaign__c c: cList) {
                campaignMap.put(c.Id, c);
            }
        }
        
        if(objectType.equalsIgnoreCase('Opportunity')) {
            objectList = [Select Campaign__c, COUNT(Id) oppCount from Opportunity__c where Campaign__c IN: cIdSet GROUP BY Campaign__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign__c'));
                        c.Actual_Opportunities__c = (Decimal) ag.get('oppCount');
                        updateCampaignList.add(c);
                    }
                }
            }
        } else if(objectType.equalsIgnoreCase('Site Visit')) {
            objectList = [Select Campaign__c, SUM(SV_Count__c) svCount from Opportunity__c where Campaign__c IN: cIdSet GROUP BY Campaign__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign__c'));
                        c.Actual_Visits__c = (Decimal) ag.get('svCount');
                        updateCampaignList.add(c);
                    }
                }
            }
        } else if(objectType.equalsIgnoreCase('Booking')) {
            objectList = [Select Campaign__c, COUNT(Id) bookingCount, SUM(Amount__c) bookingAmount from Opportunity__c 
                          where Stage__c = 'Booked' AND Campaign__c IN: cIdSet GROUP BY Campaign__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign__c'));
                        c.Actual_Bookings__c = (Decimal) ag.get('bookingCount');
                        c.Actual_Revenue__c = (Decimal) ag.get('bookingAmount');
                        updateCampaignList.add(c);
                    }
                }
            }
        }
        if(!updateCampaignList.isEmpty() && updateCampaignList != null)
            update updateCampaignList;
    }
    
    public static void calculateCampaignPerformance(String Type, List<Lead__c> leadList, List<Task> taskList) {
        List<Campaign_Performance__c> campaignPerformanceList = new List<Campaign_Performance__c>();
        List<Campaign_Performance__c> updateCampaignPerformanceList = new List<Campaign_Performance__c>();
        
        if(Type == 'Lead') {
            campaignPerformanceList = [Select Id, Name, Date__c, Lead_Count__c, Campaign__c from Campaign_Performance__c
                                       where Campaign__c =: leadList[0].Campaign__c AND Date__c =: leadList[0].Created_Date__c ORDER BY CreatedDate ASC LIMIT 1];
            system.debug('campaignPerformanceList: '+campaignPerformanceList);
            
            if(!campaignPerformanceList.isEmpty()) {
                if(campaignPerformanceList[0].Lead_Count__c == null) {
                    campaignPerformanceList[0].Lead_Count__c = 0;
                }
                campaignPerformanceList[0].Lead_Count__c = campaignPerformanceList[0].Lead_Count__c + 1;
                updateCampaignPerformanceList.add(campaignPerformanceList[0]);
            }                            
        } else if(Type == 'Task') {
            campaignPerformanceList = [Select Id, Name, Date__c, Enquiry_Count__c, Campaign__c from Campaign_Performance__c
                                       where Campaign__c =: taskList[0].Campaign__c AND Date__c =: taskList[0].Created_Date__c ORDER BY CreatedDate ASC LIMIT 1];
            system.debug('campaignPerformanceList: '+campaignPerformanceList);
            
            if(!campaignPerformanceList.isEmpty()) {
                if(campaignPerformanceList[0].Enquiry_Count__c == null) {
                    campaignPerformanceList[0].Enquiry_Count__c = 0;
                }
                campaignPerformanceList[0].Enquiry_Count__c = campaignPerformanceList[0].Enquiry_Count__c + 1;
                updateCampaignPerformanceList.add(campaignPerformanceList[0]);
            }
        }
        if(!updateCampaignPerformanceList.isEmpty() && updateCampaignPerformanceList != null)
            update updateCampaignPerformanceList;
    }
}