/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 20-01-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
public class Ex_UpdatePaymentMilestone {
    public static void updateDueDate(Map<Id, Date> quotationRegistrationMap){
        Map<Id, List<Payment_Milestone__c>> quotationPMMap = new Map<Id, List<Payment_Milestone__c>>();
        List<Payment_Milestone__c> updatepmList = new List<Payment_Milestone__c>();
        List<Quotation__c> qlist = new List<Quotation__c>();
        qlist = [Select Id, Name from Quotation__c where Id IN: quotationRegistrationMap.keySet()];
        for(Quotation__c q: qlist){
            List<Payment_Milestone__c> pmList = getPaymentMilestoneInfo(q.Id);
            if(!pmList.isEmpty() && pmList != null){
                for(Payment_Milestone__c pm : pmList){
                    System.debug('pm: '+pm);
                    pm.Due_Date__c = quotationRegistrationMap.get(pm.Quotation__c);
                   // pm.Is_Due__c = true;
                    updatepmList.add(pm);
                }
            }
        }
        try{
            System.debug('updatepmList:'+updatepmList);
            if(updatepmList != null && !updatepmList.isEmpty()){
                System.debug('updatepmList:');
                update updatepmList;
            }
        }Catch(Exception ex){
            System.debug('Exception updating pm: '+ex.getMessage());
            
        }
    }
    
    public static List<Payment_Milestone__c> getPaymentMilestoneInfo(Id qId) {
        List<Payment_Milestone__c> psMilestoneList = new List<Payment_Milestone__c>();
        String[] types = new String[]{'Payment_Milestone__c'};
        string queryFields = '';
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Schema.DescribeSobjectResult res : results) {
            string sObjectname = res.getName();
            Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
            
            for(Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                String fieldLabel = dfield.getLabel();
                
                if(queryFields == null || queryFields == '') {
                    queryFields = dField.getName();
                } else {
                    queryFields = queryFields + ', ' + dField.getName();
                }
            }
        }
        String soqlQuery = 'Select Construction_Stage__r.Name, ' + queryFields  + '  from Payment_Milestone__c Where Quotation__c = \''+qId+'\' AND Construction_Stage__r.Is_Completed__c = true ORDER BY Sequence_No__c ASC';
        system.debug('pmList: '+soqlQuery);
        psMilestoneList = Database.query(soqlQuery);
        if (psMilestoneList.size() > 0) {
            return psMilestoneList;
        } else {
            return null;
        }
    }
    
}