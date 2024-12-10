@isTest
public class TestEx_BookingTriggerHandler {
    @isTest
    public static void testUpdateBookingDetails() {
        // Create a test user
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create Project
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;

        // Create Tower
        Tower__c tower = new Tower__c(Name = 'Test Tower', Project__c = project.Id);
        insert tower;

        // Create Unit
        Unit__c unit = new Unit__c(
            Tower__c = tower.Id,
            Project__c = project.Id,
            Total_carpet_Sq_Ft__c = 10,
            Configuration_Type__c = '4 BHK',
            Floor__c = 1,
            Sales_Status__c = 'Vacant'
        );
        insert unit;
        
       // Create Quotation
        Quotation__c quotation = new Quotation__c(
            Unit__c = unit.Id,
            Project__c = project.Id,
            Tower__c = tower.Id,
            AV_GST_Percentage__c = 4
        );
        insert quotation;

        Charge_Details__c cd=new Charge_Details__c();
        cd.Quotation__c=quotation.id;
        cd.Charge_Amount__c=60000;
        cd.Charge_Bucket__c='demo';
        cd.Charge_Percentage__c=10;
        cd.Charge_Rate__c=6767;
        insert cd;
        
        Payment_Milestone__c pm=new Payment_Milestone__c();
        pm.Quotation__c=quotation.id;
        pm.Milestone_Name__c='mile 1';
        pm.Is_Raised__c=true;
        pm.Milestone_Type__c='Date Linked';
        insert pm;
        
        
        // Create Booking
        Booking__c booking = new Booking__c(
            Booking_Date__c = System.today(),
            Mode_Of_Funding__c = 'Self Funding',
            Project__c = project.Id,
            Tower__c = tower.Id,
            Booking_Stage__c = 'Booking In-Process',
            Quotation__c = quotation.Id,
            Unit__c = unit.Id,
            Remarks__c = 'Test Booking',
            Loan_Bank_Name__c = 'HDFC Bank',
            Loan_Amount__c = 700.00,
            CRM_Head__c = testUser.Id
        );
        insert booking;
        
        
         Opportunity__c op1=new Opportunity__c();
        op1.Stage__c='Booking Cancelled';
        op1.Booking__c=booking.id;
        insert op1;
        
        Unit__c unit1= new Unit__c();
            unit1.Total_carpet_Sq_Ft__c = 10;
            unit1.Configuration_Type__c = '4 BHK';
            unit1.Floor__c = 1;
            unit1.Sales_Status__c = 'Vacant';
        unit1.Opportunity__c=op1.id;
        unit1.Booking__c=booking.id;
        insert unit1;
        
        // Create a list containing the single Booking__c record
        List<Booking__c> bookingList = new List<Booking__c>{booking};
            
            // Use the list to initialize the map
            Map<Id, Booking__c> quotationBookingMap = new Map<Id, Booking__c>(bookingList);
        // Update Booking to trigger the afterUpdate logic
        booking.Booking_Stage__c = 'Booking Confirmed';
        booking.Welcome_Call_Done__c = true;
        update booking;

        set<Id> bookset=new set<Id>();
        bookset.add(booking.id);
        
         set<Id> qset=new set<Id>();
        qset.add(quotation.id);
         
        set<id> tset=new set<id>();
        tset.add(tower.id);
        
        // Validate the trigger actions
        Booking__c updatedBooking = [SELECT Id, Booking_Stage__c, Welcome_Call_Done__c FROM Booking__c WHERE Id = :booking.Id];
        System.assertEquals('Booking Confirmed', updatedBooking.Booking_Stage__c, 'Booking Stage should be updated');
        System.assertEquals(true, updatedBooking.Welcome_Call_Done__c, 'Welcome Call Done should be true');
        
        Ex_BookingHanldlerServices.getbookingCancellationUpdate(bookset);
        Ex_BookingHanldlerServices.getBookingDetailMap(bookset);
         Map<Id, Unit__c> unitMap = Ex_BookingHanldlerServices.getUnitMap(bookset);
        Ex_BookingHanldlerServices.getChargeDetailsMap(qset);
        Ex_BookingHanldlerServices.getQuotationDetailMap(qset);
        Ex_BookingHanldlerServices.getUnDemandedPaymentMilestoneMap(qset);
        Ex_BookingHanldlerServices.updatePaymentMilestoneDueDate(quotationBookingMap, tset);
        
        
        Ex_BookingFormController.getReceipts();
        //Ex_BookingFormController.getBookingWrapper(oppId);
    }
}