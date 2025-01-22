//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 21-11-2023
//-------------------------------------------//
public with sharing class Ex_PreRegistrationController {
    @AuraEnabled(cacheable=true)
    public static List<CPProjectWrapper> getCPProject(){
        String cpName = '';
        Id cpId;
        List<CPProjectWrapper> cpWrapperList = new List<CPProjectWrapper>();
        List<CP_Project__c> cpProjectList = new  List<CP_Project__c>();        
        cpProjectList = [Select Id,Name,Project__r.Name from CP_Project__c];
        if(!cpProjectList.isEmpty() && cpProjectList != null){
            for(CP_Project__c cp: cpProjectList){
                cpName = cp.Name + ' / '+ cp.Project__r.Name;
                cpId = cp.Id;
                cpWrapperList.add(new CPProjectWrapper(cpName,cpId));
            }
            
        }
        system.debug('cpWrapperList: '+ cpWrapperList);
        if(!cpWrapperList.isEmpty() && cpWrapperList != null){
            return cpWrapperList;
        } else{
            return null;
        }      
    }
    
    
    /*@AuraEnabled
public static String sendOTP(String mobile,String cpId){
String generatedOtp;
String message;
List<CP_Project__c> cpProjectList = [Select Id , Name, Mobile__c, SPOC_Name__c, Project__c, CP_Account__c from CP_Project__c where Id =: cpId ];
system.debug('cpProjectList: '+cpProjectList);

if(mobile != Null && !String.isBlank(mobile)) {
generatedOtp = String.valueOf((Math.random() * 9000) + 1000).substring(0, 4);
system.debug('generatedOtp: '+generatedOtp);
}
try{
if(!cpProjectList.isEmpty() && cpProjectList != null){
Visit_Pre_Registration__c vpr = new Visit_Pre_Registration__c();
vpr.Pre_registration_OTP__c = generatedOtp;
vpr.Mobile__c = mobile;
vpr.CP_Project__c = cpProjectList[0].Id;
vpr.Project__c = cpProjectList[0].Project__c;
if(cpProjectList[0].SPOC_Name__c != null){
vpr.SPOC__c = cpProjectList[0].SPOC_Name__c;
}
if(cpProjectList[0].Mobile__c != null){
vpr.CP_Number__c = cpProjectList[0].Mobile__c;
}
insert vpr;
message = 'OTP sent successfully ' + '' +'Please Enter OTP : ' + generatedOtp ;
} 
}catch(Exception ex){
system.debug('Error: '+ex.getMessage());
message = 'Error occured while sending OTP. Please contact system administrator.';
}

return message;
}*/
    
    /* @auraEnabled
public static Boolean validateOTP(String enterOtp, String mobile){
Boolean isVerified = false;
String message = '';
system.debug('Inside VerifyOtp');
String MasterOtp = '3011';
Visit_Pre_Registration__c vpr = [select Id,Pre_registration_OTP__c from Visit_Pre_Registration__c where Mobile__c =: mobile Order By CreatedDate DESC limit 1];
if(vpr != null){
if (enterOtp == vpr.Pre_registration_OTP__c && !String.isBlank(enterOtp) && enterOtp != null) {
system.debug('Otp Verify Successfully');
message = 'OTP Verified Successfully.';
isVerified = true;
} else if (enterOtp == masterOtp) {
system.debug('Master OTP Verified Successfully');
message = 'Master OTP Verified Successfully.';
isVerified = true;
} else{
system.debug('OTP verification failed');
message = 'OTP Verification Failed.';
isVerified = false;
}
}
return isVerified;
}*/
    
    
    @auraEnabled
    public static Id saveData(String cpId, string customerName,String customerNo,String Budget, String Configuration, String Facility, DateTime VisitDate, String Location, DateTime PickupDate){
        system.debug('customerNo: '+customerNo);
        system.debug('Budget: '+Budget);
        system.debug('Configuration: '+Configuration);
        system.debug('Facility: '+Facility);
        system.debug('VisitDate: '+VisitDate);
        system.debug('Location: '+Location);
        system.debug('PickupDate: '+PickupDate);
        List<Ola_Pickup__c> opList = new List<Ola_Pickup__c>();
        Id vprId;
        
        List<CP_Project__c> cpProjectList = [Select Id , Name, Mobile__c, SPOC_Name__c, Project__c, CP_Account__c from CP_Project__c where Id =: cpId];
        system.debug('cpProjectList: '+cpProjectList);
        
        // List<Visit_Pre_Registration__c> preList = new List<Visit_Pre_Registration__c>();
        //  preList = [Select Id,CP_Project__c,Customer_Name__c,Visit_Date__c from Visit_Pre_Registration__c where CP_Project__c =: cpId Order By CreatedDate DESC limit 1 ];
        //  System.debug('preList: '+preList.size());
        
        if(!cpProjectList.isEmpty() && cpProjectList != null){
            Visit_Pre_Registration__c vpr = new Visit_Pre_Registration__c();
            // vpr.Pre_registration_OTP__c = generatedOtp;
            vpr.Mobile__c = customerNo;
            vpr.CP_Project__c = cpProjectList[0].Id;
            vpr.Project__c = cpProjectList[0].Project__c;
            if(cpProjectList[0].SPOC_Name__c != null){
                vpr.SPOC__c = cpProjectList[0].SPOC_Name__c;
            }
            if(cpProjectList[0].Mobile__c != null){
                vpr.CP_Number__c = cpProjectList[0].Mobile__c;
            }
            vpr.Customer_Name__c = customerName ;
            vpr.Budget__c = Budget;
            vpr.Configuration_required__c = Configuration;
            vpr.Visit_Date__c = VisitDate;
            if(Location != null){
                vpr.Pickup_Location__c = Location;
            }
            if(PickupDate != null){
                vpr.Pickup_Datetime__c = PickupDate;
            }
            if(Facility != null){
                vpr.Ola_Pickup_Facility__c = Facility; 
            }
            try{
                insert  vpr ;
                vprId = vpr.Id;
            }catch(Exception ex){
                system.debug('Exception= ' +ex);
            }
            if(Facility != null && Facility == 'Yes'){
                Ola_Pickup__c op = new Ola_Pickup__c();
                op.Pickup_Location__c = Location;
                op.Pickup_Datetime__c = PickupDate;
                op.Visit_Pre_Registration__c = vpr.Id;
                op.Primary_Mobile__c = customerNo;
                opList.add(op);
            }else{
                return vpr.Id;
            }
        }
        try{
            if(!opList.isEmpty() && opList != null){
                insert opList[0];      
            } 
        }catch(Exception ex){
            system.debug('Exception= ' +ex);
        }
        return vprId;
    }
    
    public class CPProjectWrapper{
        @auraenabled  public String cpName {get;set;}
        @auraenabled  public Id cpId{get;set;}
        
        public CPProjectWrapper(String cpName,Id cpId){
            this.cpName = cpName;
            this.cpId = cpId;
            
        }
    }
}