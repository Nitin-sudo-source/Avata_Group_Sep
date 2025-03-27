/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 26-03-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
public with sharing class EX_JSONGeoParser {
    public EX_JSONGeoParser() {

    }
    public class Address_components {
        public String long_name;
        public String short_name;
        public List<String> types;
    }
    
    public class Geometry {
        public Location location;
        public String location_type;
        public Viewport viewport;
    }
    
    public class Plus_code {
        public String compound_code;
        public String global_code;
    }
    
    public List<Results> results;
    public List<Location> location;
    public String status;
    
    public class Results {
        public List<Address_components> address_components;
        public String formatted_address;
        public Geometry geometry;
        public String place_id;
        public Plus_code plus_code;
        public List<String> types;
    }
    public class Viewport {
        public Location northeast;
        public Location southwest;
    }
    public class Location {
        public Double lat;
        public Double lng;
    }
    public static EX_JSONGeoParser parse(String json) {
        return (EX_JSONGeoParser) System.JSON.deserialize(json, EX_JSONGeoParser.class);
    }
}