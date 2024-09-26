public class Ex_PaymentSchemeTriggerHandler {
    public static void afterInsert(List<Payment_Scheme__c> paymentSchemeList){
        Set<Id> psId = new Set<Id> ();
        if(paymentSchemeList != null){
            for(Payment_Scheme__c ps : paymentSchemeList){
                if(ps.Number_of_Milestone__c != null){
                    psId.add(ps.Id);
                }
            }
        }
        if(psId != null && !psId.isEmpty()){
            Ex_PaymentSchemeHandlerServices.insertPaymentSchemeMilstone(psId);
        }
    }
}