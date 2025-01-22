@RestResource(urlMapping='/LiveChat/')
global without sharing class RestLiveChatController {

    public static String response;

    @HttpPost
    global static void LiveChat() {
        returnResponse rr = new returnResponse();
        response = String.valueOf(rr);

        // Parsing the request body into LiveChatController object
        LiveChatController parseData = LiveChatController.parse(RestContext.request.requestBody.toString());
        System.debug('parseData = ' + parseData);

        // Accessing data from the parsed object
        String type = parseData.type;

        // Validating request
        if (isValidRequest(parseData)) {
            if (type == 'user-event') {
                if (handleUserEvent(parseData)) {
                    //rr.returnCode = '200';
                } else {
                    //rr.returnCode = '400';
                }
            } else if (type == 'message') {
                if (handleMessage(parseData)) {
                    //rr.returnCode = '200';
                } else {
                    //rr.returnCode = '400';
                }
            }
            else if (type == 'message-event') {
                if (handleMessageStatus(parseData)) {
                    //rr.returnCode = '200';
                } else {
                    //rr.returnCode = '400';
                }
            }
        } else {
            //rr.returnCode = '400';
        }
    }

    // Validating the request
    public static Boolean isValidRequest(LiveChatController parseData) {
        return parseData != null && parseData.payload != null;
    }

    // Handling user-event requests
    public static Boolean handleUserEvent(LiveChatController parseData) {
        String phone = parseData.payload.phone;
        String actionType = parseData.payload.type;

        // Query WA API Details
        WA_API_Details_Gupshup__c apiDetails = getWAAPIDetails(parseData.app);
        System.debug('apiDetails: ' + apiDetails);

        return userevent(parseData, phone, actionType);
    }

    // Handling message requests
    public static Boolean handleMessage(LiveChatController parseData) {
        String phone_number = parseData.payload.sender.phone;
        String sendername = parseData.payload.sender.name;
        String message_text = parseData.payload.payload.text;
        String MessageId = parseData.payload.id;
        String messageType = parseData.payload.type;
        String fileurl = parseData.payload.payload.url;

        // Query WA API Details
        WA_API_Details_Gupshup__c apiDetails = getWAAPIDetails(parseData.app);
        System.debug('apiDetails: ' + apiDetails);

        return createWhatsAppMessage(parseData, phone_number, message_text, MessageId, messageType, fileurl, sendername);
    }

    // Handling message status requests
    public static Boolean handleMessageStatus(LiveChatController parseData) {
        String messageId = parseData.payload.id;
        String destination = parseData.payload.destination;
        String messageStatus = parseData.payload.type;

        return UpdateWhatsAppMessage(parseData, messageId, destination, messageStatus);
    }

    // Creating WhatsApp message
    public static Boolean createWhatsAppMessage(LiveChatController parseData, String phone_number, String message_text, String MessageId, String messageType, String fileurl, String sendername) {
        String MobileNumber = phone_number.substring(phone_number.length() - 10);

        system.debug('MobileNumber' + MobileNumber);
        
        // Query WA API Details
        WA_API_Details_Gupshup__c apiDetails = getWAAPIDetails(parseData.app);
        System.debug('apiDetails: ' + apiDetails);
        
        List<Project__c> project = [Select Id from Project__c where Name =: apiDetails.Project_Name__c];

        List<Opportunity__c> existingOpportunity = new List<Opportunity__c>();
        List<Booking__c> existingBooking = new List<Booking__c>();

        existingBooking = [SELECT Id, Mobile__c, Project__c, Project__r.Name
                           FROM Booking__c
                           WHERE (Mobile__c = :MobileNumber 
                           AND Project__r.Name =: apiDetails.Project_Name__c)
                           LIMIT 1];

        existingOpportunity = [SELECT Id, Mobile__c, Account__c,  Project__c, Project__r.Name
                               FROM Opportunity__c
                               WHERE ((Mobile__c = :MobileNumber OR Phone__c =: MobileNumber) 
                               AND Project__r.Name =: apiDetails.Project_Name__c)
                               LIMIT 1];

        List<Lead__c> existingLead = [SELECT Id, Mobile__c, isConverted__c, Project__c, Project__r.Name
                                      FROM Lead__c WHERE Mobile__c = :MobileNumber 
                                      AND isConverted__c =: FALSE 
                                      AND Project__r.Name =: apiDetails.Project_Name__c
                                      LIMIT 1];
        system.debug('existingLead :' + existingLead);

        // Creating WhatsApp message record
        if (!existingBooking.isEmpty() && existingBooking != null) {
            WhatsApp_Message__c whatsappMessage = new WhatsApp_Message__c();
            whatsappMessage.Customer_Phone__c = MobileNumber;
            whatsappMessage.Success__c = true;

            if (!existingBooking.isEmpty() && existingBooking != null) {
                whatsappMessage.Booking__c = existingBooking[0].Id;
            }

            whatsappMessage.Message_Text__c = message_text;
            whatsappMessage.API_Request__c = String.valueOf(parseData);
            whatsappMessage.API_Response__c = response;
            whatsappMessage.Message_Id__c = MessageId;
            whatsappMessage.API_Status__c = 'Success';
            whatsappMessage.Message_Type__c = 'Normal';
            if (messageType != 'text') {
                whatsappMessage.Contains_File__c = true;
                whatsappMessage.Public_Link__c = fileurl;
            }

            try {
                insert whatsappMessage;
                return true;
            } catch (Exception e) {
                return false;
            }
        } else if (!existingOpportunity.isEmpty() && existingOpportunity != null) {
            WhatsApp_Message__c whatsappMessage = new WhatsApp_Message__c();
            whatsappMessage.Customer_Phone__c = MobileNumber;
            whatsappMessage.Success__c = true;

            if (!existingOpportunity.isEmpty() && existingOpportunity != null) {
                whatsappMessage.Opportunity__c = existingOpportunity[0].Id;
            }

            whatsappMessage.Message_Text__c = message_text;
            whatsappMessage.API_Request__c = String.valueOf(parseData);
            whatsappMessage.API_Response__c = response;
            whatsappMessage.Message_Id__c = MessageId;
            whatsappMessage.API_Status__c = 'Success';
            whatsappMessage.Message_Type__c = 'Normal';
            if (messageType != 'text') {
                whatsappMessage.Contains_File__c = true;
                whatsappMessage.Public_Link__c = fileurl;
            }

            try {
                insert whatsappMessage;
                return true;
            } catch (Exception e) {
                return false;
            }
        } else if (!existingLead.isEmpty() && existingLead != null) {
            WhatsApp_Message__c whatsappMessage = new WhatsApp_Message__c();
            whatsappMessage.Customer_Phone__c = MobileNumber;
            whatsappMessage.Success__c = true;

            if (!existingLead.isEmpty() && existingLead != null) {
                whatsappMessage.Lead__c = existingLead[0].Id;
            }

            whatsappMessage.Message_Text__c = message_text;
            whatsappMessage.API_Request__c = String.valueOf(parseData);
            whatsappMessage.API_Response__c = response;
            whatsappMessage.Message_Id__c = MessageId;
            whatsappMessage.API_Status__c = 'Success';
            whatsappMessage.Message_Type__c = 'Normal';
            if (messageType != 'text') {
                whatsappMessage.Contains_File__c = true;
                whatsappMessage.Public_Link__c = fileurl;
            }
            
            try {
                insert whatsappMessage;
                return true;
            } catch (Exception e) {
                return false;
            }

            
        } else {
            
            try {
                Lead__c l = new Lead__c();
                l.Mobile__c = MobileNumber;
                //l.First_Name__c = 'Whatsapp';
                if(sendername != null)
                    l.Last_Name__c = sendername;
                
                if(!project.isEmpty() && project != null)
                	l.Project__c = project[0].Id;
                l.Apply_Round_Robin__c = true;
                l.Lead_Source__c = 'WhatsApp';
                l.Lead_Sub_Source__c = 'External WhatsApp';
                insert l;
                
                WhatsApp_Message__c whatsappMessage = new WhatsApp_Message__c();
                whatsappMessage.Customer_Phone__c = MobileNumber;
                whatsappMessage.Success__c = true;
                
                whatsappMessage.Lead__c = l.Id;
                
                whatsappMessage.Message_Text__c = message_text;
                whatsappMessage.API_Request__c = String.valueOf(parseData);
                whatsappMessage.API_Response__c = response;
                whatsappMessage.Message_Id__c = MessageId;
                whatsappMessage.API_Status__c = 'Success';
                whatsappMessage.Message_Type__c = 'Normal';
                if (messageType != 'text') {
                    whatsappMessage.Contains_File__c = true;
                    whatsappMessage.Public_Link__c = fileurl;
                }
                
                insert whatsappMessage;    
                return true;
                
            } catch (Exception e) {
                return false;
            }
        }
    }

    public static Boolean userevent(LiveChatController parseData, String phone_number, String actionType) {
        String MobileNumber = phone_number;
        system.debug('MobileNumber userevent :' + MobileNumber);

        // Querying existing records
        List<Account> existingAccount = [SELECT Id, PersonMobilePhone, Phone, Opted_In__c
                                          FROM Account
                                          WHERE PersonMobilePhone = :MobileNumber
                                          OR Phone = :MobileNumber
                                          LIMIT 1];
        List<Opportunity__c> existingOpportunity = new List<Opportunity__c>();
        system.debug('existingAccount :' + existingAccount);

        if (!existingAccount.isEmpty() && existingAccount != null) {
            existingOpportunity = [SELECT Id, Account__c, Mobile__c, Opted_In__c
                                   FROM Opportunity__c
                                   WHERE (Mobile__c = :MobileNumber
                                   AND Account__c =: existingAccount[0].Id)
                                   LIMIT 1];
        } else {
            existingOpportunity = [SELECT Id, Mobile__c, Account__c, Opted_In__c
                                   FROM Opportunity__c
                                   WHERE Mobile__c = :MobileNumber
                                   LIMIT 1];
            system.debug('existingOpportunity' + existingOpportunity);
        }

        List<Lead__c> existingLead = [SELECT Id, Mobile__c, Opted_In__c
                                      FROM Lead__c
                                      WHERE Mobile__c = :MobileNumber
                                      LIMIT 1];
        system.debug('existingLead' + existingLead);

        if (!existingAccount.isEmpty() && existingAccount != null) {

            if (actionType == 'opted-in')
                existingAccount[0].Opted_In__c = true;
            else if (actionType == 'opted-out')
                existingAccount[0].Opted_In__c = false;

            try {
                update existingAccount;
                if (!existingOpportunity.isEmpty() && existingOpportunity != null && existingOpportunity[0].Id != null) {

                    if (actionType == 'opted-in')
                        existingOpportunity[0].Opted_In__c = true;
                    else if (actionType == 'opted-out')
                        existingOpportunity[0].Opted_In__c = false;

                    update existingOpportunity;
                }
                return true;
            } catch (Exception e) {
                return false;
            }
        }
        if (!existingOpportunity.isEmpty() && existingOpportunity != null && existingOpportunity[0].Id != null) {

            if (actionType == 'opted-in')
                existingOpportunity[0].Opted_In__c = true;
            else if (actionType == 'opted-out')
                existingOpportunity[0].Opted_In__c = false;

            try {
                update existingOpportunity;
                return true;
            } catch (Exception e) {
                return false;
            }
        } else if (!existingLead.isEmpty() && existingLead != null) {
            System.debug('actionType = ' + actionType);

            if (actionType == 'opted-in') {
                existingLead[0].Opted_In__c = true;
            } else if (actionType == 'opted-out') {
                existingLead[0].Opted_In__c = false;
            }

            try {

                System.debug('existingLead = ' + existingLead);
                update existingLead;
                return true;
            } catch (Exception e) {
                System.debug(e.getMessage());
                return false;
            }
        }
        return false;
    }

    public static Boolean UpdateWhatsAppMessage(LiveChatController parseData, String messageId, String destination, String messageStatus) {
        String MobileNumber = destination.substring(destination.length() - 10);

        // Querying existing records
        List<WhatsApp_Message__c> WhatsappMessage = [SELECT Id, Message_Status__c, Message_Id__c, Lead__c, Opportunity__c,
                                                     Account__c, Customer_Phone__c
                                                     FROM WhatsApp_Message__c
                                                     WHERE Customer_Phone__c =: MobileNumber
                                                     AND Message_Id__c =: messageId
                                                     LIMIT 1];

        if (!WhatsappMessage.isEmpty() && WhatsappMessage != null && WhatsappMessage[0].Message_Id__c != null) {

            try {

                WhatsappMessage[0].Message_Status__c = messageStatus;
                update WhatsappMessage;

                return true;
            } catch (Exception e) {
                return false;
            }
        }

        return false;
    }

    public static WA_API_Details_Gupshup__c getWAAPIDetails(String appName) {
        List<WA_API_Details_Gupshup__c> apiDetailsList = [select Id, Name, API_Key__c, Channel__c, Connection__c, EndPoint__c, 
                                                          HandleId_Endpoint__c, Name__c, Source_Phone__c, appId__c, isActive__c,
                                                          src_name__c, token__c, EndPoint_URL__c, Project_Name__c
                                                          from WA_API_Details_Gupshup__c
                                                          WHERE Name__c = :appName
                                                          LIMIT 1];
        
        System.debug('apiDetailsList = '+ apiDetailsList);
        
        if (!apiDetailsList.isEmpty()) {
            return apiDetailsList[0];
        }
        return null;
    }

    global class returnResponse {
        webservice string returnCode;
        //webservice string message;
    }
}