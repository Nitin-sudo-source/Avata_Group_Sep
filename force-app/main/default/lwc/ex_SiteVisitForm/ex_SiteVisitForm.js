import { LightningElement, track, api, wire } from 'lwc';
import selectProject from '@salesforce/apex/Ex_SiteVisitForm.selectProject';
import projectImage from '@salesforce/apex/Ex_SiteVisitForm.projectImage';
import getSVWrapper from '@salesforce/apex/Ex_SiteVisitForm.getSVWrapper';
import getSalutation from '@salesforce/apex/Ex_SiteVisitForm.getSalutation'; //searchForData
import { NavigationMixin } from 'lightning/navigation';
import search from '@salesforce/apex/Ex_SiteVisitForm.search'; //searchForData
import submit from '@salesforce/apex/Ex_SiteVisitForm.submit';
import checkCPData from '@salesforce/apex/Ex_SiteVisitForm.checkCPData';



export default class Ex_SiteVisitForm extends NavigationMixin(LightningElement) {
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }



    @track vprData = [];
    @api project;
    @track isQrcustomer = false;
    @track projectId = '';
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
    @track showFourthPage = false;
    @track showFifthPage = false;
    @track showFinalScreen = false;
    @track Salutation = '';
    @track leadId = null;
    @track oppId = null;
    @track accId = null;
    @track storeMobile = '';
    @track storeEmail = '';
    @track registration = '';
    @track disableReg = false;
    @track showCode = false;
    @track showNumber = false;
    @track regCode = '';
    @track showLeadVprData = false;
    @track showVprData = false;
    @track showVprDataArray = [];
    @track showVerify = false;
    @track changeStatus = false;
    @track disabledregcode = false;
    @track showValidation = '';
    @track showValidationPopup = false;
    @track cpLeadId = '';


    @track showAccountDataFound = false;
    @track showLeadDataFound = false;
    @track showOpportunityDataFound = false;
    @track accountFetch = [];
    @track leadFetch = [];
    @track opportunityFetch = [];
    @api accountDataFound = [];
    @api leadDataFound = [];
    @api opportunityDataFound = [];
    @track getFinalResult = [];
    @track vpId = '';

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

    @wire(selectProject) retrieveProject({ data, error }) {
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


    handleRegCode(evt) {
        this.regCode = evt.target.value;
        console.log('regCode: ' + (this.regCode));
    }




    connectedCallback() {
        console.log('project: ' + this.project);
        if (this.project != undefined) {
            this.projectId = this.project;
            this.disabledProject = true;
            this.getProjectImage();
            this.isQrcustomer = true;
        }
        this.showFirstPage = true;
        this.getSVWrapper();
        this.getSalutation();

    }


    getSalutation() {
        getSalutation({})
            .then((result) => {
                this.Salutation = result.map(picklistValue => ({ label: picklistValue, value: picklistValue }));
                //console.log('Salutation ' + JSON.stringify(this.Salutation));
            }).catch(error => {
                console.log('Salutation error ' + JSON.stringify(error));

            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }


    getSVWrapper() {
        console.log('cpLeadId: ' + this.cpLeadId);
        this.isSpinner = true;
        getSVWrapper({ projectId: this.projectId, leadId: this.leadId, oppId: this.oppId, accId: this.accId, cpLeadId: this.cpLeadId })
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
                console.log('projectImage_result::::' + JSON.stringify(result));
                this.showProjectImage = result.Project_Image__c;
                console.log('showProjectImage: ' + JSON.stringify(this.showProjectImage));
            }).catch(error => {
                //this.error = error;
                console.log('error showProjectImage: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }

    handlemobile(event) {
        this.storeMobile = event.target.value;
        if (this.storeMobile != '') {
            this.svWrapper.sv.Mobile__c = this.storeMobile;
        }
    }

    handleEmail(event) {
        this.storeEmail = event.target.value;
        if (this.storeEmail != '') {
            this.svWrapper.sv.Email__c = this.storeEmail;
        }
    }

    handleChange(event) {
        if (event.target.name == "Address") {
            this.svWrapper.sv.City__c = event.target.city;
            this.svWrapper.sv.Street_1__c = event.target.street;
            this.svWrapper.sv.Country__c = event.target.country;
            this.svWrapper.sv.State__c = event.target.province;
            this.svWrapper.sv.Pincode__c = event.target.postalCode;
        } else {

            try {
                const fieldName = event.target ? event.target.fieldName : event.detail ? event.detail.fieldName : '';
                const value = event.target ? event.target.value : event.detail ? event.detail.value : '';
                // if (fieldName == 'Lead_Source__c' && value == 'Channel Partner') {
                //     this.searchPlaceholder = 'Search Channel Partner';
                //     this.showChannelPartner = true;
                //     this.showReferenceName = false;

                // } else if (fieldName == 'Lead_Source__c' && value == 'Reference') {
                //     this.showReferenceName = true;
                //     this.showChannelPartner = false;
                //     this.getSVWrapperList = {
                //         ...this.svWrapper.sv,
                //         [fieldName]: value
                //     };
                // } else {
                //     this.showChannelPartner = false;
                //     this.showReferenceName = false;
                // }
                this.getSVWrapperList = {
                    ...this.svWrapper.sv,
                    [fieldName]: value
                };
                this.svWrapper = { sv: this.getSVWrapperList };
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));


            } catch (error) {
                console.log('svWrapper error' + JSON.stringify(error));
                console.error('svWrapper error' + JSON.stringify(error));
            }
        }
        console.log('svWrapper: ' + JSON.stringify(this.svWrapper));

    }

    handleSearch() {
        //alert('Inside Handle Search');
        const numericRegex = /^[0-9]{10}$/;
        if (this.projectId === undefined || this.projectId === '') {
            this.showValidation = 'Please Enter Project';
            this.showValidationPopup = true;
        } else if (this.registration === '') {
            this.showValidation = 'Please Select Pre Registration';
            this.showValidationPopup = true;
            return;
        } else if (this.registration === 'Yes' && this.regCode === '') {
            this.showValidation = 'Please enter a Pre-registration Code';
            this.showValidationPopup = true;
            return;
        } else if (this.registration === 'No' && !numericRegex.test(this.svWrapper.sv.Mobile__c)) {
            this.showValidation = 'Please enter a valid mobile number with exactly 10 digits.';
            this.showValidationPopup = true;
            return;
        } else if (this.registration === 'No' && (this.svWrapper.sv.Mobile__c === undefined || this.svWrapper.sv.Mobile__c === '')) {
            this.showValidation = 'Please Enter Mobile';
            this.showValidationPopup = true;
            return;
        } else if (this.registration === 'No' && this.svWrapper.sv.Mobile__c.length < 10) {
            this.showValidation = 'Please Enter Valid Mobile Number';
            this.showValidationPopup = true;
            return;
        } else if (this.registration === 'No' && !numericRegex.test(this.svWrapper.sv.Mobile__c)) {
            this.showValidation = 'Please enter a valid mobile number with exactly 10 digits.';
            this.showValidationPopup = true;
            return;
        } else {
            this.isSpinner = true;
            this.disabledProject = true;
            this.disabledMobile = true;
            this.disabledEmail = true;
            this.createNewData = true;
            this.hideSearch = true;
            this.showVerify = false;
            this.showValidation = '';
            this.showValidationPopup = false;
            // alert('Success');
            search({ num: this.svWrapper.sv.Mobile__c, email: this.svWrapper.sv.Email__c, projectId: this.projectId })
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
                                this.accountDataFound = this.accountFetch[0];
                                this.accId = this.accountDataFound[0].Id;
                                console.log('accId ' + JSON.stringify(this.accId));
                                //this.getSVWrapper();
                            }
                            if (element.key.includes('Lead')) {
                                this.showLeadDataFound = true;
                                this.leadFetch.push(element.value);
                                this.leadDataFound = this.leadFetch[0];
                                this.leadId = this.leadDataFound[0].Id;
                                //this.getSVWrapper();

                                // console.log('Lead Found : ' + JSON.stringify(this.leadDataFound));
                                // console.log('FirstName : ' + JSON.stringify(this.leadDataFound[0].First_Name__c));
                                // console.log('LastName : ' + JSON.stringify(this.leadDataFound[0].Last_Name__c));
                                // console.log('Lead Data: ' + JSON.stringify(this.leadDataFound));
                                // if (this.leadDataFound.length > 0 && this.leadDataFound[0].Last_Presales_Call_Date__c != null) {
                                //     const lastcallDate = new Date(this.leadDataFound[0].Last_Presales_Call_Date__c);
                                //     const today = new Date();
                                //     const timeDifference = today.getTime() - lastcallDate.getTime();
                                //     const dayDifference = Math.round(timeDifference / (1000 * 3600 * 24)); // Round to the nearest integer
                                //     console.log('dayDifference ' + dayDifference);
                                //     this.leadDataFound.forEach(lead => {
                                //         lead.noOfDaysFromLastCall = dayDifference;
                                //         console.log('on Lead Check : ' + lead.noOfDaysFromLastCall);
                                //     });
                                // }

                                // if (this.leadDataFound != null) {
                                //     this.leadDataFound.forEach(lead => {
                                //         lead.presalesManager = lead.Owner.FirstName + ' ' + lead.Owner.LastName;
                                //         console.log('presalesManager: ' + presalesManager);
                                //     });
                                // }

                                // if (this.leadDataFound != null && this.leadDataFound[0].Channel_Partner__r.Name != null) {
                                //     this.searchName = this.leadDataFound[0].Channel_Partner__r.Name;
                                //     this.searchPlaceholder = '';
                                //     this.showChannelPartner = true;
                                // }
                            }
                            if (element.key.includes('Opportunity')) {
                                this.showOpportunityDataFound = true;
                                this.opportunityFetch.push(element.value);
                                this.opportunityDataFound = this.opportunityFetch[0];
                                this.oppId = this.opportunityDataFound[0].Id;
                                console.log('oppId: ' + this.oppId);
                                //this.getSVWrapper();
                                // console.log('FirstName: ' + JSON.stringify(this.opportunityDataFound[0].Owner.FirstName));
                                // console.log('LastName: ' + JSON.stringify(this.opportunityDataFound[0].Owner.LastName))
                                // console.log('calling oppFetchvalue: ' + this.opportunityDataFound.length);
                            }
                            this.getSVWrapper();
                            if (this.isQrcustomer) {
                                this.handleContinue();
                            }
                        })
                    } else {
                        this.nodataFound = true;
                        if (this.isQrcustomer) {
                            this.handleContinue();
                        }
                    }
                }).catch(error => {
                    console.log('Search Data ' + JSON.stringify(error));
                }).catch(error => {
                    console.error('An unexpected error occurred:', error);
                });



        }
    }

    handleclosepopup() {
        this.showValidationPopup = false;
    }

    handleReset() {
        location.reload();
    }

    handleVerifyCode() {
        if (this.projectId === '') {
            this.showValidation = 'Please Select Project First';
            this.showValidationPopup = true;
        } else if (this.registration === 'Yes' && this.regCode === '') {
            this.showValidation = 'Please enter a Pre-registration Code';
            this.showValidationPopup = true;
            return;
        } else {
            //alert('found');
            this.showValidationPopup = false;
            this.isSpinner = true;
            checkCPData({ code: this.regCode, Proj: this.projectId })
                .then(data => {
                    console.log('data: ' + JSON.stringify(data));
                    this.showVprData = true;
                    this.showVprDataArray = data;

                    if (data != null) {
                        alert('Code verified Successfully');
                        this.isSpinner = false;
                        this.changeStatus = true;
                        this.createNewData = true;
                        this.disabledregcode = true;
                        this.disabledProject = true;
                        if (this.showVprDataArray.Id) {
                            this.vpId = this.showVprDataArray.Id;
                        }
                        if (this.showVprDataArray.Configuration__c) {
                            this.svWrapper.sv.Configuration_Required__c = this.showVprDataArray.Configuration__c;
                        }
                        if (this.showVprDataArray.Budget_Range__c) {
                            this.svWrapper.sv.Budget_Range__c = this.showVprDataArray.Budget_Range__c;
                        }
                        if (this.showVprDataArray.Customer_Name__c) {
                            this.svWrapper.sv.First_Name__c = this.showVprDataArray.Customer_Name__c;
                        }
                        if (this.showVprDataArray.Project__c) {
                            this.projectId = this.showVprDataArray.Project__c;
                            this.svWrapper.sv.Project__c = this.showVprDataArray.Project__c;
                        }
                        if (this.showVprDataArray.Mobile_Number__c) {
                            this.svWrapper.sv.Mobile__c = this.showVprDataArray.Mobile_Number__c;
                            this.storeMobile = this.showVprDataArray.Mobile_Number__c;
                        }
                        if (this.showVprDataArray.Lead__c) {
                            this.leadId = this.showVprDataArray.Lead__c;
                            this.getSVWrapper();
                        }
                        if (this.showVprDataArray.CP_Lead__c) {
                            this.cpLeadId = this.showVprDataArray.CP_Lead__c;
                            this.getSVWrapper();
                        }
                    } else {
                        alert('Invalid Code or code has been Expired');

                    }
                }).catch(error => {
                    this.isSpinner = false;
                    //alert('Invalid Code or code has been Expired');
                    if (error.status === 500) {
                        alert('Error: Invalid Code or code has been Expired');
                    }
                    console.log('vpr error ' + JSON.stringify(error));
                    return;

                })

        }
    }

    handleContinue() {
        this.showSecondPage = true;
        this.showFirstPage = false;
        this.showNumber = true;
        this.disabledMobile = true;
    }

    handlesecondPagePrevious() {
        this.showSecondPage = false;
        this.showFirstPage = true;

    }

    handlesecondPageNext() {

        if (this.svWrapper.sv.First_Name__c === undefined || this.svWrapper.sv.First_Name__c === '') {
            this.showValidation = 'Please enter a First Name';
            this.showValidationPopup = true;
            return;
        } else if (this.svWrapper.sv.Last_Name__c === undefined || this.svWrapper.sv.Last_Name__c === '') {
            this.showValidation = 'Please enter a Last Name';
            this.showValidationPopup = true;
            return;
            // } else if (this.svWrapper.sv.Email__c === undefined || this.svWrapper.sv.Email__c === '') {
            //     this.showValidation = 'Please enter a Email';
            //     this.showValidationPopup = true;
            //     return;
        } else if (this.svWrapper.sv.Age_Group__c === undefined || this.svWrapper.sv.Age_Group__c === '') {
            this.showValidation = 'Please enter Age Group';
            this.showValidationPopup = true;
            return;
        } else {
            this.showValidationPopup = false;
            this.showSecondPage = false;
            this.showthirdPage = true;
        }


    }

    handlethirdPagePrevious() {
        this.showSecondPage = true;
        this.showthirdPage = false;

    }

    validatePincode(pincode) {
        const pincodeRegex = /^\d{6}$/;
        return pincodeRegex.test(pincode);
    }

    handlethirdPageNext() {

        if (this.svWrapper.sv.Locality__c === undefined || this.svWrapper.sv.Locality__c === '') {
            this.showValidation = 'Please enter Locality';
            this.showValidationPopup = true;
        } else if (this.svWrapper.sv.City__c === undefined || this.svWrapper.sv.City__c === '') {
            this.showValidation = 'Please enter a City';
            this.showValidationPopup = true;
        } else if (this.svWrapper.sv.State__c === undefined || this.svWrapper.sv.State__c === '') {
            this.showValidation = 'Please enter a State';
            this.showValidationPopup = true;
        } else if (this.svWrapper.sv.Pincode__c === undefined || this.svWrapper.sv.Pincode__c === '') {
            this.showValidation = 'Please enter Pincode';
            this.showValidationPopup = true;
        } else if(!this.validatePincode(this.svWrapper.sv.Pincode__c)) {
            this.showValidation = 'Please enter 6 Digit Valid Pincode';
            this.showValidationPopup = true;
        }
        else {
            this.showValidationPopup = false;
            this.showthirdPage = false;
            this.showFourthPage = true;
        }
    }

    handleFourthPagePrevious() {
        this.showFourthPage = false;
        this.showthirdPage = true;
    }

    handleFourthPageNext() {

        if (this.svWrapper.sv.Employment_Type__c === undefined || this.svWrapper.sv.Employment_Type__c === '') {
            this.showValidation = 'Please enter Employment Type';
            this.showValidationPopup = true;
            return;
        } else if (this.svWrapper.sv.Office_Pincode__c === undefined || this.svWrapper.sv.Office_Pincode__c === '') {
            this.showValidation = 'Please enter a Office Pincode';
            this.showValidationPopup = true;
            return;
        } else if(!this.validatePincode(this.svWrapper.sv.Office_Pincode__c)) {
            this.showValidation = 'Please enter 6 Digit Valid Office Pincode';
            this.showValidationPopup = true;
        }
        else {
            this.showValidationPopup = false;
            this.showFourthPage = false;
            this.showFifthPage = true;
        }

    }

    handlefifthpagePrevious() {
        this.showFifthPage = false;
        this.showFourthPage = true;

    }




    handlesubmit() {
        this.svWrapper.sv.Mobile__c = this.storeMobile;
        this.svWrapper.sv.Email__c = this.storeEmail;
        if (this.svWrapper.sv.Configuration_Required__c === undefined || this.svWrapper.sv.Configuration_Required__c === '') {
            this.showValidation = 'Please enter Configuration';
            this.showValidationPopup = true;
        } else if (this.svWrapper.sv.Budget_Range__c === undefined || this.svWrapper.sv.Budget_Range__c === '') {
            this.showValidation = 'Please enter a Budget';
            this.showValidationPopup = true;
        } else if (this.svWrapper.sv.Area_Sq_Ft__c === undefined || this.svWrapper.sv.Area_Sq_Ft__c === '') {
            this.showValidation = 'Please enter a Area Sq Ft';
            this.showValidationPopup = true;
        } else if (this.svWrapper.sv.Buying_Purpose__c === undefined || this.svWrapper.sv.Buying_Purpose__c === '') {
            this.showValidation = 'Please enter Buying Purpose';
            this.showValidationPopup = true;
        } else {
            this.showValidationPopup = false;
            this.isSpinner = true;
            console.log('storeMobile: ' + this.storeMobile);
            console.log('this.svWrapper.sv.Mobile__c: ' + this.svWrapper.sv.Mobile__c);
            this.showFifthPage = false;
            this.showFinalScreen = true;
            //alert('insidesave');
            submit({ SVWrapper: this.svWrapper, projectId: this.projectId, isQRUser: this.isQrcustomer, changeStatus: this.changeStatus, vpId: this.vpId }) //, showVprDataArray: this.showVprDataArray
                .then(result => {
                    console.log('result: ' + JSON.stringify(result));
                    for (var key in result) {
                        this.getFinalResult.push({ key: key, value: result[key] });
                        console.log('key', key, result[key]);
                    }
                    this.isSpinner = false;
                })
                .catch(error => {
                    console.log('error: ' + JSON.stringify(error));
                    alert('Something went wrong please contact System Administrator');
                });

        }
    }

    ClickHere(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                actionName: "view",
                recordId: event.target.value,
                objectApiName: "Site_Visit__c"
            }
        });
    }

    // navigateToRecord(recordId) {
    //     const baseUrl = window.location.origin;
    //     const recordPageUrl = `${baseUrl}/s/detail/${recordId}`;
    //     window.location.href = recordPageUrl;
    // }



}