public class Ex_BookingHanldlerServices {
    public static void getbookingCancellationUpdate(Set<Id> bookingIds){
        System.debug('bookingIds:'+bookingIds);
        List<Unit__c> updateUnitList = new List<Unit__c>();
        List<Opportunity__c> getoppList = new List<Opportunity__c>();
        List<Unit__c> getUnit = new List<Unit__c>();
        List<Opportunity__c> updateoppList = new List<Opportunity__c>();
        
        getUnit = [SELECT Id, Sales_Status__c, Opportunity__c, Booking__c FROM Unit__c WHERE Booking__c In: bookingIds];
        System.debug('getUnit: '+getUnit);
        if(!getUnit.isEmpty() && getUnit != null){
            for(Unit__c un: getUnit){
                un.Sales_Status__c = 'Vacant';
                un.Opportunity__c = null;
                un.Booking__c = null;
                updateUnitList.add(un);
            }
        }
        
        // update Opportunity record
        getoppList = [SELECT Id, Stage__c, Booking__c FROM Opportunity__c WHERE Booking__c IN: bookingIds];
        if(!getoppList.isEmpty() && getoppList != null){
            for(Opportunity__c opp : getoppList){
                opp.Stage__c = 'Booking Cancelled';
                opp.Booking__c = null;
                updateoppList.add(opp); 
            }
        }
        if(!updateUnitList.isEmpty() && updateUnitList != null)
            update updateUnitList;
        if(!updateoppList.isEmpty() && updateoppList != null)
            update updateoppList;
        
    }
    
    private static Map<Id, Unit__c> getUnitMap(Set<Id> bookingIds) {
        Map<Id, Unit__c> unitMap = new Map<Id, Unit__c>();
        List<Unit__c> unitList = [SELECT Id, Name, Floor__c, Booking__c, Booking__r.Quotation__r.Payment_Scheme__r.Name, 
                                  Tower__c, Configuration_Type__c, Tower__r.Name, Total_Carpet_Sq_Ft__c, 
                                  Booking__r.Booking_Date__c,
                                  Booking__r.Primary_Applicant_Name__c,Booking__r.Primary_Applicant_Mobile__c,Booking__r.Primary_Applicant_Email__c
                                  FROM Unit__c 
                                  WHERE Booking__c = :bookingIds];
        for (Unit__c unit : unitList) {
            unitMap.put(unit.Booking__c, unit);
        }
        return unitMap;
    } 
    
    
    public static Map<Id, Map<String, List<Charge_Details__c>>> getChargeDetailsMap(Set<Id> qIdSet) {
        Map<Id, Map<String, List<Charge_Details__c>>> chargeDetailsMap = new Map<Id, Map<String, List<Charge_Details__c>>>();
        List<Charge_Details__c> chargeDetailList = [Select Id, Name, Quotation__c, Charge_Bucket__c, Charge_Type__c, Charge_Amount__c, Charge_Rate__c, Charge_Percentage__c
                                                    from Charge_Details__c where Quotation__c IN: qIdSet];
        
        if(chargeDetailList != null) {
            for(Charge_Details__c ch: chargeDetailList) {
                if(!chargeDetailsMap.containsKey(ch.Quotation__c)) {
                    Map<String, List<Charge_Details__c>> newMap = new Map<String, List<Charge_Details__c>>();
                    List<Charge_Details__c> newList = new List<Charge_Details__c>();
                    newList.add(ch);
                    newMap.put(ch.Charge_Bucket__c, newList);
                    chargeDetailsMap.put(ch.Quotation__c, newMap);
                } else {
                    Map<String, List<Charge_Details__c>> getMap = chargeDetailsMap.get(ch.Quotation__c);
                    
                    if(!getMap.containsKey(ch.Charge_Bucket__c)) {
                        List<Charge_Details__c> newList = new List<Charge_Details__c>();
                        newList.add(ch);
                        getMap.put(ch.Charge_Bucket__c, newList);
                    } else {
                        getMap.get(ch.Charge_Bucket__c).add(ch);
                    }
                    chargeDetailsMap.get(ch.Quotation__c).putAll(getMap);
                }
            }
        }
        return chargeDetailsMap;
    }
    
    /* public static void handleAgreementValueChange(List<Booking__c> bList) {
Set<Id> bIdSet = new Set<Id>();
Set<Id> qIdSet = new Set<Id>();
Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>();
Map<Id, Quotation__c> quotationMap = new Map<Id, Quotation__c>();
Map<Id, List<Payment_Milestone__c>> paymentMilestoneMap = new Map<Id, List<Payment_Milestone__c>>();
Map<Id, Map<String, List<Charge_Details__c>>> chargeDetailsMap = new Map<Id, Map<String, List<Charge_Details__c>>>();
List<Booking__c> updateBookingList = new List<Booking__c>();
List<Quotation__c> updateQuotationList = new List<Quotation__c>();
List<Payment_Milestone__c> updatePaymentMilestoneList = new List<Payment_Milestone__c>();
Set<Id> chargeSet = new Set<Id>();
List<Charge_Details__c> updateChargeDetails = new List<Charge_Details__c>();

for(Booking__c b: bList) {
bIdSet.add(b.Id);
qIdSet.add(b.Quotation__c);
}
system.debug('bIdSet:'+bIdSet);
system.debug('qIdSet:'+qIdSet);
if(!bIdSet.isEmpty() && bIdSet != null) {
bookingMap = getBookingDetailMap(bIdSet);
}
system.debug('bookingMap'+bookingMap);
if(!qIdSet.isEmpty() && qIdSet != null) {
quotationMap = getQuotationDetailMap(qIdSet);
paymentMilestoneMap = getUnDemandedPaymentMilestoneMap(qIdSet);
chargeDetailsMap = getChargeDetailsMap(qIdSet);
}

system.debug('quotationMap'+quotationMap);
system.debug('paymentMilestoneMap'+paymentMilestoneMap);

if(!bookingMap.isEmpty() && bookingMap != null) {
for(Booking__c b: bookingMap.values()) {
Boolean isAVChange = false;
Boolean isAVTaxChange = false;
Boolean isSDRChange = false;
Decimal diffAmount = b.Updated_Agreement_Value__c - b.Agreement_Value__c;
Decimal diffSDR = 0;


if(b.Agreement_Value__c != b.Updated_Agreement_Value__c) {
b.Agreement_Value__c = b.Agreement_Value__c + diffAmount;
b.Agreement_Value_Tax__c = ((b.Agreement_Value__c / 100) * b.GST__c).setscale(0,RoundingMode.HALF_UP);
isAVChange = true;
}
if(((b.Agreement_Value__c / 100) * b.GST__c).setscale(0,RoundingMode.HALF_UP) != b.Agreement_Value_Tax__c) {
b.Agreement_Value_Tax__c = ((b.Agreement_Value__c / 100) * b.GST__c).setscale(0,RoundingMode.HALF_UP);
isAVTaxChange = true;
}
if(((b.Agreement_Value__c / 100) * b.Stamp_Duty__c).setscale(0,RoundingMode.HALF_UP) != b.SDR_Value__c) {
b.SDR_Value__c = ((b.Agreement_Value__c / 100) * b.Stamp_Duty__c).setscale(0,RoundingMode.HALF_UP);
diffSDR = b.SDR_Value__c;
isSDRChange = true;
}

if(!quotationMap.isEmpty() && quotationMap != null) {
system.debug('quotationMap::'+quotationMap);
if(quotationMap.containsKey(b.Id)) {
Quotation__c q = quotationMap.get(b.Id);

if(q != null) {
if(isAVChange) {
Decimal amount = 0;
Decimal sgst = 0;
Decimal cgst = 0;

for(Integer i = 1; i <= 3; i++) {
if(String.isNotBlank((String)q.get('Charge_Bucket_' + i + '__c'))) {
if(((String)q.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Agreement Value')) {
amount = ((Decimal)q.get('Charge_Bucket_' + i + '_Amount__c') + diffAmount);
sgst = (((amount / 100) * b.GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
cgst = (((amount / 100) * b.GST__c) / 2).setscale(0,RoundingMode.HALF_UP);

q.put('Charge_Bucket_' + i + '_Amount__c', amount);
q.put('Charge_Bucket_' + i + '_SGST__c', sgst);
q.put('Charge_Bucket_' + i + '_CGST__c', cgst);
q.put('Charge_Bucket_' + i + '_Total_Tax__c', sgst + cgst);
}
}
}
}

if(isAVTaxChange) {
Decimal amount = 0;
Decimal sgst = 0;
Decimal cgst = 0;

for(Integer i = 1; i <= 3; i++) {
if(String.isNotBlank((String)q.get('Charge_Bucket_' + i + '__c'))) {
if(((String)q.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Agreement Value')) {
amount = ((Decimal)q.get('Charge_Bucket_' + i + '_Amount__c') + diffAmount);
sgst = (((amount / 100) * b.GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
cgst = (((amount / 100) * b.GST__c) / 2).setscale(0,RoundingMode.HALF_UP);

q.put('Charge_Bucket_' + i + '_SGST__c', sgst);
q.put('Charge_Bucket_' + i + '_CGST__c', cgst);
q.put('Charge_Bucket_' + i + '_Total_Tax__c', sgst + cgst);
}
}
}
}

if (isSDRChange) {
Decimal amount = 0;
Decimal sgst = 0;
Decimal cgst = 0;

if (!chargeDetailsMap.isEmpty() && chargeDetailsMap != null) {
if (chargeDetailsMap.containsKey(q.Id)) {
Map<String, List<Charge_Details__c>> chargeBucketMap = chargeDetailsMap.get(q.Id);

for (Integer i = 1; i <= 3; i++) {
if (String.isNotBlank((String)q.get('Charge_Bucket_' + i + '__c'))) {
Decimal totalStatutoryChargeAmount = 0; // Reset for each bucket
if (chargeBucketMap.containsKey('Statutory Charges')) {
for (Charge_Details__c ch : chargeBucketMap.get('Statutory Charges')) {
System.debug('ch: ' + ch);
if (ch.Charge_Type__c != null && ch.Charge_Type__c.equalsIgnoreCase('Percentage') && ch.Name.equalsIgnoreCase('Stamp Duty')) {
ch.Charge_Percentage__c = b.Stamp_Duty__c;
amount = ((b.Agreement_Value__c / 100) * b.Stamp_Duty__c).setscale(0,RoundingMode.HALF_UP);
sgst = (((amount / 100) * b.Stamp_Duty__c) / 2).setScale(0, RoundingMode.HALF_UP);
cgst = sgst; 
ch.Charge_Amount__c = diffSDR;
if (!chargeSet.contains(ch.Id)) {
updateChargeDetails.add(ch);
chargeSet.add(ch.Id); 
}
} else if (ch.Charge_Type__c != null && ch.Charge_Type__c.equalsIgnoreCase('Percentage')) {
amount = ((b.Agreement_Value__c * ch.Charge_Percentage__c) / 100).setScale(0, RoundingMode.HALF_UP);
sgst = (((amount / 100) * b.GST__c) / 2).setScale(0, RoundingMode.HALF_UP);
cgst = sgst; 
ch.Charge_Amount__c = amount;

if (!chargeSet.contains(ch.Id)) {
updateChargeDetails.add(ch);
chargeSet.add(ch.Id); 
}
} else {
amount = (ch.Charge_Amount__c).setScale(0, RoundingMode.HALF_UP);
sgst = (((amount / 100) * b.GST__c) / 2).setScale(0, RoundingMode.HALF_UP);
cgst = sgst; 
if (!chargeSet.contains(ch.Id)) {
updateChargeDetails.add(ch);
chargeSet.add(ch.Id); 
}
}
if(String.isNotBlank((String)q.get('Charge_Bucket_'+i+'__c')) && ((String)q.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Statutory Charges')) {
amount = ch.Charge_Amount__c;
sgst = (((amount / 100) * b.Stamp_Duty__c) / 2).setscale(0,RoundingMode.HALF_UP);
cgst = (((amount / 100) * b.Stamp_Duty__c) / 2).setscale(0,RoundingMode.HALF_UP);
totalStatutoryChargeAmount += amount;
q.put('Charge_Bucket_' + i + '_Amount__c', totalStatutoryChargeAmount);
q.put('Charge_Bucket_' + i + '_SGST__c', sgst);
q.put('Charge_Bucket_' + i + '_CGST__c', cgst);
q.put('Charge_Bucket_' + i + '_Total_Tax__c', sgst + cgst);
}
}
}
}
}
}
}
}

if(!paymentMilestoneMap.isEmpty() && paymentMilestoneMap != null) {
if(paymentMilestoneMap.containsKey(q.Id)) {
List<Payment_Milestone__c> pmList = paymentMilestoneMap.get(q.Id);

if(pmList != null) {
if(isAVChange || isAVTaxChange) {
Decimal splitAmount = diffAmount / pmList.size();

for(Payment_Milestone__c pm: pmList) {
Decimal sgst = 0;
Decimal cgst = 0;

for(Integer i = 1; i <= 3; i++) {
if(String.isNotBlank((String)pm.get('Charge_Bucket_' + i + '__c'))) {
if(((String)pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Agreement Value')) {
pm.put('Charge_Bucket_' + i + '_Amount__c', (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c') + splitAmount);
sgst = ((((Decimal)pm.get('Charge_Bucket_' + i + '_Amount__c') / 100) * b.GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
cgst = ((((Decimal)pm.get('Charge_Bucket_' + i + '_Amount__c') / 100) * b.GST__c) / 2).setscale(0,RoundingMode.HALF_UP);

pm.put('Charge_Bucket_' + i + '_SGST__c', sgst);
pm.put('Charge_Bucket_' + i + '_CGST__c', cgst);
pm.put('Charge_Bucket_' + i + '_Total_Tax__c', (sgst + cgst));
}
}
}
updatePaymentMilestoneList.add(pm);
}
}
}
}
}
updateQuotationList.add(q);
}
}
}
updateBookingList.add(b);
}
}
System.debug('updateChargeDetails: '+updateChargeDetails);
if(!updateBookingList.isEmpty() && updateBookingList != null)
update updateBookingList;
if(!updateQuotationList.isEmpty() && updateQuotationList != null)
update updateQuotationList;
if(!updateChargeDetails.isEmpty() && updateChargeDetails != null)
update updateChargeDetails;
if(!updatePaymentMilestoneList.isEmpty() && updatePaymentMilestoneList != null)
update updatePaymentMilestoneList;
}*/
    
    public static Map<Id, Booking__c> getBookingDetailMap(Set<Id> bIdSet) {
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>();
        List<Booking__c> bList = [Select Id, Name, Unit__c, Agreement_Value__c, Agreement_Value_Tax__c, SDR_Value__c, SDR_Tax__c, 
                                  Updated_Agreement_Value__c, GST__c, Stamp_Duty__c from Booking__c
                                  where Id IN: bIdSet];
        if(bList != null) {
            for(Booking__c b: bList) {
                bookingMap.put(b.Id, b);
            }
        }
        return bookingMap;
    }
    
    public static Map<Id, Quotation__c> getQuotationDetailMap(Set<Id> qIdSet) {
        Map<Id, Quotation__c> quotationMap = new Map<Id, Quotation__c>();
        List<Quotation__c> qList = new List<Quotation__c>();
        String queryString = '';
        
        for(Integer i = 1; i <= 3; i++) {
            queryString += 'Charge_Bucket_' + i + '__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_Amount__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_CGST__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_SGST__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_Total_Tax__c' + ',';
        }
        queryString += 'Id, Name, Booking__c, CreatedDate ';
        queryString = 'Select ' + queryString + ' from Quotation__c where Id IN';
        queryString += ':qIdSet';
        qList = Database.Query(queryString);
        
        if(!qList.isEmpty() && qList != null) {
            for(Quotation__c q: qList) {
                quotationMap.put(q.Booking__c, q);
            }
        }
        return quotationMap;
    }
    
    public static Map<Id, List<Payment_Milestone__c>> getUnDemandedPaymentMilestoneMap(Set<Id> qIdSet) {
        Map<Id, List<Payment_Milestone__c>> paymentMilestoneMap = new Map<Id, List<Payment_Milestone__c>>();
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        String queryString = '';
        
        for(Integer i = 1; i <= 3; i++) {
            queryString += 'Charge_Bucket_' + i + '__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_Percentage__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_Amount__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_CGST__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_SGST__c' + ',';
            queryString += 'Charge_Bucket_' + i + '_Total_Tax__c' + ',';
        }
        queryString = 'Select ' + queryString + ' Id, Name, Milestone_Name__c, Quotation__c, Is_Raised__c from Payment_Milestone__c where Quotation__c IN';
        queryString += ':qIdSet AND Is_Raised__c = false';
        pmList = Database.Query(queryString);
        system.debug('pmList:'+pmList);
        if(!pmList.isEmpty() && pmList != null) {
            for(Payment_Milestone__c pm: pmList) {
                if(paymentMilestoneMap.containsKey(pm.Quotation__c)) {
                    paymentMilestoneMap.get(pm.Quotation__c).add(pm);
                } else {
                    List<Payment_Milestone__c> newList = new List<Payment_Milestone__c>();
                    newList.add(pm);
                    paymentMilestoneMap.put(pm.Quotation__c, newList);
                }
            }
        }
        return paymentMilestoneMap;
    }
    
    public static void updatePaymentMilestoneDueDate(Map<Id, Booking__c> quotationBookingMap, Set<Id> towerIdSet) {
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> updatePMList = new List<Payment_Milestone__c>();
        Map<Id, Map<String, Construction_Stage__c>> towerConStageMap = new Map<Id, Map<String, Construction_Stage__c>>();
        
        if(!towerIdSet.isEmpty()) {
            List<Construction_Stage__c> csList = [Select Id, Name, Expected_Completion_Date__c, Actual_Completion_Date__c 
                                                  from Construction_Stage__c
                                                  where Tower__c IN: towerIdSet];
            for(Id tId: towerIdSet) {
                Map<String, Construction_Stage__c> cMap = new Map<String, Construction_Stage__c>();
                for(Construction_Stage__c cs: csList) {
                    cMap.put(cs.Id, cs);
                }
                towerConStageMap.put(tId, cMap);
            }
        }
        
        if(quotationBookingMap != null) {
            pmList = [Select Id, Name, Milestone_Type__c, Milestone_Name__c,Is_Due__c, Number_of_Days__c, Due_Date__c, Quotation__c, Construction_Stage__c 
                      from Payment_Milestone__c
                      where Quotation__c IN: quotationBookingMap.keyset()];
            system.debug('pmList: '+pmList);
            
            if(!pmList.isEmpty()) {
                for(id qId: quotationBookingMap.keyset()) {
                    DateTime dtm = quotationBookingMap.get(qId).Booking_Date__c;
                    Date dt = date.newinstance(dtm.year(), dtm.month(), dtm.day());
                    
                    for(Payment_Milestone__c pm: pmList) {
                        if(pm.Quotation__c == qId) {
                            if(String.isNotBlank(pm.Milestone_Type__c) && pm.Milestone_Type__c.equals('Date Linked')) {
                                if(pm.Number_of_Days__c != null) {
                                    pm.Due_Date__c = dt.addDays(Integer.valueOf(pm.Number_of_Days__c));
                                }
                            } else if(String.isNotBlank(pm.Milestone_Type__c) && pm.Milestone_Type__c.equals('Construction Linked')) {
                                Date completionDate = null;
                                Boolean IsMilestoneAchieved = False;
                                Map<String, Construction_Stage__c> conStageMap = towerConStageMap.get(quotationBookingMap.get(qId).Tower__c);
                                Construction_Stage__c cStage = conStageMap.get(pm.Construction_Stage__c);
                                
                                if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c > dt) {
                                    completionDate = cStage.Actual_Completion_Date__c;
                                } else if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c <= dt) {
                                    completionDate = dt.addDays(60);
                                    IsMilestoneAchieved = true;
                                } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c > dt) {
                                    completionDate = cStage.Expected_Completion_Date__c;
                                } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c <= dt) {
                                    completionDate = dt;
                                }
                                if(completionDate == null) {
                                    completionDate = dt.addDays(365);
                                }
                                pm.Due_Date__c = completionDate.addDays(Integer.valueOf(pm.Number_of_Days__c));
                                
                                if(IsMilestoneAchieved) {
                                    pm.Is_Due__c = true;
                                    pm.Milestone_Complete_At_Booking__c = true;
                                } else {
                                    pm.Is_Due__c = false;
                                }
                            }
                            updatePMList.add(pm);
                        }
                    }
                }
            }
        }
        if(!updatePMList.isEmpty() && updatePMList != null)
            update updatePMList;
    }
    
}