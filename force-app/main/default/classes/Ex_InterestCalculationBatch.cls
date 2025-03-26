global class Ex_InterestCalculationBatch implements Database.Batchable <sObject>, Schedulable {
    public String query;
    public Date cDate = system.today();
    
    public Ex_InterestCalculationBatch() {
        query = 'Select Id, Name, Booking__c from Demand__c'
                +' where (Demand_Status__c = \'Raised\') AND (Total_Amount_Remaining__c > 0 OR Total_Tax_Remaining__c > 0) AND ((Interest_Calculated_Till__c = null AND Due_Date__c <: cDate) OR (Interest_Calculated_Till__c != null AND Interest_Calculated_Till__c <: cDate))';
        system.debug('Query is :::: '+Query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<Demand__c> demandList) {
        system.debug('demandList: '+demandList.size());
        Map<Id, Date> boookingInterestDateMap = new Map<Id, Date>();
        
        if(!demandList.isEmpty() && demandList != null) {
            for(Demand__c d: demandList) {
                if(d.Booking__c != null) {
                    boookingInterestDateMap.put(d.Booking__c, cDate);
                }
            }
        }
        if(!boookingInterestDateMap.isEmpty() && boookingInterestDateMap != null)
            Ex_InterestCalculateManagementServices.interestCalculate(boookingInterestDateMap);
    }
    
    global void finish(Database.BatchableContext info) {     
    }   
    
    global void execute(SchedulableContext sc) {
        Ex_InterestCalculationBatch b = new Ex_InterestCalculationBatch(); 
        database.executebatch(b, 50);
    }
}