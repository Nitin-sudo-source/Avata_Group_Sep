//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 09-12-2023
//-------------------------------------------//
public class Ex_CarParkingAllotment {
    @AuraEnabled(cacheable=true)
    public static Booking__c getBooking(Id bookingId){
        Booking__c booking = [SELECT Tower__c, Quotation__c, Project__r.Car_Park_Maintain_At__c, Project__c FROM Booking__c WHERE Id = :bookingId];
        System.debug('bookingRecord: '+booking);
        if (booking != null) {
            return booking;
        } else {
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Car_Park__c> getCarPark(Booking__c booking, String gettype){
        System.debug('booking: '+booking);
        System.debug('gettype: '+gettype);
        List<Car_Park__c> carParkList = new List<Car_Park__c>();
        if(booking != null){
            if(gettype == ''){
                System.debug('Car_Park_Maintain_At__c Before: '+booking.Project__r.Car_Park_Maintain_At__c);
                if(booking.Project__r.Car_Park_Maintain_At__c == 'Project'){
                    System.debug('Car_Park_Maintain_At__c After: '+booking.Project__r.Car_Park_Maintain_At__c);
                    carParkList = [SELECT Id, Name, Status__c, Floor__c, Type__c, Project__c
                                   FROM Car_Park__c 
                                   WHERE Project__c = :booking.Project__c Order by Floor__c  DESC];
                    System.debug('carParkList: '+carParkList);
                }else if(booking.Project__r.Car_Park_Maintain_At__c == 'Tower'){
                    carParkList = [SELECT Id, Name, Status__c, Floor__c, Type__c, Project__c
                                   FROM Car_Park__c 
                                   WHERE Tower__c = :booking.Tower__c Order by Floor__c  DESC];
                }
                if(!carParkList.isEmpty() && carParkList != null){
                    return carParkList;
                }else{
                    return null;
                }
                
            }else{
                if(booking.Project__r.Car_Park_Maintain_At__c == 'Project'){
                    carParkList = [SELECT Id, Name, Status__c, Floor__c, Type__c, Project__c 
                                   FROM Car_Park__c 
                                   WHERE Project__c = :booking.Project__c AND Type__c =: gettype Order by Floor__c  DESC];
                }else if(booking.Project__r.Car_Park_Maintain_At__c == 'Tower'){
                    carParkList = [SELECT Id, Name, Status__c, Floor__c, Type__c 
                                   FROM Car_Park__c 
                                   WHERE Tower__c = :booking.Tower__c AND Type__c =: gettype Order by Floor__c  DESC];
                    
                }
                System.debug('carParkList: '+carParkList);
                if(!carParkList.isEmpty() && carParkList != null){
                    return carParkList;
                }else{
                    return null;
                }
                
            }
        }else{
            return null;
        }
       
    }
    
   
    
    
   
    public static Map<String,List<Car_Park__c>> getBookingRelatedCarPark(Booking__c booking){
        System.debug('booking: '+booking);
        Map<String,List<Car_Park__c>> carParkTypeMap = new  Map<String,List<Car_Park__c>>();
        List<Car_Park__c> carParkList = new List<Car_Park__c>();
        if(booking != null){
            carParkList = [Select Id, Type__c from Car_Park__c Where Booking__c =: booking.Id AND Status__c = 'Booked'];
            System.debug('carParkList: '+carParkList.size());
            System.debug('carParkList: '+carParkList);
            if(!carParkList.isEmpty() && carParkList != null){
                for (Car_Park__c carPark : carParkList) {
                    if (carParkTypeMap.containsKey(carPark.Type__c)) {
                        carParkTypeMap.get(carPark.Type__c).add(carPark);
                    }else{
                        System.debug('carParkList: '+carParkList.size());
                        List<Car_Park__c> cpList = new  List<Car_Park__c>();
                        cpList.add(carPark);
                        System.debug('cpList :'+cpList);
                        carParkTypeMap.put(carPark.Type__c, cpList);
                    }
                    System.debug('carParkTypeMap: '+carParkTypeMap); 
                }
            }
            return carParkTypeMap;
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<wrapperCarParkRequired> getCarParkRequiredWrapper(Booking__c booking){
        List<wrapperCarParkRequired> wrapperCarParkRequiredList = new List<wrapperCarParkRequired>();
        Map<String,List<Car_Park__c>> carparkBookedMap = getBookingRelatedCarPark(booking);
        System.debug('carparkBookedMap: '+carparkBookedMap);
        List<Car_Park_Required__c> carParkRequiredList = [SELECT Id, Name, Car_Park_Count__c, Car_Park_Type__c
                                                          FROM Car_Park_Required__c
                                                          WHERE Quotation__c =: booking.Quotation__c];
       // System.debug('carParkRequiredList: '+carParkRequiredList);
        if(!carParkRequiredList.isEmpty() && carParkRequiredList != null){
            for(Car_Park_Required__c cpr : carParkRequiredList){
                if(!carparkBookedMap.isEmpty() && carparkBookedMap != null){
                    if (carparkBookedMap.containsKey(cpr.Car_Park_Type__c)) {
                        wrapperCarParkRequiredList.add(new wrapperCarParkRequired(cpr.Car_Park_Type__c, cpr.Car_Park_Count__c, carparkBookedMap.get(cpr.Car_Park_Type__c).size() , cpr.Car_Park_Count__c - carparkBookedMap.get(cpr.Car_Park_Type__c).size()));
                    }else{
                        wrapperCarParkRequiredList.add(new wrapperCarParkRequired(cpr.Car_Park_Type__c, cpr.Car_Park_Count__c, 0 , cpr.Car_Park_Count__c ));
                    }
                }else{
                    wrapperCarParkRequiredList.add(new wrapperCarParkRequired(cpr.Car_Park_Type__c, cpr.Car_Park_Count__c, 0 , cpr.Car_Park_Count__c ));
                }
            }
        }
        if(!wrapperCarParkRequiredList.isEmpty() && wrapperCarParkRequiredList != null){
            return wrapperCarParkRequiredList;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public Static Boolean updateCarParkwithBooking(List<Car_Park__c> finalCarParkList, String bookingId){
        if(!finalCarParkList.isEmpty() && finalCarParkList != null){
            for (Car_Park__c carPark : finalCarParkList) {
                carPark.Booking__c = bookingId;
                carPark.Status__c = 'Booked';
            }
        }
        if(!finalCarParkList.isEmpty() && finalCarParkList != null){
            try {
                update finalCarParkList;
                return true;
            }catch(Exception ex){
                System.debug('An Error Occured Please Contact System Administrator:  '+ex.getMessage());
                return false;
            }
        }else{
            return false;
        }
    }
    
     public class wrapperCarParkRequired{
        @AuraEnabled
        public String carparktype {get;set;}
        @AuraEnabled
        public Decimal totalRequiredCount {get;set;}
        @AuraEnabled
        public Decimal allotedCount {get;set;}
        @AuraEnabled
        public Decimal unallotedCount {get;set;}
        
        public wrapperCarParkRequired(String carparktype,Decimal totalRequiredCount, Decimal allotedCount,Decimal unallotedCount ){
             this.carparktype = carparktype;
             this.totalRequiredCount = totalRequiredCount;
             this.allotedCount = allotedCount;
             this.unallotedCount = unallotedCount;
        }
     }
}