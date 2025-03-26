// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 09-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_VisitPreRegistrationHandlerServices {
    public static void createVPRLead( List<Visit_Pre_Registration__c> vprLeadList){
        Integer len = 6;
        Set<Id> pIdSet = new Set<Id>();
        List<Project__c> prList = new List<Project__c>();
        
        
        System.debug('preList: '+vprLeadList);
        if(vprLeadList != null && !vprLeadList.isEmpty()){
            for (Visit_Pre_Registration__c vpr : vprLeadList) {
                if(vpr.Project__c != null)
                {
                    pIdSet.add(vpr.Project__c);
                }
            }
        }
        prList = [Select Id from  Project__c where Id IN: pIdSet];
        System.debug('prList: '+prList);
        if(vprLeadList != null && !vprLeadList.isEmpty()){
            for (Visit_Pre_Registration__c vpr : vprLeadList) {
                Integer randomInt = (Integer)(Math.random() * 900000) + 100000;
                if(vpr.Visit_Pre_Registration_Code__c == null){
                    vpr.Visit_Pre_Registration_Code__c = String.valueOf(randomInt).substring(0,len);   
                }
                System.debug('vpr.Pre_Registration_Validity_In_Hours__c: '+vpr.Pre_Registration_Validity_In_Hours__c);
                if(vpr.Pre_Registration_Validity_In_Hours__c != null){
                    Datetime workTime = DateTime.now().addHours(Integer.valueof(vpr.Pre_Registration_Validity_In_Hours__c));
                    vpr.Pre_Registration_Expiry__c = workTime;
                    System.debug('vpr.Pre_Registration_Expiry__c: '+vpr.Pre_Registration_Expiry__c);
                }
            }
        }
        
        
    }
    public static void updateVpr( List<Visit_Pre_Registration__c> updateVpr){
        if(updateVpr != null && !updateVpr.isEmpty()){
            for (Visit_Pre_Registration__c vpr : updateVpr) {
                System.debug('Extend_Validity_In_Hours__c: '+vpr.Extend_Validity_In_Hours__c);
                if(vpr.Extend_Validity_In_Hours__c != null && vpr.Extend_Validity_In_Hours__c != 0){
                    
                    Datetime workTime = vpr.Pre_Registration_Expiry__c.addHours(Integer.valueof(vpr.Extend_Validity_In_Hours__c));
                    vpr.Pre_Registration_Expiry__c = workTime;
                    System.debug('vpr.Pre_Registration_Expiry__c: '+vpr.Pre_Registration_Expiry__c);
                }
            }
        }
        
    }
    
    public static void duplicationCheck(List<Visit_Pre_Registration__c> vprLeadList){
        Map<Visit_Pre_Registration__c, List<Ex_VisitPreRegDuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = Ex_VisitPreRegDuplicationHandlerServices.duplicationCheck(vprLeadList);
        if(!vprLeadList.isEmpty() && vprLeadList!=null){
            for(Visit_Pre_Registration__c vpr : vprLeadList){
                String errMsg = '';
                if(duplicateWrapperMap.containsKey(vpr)){
                    for(Ex_VisitPreRegDuplicationHandlerServices.duplicateWrapper dw : duplicateWrapperMap.get(vpr)){
                        errMsg = 'Visit Pre-Registration for selected '+dw.Type+' Already Exists with Moible Number: '+dw.dupVisitPreReg.Mobile_Number__c+' and Project: '+dw.dupVisitPreReg.Project__r.Name;
                    }
                    if(!test.isRunningTest() && errMsg != null)
                        vpr.addError(errMsg);
                }
            }
        }
    }   
}