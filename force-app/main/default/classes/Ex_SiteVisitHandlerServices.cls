// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_SiteVisitHandlerServices {
    public static void updateSalesManagerAvailability(Set<Id> uIdSet) {
        List<Team_Member__c> tmList = new List<Team_Member__c>();
        List<Team_Member__c> updateTMList = new List<Team_Member__c>();
        
        tmList = [Select Id, Availability__c, User__c from Team_Member__c 
                  where User__c IN: uIdSet AND Availability__c = false AND Team__r.Team_Type__c = 'Sales Team'];
        
        if(!tmList.isEmpty() && tmList != null) {
            for(Team_Member__c tm: tmList) {
                tm.Availability__c = true;
                updateTMList.add(tm);
            }
        }
        if(!updateTMList.isEmpty() && updateTMList != null)
            update updateTMList;
    }
    public static void fetchSVDateonOpportunity(Set<Id> oppIdSetForSV) {
        List<String> formattedVisits = new List<String>();
        List<Site_Visit__c> svList = new  List<Site_Visit__c>();
        List<Opportunity__c> oppList  = new List<Opportunity__c>();
        
        if(oppIdSetForSV != null){
            svList =  [Select Id, Name, CreatedDate from Site_Visit__c where Opportunity__c IN: oppIdSetForSV Order BY Name DESC];
            System.debug('svList: '+svList);
        }
        if(svList != null && !svList.isEmpty()){
            for (Site_Visit__c sv : svList) {
                if (sv.CreatedDate != null) {
                    String formattedDate = sv.CreatedDate.format('dd MMM yyyy hh:mm a') + ' IST';
                    formattedVisits.add(sv.Name + ' ' + formattedDate);
                }
            }
            String siteVisitDetails = String.join(formattedVisits, '\n');
            System.debug('siteVisitDetails: '+siteVisitDetails);
            
            
            if (!formattedVisits.isEmpty()) {
                Opportunity__c opp = [SELECT Id, SV_Date_History__c FROM Opportunity__c WHERE Id = :oppIdSetForSV LIMIT 1];
                opp.SV_Date_History__c = siteVisitDetails;
                oppList.add(opp);
            }
            System.debug('updateoppListWithDate:'+oppList);
            if(oppList != null && !oppList.isEmpty()){
                update oppList;
            }
        }
    }
}