global class Ex_VisitPreRegistrationOTPValidityBatch implements Database.Batchable<SObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Status__c, Pre_Registration_Expiry__c 
                                         FROM Visit_Pre_Registration__c
                                         WHERE Pre_Registration_Expiry__c < :System.now() AND Status__c = 'Valid']);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Visit_Pre_Registration__c> scope) {
        System.debug('Scope contains records: ' + scope);
        for (Visit_Pre_Registration__c preReg : scope) {
            preReg.Status__c = 'Expired';
        }
        update scope;
    }
    
    global void execute(SchedulableContext sc) {
        Ex_VisitPreRegistrationOTPValidityBatch batch = new Ex_VisitPreRegistrationOTPValidityBatch();
        Database.executeBatch(batch, 200); 
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}