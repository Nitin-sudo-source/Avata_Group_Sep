import { LightningElement, wire, api, track } from 'lwc';
import selectProject from '@salesforce/apex/Ex_SiteVisitFormController.selectProject';
import projectImage from '@salesforce/apex/Ex_SiteVisitFormController.projectImage';
import getSVWrapper from '@salesforce/apex/Ex_SiteVisitFormController.getSVWrapper';
import { NavigationMixin } from 'lightning/navigation';
import searchForData from '@salesforce/apex/Ex_SiteVisitFormController.searchForData';
import submit from '@salesforce/apex/Ex_SiteVisitFormController.submit';
import getSiteName from '@salesforce/apex/Ex_SiteVisitFormController.getSiteName';
// import getChannelPartner from '@salesforce/apex/Ex_SiteVisitFormController.getChannelPartner';
// import getSourcingManager from '@salesforce/apex/Ex_SiteVisitFormController.getSourcingManager';
import getChannelPartnerWrapper from '@salesforce/apex/Ex_SiteVisitFormController.getChannelPartnerWrapper';
import createChannelPartner from '@salesforce/apex/Ex_SiteVisitFormController.createChannelPartner';
import getCodeDetails from '@salesforce/apex/Ex_SiteVisitFormController.getCodeDetails';
import getCPProject from '@salesforce/apex/Ex_SiteVisitFormController.getCPProject';
import getLocationSuggestions from '@salesforce/apex/Ex_SiteVisitFormController.getLocationSuggestions';
import getPlaceInfo from '@salesforce/apex/Ex_SiteVisitFormController.getPlaceInfo';
import ExcellerLogo from '@salesforce/resourceUrl/ExcellerLogo';


const accountColumns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Mobile', fieldName: 'PersonMobilePhone' },
    // { label: 'Secondary Mobile', fieldName: 'Phone' },
    { label: 'Email', fieldName: 'PersonEmail' }
];
const leadColumns = [
    { label: 'Lead Name', fieldName: 'Full_Name__c', type: 'text' },
    { label: 'Mobile', fieldName: 'Mobile__c' },
    { label: 'Email', fieldName: 'Email__c' },
    { label: 'Lead Source', fieldName: 'Lead_Source__c', type: 'picklist' },
    { label: 'Presales Manager', fieldName: 'presalesManager', type: 'text' },
    {
        label: 'Last Presales Call Date', fieldName: 'Last_Presales_Call_Date__c',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit'
        }
    },
    {
        label: 'Lead Creation Date', fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit'

        }
    },
    { label: 'No of Days From Last Call Date', fieldName: 'noOfDaysFromLastCall', type: 'text' },

];

const opportunityColumns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
    // { label: 'Opportunity Stage', fieldName: 'Opportunity_Stage__c' },
    { label: 'Source', fieldName: 'Lead_Source__c' },
    {
        label: 'Last SV Date', fieldName: 'Last_SV_Date__c',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit'

        }
    }, //

    { label: 'No of Days from Last Visit', fieldName: 'noOfDaysFromLastSV', type: 'text' },

];

export default class Ex_SiteVisitForm extends NavigationMixin(LightningElement) {
    excellerLogoUrl = ExcellerLogo;
    accountColumns = accountColumns;
    leadColumns = leadColumns;
    opportunityColumns = opportunityColumns;


    // @api project;
    // @track isQrcustomer = false;
    @api projectId = '';
    @track projectOptions;
    @track searchDataFound;
    @track svWrapper = { sv: {} };
    @track getSVWrapperList = [];
    @track showProjectImage;
    @track isSpinner = false;
    @track disabledProject = false;
    @track disabledMobile = false;
    @track disabledEmail = false;
    @track createNewData = false;
    @track hideSearch = false;
    @track showFirstPage = false;
    @track showSecondPage = false;
    @track showthirdPage = false;
    @track Salutation = '';
    @track showNumber = false;

    @track showAccountDataFound = false;
    @track showLeadDataFound = false;
    @track showOpportunityDataFound = false;
    @track accountFetch = [];
    @track leadFetch = [];
    @track opportunityFetch = [];
    @api accountDataFound = [];
    @api leadDataFound = [];
    @api opportunityDataFound = [];

    @track leadId = null;
    @track oppId = null;
    @track accId = null;
    @track simpleMap = [];
    @track accountsList = [];
    @track showCP = false;
    @track searchPlaceholder = '';
    @track nodataFound = false;
    @track showFifthpage = false;
    @track showFinalScreen = false;
    @track svId = '';
    @track svName = '';
    @track showReferenceName = false;
    @api searchName = '';
    @track getLastSVsourceDate = '';
    @track tat = '';
    @track isSourceNotEditable = false;
    @track showsixPage = false;
    @track registration = '';
    @track disableReg = false;
    @track showCode = false;
    @track showNumber = false;
    @track regCode = '';
    @track showLeadVprData = false;
    @track showVprData = false;
    @track showVerify = false;
    @track changeStatus = false;
    @track disabledregcode = false;
    @track showSourcingCP = false;
    @api searchNameSourcing = '';
    @track searchPlaceholderSourcing = '';
    @track sourcingList = [];
    @track isShowModal = false;
    @track cpWrapper = { cp: {} };
    @track getAccountWrapperList = [];
    @track newCPresult;
    @track showCPProjectName = '';
    @track showErrorMsg = '';
    @track showValidation = '';
    @track showValidationPopup = false;
    @track isNewCPCreated = false;
    @track getCPProjectDetails = [];
    @api defaultRecordId = '';

    @track suggestions = [];
    @track selectedPlaceId = '';
    @track inputValue = '';
    @track showResidentLocation = false;
    @track showOfficeLocation = false;
    @track eventAddressName = '';
    @track inputValueResident = '';

    @track showResidentSection = true;
    @track showOfficeSection = false;
    @track mobileNumber = '';
    @track isMobileShow = false;


    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    /***************************************
     * Page 1: Search Page
     ***************************************/

    connectedCallback() {
        // this.callSV();
        this.showFirstPage = true;
        this.getSVWrapper();

    }

    callSV() {
        var link = document.createElement('a');
        const url = 'Ex_ShowFullPageWalkinVF?'
        link.href = url;
        link.target = '_self';
        link.click();

    }

    getSVWrapper() {
        this.isSpinner = true;
        getSVWrapper({ projectId: null, leadId: null, oppId: null, accId: null })
            .then((result) => {
                this.svWrapper = result;
                this.isSpinner = false;
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));
            }).catch(error => {
                console.log('svWrapper error: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }

    @wire(selectProject)
    retrieveProject({ data, error }) {
        let tempArray = [];
        if (data) {
            for (let key in data) {
                tempArray.push({ label: data[key], value: key });
            }
            this.projectOptions = tempArray;
            console.log('ProjectOptions: ' + JSON.stringify(this.projectOptions));
        } else {
            this.error = error;
            console.log('ProjectOptions: ' + JSON.stringify(this.error));
        }
    }

    lookupRecord(event) {
        // Retrieve the selected record from the event detail
        const selectedRecord = event.detail.selectedRecord;
        const getObjectName = event.target.dataset.name;
        console.log('Selected Record:', JSON.stringify(selectedRecord));
        console.log('Object Name:', getObjectName);

        // Check if getObjectName and selectedRecord are defined
        if (getObjectName && selectedRecord) {
            if (getObjectName === 'Channel_Partner__c' && selectedRecord.Id) {
                this.svWrapper.sv.Channel_Partner__c = selectedRecord.Id;
                this.searchName = selectedRecord.Name;
                //alert('Selected Channel Partner ' + selectedRecord.Name);
                this.callCPProject(this.svWrapper.sv.Channel_Partner__c, this.projectId);

                // Optionally set the display name for UI
                // this.showCP = selectedRecord.Name;
            } else if (getObjectName === 'User' && selectedRecord.Id) {
                this.svWrapper.sv.Sourcing_Manager__c = selectedRecord.Id;
                this.searchNameSourcing = selectedRecord.Name;
                //alert('Selected Sourcing Name ' + selectedRecord.Name);
            }
        }
        if (getObjectName && selectedRecord === undefined) {
            if (getObjectName === 'Channel_Partner__c') {
                this.svWrapper.sv.Channel_Partner__c = undefined;
                // alert('Selected Channel Partner ' + selectedRecord.Name);
                // Optionally set the display name for UI
                // this.showCP = selectedRecord.Name;
            } else if (getObjectName === 'User') {
                this.svWrapper.sv.Sourcing_Manager__c = undefined;
                // alert('Selected Sourcing Name ' + selectedRecord.Name);
            }

        }
        console.log('svWrapper:', JSON.stringify(this.svWrapper));
    }

    callCPProject(accId, pId) {
        // alert('accId: '+accId);
        // alert('pId'+pId);
        this.isSpinner = true;
        getCPProject({ accId: accId, projectId: pId })
            .then((result) => {
                this.isSpinner = false;
                if (result != null) {
                    console.log('result: ' + JSON.stringify(result));
                    this.getCPProjectDetails = result;
                    console.log('getCPProjectDetails: ' + JSON.stringify(this.getCPProjectDetails));
                    console.log('this.getCPProjectDetails.Id: ' + this.getCPProjectDetails.Id);
                    if (this.getCPProjectDetails.Id) {
                        this.svWrapper.sv.CP_Project__c = this.getCPProjectDetails.Id;
                    }
                    if (this.getCPProjectDetails.OwnerId) {
                        this.svWrapper.sv.Sourcing_Manager__c = this.getCPProjectDetails.OwnerId;
                    }
                    this.showValidation = '';
                    this.showValidationPopup = false;
                } else {
                    this.showValidation = 'No CP Project Found Againt Channel Partner Please Create New CP or Select Other Channel Partner';
                    this.showValidationPopup = true;
                    return;
                }
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));

            }).catch(error => {
                //this.error = error;
                console.log('error getCPProjectDetails: ' + JSON.stringify(error));
                this.isSpinner = false;
                alert('Something went Wrong Please Contact System Administrator');
                return;
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
                this.isSpinner = false;
                alert('Something went Wrong Please Contact System Administrator');
                return;
            });

    }


    handleProjectChange(event) {
        this.projectId = event.target.value;
        console.log('projectId: ' + JSON.stringify(this.projectId));
        if (this.projectId != null || this.projectId != '') {
            this.getProjectImage();
        }
    }

    getProjectImage() {
        projectImage({ projectId: this.projectId })
            .then((result) => {
                this.showProjectImage = result;
                //console.log('showProjectImage: ' + JSON.stringify(this.showProjectImage));
            }).catch(error => {
                //this.error = error;
                console.log('error showProjectImage: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }


    handleRegistration(event) {
        this.registration = event.detail.value;
        if (this.registration != null) {
            this.disableReg = true;
        }
        if (this.registration == 'Yes') {
            this.showCode = true;
            this.showNumber = false;
            this.hideSearch = true;
            this.showVerify = true;

        } else if (this.registration == 'No') {
            this.showCode = false;
            this.showNumber = true;
            this.showVerify = false;
        }
    }

    handleRegCode(evt) {
        this.regCode = evt.target.value;
        console.log('regCode: ' + (this.regCode));
    }


    handleVerifyCode() {
        if (this.regCode == '') {
            alert('Please enter Paradigm Code ')
        } else {

            alert('regCode: ' + this.regCode);
            this.isSpinner = true;
            getCodeDetails({ projectId: this.projectId, regCode: this.regCode })
                .then(result => {
                    console.log('code Details: ' + JSON.stringify(result));
                    if (result != null) {
                        alert('Code Verify Successfully');
                        this.disabledregcode = true;
                        this.disabledProject = true;
                        this.showVerify = false;
                        if (result.Id) {
                            this.leadId = result.Id;
                            //alert('leadId: '+this.leadId);
                        }
                        if (result.Mobile__c) {
                            this.svWrapper.sv.Mobile__c = result.Mobile__c;
                            //alert('this.svWrapper.sv.Mobile__c:  '+this.svWrapper.sv.Mobile__c);
                        }
                        if (result.Email__c) {
                            this.svWrapper.sv.Email__c = result.Email__c;
                            //alert('this.svWrapper.sv.Email__c:  '+this.svWrapper.sv.Email__c);
                        }
                        this.handleSearch();
                        //this.isSpinner = false;

                    } else {
                        alert('Invalid Code ');
                        this.isSpinner = false;
                    }
                }).catch(error => {
                    console.log('svWrapper error: ' + JSON.stringify(error));
                    alert('Invalid Code ');
                    this.isSpinner = false;

                }).catch(error => {
                    console.error('An unexpected error occurred:', error);
                    alert('Invalid Code ');
                    this.isSpinner = false;
                });
        }
    }

    handleclosepopup() {
        this.showValidationPopup = false;
    }

    // Edited By Priyanshu Agarkar
    formatDateTime(dateStr) {
        if (!dateStr) return '';

        const date = new Date(dateStr);

        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');

        let hours = date.getHours();
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const ampm = hours >= 12 ? 'PM' : 'AM';

        hours = hours % 12;
        hours = hours ? hours : 12; // If hours is 0, make it 12 (for 12 AM/PM)

        return `${day}/${month}/${year} ${String(hours).padStart(2, '0')}:${minutes} ${ampm}`;
    }
    // Edited By Priyanshu Agarkar

    handleSearch() {
        const numericRegex = /^[0-9]{10}$/;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        //Do not change existing Lead Mobile__c if it already has a value
        if (this.mobileNumber) {
            this.isMobileShow = true;
        } else {
            this.isMobileShow = false;
        }

        if (this.projectId == undefined || this.projectId == '') {
            this.showValidation = 'Please Provide Project Name';
            this.showValidationPopup = true;
            // alert('Please Enter Project');
            return;
        }
        // else if (this.registration == '') {
        //     this.showValidation = 'Please select Paradigm Code';
        //     this.showValidationPopup = true;
        //     // alert('Please select Paradigm Code');
        //     return;
        // }
        else if (!numericRegex.test(this.svWrapper.sv.Mobile__c)) {
            this.showValidation = 'Please enter a valid mobile number with exactly 10 digits.';
            //alert('Please enter a valid mobile number with exactly 10 digits.');
            this.showValidationPopup = true;
            return;
        } else if (this.svWrapper.sv.Mobile__c == undefined || this.svWrapper.sv.Mobile__c == '') {
            this.showValidation = 'Please Enter Mobile';
            this.showValidationPopup = true;
            // alert('Please Enter Mobile');
            return;
        } else if (this.svWrapper.sv.Mobile__c.length < 10) {
            this.showValidation = 'Please Enter Valid Mobile Number';
            this.showValidationPopup = true;
            //alert('Please Enter Valid Mobile Number');
            return;
        } /*else if (this.svWrapper.sv.Email__c == undefined || this.svWrapper.sv.Email__c == '') {
            this.showValidation = 'Please Enter Email';
            this.showValidationPopup = true;
            return;
        } else if (!emailRegex.test(this.svWrapper.sv.Email__c)) {
            this.showValidation = 'Please enter a valid email address.';
            this.showValidationPopup = true;
            return;
        }*/
        else {
            this.showValidationPopup = false;
            this.showValidation = '';
            this.isSpinner = true;
            this.disabledProject = true;
            this.disabledMobile = true;
            this.disabledEmail = true;
            this.createNewData = true;
            this.hideSearch = true;
            // this.showFirstPage = false;
            //   this.isSpinner = false;
            searchForData({ num: this.svWrapper.sv.Mobile__c, email: this.svWrapper.sv.Email__c, projectId: this.projectId })
                .then((result) => {
                    this.isSpinner = false;
                    this.simpleMap = [];
                    for (var key in result) {
                        this.simpleMap.push({ key: key, value: result[key] });
                        console.log('simpleMap: ' + JSON.stringify(this.simpleMap));
                        this.searchDataFound = this.simpleMap;
                    }
                    if (this.searchDataFound != null) {

                        this.searchDataFound.forEach(element => {
                            element.value;
                            element.key;
                            if (element.key.includes('Account')) {
                                this.showAccountDataFound = true;
                                this.accountFetch.push(element.value);
                                console.log('Account Fetched: ', JSON.stringify(this.accountFetch));
                                this.accountDataFound = this.accountFetch[0];
                                this.accId = this.accountDataFound[0].Id;
                                this.accountDataFound.forEach(account => {
                                    account.PersonMobilePhone = account.PersonMobilePhone || '';
                                    account.PersonEmail = account.PersonEmail || '';
                                });
                                this.getFetchValue();
                                console.log('Account Data Found: ', JSON.stringify(this.accountDataFound));

                            }
                            if (element.key.includes('Lead')) {
                                this.showLeadDataFound = true;
                                this.leadFetch.push(element.value);
                                this.leadDataFound = this.leadFetch[0];
                                this.leadId = this.leadDataFound[0].Id;
                                this.getFetchValue();
                                console.log('Lead Found : ' + JSON.stringify(this.leadDataFound));
                                console.log('FirstName : ' + JSON.stringify(this.leadDataFound[0].First_Name__c));
                                console.log('LastName : ' + JSON.stringify(this.leadDataFound[0].Last_Name__c));
                                console.log('Lead Data: ' + JSON.stringify(this.leadDataFound));
                                this.leadDataFound.forEach(lead => {
                                    lead.formattedPresalesCallDate = this.formatDateTime(lead.Last_Presales_Call_Date__c); // Assign formatted date
                                    lead.formattedCreatedDate = this.formatDateTime(lead.CreatedDate); // Ensure created date is used properly
                                });

                                console.log('Formatted Dates:', this.leadDataFound[0].formattedPresalesCallDate, this.leadDataFound[0].formattedCreatedDate);

                                if (this.leadDataFound.length > 0 && this.leadDataFound[0].Last_Presales_Call_Date__c != null) {
                                    // alert('check Date: ' + this.leadDataFound[0].Last_Presales_Call_Date__c);
                                    const lastcallDate = new Date(this.leadDataFound[0].Last_Presales_Call_Date__c);
                                    const today = new Date();
                                    const timeDifference = today.getTime() - lastcallDate.getTime();
                                    const dayDifference = Math.round(timeDifference / (1000 * 3600 * 24)); // Round to the nearest integer
                                    console.log('dayDifference ' + dayDifference);
                                    this.leadDataFound.forEach(lead => {
                                        lead.noOfDaysFromLastCall = dayDifference;
                                        console.log('on Lead Check : ' + lead.noOfDaysFromLastCall);
                                    });

                                }

                                if (this.leadDataFound != null) {
                                    this.leadDataFound.forEach(lead => {
                                        lead.presalesManager = lead.Owner.FirstName + ' ' + lead.Owner.LastName;
                                        console.log('presalesManager: ' + presalesManager);
                                    });
                                }

                                if (this.leadDataFound != null && this.leadDataFound[0].Channel_Partner__r.Name != null) {
                                    this.searchName = this.leadDataFound[0].Channel_Partner__r.Name;
                                    this.searchPlaceholder = '';
                                    this.showChannelPartner = true;
                                }
                                console.log('Lead Data Found: ', JSON.stringify(this.leadDataFound));


                            }
                            if (element.key.includes('Opportunity')) {
                                this.showOpportunityDataFound = true;
                                this.opportunityFetch.push(element.value);
                                this.opportunityDataFound = this.opportunityFetch[0];
                                this.oppId = this.opportunityDataFound[0].Id;
                                this.getFetchValue();
                                console.log('oppId: ' + this.oppId);
                                console.log('FirstName: ' + JSON.stringify(this.opportunityDataFound[0].Owner.FirstName));
                                console.log('LastName: ' + JSON.stringify(this.opportunityDataFound[0].Owner.LastName))



                                if (this.opportunityDataFound != [] && this.opportunityDataFound.length > 0) {
                                    console.log('FirstName: ' + JSON.stringify(this.opportunityDataFound[0].Owner.FirstName));
                                    this.opportunityDataFound.forEach(Opportunity => {
                                        Opportunity.salesManager = Opportunity.Owner.FirstName + ' ' + Opportunity.Owner.LastName;
                                        console.log('salesManager: ' + JSON.stringify(Opportunity.salesManager));
                                    });
                                }

                                if (this.opportunityDataFound != null && this.opportunityDataFound[0].Last_SV_Date__c != null) {
                                    const lastCallSV = new Date(this.opportunityDataFound[0].Last_SV_Date__c);
                                    const today = new Date();
                                    const timeDifference = today.getTime() - lastCallSV.getTime();
                                    const dayDifference = Math.round(timeDifference / (1000 * 3600 * 24)); // Round to the nearest integer
                                    console.log('dayDifference ' + dayDifference);
                                    this.opportunityDataFound.forEach(Opportunity => {
                                        Opportunity.noOfDaysFromLastSV = dayDifference;
                                        console.log('noOfDaysFromLastSV: ' + Opportunity.noOfDaysFromLastSV);
                                    });

                                    this.opportunityDataFound.forEach(Opportunity => {
                                        Opportunity.formattedSVCallDate = this.formatDateTime(Opportunity.Last_SV_Date__c); // Assign formatted date
                                        Opportunity.formattedCreatedDate = this.formatDateTime(Opportunity.CreatedDate); // Ensure created date is used properly
                                    });

                                    console.log('Formatted Dates:', this.opportunityDataFound[0].formattedSVCallDate, this.opportunityDataFound[0].formattedCreatedDate);

                                }

                                if (this.opportunityDataFound != null && this.opportunityDataFound[0].First_Site_Visit_Date__c && this.opportunityDataFound[0].Project__r.Opportunity_Source_TAT__c != null) {
                                    this.tatDays = this.opportunityDataFound[0].Project__r.Opportunity_Source_TAT__c;
                                    console.log('this.tatDays: ' + this.tatDays);
                                    var today = new Date().toISOString().substring(0, 10);
                                    console.log('today: ' + today);
                                    console.log('isSourceNotEditable before: ' + this.isSourceNotEditable);
                                    var lastSVsourceDateObj = new Date(this.opportunityDataFound[0].First_Site_Visit_Date__c);
                                    lastSVsourceDateObj.setDate(lastSVsourceDateObj.getDate() + this.tatDays);
                                    this.getLastSVsourceDate = lastSVsourceDateObj.toISOString().substring(0, 10);
                                    console.log('getLastSVsourceDateWithTATDAYS: ' + this.getLastSVsourceDate);

                                    if (this.getLastSVsourceDate != null && this.getLastSVsourceDate != '' && this.getLastSVsourceDate >= today) {
                                        this.isSourceNotEditable = true;
                                        console.log('isSourceNotEditable After: ' + this.isSourceNotEditable);
                                    }

                                }

                                console.log('length: ' + this.opportunityDataFound.length);
                                if (this.opportunityDataFound.length > 0 && this.opportunityDataFound[0].Channel_Partner__c && this.opportunityDataFound[0].Channel_Partner__r.Name !== undefined && this.opportunityDataFound[0].Channel_Partner__c !== '' && this.opportunityDataFound[0].Channel_Partner__r.Name !== '') {
                                    if (this.opportunityDataFound.length > 0 && this.opportunityDataFound[0].Channel_Partner__r.Name != '' || this.opportunityDataFound[0].Channel_Partner__r.Name != null || this.opportunityDataFound[0].Channel_Partner__r.Name != undefined) {
                                        this.searchName = this.opportunityDataFound[0].Channel_Partner__r.Name;
                                        this.searchPlaceholder = '';
                                        this.showChannelPartner = true;
                                    }
                                }
                                if (this.opportunityDataFound.length > 0 && this.opportunityDataFound[0].Sourcing_Manager__c && this.opportunityDataFound[0].Sourcing_Manager__r.Name !== undefined && this.opportunityDataFound[0].Sourcing_Manager__c !== '' && this.opportunityDataFound[0].Sourcing_Manager__r.Name !== '') {
                                    if (this.opportunityDataFound[0].Sourcing_Manager__r.Name != '' || this.opportunityDataFound[0].Sourcing_Manager__r.Name != null || this.opportunityDataFound[0].Sourcing_Manager__r.Name != undefined) {
                                        this.searchNameSourcing = this.opportunityDataFound[0].Sourcing_Manager__r.Name;
                                        this.searchPlaceholderSourcing = '';
                                    }
                                }
                                console.log('calling oppFetchvalue: ' + this.opportunityDataFound.length);


                            }


                        })
                    } else {
                        this.nodataFound = true;
                    }
                }).catch(error => {
                    console.log('Search Data ' + JSON.stringify(error));
                }).catch(error => {
                    console.error('An unexpected error occurred:', error);
                });
        }
    }


    async fetchPlaceSuggestions(event) {
        const inputSearch = event.target.value;
        this.eventAddressName = event.target.name;
        if (this.eventAddressName === 'Residential') {
            this.showResidentLocation = true;
        }
        if (this.eventAddressName === 'Office') {
            this.showOfficeLocation = true;
        }

        //alert('fetchPlaceSuggestions: '+query);
        //console.log('query: '+query);
        try {
            // Replace 'YOUR_API_KEY' with your actual API key
            //const apiKey = 'AIzaSyAE59k8gMSf0-uNA9SqZ15KeYA_2gL164c';
            const apiKey = 'AIzaSyDIeqrVuALobFWDBVEvGa5IVSLM9k3luoI';
            const result = await getLocationSuggestions({ apiKey, input: inputSearch });
            // console.log('Result: ' + JSON.stringify(result));
            const parsedResult = JSON.parse(result);

            if (parsedResult.status === 'OK') {
                this.suggestions = parsedResult.predictions.map(prediction => ({
                    description: prediction.description,
                    placeId: prediction.place_id
                }));
                console.log('suggestions: ' + JSON.stringify(this.suggestions));

            } else {
                console.error('Error fetching place suggestions:', parsedResult.error_message);
            }
        } catch (error) {
            console.error('Error fetching place suggestions:', error);
        }
    }



    async fetchPlaceDetails(placeId) {
        try {
            // Replace 'YOUR_API_KEY' with your actual API key
            //const apiKey = 'AIzaSyAE59k8gMSf0-uNA9SqZ15KeYA_2gL164c';
            const apiKey = 'AIzaSyDIeqrVuALobFWDBVEvGa5IVSLM9k3luoI';
            const result = await getPlaceInfo({ apiKey, placeId });
            console.log('result: ' + JSON.stringify(result));
            const parsedResult = JSON.parse(result);

            if (parsedResult.status === 'OK') {
                const place = parsedResult.result;
                console.log('Place Details:', JSON.stringify(place));
                this.updateAddressFields(place);


            } else {
                console.error('Error fetching place details:', parsedResult.error_message);
            }
        } catch (error) {
            console.error('Error fetching place details:', error);
        }
    }

    updateAddressFields(place) {
        const addressComponents = place.address_components.reduce((acc, component) => {
            const type = component.types[0];
            acc[type] = component.long_name;
            return acc;
        }, {});
        console.log('addressComponents: ' + JSON.stringify(addressComponents));
        if (this.eventAddressName === 'Residential') {
            this.svWrapper.sv.City__c = addressComponents.locality || '';
            if (this.inputValueResident !== '') {
                this.svWrapper.sv.Locality__c = '';
                if (addressComponents.subpremise === undefined) {
                    addressComponents.subpremise = '';
                }
                if (addressComponents.premise === undefined) {
                    addressComponents.premise = '';
                }
                if (addressComponents.subpremise !== '') {
                    this.svWrapper.sv.Locality__c += addressComponents.subpremise || '';
                }
                if (addressComponents.premise !== '') {
                    this.svWrapper.sv.Locality__c += addressComponents.premise || '';
                }
                if (this.inputValueResident !== '') {
                    this.svWrapper.sv.Locality__c += this.inputValueResident || '';
                }
            }
            this.svWrapper.sv.Country__c = addressComponents.country || '';
            this.svWrapper.sv.State__c = addressComponents.administrative_area_level_1 || '';
            this.svWrapper.sv.Pincode__c = addressComponents.postal_code || '';
            this.showResidentLocation = false;
            console.log('Residential Address: ' + JSON.stringify(this.svWrapper));
        } else if (this.eventAddressName === 'Office') {
            this.svWrapper.sv.City_1__c = addressComponents.locality || '';
            if (this.inputValue !== '') {
                this.svWrapper.sv.Locality_1__c = '';
                if (addressComponents.subpremise === undefined) {
                    addressComponents.subpremise = '';
                }
                if (addressComponents.premise === undefined) {
                    addressComponents.premise = '';
                }
                if (addressComponents.subpremise !== '') {
                    this.svWrapper.sv.Locality_1__c += addressComponents.subpremise || '';
                }
                if (addressComponents.premise !== '') {
                    this.svWrapper.sv.Locality_1__c += addressComponents.premise || '';
                }
                if (this.inputValue !== '') {
                    this.svWrapper.sv.Locality_1__c += this.inputValue || '';
                }
            }
            this.svWrapper.sv.Country_1__c = addressComponents.country || '';
            this.svWrapper.sv.State_1__c = addressComponents.administrative_area_level_1 || '';
            this.svWrapper.sv.Pincode_1__c = addressComponents.postal_code || '';
            this.showOfficeLocation = false;
            console.log('Office Address: ' + JSON.stringify(this.svWrapper));
        } else {

        }
    }



    handleSuggestionSelect(event) {
        //alert('Inside Suggesstion');
        const placeId = event.currentTarget.dataset.placeId;
        this.selectedPlaceId = placeId;
        //alert('selectedPlaceId'+this.selectedPlaceId);
        if (this.eventAddressName === 'Residential') {
            this.inputValueResident = event.target.dataset.name;
        }
        if (this.eventAddressName === 'Office') {
            this.inputValue = event.target.dataset.name;
        }
        this.fetchPlaceDetails(placeId);
    }




    /***************************************
 * Page 1: Search Page End
 ***************************************/

    handleChange(event) {
        // For Residential Address
        if (event.target.name == "Residential") {
            this.svWrapper.sv.City__c = event.target.city;
            this.svWrapper.sv.Locality__c = event.target.street;
            this.svWrapper.sv.Country__c = event.target.country;
            this.svWrapper.sv.State__c = event.target.province;
            this.svWrapper.sv.Pincode__c = event.target.postalCode;
            console.log('Residential Address: ' + JSON.stringify(this.svWrapper));

            //this.fetchPlaceSuggestions(event.target.postalCode);
            // For Office Address
        } else if (event.target.name == "Office") {
            this.svWrapper.sv.City_1__c = event.target.city;
            this.svWrapper.sv.Locality_1__c = event.target.street;
            this.svWrapper.sv.Country_1__c = event.target.country;
            this.svWrapper.sv.State_1__c = event.target.province;
            this.svWrapper.sv.Pincode_1__c = event.target.postalCode;
            console.log('Office Address: ' + JSON.stringify(this.svWrapper));
        } else {

            try {
                const fieldName = event.target ? event.target.fieldName : event.detail ? event.detail.fieldName : '';
                const value = event.target ? event.target.value : event.detail ? event.detail.value : '';

                if (event.target.name === "Mobile__c") {
                    this.mobileNumber = value.trim();
                }


                console.log('Mobile Number:', this.mobileNumber);
                //console.log('isMobileShow:', this.isMobileShow);

                this.getSVWrapperList = {
                    ...this.svWrapper.sv,
                    [fieldName]: value
                };
                this.svWrapper = { sv: this.getSVWrapperList };
                if (this.svWrapper.sv.Walk_In_Source__c == 'Channel Partner' || this.svWrapper.sv.Walk_In_Sub_Source__c == 'Channel Partner') {
                    this.searchPlaceholder = 'Search Channel Partner';
                    this.searchPlaceholderSourcing = 'Search Sourcing Manager'
                    this.showChannelPartner = true;
                    this.showReferenceName = false;
                    this.noCPFound = true;

                } else if (this.svWrapper.sv.Walk_In_Source__c == '' || this.svWrapper.sv.Walk_In_Sub_Source__c == '') {
                    this.showChannelPartner = false;
                    this.showReferenceName = false;
                    this.noCPFound = false;
                }

                if (this.svWrapper.sv.Walk_In_Source__c == 'Reference' || this.svWrapper.sv.Walk_In_Sub_Source__c == 'Reference') {
                    this.showReferenceName = true;
                    this.showChannelPartner = false;
                    this.noCPFound = false;

                }
                if (this.svWrapper.sv.Walk_In_Source__c == 'Channel Partner' || this.svWrapper.sv.Walk_In_Sub_Source__c == 'Channel Partner') {
                    this.searchPlaceholder = 'Search Channel Partner';
                    this.searchPlaceholderSourcing = 'Search Sourcing Manager'
                    this.showChannelPartner = true;
                    this.showReferenceName = false;
                    this.noCPFound = true;

                } else if (this.svWrapper.sv.Walk_In_Source__c == '' || this.svWrapper.sv.Walk_In_Sub_Source__c == '') {
                    this.showChannelPartner = false;
                    this.showReferenceName = false;
                    this.noCPFound = false;
                }

                if (this.svWrapper.sv.Walk_In_Source__c == 'Reference' || this.svWrapper.sv.Walk_In_Sub_Source__c == 'Reference') {
                    this.showReferenceName = true;
                    this.showChannelPartner = false;
                    this.noCPFound = false;

                }
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));

            } catch (error) {
                console.log('svWrapper error' + JSON.stringify(error));
                console.error('svWrapper error' + JSON.stringify(error));
            }
        }
        console.log('svWrapper: ' + JSON.stringify(this.svWrapper));
    }

    getFetchValue() {
        console.log('getFecthvalue Inside: ');
        this.isSpinner = true;
        getSVWrapper({ projectId: this.projectId, leadId: this.leadId, oppId: this.oppId, accId: this.accId })
            .then((result) => {
                this.svWrapper = result;
                console.log('getFetchValue : ' + JSON.stringify(this.svWrapper));

                if (this.mobileNumber) {
                    this.svWrapper.sv.Mobile__c = this.mobileNumber;
                }

                if (this.svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && this.svWrapper.sv.Channel_Partner__c != null) {
                    this.showChannelPartner = true;
                    this.showReferenceName = false;
                    this.noCPFound = true;
                } else if (this.svWrapper.sv.Walk_In_Source__c == '' && this.svWrapper.sv.Walk_In_Source__c === '') {
                    this.showChannelPartner = false;
                    this.showReferenceName = false;
                    this.noCPFound = false;
                } else {
                    this.showChannelPartner = false;
                }

                if (this.svWrapper.sv.Referrer_Name__c == 'Reference' && this.svWrapper.sv.Referrer_Name__c != '') {
                    this.showReferenceName = true;
                    this.showChannelPartner = false;
                    this.noCPFound = false;
                } else {
                    this.showReferenceName = false;
                }

                if (this.svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && this.svWrapper.sv.Walk_In_Source__c != null) {
                    this.showChannelPartner = true;
                    this.noCPFound = true;
                    this.showReferenceName = false;
                } else if (this.svWrapper.sv.Walk_In_Source__c == '' && this.svWrapper.sv.Walk_In_Source__c === '') {
                    this.showChannelPartner = false;
                    this.showReferenceName = false;
                    this.noCPFound = false;
                } else {
                    this.showChannelPartner = false;
                }


                if (this.svWrapper.sv.Walk_In_Source__c == 'Reference' && this.svWrapper.sv.Walk_In_Source__c != '') {
                    this.showReferenceName = true;
                    this.showChannelPartner = false;
                    this.noCPFound = false;
                } else {
                    this.showReferenceName = false;
                }
                this.isSpinner = false;
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));
            }).catch(error => {
                console.log('svWrapper error: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }

    /***************************************
 *      For NEW CP & CP Project Logic Start
 ***************************************/

    handleAccountWrapper() {
        getChannelPartnerWrapper({})
            .then((result) => {
                this.cpWrapper = result;
                console.log('data: ' + JSON.stringify(this.cpWrapper));
            })
            .catch((error) => {
                this.error = error;
                this.cpWrapper = undefined;
            });

    }

    handleChannelPartnerInfo(event) {
        const fieldName = event.target ? event.target.fieldName : event.detail ? event.detail.fieldName : '';
        console.log('fieldName: ' + fieldName);
        const value = event.target.value;
        console.log('value: ' + value);
        this.getAccountWrapperList = {
            ...this.cpWrapper.cp,
            [fieldName]: value
        };
        this.cpWrapper = { cp: this.getAccountWrapperList };
        console.log('cpWrapper: ' + JSON.stringify(this.cpWrapper));

    }

    handleNewChannelPartner() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    handlecreateChannelPartner() {
        if (this.cpWrapper.cp.Name == null || this.cpWrapper.cp.Name.trim() === '') {
            alert('Please enter CP Name');
        } else if (this.cpWrapper.cp.CP_Firm_Type__c == null || this.cpWrapper.cp.CP_Firm_Type__c.trim() === '') {
            alert('Please Enter Firm Type');
        } else if (this.cpWrapper.cp.Mobile__c == null || this.cpWrapper.cp.Mobile__c.trim() === '') {
            alert('Please Enter Mobile Number');
        } else if (!/^\d{10}$/.test(this.cpWrapper.cp.Mobile__c.trim())) {
            alert('Please enter a valid 10-digit Mobile Number');
        } /*else if (this.cpWrapper.cp.PAN_No__c == null || this.cpWrapper.cp.PAN_No__c.trim() === '') {
            alert('Please Enter PAN Number');
        }*/ else if (!/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/.test(this.cpWrapper.cp.PAN_No__c.trim())) {
            alert('Please enter a valid PAN Number (Format: ABCDE1234F)');
        } else {

            this.isSpinner = true;
            console.log('cpWrapper: ' + JSON.stringify(this.cpWrapper));
            createChannelPartner({ cpWrapper: this.cpWrapper, projectId: this.projectId })
                .then((result) => {
                    console.log('result: ' + JSON.stringify(result));
                    if (result != null) {
                        this.newCPresult = result;
                        console.log('data: ' + JSON.stringify(this.newCPresult));
                        if (this.newCPresult) {
                            if (this.newCPresult.Id) {
                                this.svWrapper.sv.CP_Project__c = this.newCPresult.Id;
                                console.log('newAccountId: ' + JSON.stringify(this.svWrapper.sv.CP_Project__c));
                            }
                            if (this.newCPresult.Channel_Partner__c) {
                                this.svWrapper.sv.Channel_Partner__c = this.newCPresult.Channel_Partner__r.Id;
                                console.log('this.svWrapper.sv.Channel_Partner__c: ' + JSON.stringify(this.svWrapper.sv.Channel_Partner__c));
                            }
                            if (this.newCPresult.Channel_Partner__r && this.newCPresult.Channel_Partner__r.Name) {
                                this.searchName = this.newCPresult.Channel_Partner__r.Name;
                                console.log('this.searchName: ' + JSON.stringify(this.searchName));
                            }
                            if (this.newCPresult.Owner && this.newCPresult.Owner.FirstName && this.newCPresult.Owner.LastName && this.newCPresult.OwnerId) {
                                this.svWrapper.sv.Sourcing_Manager__c = this.newCPresult.OwnerId;
                                this.searchNameSourcing = `${this.newCPresult.Owner.FirstName} ${this.newCPresult.Owner.LastName}`;
                                console.log('searchNameSourcing: ' + JSON.stringify(this.searchNameSourcing));
                            }
                            this.isNewCPCreated = true;
                            this.svWrapper.sv.Is_New_CP_Created__c = true;
                        }
                    } else {
                        alert('Something went wrong Please Contact System Administrator');
                        this.isSpinner = false;
                        this.isShowModal = false;
                        this.isNewCPCreated = false;
                    }
                    this.isSpinner = false;
                    this.isShowModal = false;
                })
                .catch((error) => {
                    alert('Something went wrong Please Contact System Administrator');
                    this.error = error;
                    this.newCPresult = undefined;
                    this.isSpinner = false;
                    this.isShowModal = false;
                    this.isNewCPCreated = false;
                });
        }
    }
    /***************************************
*      For NEW CP & CP Project Logic End
***************************************/

    handleReset() {
        this.isSpinner = true;
        location.reload(true);
        this.isSpinner = false;
    }

    handleContinue() {
        this.isSpinner = true;
        this.showSecondPage = true;
        this.showFirstPage = false;
        this.showNumber = true;
        this.isSpinner = false;
    }


    handleSecondPage() {
        if (this.svWrapper.sv.Salutation__c == "" || this.svWrapper.sv.Salutation__c == null || this.svWrapper.sv.Salutation__c == undefined) {
            this.showValidation = 'Please enter Salutation';
            this.showValidationPopup = true;
            // alert('Please enter Salutation ');
            return;

        } else if (this.svWrapper.sv.First_Name__c == undefined || this.svWrapper.sv.First_Name__c == "" || this.svWrapper.sv.First_Name__c == null) {
            this.showValidation = 'Please enter First Name';
            this.showValidationPopup = true;
            //alert('Please enter First Name ');
            return;

        } else if (this.svWrapper.sv.Last_Name__c == "" || this.svWrapper.sv.Last_Name__c == undefined || this.svWrapper.sv.Last_Name__c == null) {
            this.showValidation = 'Please enter Last Name';
            this.showValidationPopup = true;
            //alert('Please enter Last Name ');
            return;

        } else {
            this.showValidation = '';
            this.showValidationPopup = false;
            this.isSpinner = true;
            this.showthirdPage = true;
            this.showSecondPage = false;
            this.isSpinner = false;
        }
    }

    handleSecondPagePrevious() {
        this.isSpinner = true;
        this.showSecondPage = false;
        this.showFirstPage = true;
        this.isSpinner = false;
    }

    handleThirdPage() {
        // Validate each field
        // if (this.svWrapper.sv.Flat_No__c == '' || this.svWrapper.sv.Flat_No__c == null || this.svWrapper.sv.Flat_No__c == undefined) {
        //     this.showValidation = 'Please enter Flat No. ';
        //     this.showValidationPopup = true;
        // }
        // else if (this.svWrapper.sv.Locality__c == '' || this.svWrapper.sv.Locality__c == null || this.svWrapper.sv.Locality__c == undefined) {
        //     this.showValidation = 'Please enter Street';
        //     this.showValidationPopup = true;
        // }
        // else if (this.svWrapper.sv.City__c == '' || this.svWrapper.sv.City__c == null || this.svWrapper.sv.City__c == undefined) {
        //     this.showValidation = 'Please enter City';
        //     this.showValidationPopup = true;
        // }
        // else if (this.svWrapper.sv.Country__c == '' || this.svWrapper.sv.Country__c == null || this.svWrapper.sv.Country__c == undefined) {
        //     this.showValidation = 'Please enter Country';
        //     this.showValidationPopup = true;
        // }
        // else if (this.svWrapper.sv.State__c == '' || this.svWrapper.sv.State__c == null || this.svWrapper.sv.State__c == undefined) {
        //     this.showValidation = 'Please enter State';
        //     this.showValidationPopup = true;
        // }
        // else if (this.svWrapper.sv.Pincode__c == '' || this.svWrapper.sv.Pincode__c == null || this.svWrapper.sv.Pincode__c == undefined) {
        //     this.showValidation = 'Please enter Postal/Pin Code';
        //     this.showValidationPopup = true;
        // } else{
        this.isSpinner = true;
        this.showFourthPage = true;
        this.showthirdPage = false;
        this.isSpinner = false;
        this.showValidation = '';
        this.showValidationPopup = false;
        this.showOfficeSection = false;
        // }

    }

    handlethirdPagePrevious() {
        this.showSecondPage = true;
        this.showthirdPage = false;
    }

    handleshowFourthPage() {
        if (this.svWrapper.sv.Walk_In_Source__c == "" || this.svWrapper.sv.Walk_In_Source__c == null || this.svWrapper.sv.Walk_In_Source__c == undefined) {
            this.showValidation = 'Please enter WalkIn Source';
            this.showValidationPopup = true;

            //alert('Please enter Walk In Source ');
            return;
        } else if (this.svWrapper.sv.Walk_In_Sub_Source__c == "" || this.svWrapper.sv.Walk_In_Sub_Source__c == null || this.svWrapper.sv.Walk_In_Sub_Source__c == undefined) {
            this.showValidation = 'Please enter WalkIn Sub Source';
            this.showValidationPopup = true;
            // alert('Please enter Walk In Sub Source ');
            return;
        } else if (this.svWrapper.sv.Walk_In_Source__c == "Channel Partner" && (this.svWrapper.sv.Channel_Partner__c == undefined || this.svWrapper.sv.Channel_Partner__c == "")) {
            //alert('Please Select Channel Partner ');
            this.showValidation = 'Please Select Channel Partner';
            this.showValidationPopup = true;
            return;
        } else if (this.svWrapper.sv.Walk_In_Source__c == "Channel Partner" && (this.svWrapper.sv.Sourcing_Manager__c == undefined || this.svWrapper.sv.Sourcing_Manager__c == "")) {
            this.showValidation = 'Please Select Sourcing Manager';
            this.showValidationPopup = true;
            //alert('Please Select Sourcing Manager ');
            return;
        } else if (this.svWrapper.sv.Clash__c == true && (this.svWrapper.sv.Clash_Details__c == undefined || this.svWrapper.sv.Clash_Details__c == "")) {
            this.showValidation = 'Please enter Clash Details';
            this.showValidationPopup = true;
            //alert('Please enter Clash Details ');
            return;
        }
        else if (this.svWrapper.sv.Walk_In_Source__c == "Reference" && (this.svWrapper.sv.Referrer_Name__c == undefined || this.svWrapper.sv.Referrer_Name__c == "")) {
            this.showValidation = 'Please enter Reference Name';
            this.showValidationPopup = true;
            //alert('Please enter Reference Name ');
            return;
        } else {
            this.showValidation = '';
            this.showValidationPopup = false;
            this.isSpinner = true;
            this.showFifthpage = true;
            this.showFourthPage = false;
            this.isSpinner = false;

        }
    }

    handlefourthPagePrevious() {
        this.showthirdPage = true;
        this.showFourthPage = false;
        this.showOfficeSection = true;
    }

    handlefifthpage() {
        if (this.svWrapper.sv.Configuration_Required__c == "" || this.svWrapper.sv.Configuration_Required__c == null || this.svWrapper.sv.Configuration_Required__c == undefined) {
            this.showValidation = 'Please select Configuration you are interested in';
            this.showValidationPopup = true;
            //alert('Please select Configuration you are interested in ');
            return;
        } else if (this.svWrapper.sv.Budget__c == "" || this.svWrapper.sv.Budget__c == null || this.svWrapper.sv.Budget__c == undefined) {
            this.showValidation = 'Please select Price Range ';
            this.showValidationPopup = true;
            //alert('Please select Price Range ');
            return;
        } else if (this.svWrapper.sv.Buying_Purpose__c == "" || this.svWrapper.sv.Buying_Purpose__c == null || this.svWrapper.sv.Buying_Purpose__c == undefined) {
            this.showValidation = 'Please select Purpose of Buying ';
            this.showValidationPopup = true;
            //alert('Please select Purpose of Buying ');
            return;
        } else if (this.svWrapper.sv.Possession_Timeframe_Required__c == "" || this.svWrapper.sv.Possession_Timeframe_Required__c == null || this.svWrapper.sv.Possession_Timeframe_Required__c == undefined) {
            this.showValidation = 'Please enter Possession Timeline ';
            this.showValidationPopup = true;
            //alert('Please enter Possession Timeline ');
            return;
        } else if (this.svWrapper.sv.Current_Residence_Status__c == "" || this.svWrapper.sv.Current_Residence_Status__c == null || this.svWrapper.sv.Current_Residence_Status__c == undefined) {
            this.showValidation = 'Please select Current Residence Status ';
            this.showValidationPopup = true;
        }

        else {
            this.showsixPage = true;
            this.showFifthpage = false;
            this.showValidation = '';
            this.showValidationPopup = false;
        }
    }

    handlefifthPrevious() {
        this.showFifthpage = false;
        this.showFourthPage = true;
    }

    handlesixprevious() {
        this.showsixPage = false;
        this.showFifthpage = true;
    }

    // Edited by Priyanshu Agarkar
    handlesix() {
        // Check if Company Name is empty or null or undefined
        if (this.svWrapper.sv.Company_Name__c === "" || this.svWrapper.sv.Company_Name__c === null || this.svWrapper.sv.Company_Name__c === undefined) {
            this.showValidation = 'Please enter Company Name';
            this.showValidationPopup = true;
            return;
        }
        // Check if Occupation is empty or null or undefined
        else if (this.svWrapper.sv.Occupation__c === "" || this.svWrapper.sv.Occupation__c === null || this.svWrapper.sv.Occupation__c === undefined) {
            this.showValidation = 'Please select Occupation';
            this.showValidationPopup = true;
            return;
        }

        try {
            this.showValidation = '';
            this.showValidationPopup = false;
            this.isSpinner = true;
            this.showsixPage = false;
            this.showFinalScreen = true;

            console.log('Inside Save: ' + JSON.stringify(this.svWrapper));

            // Submit data
            submit({
                projectId: this.projectId,
                leadId: this.leadId,
                oppId: this.oppId,
                accId: this.accId,
                svWrapper: this.svWrapper,
                changeStatus: this.changeStatus,
                regCode: this.regCode,
                isSourceChanged: this.isSourceNotEditable
            })
                .then((result) => {
                    console.log('result: ' + JSON.stringify(result));
                    this.svId = result[0];

                    if (this.svId != '') { // Fetch site name based on svId
                        getSiteName({ svId: this.svId })
                            .then(data => {
                                this.isSpinner = false;
                                this.svName = data;
                                console.log('svName: ' + JSON.stringify(this.svName));
                            })
                            .catch(error => {
                                console.log('Error in getSiteName:', error);
                                // Modified by Priyanshu Agarkar
                                this.displayError(error);
                                // Modified by Priyanshu Agarkar
                            });
                    } else {
                        console.log('Site Visit number generation failed.');
                        // Modified by Priyanshu Agarkar
                        this.displayError(error);
                        // Modified by Priyanshu Agarkar
                    }
                })
                .catch(error => {
                    console.log('Error in submit:', error);
                    // Modified by Priyanshu Agarkar
                    this.displayError(error);
                    // Modified by Priyanshu Agarkar
                });

        } catch (error) {
            console.log('Unexpected error:', error);
            // Modified by Priyanshu Agarkar
            this.displayError(error);
            // Modified by Priyanshu Agarkar
        }
    }
    // Edited by Priyanshu Agarkar

    handleCloseErrorPopup() {
        this.showErrorPopup = false;
        this.errorMessage = '';
    }

    displayError(error) {
        // Show the error message on the final page
        this.isSpinner = false;
        this.showValidation = error.body ? error.body.message : error;
        this.showValidationPopup = true;
    }

    // Edited by Priyanshu Agarkar

    handleviewRecord() {
        location.replace('/' + this.svId);
        //     this[NavigationMixin.Navigate]({
        //         type: 'standard__recordPage',
        //         attributes: {
        //             recordId: this.svId,
        //             actionName: 'view'
        //         }
        //     });
    }

    handleNext() {
        // Validate each field
        if (this.svWrapper.sv.Flat_No__c == '' || this.svWrapper.sv.Flat_No__c == null || this.svWrapper.sv.Flat_No__c == undefined) {
            this.showValidation = 'Please enter Flat No. ';
            this.showValidationPopup = true;
        }
        else if (this.svWrapper.sv.Locality__c == '' || this.svWrapper.sv.Locality__c == null || this.svWrapper.sv.Locality__c == undefined) {
            this.showValidation = 'Please enter Street';
            this.showValidationPopup = true;
        }
        else if (this.svWrapper.sv.City__c == '' || this.svWrapper.sv.City__c == null || this.svWrapper.sv.City__c == undefined) {
            this.showValidation = 'Please enter City';
            this.showValidationPopup = true;
        }
        else if (this.svWrapper.sv.Country__c == '' || this.svWrapper.sv.Country__c == null || this.svWrapper.sv.Country__c == undefined) {
            this.showValidation = 'Please enter Country';
            this.showValidationPopup = true;
        }
        else if (this.svWrapper.sv.State__c == '' || this.svWrapper.sv.State__c == null || this.svWrapper.sv.State__c == undefined) {
            this.showValidation = 'Please enter State';
            this.showValidationPopup = true;
        }
        else if (this.svWrapper.sv.Pincode__c == '' || this.svWrapper.sv.Pincode__c == null || this.svWrapper.sv.Pincode__c == undefined) {
            this.showValidation = 'Please enter Postal/Pin Code';
            this.showValidationPopup = true;
        } else {
            this.isSpinner = true;
            this.showFourthPage = false;
            this.showthirdPage = true;
            this.isSpinner = false;
            this.showValidation = '';
            this.showValidationPopup = false;
            this.showResidentSection = false;
            this.showOfficeSection = true;
        }

    }

    handlePrevious() {
        this.showResidentSection = true;
        this.showOfficeSection = false;
    }

}