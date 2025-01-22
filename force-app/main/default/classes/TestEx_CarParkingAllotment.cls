@isTest
public class TestEx_CarParkingAllotment {
    @isTest
    static void testGetTowerFromBooking() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Car_Park_Maintain_At__c = 'Project';
        insert p;
        System.debug('p: '+p);
        
        
        tower__c t = new tower__c();
        t.Name = 'Test Tower';
        t.Project__c = p.Id;
        insert t ;
     
        
        Quotation__c quotation = new Quotation__c();
        quotation.Project__c = p.id;
        quotation.Tower__c = t.id;
        insert quotation;
        
        Booking__c booking = new Booking__c();
        booking.Quotation__c = quotation.Id;
        booking.Project__c = p.id;
      //  booking.Tower__c = t.id;
        insert booking;
        System.debug('Booking: '+booking);
        
        Car_Park__c carPark = new Car_Park__c(Status__c = 'Available',  Project__c = booking.Project__c , Type__c = 'Podium Parking', Booking__c = booking.Id);
        insert carPark;
        
        Car_Park__c carPark2 = new Car_Park__c(Status__c = 'Available',  Project__c = booking.Project__c , Type__c = 'Podium Parking' , Booking__c = booking.Id);
        insert carPark2;
        
        
        Car_Park_Required__c carParkRequired = new Car_Park_Required__c(
            Quotation__c = Booking.Quotation__c,
            Car_Park_Count__c = 2,
            Car_Park_Type__c = 'Podium Parking'
            
        );
        insert carParkRequired;
        
        Car_Park__c carPark1 = new Car_Park__c(Status__c = 'Available',  Project__c = booking.Project__c , Type__c = 'Podium Parking');
        insert carPark1;
       
        Ex_CarParkingAllotment.updateCarParkwithBooking(new List<Car_Park__c>{carPark1}, booking.Id);
        Ex_CarParkingAllotment.getCarParkRequiredWrapper(booking);
        List<Car_Park__c> carParkList = new List<Car_Park__c>();
        
        carParkList = Ex_CarParkingAllotment.getCarPark(booking ,'Podium Parking');
        Ex_CarParkingAllotment.getCarPark(booking ,'');
        Ex_CarParkingAllotment.getBookingRelatedCarPark(booking);
        Ex_CarParkingAllotment.getBooking(booking.Id);
        
    }
    
    
    
}