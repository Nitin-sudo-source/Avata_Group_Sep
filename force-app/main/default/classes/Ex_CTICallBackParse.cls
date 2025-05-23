public class Ex_CTICallBackParse {
     public String monitorUCID {get;set;} 
    public String UUI {get;set;} 
    public String Did {get;set;} 
    public String CampaignName {get;set;} 
    public String Location {get;set;} 
    public String CallerID {get;set;} 
    public String PhoneName {get;set;} 
    public String Skill {get;set;} 
    public String StartTime {get;set;} 
    public String EndTime {get;set;} 
    public String TimeToAnswer {get;set;} 
    public String CallDuration {get;set;} 
    public String Duration {get;set;} 
    public String FallBackRule {get;set;} 
    public String DialedNumber {get;set;} 
    public String CallType {get;set;} 
    public String AgentID {get;set;} 
    public String AgentPhoneNumber {get;set;} 
    public String AgentUniqueID {get;set;} 
    public String AgentName {get;set;} 
    public String Disposition {get;set;} 
    public String HangupBy {get;set;} 
    public String Status {get;set;} 
    public String AudioFile {get;set;} 
    public String TransferType {get;set;} 
    public String TransferredTo {get;set;} 
    public String Comments {get;set;} 
    public String DialStatus {get;set;} 
    public String Apikey {get;set;} 
    public String AgentStatus {get;set;} 
    public String CustomerStatus {get;set;} 
    public String UserName {get;set;} 
    public String CallerConfAudioFile {get;set;} 
    public String ConfDuration {get;set;} 
    public String CampaignStatus {get;set;} 
    public String DataUniqueId {get;set;} 
    public String WrapUpDuration {get;set;} 
    
    public Ex_CTICallBackParse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'monitorUCID') {
                        monitorUCID = parser.getText();
                    } else if (text == 'UUI') {
                        UUI = parser.getText();
                    } else if (text == 'Did') {
                        Did = parser.getText();
                    } else if (text == 'CampaignName') {
                        CampaignName = parser.getText();
                    } else if (text == 'Location') {
                        Location = parser.getText();
                    } else if (text == 'CallerID') {
                        CallerID = parser.getText();
                    } else if (text == 'PhoneName') {
                        PhoneName = parser.getText();
                    } else if (text == 'Skill') {
                        Skill = parser.getText();
                    } else if (text == 'StartTime') {
                        StartTime = parser.getText();
                    } else if (text == 'EndTime') {
                        EndTime = parser.getText();
                    } else if (text == 'TimeToAnswer') {
                        TimeToAnswer = parser.getText();
                    } else if (text == 'CallDuration') {
                        CallDuration = parser.getText();
                    } else if (text == 'Duration') {
                        Duration = parser.getText();
                    } else if (text == 'FallBackRule') {
                        FallBackRule = parser.getText();
                    } else if (text == 'DialedNumber') {
                        DialedNumber = parser.getText();
                    } else if (text == 'Type') {
                        CallType = parser.getText();
                    } else if (text == 'AgentID') {
                        AgentID = parser.getText();
                    } else if (text == 'AgentPhoneNumber') {
                        AgentPhoneNumber = parser.getText();
                    } else if (text == 'AgentUniqueID') {
                        AgentUniqueID = parser.getText();
                    } else if (text == 'AgentName') {
                        AgentName = parser.getText();
                    } else if (text == 'Disposition') {
                        Disposition = parser.getText();
                    } else if (text == 'HangupBy') {
                        HangupBy = parser.getText();
                    } else if (text == 'Status') {
                        Status = parser.getText();
                    } else if (text == 'AudioFile') {
                        AudioFile = parser.getText();
                    } else if (text == 'TransferType') {
                        TransferType = parser.getText();
                    } else if (text == 'TransferredTo') {
                        TransferredTo = parser.getText();
                    } else if (text == 'Comments') {
                        Comments = parser.getText();
                    } else if (text == 'DialStatus') {
                        DialStatus = parser.getText();
                    } else if (text == 'Apikey') {
                        Apikey = parser.getText();
                    } else if (text == 'AgentStatus') {
                        AgentStatus = parser.getText();
                    } else if (text == 'CustomerStatus') {
                        CustomerStatus = parser.getText();
                    } else if (text == 'UserName') {
                        UserName = parser.getText();
                    } else if (text == 'CallerConfAudioFile') {
                        CallerConfAudioFile = parser.getText();
                    } else if (text == 'ConfDuration') {
                        ConfDuration = parser.getText();
                    } else if (text == 'CampaignStatus') {
                        CampaignStatus = parser.getText();
                    } else if (text == 'DataUniqueId') {
                        DataUniqueId = parser.getText();
                    } else if (text == 'WrapUpDuration') {
                        WrapUpDuration = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public static Ex_CTICallBackParse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new Ex_CTICallBackParse(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                           curr == System.JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }

}