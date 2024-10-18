public class Ex_PrintBookingPDF {
    public string bId { get; set; }
    public Booking__c bk { get; set; }
    public List<Booking__c> bkList { get; set; }
    public List<applicant__c> apList { get; set; }
    public List<Receipt__c> rtList { get; set; }
    public List<Car_Park__c> carList { get; set; }

    public String amountInWords { get; set; }
    public decimal countOfIds { get; set; }
    public string stringCar { get; set; }

    public List<String> termsList { get; set; } // Terms list for storing multiple terms
    public List<ApplicantWrapper> ApplicantWrapperList { get; set; }
   

    public Ex_PrintBookingPDF() {
        bId = ApexPages.currentPage().getParameters().get('bId');
        
        bkList = new List<Booking__c>();
        carList = new List<Car_Park__c>();
        apList = new List<Applicant__c>();
        rtList = new List<Receipt__c>();
        termsList = new List<String>(); // Initialize the terms list
        ApplicantWrapperList = new List<ApplicantWrapper>();

        if (bId != null) {
            // Fetch Booking details
            bkList = [
                SELECT Id, Name, Agreement_Value__c, Project__r.Project_Logo__c, Booking_Date__c, Tower__r.Name,
                       Unit__r.Name, Unit__r.Configuration_Type__c, Unit__r.RERA_Carpet_Area_Sq_Ft__c, 
                       Project__r.Booking_Terms_and_Conditions_2__c  // Fetching the terms from Project__c
                FROM Booking__c 
                WHERE Id = :bId
            ];

            if (!bkList.isEmpty()) {
                Booking__c booking = bkList[0];
                
                // Convert Agreement value to words if available
                if (booking.Agreement_Value__c != null) {
                    amountInWords = Ex_NumberToWord.convertNumbertoWords(Integer.valueOf(booking.Agreement_Value__c));
                }

                // Fetch Car Park details
                carList = [SELECT Id FROM Car_Park__c WHERE Booking__c = :bId];
                countOfIds = carList.size();
                if (countOfIds > 0) {
                    stringCar = Ex_NumberToWord.convertNumbertoWords(Integer.valueOf(countOfIds));
                }

                // Fetch Receipts
                rtList = [
                    SELECT Id, Name, Receipt_Date__c, Transaction_ID__c
                    FROM Receipt__c 
                    WHERE Booking__c = :bId 
                    ORDER BY Receipt_Date__c, CreatedDate ASC
                ];

                // Fetch Applicants
                apList = [
                    SELECT Id, Name, Applicant_Number__c, Applicant_Title__c, DOB__c, Anniversary_Date__c, 
                           Occupation__c, Mobile__c, Email__c, PAN_Number__c, Permanent_Address__c, 
                           Country__c, State__c, City__c, PIN__c
                    FROM Applicant__c 
                    WHERE Booking__c = :bId 
                    ORDER BY Applicant_Number__c ASC
                ];

                // Populate ApplicantWrapperList
                for (Applicant__c applicant : apList) {
                    ApplicantWrapperList.add(new ApplicantWrapper(
                        applicant.Applicant_Title__c,
                        applicant.Applicant_Number__c,
                        applicant.Name,
                        null, // Gender (not available in the queried fields)
                        applicant.DOB__c,
                        applicant.Anniversary_Date__c,
                        applicant.Occupation__c,
                        applicant.Mobile__c,
                        applicant.PAN_Number__c,
                        applicant.Email__c,
                        applicant.Permanent_Address__c,
                        applicant.State__c,
                        applicant.Country__c,
                        applicant.City__c,
                        applicant.PIN__c,
                        '', // Permanent address fields can be adjusted if necessary
                        applicant.State__c,
                        applicant.Country__c,
                        applicant.City__c,
                        applicant.PIN__c
                    ));
                }

                // Add Booking Terms and Conditions 2 to the terms list
                if (booking.Project__r.Booking_Terms_and_Conditions_2__c != null) {
                    termsList.add(booking.Project__r.Booking_Terms_and_Conditions_2__c);
                }
            }
        }
    }

    public class ApplicantWrapper {
        public String apTitle { get; set; }
        public String applicantNumber { get; set; }
        public String applicantName { get; set; }
        public String applicantGender { get; set; }
        public Date applicantDOB { get; set; }
        public Date applicantAnivserD { get; set; }
        public String applicantOccupation { get; set; }
        public String applicantMobile { get; set; }
        public String applicantPAN { get; set; }
        public String applicantEmail { get; set; }
        public String commAddress { get; set; }
        public String commState { get; set; }
        public String commCountry { get; set; }
        public String commCity { get; set; }
        public String commPIN { get; set; }
        public String permAddress { get; set; }
        public String permState { get; set; }
        public String permCountry { get; set; }
        public String permCity { get; set; }
        public String permPIN { get; set; }

        public ApplicantWrapper(String apTitle, String applicantNumber, String applicantName, String applicantGender, 
                                Date applicantDOB, Date applicantAnivserD, String applicantOccupation, String applicantMobile, 
                                String applicantPAN, String applicantEmail, String commAddress, String commState, 
                                String commCountry, String commCity, String commPIN, String permAddress, String permState, 
                                String permCountry, String permCity, String permPIN) {
            this.apTitle = apTitle;
            this.applicantNumber = applicantNumber;
            this.applicantName = applicantName;
            this.applicantGender = applicantGender;
            this.applicantDOB = applicantDOB;
            this.applicantAnivserD = applicantAnivserD;
            this.applicantOccupation = applicantOccupation;
            this.applicantMobile = applicantMobile;
            this.applicantPAN = applicantPAN;
            this.applicantEmail = applicantEmail;
            this.commAddress = commAddress;
            this.commState = commState;
            this.commCountry = commCountry;
            this.commCity = commCity;
            this.commPIN = commPIN;
            this.permAddress = permAddress;
            this.permState = permState;
            this.permCountry = permCountry;
            this.permCity = permCity;
            this.permPIN = permPIN;
        }
    }
}