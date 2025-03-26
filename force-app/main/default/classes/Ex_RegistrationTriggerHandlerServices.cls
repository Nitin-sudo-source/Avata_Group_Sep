public class Ex_RegistrationTriggerHandlerServices {
    
    @Future (callout=true)
    public static void sendEmailRegistrationSchedule(Set<Id> rcSetId) {
        Set<Id> bkSetId = new Set<Id>();
        String emailbody = '';
        if (rcSetId == null || rcSetId.isEmpty()) {
            System.debug('No Registration provided');
            return;
        }
        List<Registration__c> regisList = new List<Registration__c>();
        regisList = [Select Id, Booking__c, Name, Registration_Scheduled_Date__c, Registration_Stage__c from Registration__c where Id IN: rcSetId];
        System.debug('regisList: '+regisList);
        
        for(Registration__c rc: regisList){
            if(rc.Booking__c != null){
                bkSetId.add(rc.Booking__c);
            }
        }
        List<Booking__c> bkList = new List<booking__c>();
        bkList = [Select Id, Name, Primary_Applicant_Email__c, Unit__r.Name, Opportunity__r.Name, Project__r.Vendor_Email__c from Booking__c where Id IN: bkSetId];
        System.debug('bkList: '+bkList);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmail;
        
        try {
            orgWideEmail = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Registration Email' LIMIT 1];
            System.debug('orgWideEmail: '+orgWideEmail);
        } catch (Exception e) {
            System.debug('Error in getting OrgWideEmailAddress: ' + e.getMessage());
        }
        
        if(!bkList.isEmpty() && bkList != null){
            for (Booking__c booking : bkList) {
                if (booking.Primary_Applicant_Email__c != null || booking.Project__r.Vendor_Email__c != null) { 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    // Set the subject
                    if(regisList[0].Registration_Stage__c != null && regisList[0].Registration_Stage__c.equalsIgnoreCase('Registration Completed')){
                        mail.setSubject('Registration Completed: [' + booking.Unit__r.Name + '] - [' + booking.Opportunity__r.Name + ']');
                    }else{
                        mail.setSubject('Registration Confirmation: [' + booking.Unit__r.Name + '] - [' + booking.Opportunity__r.Name + ']');
                    }
                    
                    // Build the email body
                    emailBody = '<p>Dear ' + booking.Name + ',</p>';
                    emailBody += '<p>We are pleased to confirm your registration for the following unit:</p>';
                    emailBody += '<ul>';
                    emailBody += '<li><strong>Unit Name:</strong> ' + booking.Unit__r.Name + '</li>';
                    emailBody += '<li><strong>Opportunity:</strong> ' + booking.Opportunity__r.Name + '</li>';
                    emailBody += '</ul>';
                    
                    // Handle body for 'Registration Completed'
                    if (regisList[0].Registration_Stage__c != null && regisList[0].Registration_Stage__c.equalsIgnoreCase('Registration Completed')) {
                        emailBody += '<p><strong>Registration Completed:</strong></p>';
                        emailBody += '<p>We are pleased to inform you that the registration for your unit has been successfully completed.</p>';
                        emailBody += '<p>For any inquiries, feel free to reach out to us at [avantgroup@gmail.com] or [8887776566].</p>';
                        emailBody += '<p>Best regards,</p>';
                        emailBody += '<p>The Avant Group Team</p>';
                    } 
                    // Handle body for 'Registration Scheduled'
                    else {
                        emailBody += '<p><strong>Registration Schedule:</strong></p>';
                        emailBody += '<p>Your registration is scheduled as follows:</p>';
                        emailBody += '<ul>';
                        
                        String formattedDate = '';
                        if (regisList[0].Registration_Scheduled_Date__c != null) {
                            DateTime dt = DateTime.newInstance(
                                regisList[0].Registration_Scheduled_Date__c.year(), 
                                regisList[0].Registration_Scheduled_Date__c.month(), 
                                regisList[0].Registration_Scheduled_Date__c.day());
                            formattedDate = dt.format('MMMM dd, yyyy'); // Custom format
                        }
                        emailBody += '<li>Date: ' + formattedDate + '</li>';
                        emailBody += '</ul>';
                        emailBody += '<p>For any inquiries, feel free to reach out to us at [avantgroup@gmail.com] or [8887776566].</p>';
                        emailBody += '<p>We look forward to welcoming you!</p>';
                        emailBody += '<p>Best regards,</p>';
                        emailBody += '<p>The Avant Group Team</p>';
                    }
                    
                    System.debug('body: '+emailBody);
                    
                    // Set the email body (HTML format)
                    mail.setHtmlBody(emailBody);
                    
                    // Set the recipients
                    if(regisList[0].Registration_Stage__c != null && regisList[0].Registration_Stage__c.equalsIgnoreCase('Registration Completed')){
                        mail.setToAddresses(new List<String>{booking.Primary_Applicant_Email__c});
                    }else{
                        mail.setToAddresses(new List<String>{booking.Primary_Applicant_Email__c, booking.Project__r.Vendor_Email__c});
                    }
                    
                    if (orgWideEmail != null) {
                        mail.setOrgWideEmailAddressId(orgWideEmail.Id);
                    }
                    
                    // Add the mail to the list
                    emails.add(mail);
                }
            }
            System.debug('emails: '+emails);
        }
        
        if (!emails.isEmpty() && !Test.isRunningTest()) {
            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(emails);
            for (Messaging.SendEmailResult result : sendEmailResults) {
                System.debug('result: '+result);
                if (result.isSuccess()) {
                    System.debug('Email sent successfully to recipient.');
                } else {
                    System.debug('Failed to send email: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }
    
}