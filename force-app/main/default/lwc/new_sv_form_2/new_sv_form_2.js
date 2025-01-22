import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import selectProject from '@salesforce/apex/Ex_SiteVisitForm.selectProject';
import searchForData from '@salesforce/apex/Ex_SiteVisitForm.searchForData';
//import submit from '@salesforce/apex/Ex_SiteVisitForm.submit';
import projectImage from '@salesforce/apex/Ex_SiteVisitForm.projectImage';
import getConfigPicklistValues from '@salesforce/apex/Ex_SiteVisitForm.getConfigPicklistValues';
/*import getBuyPurposePicklistValues from '@salesforce/apex/Ex_SiteVisitForm.getBuyPurposePicklistValues';
import getPossTimeframePicklistValues from '@salesforce/apex/Ex_SiteVisitForm.getPossTimeframePicklistValues';*/
import getChannelPartners from '@salesforce/apex/Ex_SiteVisitForm.getChannelPartners';
import getCPProjectOwner from '@salesforce/apex/Ex_SiteVisitForm.getCPProjectOwner';
import checkCPData from '@salesforce/apex/Ex_SiteVisitForm.checkCPData';
import submits from '@salesforce/apex/Ex_SiteVisitForm.submits';
import getSiteName from '@salesforce/apex/Ex_SiteVisitForm.getSiteName'; //createSMS
import createSMS from '@salesforce/apex/Ex_SiteVisitForm.createSMS';
import { NavigationMixin } from 'lightning/navigation';

/*const columns = [
    {
        label: 'Name', fieldName: 'recordLink', type: 'url',
        typeAttributes: {label: { fieldName: 'Name' },  
        target: '_blank'},
        sortable: true 
    },
    //{ label: 'Account Phone', fieldName: 'Mobile__c'},
    { label: 'Phone', fieldName: 'Phone'},
    { label: 'Email', fieldName: 'Email__c'}
];*/
const accountColumns = [
    /*{
        label: 'Name', fieldName: 'recordLink', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' },
        target: '_blank' },
        sortable: true
    },*/
    { label: 'Name', fieldName: 'Name' },
    { label: 'Phone', fieldName: 'PersonMobilePhone' },
    { label: 'Email', fieldName: 'PersonEmail' }
];

const leadColumns = [
    /*{
        label: 'Name', fieldName: 'recordLink', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' },
        target: '_blank' },
        sortable: true
    },*/
    { label: 'Name', fieldName: 'Name' },
    { label: 'Mobile', fieldName: 'Mobile__c' },
    { label: 'Email', fieldName: 'Email__c' },
    { label: 'Presales Manager', fieldName: 'PresalesManager__c' },
    { label: 'Lead Created Date', fieldName: 'Created_Date__c' }
];

const opportunityColumns = [
    /*{
        label: 'Name', fieldName: 'recordLink', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' },
        target: '_blank' },
        sortable: true
    },*/
    { label: 'Name', fieldName: 'Name', initialWidth: 150 },
    { label: 'Lead Source', fieldName: 'Lead_Source__c', initialWidth: 150 },
    { label: 'SM Name', fieldName: 'SalesManager__c', initialWidth: 150 },
    { label: 'Sourcing Manager Name', fieldName: 'SourcingManager__c', initialWidth: 150 },
    { label: 'Last Date of Visit', fieldName: 'Last_SV_Date__c', type: 'date', initialWidth: 150 },
    { label: 'First date of Visit', fieldName: 'First_Site_Visit_Date__c', type: 'date', initialWidth: 150 },
    { label: 'Opportunity Stage', fieldName: 'Opportunity_Stage__c', initialWidth: 150 }
];




export default class New_sv_form_2 extends NavigationMixin(LightningElement) {

    //columns = columns;
    accountColumns = accountColumns;
    leadColumns = leadColumns;
    opportunityColumns = opportunityColumns;
    @track Projectoptions = null;
    @api mobile;
    @track email;
    @api randomNumber;
    @api project;
    @api showFirstPage = false;
    @api OTPverified = false;
    @api OTPverificationSuccess = false;
    @track EnteredOTP = '';
    @track disableSendOTP = false;
    @track disableVerifyOTP = false;
    @api showData = false;
    @track detailsFound;
    @api accDataFound;
    @api recordKey;
    leadList = [];
    @api accountDataFound = [];
    @api leadDataFound = [];
    @api opportunityDataFound = [];
    @api showAccountDataFound = false;
    @api showLeadDataFound = false;
    @api showOpportunityDataFound = false;
    @track accountId;
    @track leadId;
    @track oppoId;
    @api createNewData = false;
    @api OTPGenerated = false;
    @api regenerateOTP = false;
    @track visible = false;
    @api registration;
    @api showCode = false;
    @api showNumber = false;
    @api regCode;
    @api disableReg = false;
    @api cpData;
    @api showCpData = false;
    @api showButtons = false;
    @api hideEmailMobile = false;
    @track Manager = '';
    @api hideMedia = false;
    @api showMobile = false;
    @api hideMobile = false;
    @track changeStatus;
    /*<--------------------------------------------------------------------Second Page Variables--------------------------------------------------------->*/
    @api secondPage = false;
    @api salute = null;
    @api handleName = null;
    @api lastName = null;
    @api disableMobile = false;
    @track disableProject = false;
    @api showSendOTP = false;
    @api handleEmailforSecondPage;
    get salutation() {
        return [
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' },
            { label: 'Dr.', value: 'Dr.' },
            { label: 'Prof.', value: 'Prof.' },
        ];
    }
    /*<--------------------------------------------------------------------Second Page Variables--------------------------------------------------------->*/
    /*<--------------------------------------------------------------------Third Page Variables--------------------------------------------------------->*/
    @api thirdPage = false;
    @api localityRequired = false;
    @api cityRequired = false;
    @api countryMandatory = false;
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    /*<--------------------------------------------------------------------Third Page Variables--------------------------------------------------------->*/
    /*<--------------------------------------------------------------------Fourth Page Variables--------------------------------------------------------->*/
    @api fourthPage = false;
    @track channelPartnerArray = [];
    @api allChannelPartners;
    @track cpList = [];
    @track searchKey = '';
    @track showCPName = '';
    @track showCPLookup = false;
    @track cpProjectId = '';
    @track disabledregCode = false;
    /*<--------------------------------------------------------------------Fourth Page Variables--------------------------------------------------------->*/

    /*<--------------------------------------------------------------------Fifth Page Variables--------------------------------------------------------->*/
    @api fifthPage = false;
    @api mastersource;
    @api channelpartner;
    @api cp = false;
    @api projectimage;
    @track isLoading = false;
    @track messages;
    @track view = false;
    @track finalList = [];
    @track reff = null;
    @api acc;
    @track execute = false;
    @api errorMessages;
    @api svId;
    @api showSuccessMessage = false;
    @api showErrorMessage = false;
    @api svNaame;
    @track ownerId;
    @track source;
    @track ownerName;
    @track cpName;
    @track isSourceNotEditable = true;
    @track getLastSVsourceDate;
    @track isSourceChanged = false;
    @track tatDays;
    @track masterOTP = '';
    /*<--------------------------------------------------------------------Fifth Page Variables--------------------------------------------------------->*/


    handleRegistration(event) {
        this.registration = event.detail.value;
        if (this.registration != null) {
            this.disableReg = true;
        }
        if (this.registration == 'Yes') {
            this.showCode = true;
            this.showNumber = false;
        } else if (this.registration == 'No') {
            this.showCode = false;
            this.showNumber = true;
        }
    }


    @wire(selectProject) retrieveProject({ data }) {
        let tempArray = [];
        if (data) {
            for (let key in data) {
                tempArray.push({ label: data[key], value: key });
            }
            this.project = tempArray;
            this.showFirstPage = true;
        }
    }

    handleProjectChange(event) {
        this.Projectoptions = event.target.value;
        if (this.Projectoptions != null) {
            projectImage({ pid: this.Projectoptions })
                .then((result) => {
                    console.log('Result: '+JSON.stringify(result));
                        this.projectimage = result.Project_Logo__c;
                        this.masterOTP = result.Master_OTP__c;
                        console.log('masterOTP : ' + this.masterOTP);
                })
                .catch(error => {

                })
        }

    }

    handleRegCode(evt) {
        this.regCode = evt.target.value;
    }

    handleVerifyCode() {
        console.log('isSourceNotEditable: ' + this.isSourceNotEditable);
        console.log('regCode: ' + this.regCode);
        console.log('Proj: ' + this.Projectoptions);

        if (this.Projectoptions != null) {
            if (this.regCode) {
                checkCPData({ code: this.regCode, Proj: this.Projectoptions })
                    .then(data => {
                        this.cpData = data;
                        this.disableProject = true;
                        this.disabledregCode = true;
                        if (this.cpData.length > 0) {
                            this.changeStatus = true;
                            if (this.cpData[0].Opportunity__c != null) {
                                this.showMobile = true;
                                this.hideMedia = false;
                                this.cp = false;
                                this.media = this.cpData[0].Opportunity__r.Lead_Source__c;
                                this.accountId = this.cpData[0].Opportunity__r.Account__c;
                                this.oppoId = this.cpData[0].Opportunity__c;
                                this.mobile = this.cpData[0].Opportunity__r.Mobile__c;
                                console.log('oppoId in CP is: ' + this.oppoId);
                                console.log('accountId in CP is: ' + this.accountId);
                                if (this.media == 'Channel Partner') {
                                    this.cp = true;
                                    this.hideMedia = true;
                                    this.channelpartner = this.cpData[0].Opportunity__r.Channel_Partner__c;
                                    this.showCPName = this.cpData[0].Opportunity__r.Channel_Partner__r.Name;
                                    this.cpProjectId = this.cpData[0].Opportunity__r.CP_Project__c;
                                    this.isSourceNotEditable = false;
                                }
                                this.showCpData = true;
                                this.createNewData = true;
                                this.hideEmailMobile = true;
                               // this.hideMobile = false;
                                this.hideMedia = true;
                                //this.showMobile = false;
                                //this.hideMedia = true;
                            } else if (this.cpData[0].Lead__c != null) {
                                this.showMobile = true;
                                this.hideMedia = false;
                                this.cp = false;
                                this.media = this.cpData[0].Lead__r.Lead_Source__c;
                                this.leadId = this.cpData[0].Lead__c;
                                this.mobile = this.cpData[0].Lead__r.Mobile__c;
                                console.log('this.leadId in CP is::' + this.leadId);
                                if (this.media == 'Channel Partner') {
                                    this.cp = true;
                                    this.hideMedia = true;
                                    this.channelpartner = this.cpData[0].Lead__r.Channel_Partner__c;
                                    this.showCPName = this.cpData[0].Lead__r.Channel_Partner__r.Name;
                                    this.cpProjectId = this.cpData[0].Lead__r.CP_Project__c;

                                }
                                this.showCpData = true;
                                this.createNewData = true;
                                this.hideEmailMobile = true;
                                //this.hideMobile = false;
                                this.hideMedia = true;
                                //this.showMobile = false;
                                //this.hideMedia = true;
                            } else if (this.cpData[0].CP_Project__c != null) {
                                this.hideMobile = true;
                                this.hideMedia = true;
                                this.cp = true;
                                this.media = 'Channel Partner';
                                this.channelpartner = this.cpData[0].CP_Project__r.CP_Account__c;
                                this.showCPName = this.cpData[0].CP_Project__r.CP_Account__r.Name;
                                this.cpProjectId = this.cpData[0].CP_Project__c;
                                console.log('cpProjectId: ' + this.cpProjectId);
                                this.showCpData = true;
                                this.createNewData = true;
                                this.mobile = this.cpData[0].Mobile__c;
                                const names = this.cpData[0].Customer_Name__c.split(' ');
                                this.handleName = names.length > 0 ? names[0] : '';
                                this.lastName = names.length > 1 ? names.slice(1).join(' ') : '';
                                this.config = this.cpData[0].Configuration_required__c;
                                this.ownerName = this.cpData[0].Sourcing_Manager_Name__c;
                                this.cpName = this.cpData[0].CP_Name__c;
                                this.isSourceNotEditable = false;
                                this.hideEmailMobile = true;
                                this.hideMobile = false;
                                this.hideMedia = true;
                            } 
                        } else if (this.cpData.Status__c != 'Valid') {
                            this.showCpData = false;
                            const toastEvent = new ShowToastEvent({
                                title: 'Error',
                                message: 'The code you entered is expired',
                                variant: 'error'
                            });
                            this.dispatchEvent(toastEvent);
                        } else {
                            this.showCpData = false;
                            const toastEvent = new ShowToastEvent({
                                title: 'Error',
                                message: 'The code you entered is expired',
                                variant: 'error'
                            });
                            this.dispatchEvent(toastEvent);
                            this.disableReg = false;
                            this.hideEmailMobile = false;
                            this.hideMedia = false;
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    })
            } else {
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Verification Code',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            }
        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select Project',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleMobile(event) {
        this.mobile = event.target.value;

        if (this.mobile.length >= 10) {
            //this.validateMobile();
            this.disableMobile = true;
        } else {
            this.disableMobile = false;
        }
    }

    handleCheckValidation() {
        let inputFields = this.template.querySelectorAll('.reqInpFld1');
        this.isValid = true;
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid mobile',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                this.isValid = false;
            }
        });
        return this.isValid;
    }

    handleEmail(event) {
        this.email = event.target.value;
    }

    handleSearch() {
        if (this.Projectoptions == undefined || this.Projectoptions == '') {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter Project',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            this.isLoading = false;
            return;

        } else if (this.mobile == undefined || this.mobile == '') {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter Mobile',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            this.isLoading = false;
            return;
        } else {
            this.disableMobile = true;
            this.disableProject = true;
            this.showData = false;
            this.isLoading = true;
            searchForData({ num: this.mobile, mId: this.email, project: this.Projectoptions })
                .then((result) => {
                    this.isLoading = false;
                    this.Manager =
                        this.simpleMap = [];
                    for (var key in result) {
                        this.simpleMap.push({ key: key, value: result[key] });
                        this.accDataFound = this.simpleMap;
                    }

                    if (this.accDataFound != null) {
                        this.createNewData = true;
                        var accountFond = [];
                        var leadFond = [];
                        var opportunityFond = [];
                        this.accDataFound.forEach(element => {
                            element.value;
                            element.key;
                            if (element.key.includes('Account')) {
                                this.showAccountDataFound = true;
                                accountFond.push(element.value);
                            }
                            if (element.key.includes('Lead')) {
                                this.showLeadDataFound = true;
                                leadFond.push(element.value);
                            }
                            if (element.key.includes('Opportunity')) {
                                this.showOpportunityDataFound = true;
                                opportunityFond.push(element.value);
                            }
                            this.accountDataFound = accountFond[0];
                            this.leadDataFound = leadFond[0];
                            this.opportunityDataFound = opportunityFond[0];
                            if (this.accountDataFound != null) {
                                this.accountId = this.accountDataFound[0].Id;
                                this.selectedCityType = this.accountDataFound[0].City_Type__c;
                                this.selectedCountry = this.accountDataFound[0].Country__c;
                                this.selectedCityName = this.accountDataFound[0].City_Name__c;
                                this.selectedLocality = this.accountDataFound[0].Locality__c;
                                this.selectedLocalityDetails = this.accountDataFound[0].Locality_details__c;
                                this.handleName = this.accountDataFound[0].FirstName;
                                this.lastName = this.accountDataFound[0].LastName;
                                this.salute = this.accountDataFound[0].Salutation;
                            }
                            if (this.leadDataFound != null) {
                                this.leadId = this.leadDataFound[0].Id;
                                this.handleName = this.leadDataFound[0].First_Name__c;
                                this.lastName = this.leadDataFound[0].Last_Name__c;
                                if (this.leadDataFound[0].Lead_Source__c == 'Channel Partner') {
                                    this.cp = true;
                                    this.hideMedia = true;
                                    this.channelpartner = this.leadDataFound[0].Channel_Partner__c;
                                    this.showCPName = this.leadDataFound[0].Channel_Partner__r.Name;
                                }
                            }
                            if (this.opportunityDataFound != null) {
                                this.oppoId = this.opportunityDataFound[0].Id;
                                this.getLastSVsourceDate = this.opportunityDataFound[0].Last_Source_Changed_By__c;
                                this.media = this.opportunityDataFound[0].Lead_Source__c;
                                console.log('media: ' + JSON.stringify(this.media));
                                if (this.opportunityDataFound[0].Lead_Source__c == 'Channel Partner') {
                                    this.cp = true;
                                    this.hideMedia = true;
                                    this.channelpartner = this.opportunityDataFound[0].Channel_Partner__c;
                                    this.showCPName = this.opportunityDataFound[0].Channel_Partner__r.Name;
                                    this.cpProjectId = this.opportunityDataFound[0].CP_Project__c;
                                    console.log('channel Partner' + JSON.stringify(this.channelpartner));

                                }
                                console.log('this.getLastSVsourceDate: ' + this.getLastSVsourceDate);
                                this.tatDays = this.opportunityDataFound[0].Project__r.TAT__c;
                                console.log('this.tatDays: ' + this.tatDays);
                                var today = new Date().toISOString().substring(0, 10);
                                console.log('today: ' + today);
                                console.log('isSourceNotEditable before: ' + this.isSourceNotEditable);
                                var lastSVsourceDateObj = new Date(this.getLastSVsourceDate);
                                // Add 3 days to the date
                                lastSVsourceDateObj.setDate(lastSVsourceDateObj.getDate() + this.tatDays);
                                // Update this.getLastSVsourceDate with the new date
                                this.getLastSVsourceDate = lastSVsourceDateObj.toISOString().substring(0, 10);

                                console.log('getLastSVsourceDateWithTATDAYS: ' + this.getLastSVsourceDate);

                                if (this.getLastSVsourceDate != null && this.getLastSVsourceDate >= today) {
                                    this.isSourceNotEditable = false;
                                }
                                console.log('isSourceNotEditable after: ' + this.isSourceNotEditable);


                            }
                            this.detailsFound = element.value; // Value from the array
                            this.recordKey = element.key; //Key from the array
                            var templeadList = [];
                            for (var i = 0; i < this.detailsFound.length; i++) {
                                let tempRecord = Object.assign({}, this.detailsFound[i]); //cloning object  
                                tempRecord.recordLink = "/" + tempRecord.Id;
                                templeadList.push(tempRecord);
                            }
                            this.leadList = templeadList;
                            if (this.leadList.length > 0) {
                                this.email = this.leadList[0].Email__c;
                                this.media = this.leadList[0].Lead_Source__c;
                                this.config = this.leadList[0].Configuration_Required__c;
                            }
                        })
                    }
                    else { this.visible = true; this.showData = false; this.createNewData = true; }
                })
                .catch(error => {
                    this.error = error;
                })

        }
    }

    sendOTPSMS() {
        console.log('Project: '+this.Projectoptions);
        console.log('mobile: ' + this.mobile);
        createSMS({ mobile: this.mobile, project: this.Projectoptions })
            .then((result) => {
                console.log('result: ' + JSON.stringify(result));
                this.randomNumber = result;
            }).catch(error => {
                this.error = error;
                console.log('error result: ' + JSON.stringify(this.error));
            })
    }

    handleSendOTPButton() {
        this.showSendOTP = true;
        if (this.mobile == null || this.mobile.length < 10) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Invalid mobile no',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            this.showSendOTP = false;
        } else {
            this.regenerateOTP = false;
            this.sendOTPSMS();
            //this.randomNumber = Math.floor(Math.random() * 9000) + 1000;
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'OTP Generated Successfully',
                variant: 'Success'
            });
            this.dispatchEvent(toastEvent);
            this.OTPGenerated = true;
            this.OTPverified = true;
            this.disableSendOTP = true;
        }
        setTimeout(() => {
            this.OTPGenerated = false;
            this.regenerateOTP = true;
            this.disableVerifyOTP = false;

        }, 150000);
    }

    handleEnteredOTP(event) {
        this.EnteredOTP = event.target.value;
    }

    handleVerifyOTPButton() {
        if (this.EnteredOTP == this.randomNumber) {
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'OTP Verified Succecssfully',
                variant: 'Success'
            });
            this.dispatchEvent(toastEvent);
            this.OTPverificationSuccess = true;
            this.disableVerifyOTP = true;
            this.showButtons = true;
            this.regenerateOTP = false;

        } else if (this.EnteredOTP == this.masterOTP) {
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Master OTP Verified Succecssfully',
                variant: 'Success'
            });
            this.dispatchEvent(toastEvent);
            this.OTPverificationSuccess = true;
            this.disableVerifyOTP = true;
            this.showButtons = true;
            this.regenerateOTP = false;

        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter Valid OTP.',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            this.showButtons = false;
        }
    }

    handleContinue() {
        const isValid1 = this.handleCheckValidation();
        if (isValid1) {
            this.handlenext1();
        } else {
            this.isLoading = false;
        }
    }
    handleReset() {
        location.reload();
    }
    handlenext1() {
        this.secondPage = true;
        this.showFirstPage = false;
    }
    /*<----------------------------------------------------------------------Code for Second Page ------------------------------------------------------>*/
    handleSalutation(event) { this.salute = event.target.value; }
    handleNameChange(event) {
        this.handleName = event.target.value;
    }
    handleLastNameChange(event) { this.lastName = event.target.value; }
    handleEmailOnSecondPage(event) { this.handleEmailforSecondPage = event.target.value; }
    handleNext() {
        if (this.salute == null) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select the Salutation',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
        }

        else if ((this.handleName == null || this.handleName == '') && (this.accDataFound == null)) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select the First Name',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
        }
        else if (this.lastName == null || this.lastName == '') {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select the Last Name',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
        }
        /*else if(this.handleEmailforSecondPage == null || this.handleEmailforSecondPage == ''){
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter the Email',    
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
        }*/
        else {
            this.secondPage = false;
            this.thirdPage = true;
        }

    }
    handlePrevious() { this.secondPage = false; this.showFirstPage = true; }
    /*<----------------------------------------------------------------------Code for Third Page ------------------------------------------------------->*/
    handleCityType(event) {
        this.selectedCityType = event.target.value;
        console.log('this.selectedCityType::' + this.selectedCityType);
        if (this.selectedCityType === 'Mumbai') {
            this.localityRequired = true;
            this.cityRequired = false;
            this.countryMandatory = false;
        } else if (this.selectedCityType === 'Outstation') {
            this.cityRequired = true;
            this.countryMandatory = true;
            this.localityRequired = false;
        } else if (this.selectedCityType === 'NRI') {
            this.countryMandatory = true;
            this.localityRequired = false;
            this.cityRequired = false;
        }
    }

    handleCountryChange(event) {
        this.selectedCountry = event.target.value;
        console.log('this.selectedCountry::' + this.selectedCountry);
    }

    handleLocality(event) {
        this.selectedLocality = event.target.value;
        console.log('this.selectedLocality ::' + this.selectedLocality);
    }

    handleLocalityDetailsPicklist(event) {
        this.selectedLocalityDetails = event.target.value;
        console.log('this.selectedLocalityDetails::' + this.selectedLocalityDetails);
    }

    handleCityNamePicklist(event) {
        console.log('isSourceNotEditable: ' + this.isSourceNotEditable);

        this.selectedCityName = event.target.value;
        console.log('this.selectedCityName::' + this.selectedCityName);
    }

    handleNextOnThirdPage() {
        console.log('isSourceNotEditable: ' + this.isSourceNotEditable);

        this.isLoading = true;
        setTimeout(() => {
            this.isLoading = false;
        }, 2500);
        this.thirdPage = false;
        this.fourthPage = true;
        /* if(this.selectedCityType != undefined || this.selectedCityType != null){
             if(this.selectedCityType == 'Mumbai'){
                 if(this.selectedLocality == null || this.selectedLocality == ''){
                     const toastEvent = new ShowToastEvent({
                         title: 'Error',
                         message: 'Please Select the Locality',    
                         variant: 'Error'
                     });
                     this.dispatchEvent(toastEvent);
                     this.thirdPage = true; 
                     this.fourthPage = false;
                 }else{
                     this.thirdPage = false; 
                     this.fourthPage = true;
                 }
             }else if(this.selectedCityType == 'Outstation'){
                 if(this.selectedCityName == null || this.selectedCityName == ''){
                     const toastEvent = new ShowToastEvent({
                         title: 'Error',
                         message: 'Please Select the City Name',    
                         variant: 'Error'
                     });
                     this.dispatchEvent(toastEvent);
                     this.thirdPage = true; 
                     this.fourthPage = false;
                 }else if(this.selectedCountry == null || this.selectedCountry == ''){
                     const toastEvent = new ShowToastEvent({
                         title: 'Error',
                         message: 'Please Select the Country',    
                         variant: 'Error'
                     });
                     this.dispatchEvent(toastEvent);
                     this.thirdPage = true; 
                     this.fourthPage = false;
                 }else{
                     this.thirdPage = false; 
                     this.fourthPage = true;
                 }
             }else if(this.selectedCityType == 'NRI'){
                 if(this.selectedCountry == null || this.selectedCountry == ''){
                     const toastEvent = new ShowToastEvent({
                         title: 'Error',
                         message: 'Please Select the Country',    
                         variant: 'Error'
                     });
                     this.dispatchEvent(toastEvent);
                     this.thirdPage = true; 
                     this.fourthPage = false;
                 }else{
                     this.thirdPage = false; 
                     this.fourthPage = true;
                 }
             }
         }*//*else{
          const toastEvent = new ShowToastEvent({
              title: 'Error',
              message: 'Please Select City Type',    
              variant: 'Error'
          });
          this.dispatchEvent(toastEvent);
      }*/
    }
    handlePreviousOnThirdPage() {
        this.secondPage = true;
        this.thirdPage = false;
    }
    /*<----------------------------------------------------------------------Code for Fourth Page ------------------------------------------------------->*/

    handleMedia(event) {
        console.log('isSourceNotEditable: ' + this.isSourceNotEditable);

        this.media = event.target.value;
        this.isSourceChanged = true;

        if (this.media == 'Channel Partner') {
            this.getChannelPartners();
            this.cp = true;
        }
        else {
            this.cp = false;
        }
        if (this.media == 'Reference') {
            this.acc = true;
        }
        else {
            this.acc = false;
        }
    }
    handleReferrerName(evt) {
        this.referrerName = evt.target.value;
    }
    handleReferrerExistingProject(evt) {
        this.referrerExistingProject = evt.target.value;
    }
    handleReferrerExistingUnitNumber(evt) {
        this.referrerExistingUnitNumber = evt.target.value;
    }
    handleReferrerMobile(evt) {
        this.referrerMobile = evt.target.value;
    }
    handlePreviousOnfourthPage() {
        this.fourthPage = false;
        this.thirdPage = true;
    }

    getChannelPartners() {
        getChannelPartners({ proj: this.Projectoptions, cpName: this.searchKey })
            .then(data => {
                //  console.log('data: '+JSON.stringify(data));
                if (data != null) {
                    this.cpList = data;
                    this.showCPLookup = true;
                    console.log('cpList: ' + JSON.stringify(this.cpList));
                } else {
                    this.cpList = [];
                }
            })
            .catch(error => {
                this.errorInCP = error;
            })
    }

    handlechannelpartner(event) {
        console.log('proj: ' + this.Projectoptions);
        this.searchKey = event.target.value;
        console.log('searchKey: ' + this.searchKey);
        this.getChannelPartners();
    }

    handleParentSelection(event) {
        this.showCPName = event.target.dataset.label;
        console.log('showCPName: ' + this.showCPName);
        this.cpProjectId = event.target.dataset.id;
        console.log('cpProjectId: ' + this.cpProjectId);
        this.channelpartner = event.target.dataset.value;
        this.showCPLookup = false;
        console.log('value: ' + this.channelpartner);
        if (this.channelpartner != null) {
            this.getCPProjectOwner();
        }
    }
    getCPProjectOwner() {
        getCPProjectOwner({ cpId: this.channelpartner, proj: this.Projectoptions })
            .then(data => {
                if (data != null) {
                    this.ownerId = data;
                }
                //this.data = data;           
            })
            .catch(error => {
                this.error = error;
            })
    }


    handleNextOnfourthPage() {
        if (this.media != null || this.media != undefined) {
            if (this.media == 'Channel Partner') {
                if (this.channelpartner == null) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select Channel Partner',
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                } else {
                    this.fifthPage = true;
                    this.fourthPage = false;
                }
            } else if (this.media == 'Reference') {
                if (this.referrerName == null) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select Referrer Name',
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                } else if (this.referrerExistingProject == null) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select Referrer Existing Project Name',
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                } else if (this.referrerExistingUnitNumber == null) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select Referrer Existing Unit Number',
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                } else if (this.referrerMobile == null) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select Referrer Mobile Number',
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                } else {
                    this.fifthPage = true;
                    this.fourthPage = false;
                }
            } else {
                this.fifthPage = true;
                this.fourthPage = false;
            }
        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select Where did you hear about us?',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
        }
    }
    /*<----------------------------------------------------------------------Code for fifth Page ------------------------------------------------------->*/
    @wire(getConfigPicklistValues) getConfigPicklistValues({ data, error }) {
        if (data) {
            let options = [];
            for (let i = 0; i < data.length; i++) {
                options.push({ label: data[i], value: data[i] })
            }
            this.configOptions = options;
        }
        else if (error) {

        }
    }
    handleConfig(event) {
        this.config = event.target.value;
    }

    handleSubmitOnFifthPage() {
        if (this.config == null || this.config == '') {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select the Configuration you are interested in',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
        } else {
            this.isLoading = true;
            if (this.leadList.length == 0) {
                console.log('Inside if: ' + this.leadId);
                submits({
                    ldId: this.leadId, opId: this.oppoId, acId: this.accountId, cp: this.channelpartner, CPProjectOwner: this.ownerId, cpProjectId: this.cpProjectId, Mobile: this.mobile, project: this.Projectoptions, email: this.email, mastersource: this.media,
                    lname: this.lastName, fname: this.handleName, salutation: this.salute, configuration: this.config, country: this.selectedCountry, cityType: this.selectedCityType, status: this.changeStatus, otp: this.regCode,
                    cityName: this.selectedCityName, locality: this.selectedLocality, locDetails: this.selectedLocalityDetails, rrName: this.referrerName, isSourceChanged: this.isSourceChanged
                })
                    .then((result) => {
                        this.isLoading = false;
                        this.fifthPage = false;
                        //this.view = true;
                        this.finalList = result;
                        this.svId = this.finalList[0];
                        console.log('this.svId: ' + JSON.stringify(this.svId));
                        if (this.svId != null || this.svId != undefined) {
                            this.showSuccessMessage = true;
                            this.showErrorMessage = false;
                            getSiteName({ sId: this.svId })
                                .then(data => {
                                    this.svNaame = data;
                                })
                                .catch(error => {
                                    this.error = error;
                                })

                        } else {
                            this.showErrorMessage = true;
                            this.showSuccessMessage = false;
                        }
                        this.messages = result[0];
                        setTimeout(() => {
                            location.reload();
                        }, 60000);
                    })
                    .catch(error => {
                        this.isLoading = false;
                        //this.view = true;
                        if (error.length > 0) {
                            this.errorMessages = error;
                        } else {
                            this.errorMessages = ["An unexpected error occurred."];
                        }
                    });
            } else {
                console.log('Inside else: ' + this.leadId);
                submits({
                    ldId: this.leadId, opId: this.oppoId, acId: this.accountId, cp: this.channelpartner, CPProjectOwner: this.ownerId, cpProjectId: this.cpProjectId, Mobile: this.mobile, project: this.Projectoptions, email: this.email, mastersource: this.media,
                    lname: this.lastName, fname: this.handleName, salutation: this.salute, configuration: this.config, country: this.selectedCountry, cityType: this.selectedCityType, status: this.changeStatus, otp: this.regCode,
                    cityName: this.selectedCityName, locality: this.selectedLocality, locDetails: this.selectedLocalityDetails, rrName: this.referrerName, isSourceChanged: this.isSourceChanged
                })
                    .then((result) => {
                        this.isLoading = false;
                        this.fifthPage = false;
                        //this.view = true;
                        this.finalList = result;
                        this.svId = this.finalList[0];
                        if (this.svId != null || this.svId != undefined) {
                            this.showSuccessMessage = true;
                            this.showErrorMessage = false;
                            getSiteName({ sId: this.svId })
                                .then(data => {
                                    this.svNaame = data;
                                })
                                .catch(error => {
                                    this.error = error;
                                })

                        } else {
                            this.showErrorMessage = true;
                            this.showSuccessMessage = false;
                        }
                        this.messages = result[0];
                        setTimeout(() => {
                            location.reload();
                        }, 60000);
                    })
                    .catch(error => {
                        this.isLoading = false;
                        //this.view = true;
                        if (error.length > 0) {
                            this.errorMessages = error;
                        } else {
                            this.errorMessages = ["An unexpected error occurred."];
                        }
                    });
            }

        }
    }

    handleclose() {
        location.reload();
        /*if(this.finalList.length > 1){

            let delay = 1000
            setTimeout(() => {
                location.replace(`/${this.finalList[1]}`);
            }, delay );

        }
        else{
            location.reload();
        }*/
    }

    handleCheckHere() {
        this.navigateToViewSVPage();
    }

    navigateToViewSVPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.svId,
                objectApiName: 'Site_Visit__c',
                actionName: 'view'
            },
            target: '_blank'
        });
    }

    handlePreviousOnFifthPage() { this.fourthPage = true; this.fifthPage = false; }
}