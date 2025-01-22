Trigger Ex_VisitPreRegistrationTrigger on Visit_Pre_Registration__c (before insert) {
    if (Trigger.isInsert && Trigger.isBefore) {
        Integer len = 6;
        for (Visit_Pre_Registration__c record : Trigger.new) {
            Integer randomInt = (Integer)(Math.random() * 900000) + 100000;
            system.debug('randomInt:'+randomInt);
            if(record.Pre_registration_OTP__c == null){
             	record.Pre_registration_OTP__c = String.valueOf(randomInt).substring(0,len);   
            }
            system.debug('record.Pre_registration_OTP__c:'+record.Pre_registration_OTP__c);
        }
    }
}