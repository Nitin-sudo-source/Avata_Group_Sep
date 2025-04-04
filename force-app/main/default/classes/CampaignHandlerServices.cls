//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class CampaignHandlerServices {
    public static void createCampaignPerformance(Set<Id> cId) {
        List<Campaign_Performance__c> cpList = new List<Campaign_Performance__c>();
        List<Campaign__c> cList = [Select Id, Name, Active__c, Start_Date__c, End_Date__c, Performance_Measure_On__c from Campaign__c 
                                where Id IN: cId];
        system.debug('cList: '+cList);
        
        if(!cList.isEmpty()) {
            for(Campaign__c c : cList) {
                Integer fDay   = c.Start_Date__c.day();
                Integer fMonth = c.Start_Date__c.month();
                Integer fYear  = c.Start_Date__c.year();
                Integer tDay   = c.End_Date__c.day();
                Integer tMonth = c.End_Date__c.month();
                Integer tYear  = c.End_Date__c.year();
                Date fromDate  = Date.newInstance(fYear, fMonth, fDay);
                Date toDate    = Date.newInstance (tYear, tMonth, tDay);
                System.debug(fromDate +' : '+ toDate);
                
                if(c.Performance_Measure_On__c == 'Daily') {
                    while(fromDate <= toDate) {
                        Campaign_Performance__c cp = new Campaign_Performance__c();
                        cp.Campaign__c = c.Id;
                        cp.Start_Date__c = fromDate;
                        cp.End_Date__c = fromDate;
                        cpList.add(cp);
                        
                        //Add 1 Day In From Date
                        fromDate = fromDate.addDays(1);
                    }
                } else if(c.Performance_Measure_On__c == 'Weekly') {
                    while(fromDate <= toDate) {
                        Campaign_Performance__c cp = new Campaign_Performance__c();
                        cp.Campaign__c = c.Id;
                        cp.Start_Date__c = fromDate;
                        Date endDate = fromDate.addDays(6);
                        if(toDate > endDate)
                            cp.End_Date__c = endDate;
                        else
                            cp.End_Date__c = toDate;
                        cpList.add(cp);
                        
                        //Add 7 Day In From Date
                        fromDate = fromDate.addDays(7);
                    }
                } /*else if (c.Performance_measure_on__c == 'Fortnight'){
                     while(fromDate <= toDate) {
                        Campaign_Performance__c cp = new Campaign_Performance__c();
                        cp.Campaign__c = c.Id;
                        cp.Start_Date__c = fromDate;
                        Date endDate = fromDate.addDays(13);
                        if(toDate > endDate)
                            cp.End_Date__c = endDate;
                        else
                            cp.End_Date__c = toDate;
                        cpList.add(cp);
                        
                        //Add 14 Day In From Date
                        fromDate = fromDate.addDays(14);
                    }
               }*/ else if(c.Performance_Measure_On__c == 'Monthly') {
                    while(fromDate <= toDate) {
                        Campaign_Performance__c cp = new Campaign_Performance__c();
                        if(fMonth == tMonth && fYear == tYear) {
                            cp.Campaign__c = c.Id;
                            cp.Start_Date__c = fromDate;
                            cp.End_Date__c = toDate;
                            cpList.add(cp);
                        } else {
                            cp.Campaign__c = c.Id;
                            cp.Start_Date__c = fromDate;
                            Date endDate = Date.newInstance(fromDate.year(), fromDate.month(), Date.daysInMonth(fromDate.year(), fromDate.month()));
                            if(toDate > endDate)
                                cp.End_Date__c = endDate;
                            else
                                cp.End_Date__c = toDate;
                            cpList.add(cp);
                        } 
                        fromDate = fromDate.addMonths(1).toStartOfMonth();
                    }
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
        
        cList = [Select Id, Name, Converted_Leads_Count__c, Site_Visit_Count__c, Booking_Count__c from Campaign__c
                 where Id IN: cIdSet];
        system.debug('cList: '+cList);
        
        if(!cList.isEmpty() && cList != null) {
            for(Campaign__c c: cList) {
                campaignMap.put(c.Id, c);
            }
        }
        
        if(objectType.equalsIgnoreCase('Opportunity')) {
            objectList = [Select Campaign_Custom__c, COUNT(Id) oppCount from Opportunity__c where Campaign_Custom__c IN: cIdSet GROUP BY Campaign_Custom__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign_Custom__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign_Custom__c'));
                        c.Converted_Leads_Count__c = (Decimal) ag.get('oppCount');
                        updateCampaignList.add(c);
                    }
                }
            }
        } else if(objectType.equalsIgnoreCase('Site Visit')) {
            objectList = [Select Campaign_Custom__c, SUM(Site_Visit_Count__c) svCount from Opportunity__c where Campaign_Custom__c IN: cIdSet GROUP BY Campaign_Custom__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign_Custom__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign_Custom__c'));
                        c.Site_Visit_Count__c = (Decimal) ag.get('svCount');
                        updateCampaignList.add(c);
                    }
                }
            }
        }/* else if(objectType.equalsIgnoreCase('Booking')) {
            objectList = [Select Campaign_Custom__c, COUNT(Id) bookingCount from Opportunity__c where Campaign_Custom__c IN: cIdSet  GROUP BY Campaign_Custom__c];
            system.debug('objectList: '+objectList);
            
            if(!objectList.isEmpty() && objectList != null) {
                for(AggregateResult ag: objectList) {
                    if(campaignMap.containsKey((String) ag.get('Campaign_Custom__c'))) {
                        Campaign__c c = campaignMap.get((String) ag.get('Campaign_Custom__c'));
                        c.Booking_Count__c = (Decimal) ag.get('bookingCount');
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
            campaignPerformanceList = [Select Id, Name, Start_Date__c, End_Date__c, Lead_Count__c, Campaign__c from Campaign_Performance__c
                                        where Campaign__c =: leadList[0].Campaign_Custom__c AND Start_Date__c <=: leadList[0].Created_Date__c
                                        AND End_Date__c >=: leadList[0].Created_Date__c LIMIT 1];
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
            campaignPerformanceList = [Select Id, Name, Start_Date__c, End_Date__c, Enquiry_Count__c, Campaign__c from Campaign_Performance__c
                                        where Campaign__c =: taskList[0].Campaign__c AND Start_Date__c <=: taskList[0].Created_Date__c
                                        AND End_Date__c >=: taskList[0].Created_Date__c LIMIT 1];
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
    
    public static void createCampaignMember(List<Lead__c> leadList) {
        List<CampaignMember> memberList = new List<CampaignMember>();
        Map<String, List<Lead__c>> campaignLeadMap = new Map<String, List<Lead__c>>();
        Map<String, Campaign__c> campaignMap = new Map<String, Campaign__c>();
        List<Campaign__c> cList = new List<Campaign__c>();
        
        for(Lead__c l: leadList) {
            if(!campaignLeadMap.containsKey(l.Campaign_Code__c)) {
                List<Lead__c> lList = new List<Lead__c>();
                lList.add(l);
                campaignLeadMap.put(l.Campaign_Code__c, lList);
            } else {
                campaignLeadMap.get(l.Campaign_Code__c).add(l);
            }
        }
        
        if(campaignLeadMap != null && !campaignLeadMap.isEmpty()) {
            cList = [Select Id, Name, Campaign_Code__c, Active__c, Start_Date__c, End_Date__c from Campaign__c where Campaign_Code__c IN: campaignLeadMap.keySet() AND Active__c = true];
            system.debug('cList: '+cList);
            
            if(!cList.isEmpty() && cList != null) {
                for(Campaign__c c: cList) { 
                    campaignMap.put(c.Campaign_Code__c, c);
                }
            }
        }
        
        if(campaignMap != null && !campaignMap.isEmpty()) {
            for(String code: campaignMap.keySet()) {
                List<Lead__c> getLeadList = new List<Lead__c>();
                getLeadList = campaignLeadMap.get(code);
                
                if(!getLeadList.isEmpty() && getLeadList != null) {
                    for(Lead__c l: getLeadList) {
                        CampaignMember cm = new CampaignMember(CampaignId = campaignMap.get(code).Id, LeadId = l.Id, Status = 'Responded');
                    	memberList.add(cm);
                    }
                }
            }
        }
        if(!memberList.isEmpty() && memberList != null)
            insert memberList;
    }
}