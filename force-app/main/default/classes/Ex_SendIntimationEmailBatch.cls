/*
  Created By : Exceller Tech
  Created Date : 03/06/2025
  Developer : Ganesh Gavhane
*/
public class Ex_SendIntimationEmailBatch implements Database.Batchable<sObject>{
    
    Public String query;
    public Date todaysDate = system.today();
    
    
    public Ex_SendIntimationEmailBatch(){
        query = 'SELECT Id, Welcome_Call_Done_DateTime__c, Welcome_Call_Done__c, Registration_Status__c, Registration_Done__c'
            +' From Booking__c WHERE Welcome_Call_Done__c = TRUE AND Registration_Done__c = TRUE AND Welcome_Call_Done_DateTime__c != NULL AND (Registration_Status__c != \'Registration Completed\')';
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Booking__c> bookingList){
        system.debug('bookingList: '+bookingList.size());
        DateTime Intimation1Date;
        DateTime Intimation2Date;
        DateTime Intimation3Date;
        Set<Id> Intimation1Ids = new Set<Id>();
        Set<Id> Intimation2Ids = new Set<Id>();
        Set<Id> Intimation3Ids = new Set<Id>();
        
        if(bookingList != null && !bookingList.isEmpty()){
            for(Booking__c bk : bookingList){
                Intimation1Date = bk.Welcome_Call_Done_DateTime__c.addDays(21);
                Intimation2Date = bk.Welcome_Call_Done_DateTime__c.addDays(25);
                Intimation3Date = bk.Welcome_Call_Done_DateTime__c.addDays(30);
                
                if(todaysDate == Intimation1Date.date()){
                    System.debug('Inside Intimation1Date');
                    Intimation1Ids.add(bk.Id); 
                }
                if(todaysDate == Intimation2Date.date()){
                    System.debug('Inside Intimation2Date');
                    Intimation2Ids.add(bk.Id); 
                }
                if(todaysDate == Intimation2Date.date()){
                    System.debug('Inside Intimation3Date');
                    Intimation3Ids.add(bk.Id); 
                }
            }
        }
        
        if(Intimation1Ids != null && !Intimation1Ids.isEmpty())
            sendIntimation1Email(Intimation1Ids); 
        
        if(Intimation2Ids != null && !Intimation2Ids.isEmpty())
            sendIntimation2Email(Intimation2Ids);
        
        if(Intimation3Ids != null && !Intimation3Ids.isEmpty())
            sendIntimation3Email(Intimation3Ids); 
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    public static void sendIntimation1Email(Set<Id> Intimation1Ids){
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        bookingList = [Select Id, Name, Tower__c, Tower__r.MIS_User__c, Tower__r.RM_User__c, Tower__r.RM_User__r.Email, Tower__r.MIS_User__r.Email, Tower__r.MIS_User__r.isActive, Tower__r.RM_User__r.isActive
                       FROM Booking__c WHERE Id IN : Intimation1Ids];
        
        if(bookingList != null && !bookingList.isEmpty()){
            try{
                for(Booking__c bk : bookingList){
                    if(bk.Tower__r.RM_User__c != null && bk.Tower__r.MIS_User__c != null && bk.Tower__r.RM_User__r.isActive == True && bk.Tower__r.MIS_User__r.isActive == True){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new List<String>{bk.Tower__r.RM_User__r.Email,bk.Tower__r.MIS_User__r.Email});
                        email.setSubject('Intimation Email Notification 1');
                        String htmlBody = '<html><body>';
                        htmlBody += '<p>First Intimation Email</p>';
                        htmlBody += '<p>Regards<br>';
                        htmlBody += 'Awant Realty';
                        htmlBody += '</p>';
                        htmlBody += '</body></html>';
                        email.setHtmlBody(htmlBody);
                        allmsg.add(email); 
                    }
                }
                if(!allmsg.isEmpty()){
                    Messaging.sendEmail(allmsg,true);
                }
                
            }catch(Exception ex){
                System.debug('An error occurred: ' + ex.getMessage());
            }
        }  
    }
    
    public static void sendIntimation2Email(Set<Id> Intimation2Ids){
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        bookingList = [Select Id, Name, Tower__c, Tower__r.MIS_User__c, Tower__r.RM_User__c, Tower__r.RM_User__r.Email, Tower__r.MIS_User__r.Email, Tower__r.MIS_User__r.isActive, Tower__r.RM_User__r.isActive
                       FROM Booking__c WHERE Id IN : Intimation2Ids];
        
        if(bookingList != null && !bookingList.isEmpty()){
            try{
                for(Booking__c bk : bookingList){
                    if(bk.Tower__r.RM_User__c != null && bk.Tower__r.MIS_User__c != null && bk.Tower__r.RM_User__r.isActive == True && bk.Tower__r.MIS_User__r.isActive == True){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new List<String>{bk.Tower__r.RM_User__r.Email,bk.Tower__r.MIS_User__r.Email});
                        email.setSubject('Intimation Email Notification 2');
                        String htmlBody = '<html><body>';
                        htmlBody += '<p>Second Intimation Email</p>';
                        htmlBody += '<p>Regards<br>';
                        htmlBody += 'Awant Realty';
                        htmlBody += '</p>';
                        htmlBody += '<hr>';
                        htmlBody += '</body></html>';
                        
                        allmsg.add(email); 
                        
                    }
                }
                if(!allmsg.isEmpty()){
                    Messaging.sendEmail(allmsg,false);
                }
                
            }catch(Exception ex){
                System.debug('An error occurred: ' + ex.getMessage());
            }
        }
        
    }
    
    public static void sendIntimation3Email(Set<Id> Intimation3Ids){
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        bookingList = [Select Id, Name, Tower__c, Tower__r.MIS_User__c, Tower__r.RM_User__c, Tower__r.RM_User__r.Email, Tower__r.MIS_User__r.Email, Tower__r.MIS_User__r.isActive, Tower__r.RM_User__r.isActive
                       FROM Booking__c WHERE Id IN : Intimation3Ids];
        if(bookingList != null && !bookingList.isEmpty()){
            try{
                for(Booking__c bk : bookingList){
                    if(bk.Tower__r.RM_User__c != null && bk.Tower__r.MIS_User__c != null && bk.Tower__r.RM_User__r.isActive == True && bk.Tower__r.MIS_User__r.isActive == True){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new List<String>{bk.Tower__r.RM_User__r.Email,bk.Tower__r.MIS_User__r.Email});
                        email.setSubject('Intimation Email Notification 3');
                        String htmlBody = '<html><body>';
                        htmlBody += '<p>Third Intimation Email</p>';
                        htmlBody += '<p>Regards<br>';
                        htmlBody += 'Awant Realty';
                        htmlBody += '</p>';
                        htmlBody += '<hr>';
                        htmlBody += '</body></html>';
                        allmsg.add(email); 
                        
                    }
                }
                if(!allmsg.isEmpty()){
                    Messaging.sendEmail(allmsg,false);
                }
                
            }catch(Exception ex){
                System.debug('An error occurred: ' + ex.getMessage());
            }
        } 
    }
}