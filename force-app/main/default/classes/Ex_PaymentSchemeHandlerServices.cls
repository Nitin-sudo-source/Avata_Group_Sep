public class Ex_PaymentSchemeHandlerServices {
    public static void insertPaymentSchemeMilstone(Set<Id> psId){
        List<Payment_Scheme_Milestone__c> psMilestoneList = new List<Payment_Scheme_Milestone__c> ();
        
        Payment_scheme__c paymentScheme = [SELECT Id, Name, Number_of_Milestone__c FROM Payment_scheme__c WHERE Id =: psId];
        
        for (Integer i = 1; i <= paymentScheme.Number_of_Milestone__c; i++) {
            Payment_Scheme_Milestone__c psm = new Payment_Scheme_Milestone__c();
            psm.Payment_scheme__c = paymentScheme.Id;
            psm.Milestone_Type__c = 'Date Linked';
            psm.Number_of_Days__c = 0;
            psm.Sequence_No__c = i;
            psm.Charge_Bucket_1__c = 'Agreement Value';
            for (Integer j = 1; j <= 5; j++) {
                String chargeBucketType = 'Charge_Bucket_' + j + '_Type__c';
                psm.put(chargeBucketType, 'Percentage');
                
                String chargeBucketAmount = 'Charge_Bucket_' + j + '_Amount__c';
                psm.put(chargeBucketAmount, 0);
                
                String chargeBucketPercentage = 'Charge_Bucket_' + j + '_Percentage__c';
                psm.put(chargeBucketPercentage, 0.0);
            }
            
            psMilestoneList.add(psm);
        }
        if(psMilestoneList != null && !psMilestoneList.isEmpty()){
            insert psMilestoneList ;
        }
    }
}