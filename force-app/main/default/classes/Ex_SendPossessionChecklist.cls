public class Ex_SendPossessionChecklist {
    @future
    public static void sendPossessionEmailWithLink(Set<Id> bookingId) {
        try {
            Booking__c booking = [SELECT Tower__r.Finance_Manager__r.Email, Project__r.CRM_Head__r.Email, 
                                  Primary_Applicant_Email__c, Possession_Process_Start__c, Project__r.CRM_Head__c,
                                  Project__c, Account_Possession_Checklist__c, 
                                  Possession_Approved_By_CRM_Head__c ,RM_Possession_Checklist__c
                                  FROM Booking__c WHERE Id IN: bookingId];
            
            String link = '';
            String recipientEmail = '';
            
            
            if(booking.Possession_Process_Start__c && booking.RM_Possession_Checklist__c &&  !booking.Possession_Approved_By_CRM_Head__c) {
                recipientEmail = booking.Project__r.CRM_Head__r.Email;  
                link = System.Label.Possession_Checklists_Link + '?recordId=' + booking.Id + '&isCRMHead=true';
            } else if(booking.Possession_Process_Start__c && booking.Possession_Approved_By_CRM_Head__c && !booking.Account_Possession_Checklist__c) {
                recipientEmail = booking.Tower__r.Finance_Manager__r.Email; 
                link = System.Label.Possession_Checklists_Link + '?recordId=' + booking.Id  + '&isAccManager=true';
            }  
           /* } else if (booking.Possession_Process_Start__c && booking.Possession_Approved_By_CRM_Head__c && !booking.Customer_Possession_Checklist__c) {
                recipientEmail = booking.Primary_Applicant_Email__c;
                link = System.Label.Possession_Checklists_Link + '?recordId=' + booking.Id  + '&isCustomer=true';
            }*/
            OrgWideEmailAddress orgWideEmail = fetchOrgWideEmailAddress('Welcome Call');
            if (orgWideEmail == null) {
                System.debug('No OrgWideEmailAddress found.');
            }
            
            
            if(String.isNotBlank(link) && String.isNotBlank(recipientEmail)) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { recipientEmail });
   
                email.setSubject('Possession Checklist Link');
                email.setHtmlBody('<p>Dear Recipient,</p><p>Please find the possession checklist link below:</p><p><a href="' + link + '">' + link + '</a></p><p>If you can\'t click the link, copy and paste it into your Web browser. If you have questions, contact your System administrator.</p><p>Best regards,<br>Vihang Team</p>');
                if (orgWideEmail != null) {
                    email.setOrgWideEmailAddressId(orgWideEmail.Id);
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                System.Debug('Email Send Sucessfully On recipient email is .'+recipientEmail);
            } else {
                System.Debug('No valid link or recipient email found.');
            }
        } catch (Exception e) {
            System.debug('Error while sending email: ' + e.getMessage());
        }
    }
    
    private static OrgWideEmailAddress fetchOrgWideEmailAddress(String displayName) {
        try {
            return [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :displayName LIMIT 1];
        } catch (Exception e) {
            System.debug('Error fetching OrgWideEmailAddress: ' + e.getMessage());
            return null;
        }
    }
    
}