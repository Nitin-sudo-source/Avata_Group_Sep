import { LightningElement, api, wire, track } from 'lwc';
//import sendOTP from '@salesforce/apex/Ex_PreRegistrationController.sendOTP';
//import validateOTP from '@salesforce/apex/Ex_PreRegistrationController.validateOTP';
import getCPProject from '@salesforce/apex/Ex_PreRegistrationController.getCPProject';
import saveData from '@salesforce/apex/Ex_PreRegistrationController.saveData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_PreRegistrationPortalLwc extends NavigationMixin(LightningElement) {
    ampm = false;
    @api recordId;
    @track customerNo;
    @track OTP;
    @track validateType = false;
    @track validateMessage;
    @track sendMessage;
    @track errorMsg = '';
    @track preRegistrationDateTime;
    @track formattedDate;
    @track customerName;
    showSendMessage = false;
    showErrorMessage = false;
    showValidateMessage = false;
    showErrorValidate = false;
    showResendMessage = false;
    showErrorResend = false;
    showResendButton = false;
    HidesendButton = true;
    @track getCPData = [];
    @track items = [];
    @track cpId;
    @track showPickup = false;
    @track getFacility;
    @track getVisitDate;
    @track getConfiguration;
    @track getBudget;
    @track getPickupDate;
    @track getLocation;
    @track getVisitDateonly;
    todayDate;
    @track isErrorMsg = '';



    @wire(getCPProject) getCPList({ error, data }) {
        if (data) {
            //  this.getCPData = data;
            let array = [];
            for (var i = 0; i < data.length; i++) {
                array.push({ value: data[i].cpId, label: data[i].cpName });
            }
            this.getCPData = array;
            console.log('getCPData: ' + JSON.stringify(this.getCPData));

            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.getCPData = undefined;
        }
    }


    handleChange(event) {
        this.cpId = event.detail.value;
        console.log('this.cpId: ' + this.cpId);
    }

    getCustomerNumber(event) {
        this.customerNo = event.detail.value;
        console.log(this.customerNo);
        console.log(this.customerNo.length);
        if (this.customerNo.length != 10) {
            this.isErrorMsg = 'Please Enter 10 Digit Valid Mobile Number';
        } else {
            this.isErrorMsg = '';
        }
    }
    getCustomerName(event) {
        this.customerName = event.detail.value;
    }

    handleFacility(event) {
        // let facility = this.template.querySelector("[data-id='Ola_Pickup_Facility__c']");
        this.getFacility = event.target.value;
        if (this.getFacility == 'Yes') {
            this.showPickup = true;
        } else {
            this.showPickup = false;
            // this.getFacility = 'No';
        }
        console.log(this.getFacility);
    }

    handleVisitDate() {
        let visitDate = this.template.querySelector("[data-id='Visit_Date__c']");
        this.getVisitDate = visitDate ? visitDate.value : null;
        console.log('DateTimeVisit: ' + this.getVisitDate);
        const dateValue = new Date(this.getVisitDate);
        this.getVisitDateonly = dateValue.toISOString().split('T')[0];
        console.log('VisitDate: ' + this.getVisitDateonly);
    }

    handleBudget() {
        let budget = this.template.querySelector("[data-id='Budget__c']");
        this.getBudget = budget ? budget.value : null;
        console.log(this.getBudget);
    }

    handleConfiguration() {
        let config = this.template.querySelector("[data-id='Configuration_required__c']");
        this.getConfiguration = config ? config.value : null;
        console.log(this.getConfiguration);
    }

    handleLocation() {
        let location = this.template.querySelector("[data-id='Pickup_Location__c']");
        this.getLocation = location ? location.value : null;
        console.log(this.getLocation);
    }

    handlePickupDateTime() {
        let pickupDateTime = this.template.querySelector("[data-id='Pickup_Datetime__c']");
        this.getPickupDate = pickupDateTime ? pickupDateTime.value : null;
        console.log(this.getPickupDate);
    }


   /* sendOTP(event) {
        // alert(this.customerNo);
        if (this.customerNo === undefined) {
            // alert('Please Enter Mobile Number');
            this.showToast('Error', 'Please Enter Mobile Number', 'error', 'dismissible');
            return;
        } else {
            sendOTP({ mobile: this.customerNo, cpId: this.cpId })
                .then(result => {
                    console.log('resultsendOTP: ' + result);
                    if (result != null) {
                        this.HidesendButton = false;
                        this.showResendButton = true;
                        this.sendMessage = result;
                    } else {
                        this.sendMessage = result;
                    }
                })
        }
    }*/

   /* handlechangeotp(event) {
        this.OTP = parseInt(event.target.value);
        console.log(this.OTP);
    }*/

   /* ValidateOTP(event) {
        if (this.customerNo === undefined) {
            // alert('Please Enter Mobile Number');
            this.showToast('Error', 'Please Enter Mobile Number', 'error', 'dismissible');
            return;
        } else {

            validateOTP({ mobile: this.customerNo, enterOtp: this.OTP })
                .then(result => {
                    console.log('resultValidateOTP: ' + result);
                    if (result == true) {
                        this.sendMessage = 'OTP Verified Successfully.';
                        this.errorMsg = '';
                        this.validateType = true;
                    } else {
                        this.errorMsg = 'OTP Verification Failed.';
                        this.sendMessage = '';
                        this.validateType = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                })
        }
    } */

    handleSave() {
        let currentDate = new Date();
        currentDate.setDate(currentDate.getDate() + 2);
        let myDate = new Date();
        myDate.setDate(myDate.getDate());
        let getTodayDate = myDate.toISOString().substring(0, 10);
        console.log('getTodayDate: '+getTodayDate);
        this.todayDate = currentDate.toISOString().substring(0, 10);
        console.log('this.todayDate: ' + this.todayDate);
        console.log('getFacility: ' + this.getFacility); //this.validateType
        console.log('validType: ' + this.validateType);
        let facility = this.template.querySelector("[data-id='Ola_Pickup_Facility__c']");
        this.getFacility = facility.value;
        if (this.cpId === undefined) {
            this.showToast('Error', 'Please Select CP Project', 'error', 'dismissible');
            return;
            //
        } else if (this.customerName === undefined) {
            // alert('Please Enter Mobile Number');
            this.showToast('Error', 'Please Enter Customer Name', 'error', 'dismissible');
            return;
        } else if (this.customerNo === undefined) {
            // alert('Please Enter Mobile Number');
            this.showToast('Error', 'Please Enter Mobile Number', 'error', 'dismissible');
            return;
        } /*else if (this.validateType == false) {
            this.showToast('Error', 'Please Verify OTP ', 'error', 'dismissible');
            return;
        } */else if (this.getVisitDate === undefined) {
            this.showToast('Error', 'Please Select Visit Date  ', 'error', 'dismissible');
            return;
        } else if (this.getVisitDateonly > this.todayDate || this.getVisitDateonly < getTodayDate) {
            this.showToast('Error', 'Please Select Visit Date within 48 hours  ', 'error', 'dismissible');
            return;
        } else if (this.getBudget === undefined) {
            this.showToast('Error', 'Please Select Budget ', 'error', 'dismissible');
            return;
        } else if (this.getConfiguration === undefined) {
            this.showToast('Error', 'Please Select Configuration ', 'error', 'dismissible');
            return;
        } else if (this.getFacility === undefined || this.getFacility == null || this.getFacility === '') {
            this.showToast('Error', 'Please Select Ola Pickup Facility for Customer ', 'error', 'dismissible');
            return;
        } else if (this.customerNo.length != 10) {
            this.showToast('Error', 'Please Enter Valid Mobile Number ', 'error', 'dismissible');
            return;
        } /*else if (this.validateType == false) {
            this.showToast('Error', 'Please Verify OTP  ', 'error', 'dismissible');
            return;
        } */else if (this.getFacility == 'Yes' && this.getLocation === undefined) {
            this.showToast('Error', 'Please Enter Pickup Location ', 'error', 'dismissible');
            return;
        } else if (this.getFacility == 'Yes' && this.getPickupDate === undefined) {
            this.showToast('Error', 'Please Select Pickup Date ', 'error', 'dismissible');
            return;
        }
        else {

            saveData({
                cpId: this.cpId, customerName: this.customerName, customerNo: this.customerNo,
                Budget: this.getBudget, Configuration: this.getConfiguration, Facility: this.getFacility,
                VisitDate: this.getVisitDate, Location: this.getLocation, PickupDate: this.getPickupDate
            })
                .then(result => {
                    console.log("result" + JSON.stringify(result));
                    this.showToast('success', 'Record Save Successfully', 'success', 'dismissible');

                    window.location.href = '/' + result;
                })
        }
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}