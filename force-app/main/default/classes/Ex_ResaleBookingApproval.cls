public with sharing class Ex_ResaleBookingApproval {
    public class ApprovalResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String bookingName;
    }

    @AuraEnabled
    public static ApprovalResponse submitForApproval(Id recordId, String comment) {
        ApprovalResponse resp = new ApprovalResponse();
        Booking__c booking = [SELECT Id, Name, Sales_Manager__c 
                              FROM Booking__c 
                              WHERE Id = :recordId 
                              LIMIT 1];

        if (booking.Sales_Manager__c == null) {
            resp.success = false;
            resp.message = 'A Sales Manager must be assigned before approval.';
            return resp;
        }

        try {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(booking.Id);
            req.setComments(comment);
            req.setProcessDefinitionNameOrId('Booking_Resale_Approval_Process');
            Approval.ProcessResult result = Approval.process(req);

            if (!result.isSuccess()) {
                resp.success = false;
                resp.message = 'Unable to submit for approval. Please try again.';
                return resp;
            }

            List<Id> workItemIds = result.getNewWorkitemIds();
            if (!workItemIds.isEmpty()) {
                List<ProcessInstanceWorkitem> items = [
                    SELECT Id, ActorId 
                      FROM ProcessInstanceWorkitem 
                     WHERE Id IN :workItemIds
                ];
                for (ProcessInstanceWorkitem wi : items) {
                    wi.ActorId = booking.Sales_Manager__c;
                }
                update items;
            }

            resp.success = true;
            resp.bookingName = booking.Name;
            resp.message = booking.Name + ' has been approved for resale.';
            return resp;

        } catch (Exception e) {
            if (e.getMessage().contains('ALREADY_IN_PROCESS')) {
                resp.message = 'This booking is already in an approval process.';
            } else {
                resp.message = 'Something went wrong. Please contact your admin.';
            }
            resp.success = false;
            return resp;
        }
    }
}