@istest 
public class mCubeController_Test {
   
    @istest
    public static void inboundCalltest(){
        Profile p = [SELECT Id FROM Profile  limit 1];
         
    User u = new User(Alias = 'standt12', Email='standarduser@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.123',MobilePhone = '111');
        u.massdialerIds__c = ','+lead.id;
        insert  u;
        
        Lead__c lead = new Lead__c();
        //lead.lastname = 'Test Lead';
        lead.Lead_Stage__c = 'Prospects';
        lead.Lead_Sub_Stage__c = 'Hot';
        lead.OwnerId=u.id;
        //lead.Company = 'TestCompany';
        //lead.Phone = '67878';
        //lead.mobilePhone = '1111111'; 
        //lead.Email = 'standarduser@testorgfil.com';
        insert lead;
        MCUBE_Object_Api__c  m  = new MCUBE_Object_Api__c ();
        m.name = 'Lead__c';
        m.Field_to_Compare_Mobile_Incoming_Number__c = 'Mobile__c ';
        m.field__c = 'FirstName';
        m.field1__c = 'LastName';
        m.field2__c = 'company';
        m.Value__c = 'company';
        m.value1__c = 'company';
        m.value2__c = 'company';
        insert m;
        MCUBE_Object_Api__c  m1  = new MCUBE_Object_Api__c ();
        m1.name = 'CP_Lead__c';
        m1.Field_to_Compare_Mobile_Incoming_Number__c = 'Mobile__c ';
        m1.field__c = 'FirstName';
        m1.field1__c = 'LastName';
        m1.field2__c = 'company';
        m1.Value__c = 'company';
        m1.value1__c = 'company';
        m1.value2__c = 'company';
        insert m1;
         

       
        
        string data = '{\"dialstatus\":\"CONNECTING\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"empnumber\":\"111\",\"callfrom\":\"1111111\"}' ;        
        PageReference pageRef = Page.calland;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();
        
        
        data = '{\"dialstatus\":\"ANSWER\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"empnumber\":\"111\",\"callfrom\":\"1111111\"}' ;        
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();
        
        data = '{\"status\":\"ORIGINATE\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"executive\":\"111\",\"customer\":\"1111111\",\"refid\":\"'+lead.id+'\"}' ;        
         PageReference pageRef1 = Page.calland;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();
        data = '{\"status\":\"ORIGINATE\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"executive\":\"111\",\"customer\":\"1111111\",\"refid\":\"'+lead.id+'\"}' ;        
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();
        
        data = '{\"dialstatus\":\"CALL COMPLETE\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"executive\":\"111\",\"customer\":\"1111111\",\"refid\":\"'+lead.id+'\"}' ;        
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();
       
                data = '{\"dialstatus\":\"CALL COMPLETE\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"executive\":\"111\",\"customer\":\"1111111\"}' ;        
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();
        mCubeController.readCall();
        
        mCubeController.readCall();
        
        
       CP_Project__c testProject = new CP_Project__c(DID_1__c = '9988776655', DID_2__c = '9988776644');
        insert testProject;

        // Create a CP_Lead__c record associated with the CP_Project__c
        CP_Lead__c testLead = new CP_Lead__c( CP_Project__c = testProject.Id);
        insert testLead;
        
        data = '{\"status\":\"ORIGINATE\",\"endtime\":\"'+system.now()+'\",\"starttime\":\"'+system.now()+'\",\"executive\":\"111\",\"customer\":\"1111111\",\"refid\":\"'+testLead.id+'\"}' ;        
        ApexPages.currentPage().getParameters().put('data',data);
        mCubeController.inboundCall();

        
        System.runAs(u) {
            mCubeController.clickToCall(lead.id,'1234567');
            
            mCubeController.clickToCallWithoutDID(lead.id);
            mCubeController.getVisitPreRegistrationRecord('CP Lead', testLead.id);
            mCubeController.clickToCallNumber(string.valueof( lead.id),'1111111' );
            mCubeController.readNumbers(string.valueof( lead.id) );
            mCubeController.getTheObjectDetails(testLead.id);
            mCubeController.getProjects();
            pageRef = Page.Dialer;
            Test.setCurrentPage(pageRef);
            mCubeController.getcover();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Lead__c>{lead});
           /* Dialercontroller s = new Dialercontroller(stdSetController );
            s.direct();
            u.massdialerIds__c = +','+lead.id;
            update u;*/
            
         }
        

        
    }
    
  }