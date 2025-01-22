/* Developer .: Aditya Marne, Yash Jain, Harshal More */
/* Disclaimer .: Please do not make any changes without informing the developers mentioned above*/
/* Currently used for sending Whatsapp Bulk Message */

public class WhatsAppMessageWrapper {
    public String mobile { get; set; }
    public String templateId { get; set; }
    public String parameters { get; set; }
    public String recordId {get; set;}
    public String messsage {get; set;}
    
    public WhatsAppMessageWrapper(String mobile, String templateId, String parameters, String recordId, String messsage) {
        this.mobile = mobile;
        this.templateId = templateId;
        this.parameters = parameters;
        this.recordId = recordId;
        this.messsage = messsage;
    }
}