public without sharing class LiveChatController {
    public class Sender {
        public String phone;
        public String name;
        public String country_code;
        public String dial_code;
    }

    public class PayloadData {
        public String text;
        public String url;
    }

    public class Payload {
        public String id;
        public String source;
        public String type;
        public PayloadData payload;
        public Sender sender;
        public Context context;
        public String phone;
        public String destination;
    }

    public class Context {
        public String id;
        public String gsId;
    }

    public String app;
    public Long timestamp;
    public Integer version;
    public String type;
    public Payload payload;

    public static LiveChatController parse(String json) {
        return (LiveChatController) System.JSON.deserialize(json, LiveChatController.class);
    }

}