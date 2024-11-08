public class Ex_InterestCalculateManagementServices {
 
    /*public static void interestCalculate(Map<Id, Date> boookingInterestDateMap) {
        Map<String, List<Demand__c>> pendingDemandMap = new Map<String, List<Demand__c>>();
        List<Demand__c> updateDemandList = new List<Demand__c>();
        
        pendingDemandMap = getPendingDemandMap(boookingInterestDateMap.keySet());
        
        if(!pendingDemandMap.isEmpty() && pendingDemandMap != null) {
            for(Id bId: boookingInterestDateMap.keySet()) {
                if(pendingDemandMap.containsKey(bId)) {
                    for(Demand__c d: pendingDemandMap.get(bId)) {
                        if(boookingInterestDateMap.get(bId) > d.Due_Date__c && d.Booking__r.Project__r.Rate_of_Interest_Daily__c != null) {
                            Integer noOfDays = 0;
                            if(d.Interest_Calculated_Till__c != null) {
                                noOfDays = d.Interest_Calculated_Till__c.daysBetween(boookingInterestDateMap.get(bId));
                            } else {
                                noOfDays = d.Due_Date__c.daysBetween(boookingInterestDateMap.get(bId));
                            }
                            //Decimal interestAmount = (((d.Total_Amount_Remaining__c + d.Total_Tax_Remaining__c) * (d.Booking__r.Project__r.Rate_of_Interest_Daily__c)) * noOfDays).setscale(2, RoundingMode.HALF_UP);
                            Decimal interestAmount =  ((d.Total_Amount_Remaining__c + d.Total_Tax_Remaining__c) * ((1 + d.Booking__r.Project__r.Rate_of_Interest_Daily__c).pow(noOfDays)) - (d.Total_Amount_Remaining__c + d.Total_Tax_Remaining__c));
                            d.Total_Interest_Amount__c = d.Total_Interest_Amount__c + interestAmount.setscale(2, RoundingMode.HALF_UP);
                            
                            Decimal interestRatePercentage = Decimal.valueOf(Label.Interest_GST);
                            //system.debug('interestRatePercentage---->'+interestRatePercentage);
                            Decimal interestRateFraction = interestRatePercentage / 100;
							//system.debug('interestRateFraction---->'+interestRateFraction);
                            Decimal interestOnTaxAmount = (d.Total_Interest_Amount__c * interestRateFraction).setscale(2, RoundingMode.HALF_UP);
                            //system.debug('interestOnTaxAmount---->'+interestOnTaxAmount);
							d.Total_Tax_On_Interest_Amount__c = interestOnTaxAmount;
                            d.Interest_Calculated_Till__c = boookingInterestDateMap.get(bId);
                            updateDemandList.add(d);
                        }
                    }
                }
            }
        }
        if(!updateDemandList.isEmpty() && updateDemandList != null)
            update updateDemandList;
    }
    
    public static Map<String, List<Demand__c>> getPendingDemandMap(Set<Id> bookingIdSet) {
        Map<String, List<Demand__c>> pendingDemandMap = new Map<String, List<Demand__c>>();
        List<Demand__c> demandList = [Select Id, Booking__c, Quotation__c, Payment_Milestone__c, Milestone_Name__c, Due_Date__c, Invoice_Date__c, Demand_Type__c, Booking__r.Project__r.Rate_of_Interest__c,
                                    Total_Interest_Amount__c, Total_Interest_Amount_Paid__c, Total_Interest_Amount_Waived__c, Total_Interest_Amount_Remaining__c, Interest_Calculated_Till__c,
                                    Total_Tax_On_Interest_Amount__c, Total_Tax_On_Interest_Amount_Paid__c, Total_Tax_On_Interest_Amount_Waived__c, Total_GST_On_Interest_Amount_Remaining__c,
                                    Total_Amount_Demanded__c, Total_Amount_Paid__c, Total_Amount_Remaining__c, Total_Tax_Demanded__c, Total_Tax_Paid__c, Total_Tax_Remaining__c,Booking__r.Project__r.Rate_of_Interest_Daily__c,
                                    Agreement_Value_Demanded__c, Agreement_Value_Paid__c, Agreement_Value_Remaining__c, Agreement_Value_Tax_Demanded__c, Agreement_Value_Tax_Paid__c, Agreement_Value_Tax_Remaining__c,
                                    Other_Charges_Demanded__c, Other_Charges_Paid__c, Other_Charges_Remaining__c, Other_Charges_Tax_Demanded__c, Other_Charges_Tax_Paid__c, Other_Charges_Tax_Remaining__c
                                    from Demand__c where Booking__c IN: bookingIdSet AND 
                                    (Total_Amount_Remaining__c > 0 OR Total_Tax_Remaining__c > 0)
                                    ORDER BY Due_Date__c ASC];
        //system.debug('demandList: '+demandList);

        if(demandList != null) {
            for(Demand__c d: demandList) {
                if(pendingDemandMap.containsKey(d.Booking__c)) {
                    pendingDemandMap.get(d.Booking__c).add(d);
                } else {
                    List<Demand__c> newList = new List<Demand__c>();
                    newList.add(d);
                    pendingDemandMap.put(d.Booking__c, newList);
                }
            }
        }
        return pendingDemandMap;
    }*/
}