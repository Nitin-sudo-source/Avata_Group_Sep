public class Ex_SendEmailWelcomeCall {
    
    @Future (callout=true)
    public static void sendEmailWelcomeCall(Set<Id> bkSetId) {
        if (bkSetId == null || bkSetId.isEmpty()) {
            System.debug('No bookings provided for the welcome call.');
            return;
        }
        
        List<Booking__c> bkList = new List<booking__c>();
        bkList = [Select Id, Name, Primary_Applicant_Email__c from Booking__c where Id IN: bkSetId];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmail;
        
        try {
            orgWideEmail = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Welcome Call' LIMIT 1];
            System.debug('orgWideEmail: '+orgWideEmail);
        } catch (Exception e) {
            System.debug('Error in getting OrgWideEmailAddress: ' + e.getMessage());
        }
        
        if(!bkList.isEmpty() && bkList != null){
            for (Booking__c booking : bkList) {
                System.debug('Booking: '+booking);
                System.debug('Booking Email: '+booking.Primary_Applicant_Email__c);
                if (booking.Primary_Applicant_Email__c != null) { 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSubject('Welcome Call Checklist');
                    mail.setHtmlBody('Demo Test'); 
                    mail.setToAddresses(new List<String>{booking.Primary_Applicant_Email__c});
                    
                    if (orgWideEmail != null) {
                        mail.setOrgWideEmailAddressId(orgWideEmail.Id);
                    }
                    
                    Blob getPDF = Blob.valueOf('Nitin');
                    PageReference sendWelcomeCallPage = new PageReference('/apex/Ex_WelcomeCallPrint');
                    sendWelcomeCallPage.getParameters().put('bId', booking.Id);
                    
                    try {
                        if (!Test.isRunningTest()) {
                            getPDF = sendWelcomeCallPage.getContentAsPDF();
                            System.debug('getPdf'+getPDF);
                        }
                    } catch (Exception e) {
                        System.debug('Error in generating PDF: ' + e.getMessage());
                    }
                    
                    Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                    fileAttachment.setFileName('WelcomeCall.pdf');
                    fileAttachment.setBody(getPDF);
                    mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{fileAttachment});
                    
                    emails.add(mail);
                }
            }
        }
        
        if (!emails.isEmpty() && !Test.isRunningTest()) {
            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(emails);
            for (Messaging.SendEmailResult result : sendEmailResults) {
                if (result.isSuccess()) {
                    System.debug('Email sent successfully to recipient.');
                } else {
                    System.debug('Failed to send email: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }
}