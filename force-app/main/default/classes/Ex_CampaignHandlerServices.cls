//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 17-10-2023
//-------------------------------------------//
public class Ex_CampaignHandlerServices {
     public static void createCampaignPerformance(Set<Id> cId) {
        List<Campaign_Performance__c> cpList = new List<Campaign_Performance__c>();
        List<Campaign__c> cList = [Select Id, Name, IsActive__c, Start_Date__c, End_Date__c from Campaign__c 
                                   where Id IN: cId];
        system.debug('cList: '+cList);
        
        if(!cList.isEmpty()) {
            Date today = system.today();
            for(Campaign__c c : cList) {
                if((c.Start_Date__c != null && c.Start_Date__c <= today ) || (c.End_Date__c >= today && c.Start_Date__c != null && c.Start_Date__c <= today )){
                    Campaign_Performance__c cp = new Campaign_Performance__c();
                    cp.Campaign__c = c.Id;
                    cp.Date__c = system.today();
                    cpList.add(cp);
                }
            }
            system.debug('cpList: '+cpList);
            system.debug('cpList Size: '+cpList.size());
            if(!cpList.isEmpty())
                insert cpList;
        }
    }
    public static void updateCampaignDetails(Set<Id> cIdSet, String objectType) {
        List<Campaign__c> cList = new List<Campaign__c>();
        Map<Id, Campaign__c> campaignMap = new Map<Id, Campaign__c>();
        List<AggregateResult> objectList = new List<AggregateResult>();
        List<Campaign__c> updateCampaignList = new List<Campaign__c>();
        
        cList = [Select Id, Name /*, Converted_Leads_Count__c,*/, Actual_Visits__c, Actual_Bookings__c from Campaign__c
                 where Id IN: cIdSet];
        system.debug('cList: '+cList);
        
        if(!cList.isEmpty() && cList != null) {
            for(Campaign__c c: cList) {
                campaignMap.put(c.Id, c);
            }
        }
        
        if(objectType.equalsIgnoreCase('Opportunity')) {
            objectList = [Select Campaign__c, COUNT(Id) oppCount from Opportunity__c where  Campaign__c IN: cIdSet GROUP BY Campaign__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign__c'));
                      //  c.Converted_Leads_Count__c = (Decimal) ag.get('oppCount');
                        updateCampaignList.add(c);
                    }
                }
            }
        } else if(objectType.equalsIgnoreCase('Site Visit')) {
            objectList = [Select Campaign__c, SUM(Site_Visit_Count__c) svCount from Opportunity__c where Campaign__c IN: cIdSet GROUP BY Campaign__c];
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
        } /*else if(objectType.equalsIgnoreCase('Booking')) {
            objectList = [Select Campaign__c, COUNT(Id) bookingCount from Opportunity__c  Where Stage__c = 'Booked' AND Campaign__c IN: cIdSet  GROUP BY Campaign__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign__c'));
                       // c.Booking_Count__c = (Decimal) ag.get('bookingCount');
                       // system.debug('bookingCount:::'+c.Booking_Count__c);
                        updateCampaignList.add(c);
                    }
                }
            }
        }*/
        
        if(!updateCampaignList.isEmpty() && updateCampaignList != null)
            update updateCampaignList;
    }
    
    
    public static void calculateCampaignPerformance(String Type, List<Lead__c> leadList, List<Task> taskList) {
        List<Campaign_Performance__c> campaignPerformanceList = new List<Campaign_Performance__c>();
        List<Campaign_Performance__c> updateCampaignPerformanceList = new List<Campaign_Performance__c>();
        
        if(Type == 'Lead') {
            system.debug('InsideLead'+ Type);
            campaignPerformanceList = [Select Id, Name, date__c, Lead_Count__c, Campaign__c from Campaign_Performance__c
                                        where Campaign__c =: leadList[0].Campaign__c AND date__c =: leadList[0].Created_Date__c LIMIT 1];
            system.debug('campaignPerformanceList: '+campaignPerformanceList);
            
            if(!campaignPerformanceList.isEmpty()) {
                if(campaignPerformanceList[0].Lead_Count__c == null) {
                    campaignPerformanceList[0].Lead_Count__c = 0;
                    system.debug('Lead Count:'+campaignPerformanceList[0].Lead_Count__c);
                }
                campaignPerformanceList[0].Lead_Count__c = campaignPerformanceList[0].Lead_Count__c + 1;
                updateCampaignPerformanceList.add(campaignPerformanceList[0]);
            }                            
        } else if(Type == 'Task') {
            campaignPerformanceList = [Select Id, Name, date__c, Enquiry_Count__c, Campaign__c from Campaign_Performance__c
                                        where Campaign__c =: taskList[0].Campaign__c AND date__c =: taskList[0].Created_Date__c LIMIT 1];
            system.debug('campaignPerformanceList: '+campaignPerformanceList);
            
            if(!campaignPerformanceList.isEmpty()) {
                if(campaignPerformanceList[0].Enquiry_Count__c == null) {
                    campaignPerformanceList[0].Enquiry_Count__c = 0;
                }
                campaignPerformanceList[0].Enquiry_Count__c = campaignPerformanceList[0].Enquiry_Count__c + 1;
                updateCampaignPerformanceList.add(campaignPerformanceList[0]);
            }
        }
        system.debug('updateCampaignPerformanceList: '+updateCampaignPerformanceList);
        if(!updateCampaignPerformanceList.isEmpty())
            update updateCampaignPerformanceList;
    }
}