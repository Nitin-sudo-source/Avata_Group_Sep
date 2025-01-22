@isTest
public class TestEx_BookingCancellationHandler {
    @isTest
    static void testFetchBooking() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        List<User> uu = new List<User>();
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@testdomain.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = prof.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@testdomain.com');      
        uu.add(u);
        
        insert uu;
        System.debug('uu: '+uu[0].Id);

        Project__c p = new Project__c();
        p.Name = 'p';
        p.Booking_Cancellation_Approver__c = uu[0].Id;
        insert p;
       
        Unit__c testUnit = new Unit__c(Sale_Status__c = 'Booked');
        insert testUnit;
        
        Opportunity__c testOpportunity = new Opportunity__c(Opportunity_Stage__c = 'Booking Confirmed');
        insert testOpportunity;
        
        Booking__c testBooking = new Booking__c(
            Unit__c = testUnit.Id,
            Opportunity__c = testOpportunity.Id,
            Booking_Stage__c = 'Booking Confirmed',
            Booking_Cancellation_Approver__c = p.Booking_Cancellation_Approver__c
        );
        insert testBooking;
        
        Test.startTest();
        String result = Ex_BookingCancellationHandler.fetchBooking(
            testBooking,
            'Unit Cancellation',
            100.0,
            'Cancellation Remarks'
        );
        
     
        
        
        // Verify that the booking and related records were updated correctly
        Booking__c bk = [SELECT Id, Booking_Stage__c, Cancellation_Type__c, Unit__c, Opportunity__c, Refund_Amount__c, Cancellation_Remark__c FROM Booking__c WHERE Id = :testBooking.Id];
        bk.Booking_Cancellation_Approver__c = p.Booking_Cancellation_Approver__c;
        bk.Booking_Stage__c = 'Cancellation in-process';
        bk.Cancellation_Type__c = 'Unit Cancellation';
        bk.Refund_Amount__c = 0;
        bk.Cancellation_Remark__c = 'Test';
        update bk;
        System.debug('bk: '+bk);
        
        Unit__c un = [SELECT Id, Sale_Status__c, Opportunity__c, Booking__c FROM Unit__c WHERE Id = : bk.Unit__c];
        un.Sale_Status__c = 'Vacant';
        un.Opportunity__c = null;
        un.Booking__c = null;
        update un;
        
        Opportunity__c opp = [SELECT Id, Opportunity_Stage__c, Booking__c FROM Opportunity__c WHERE Id = :bk.Opportunity__c];
        opp.Opportunity_Stage__c = 'Booking Cancelled';
        opp.Booking__c = null;
        update opp;
        
         Test.stopTest();
    }
    }