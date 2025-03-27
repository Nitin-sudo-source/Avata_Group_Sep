/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 27-03-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecordType from '@salesforce/apex/Ex_CPMeetingLocationTagging.getRecordType';
import getWrapper from '@salesforce/apex/Ex_CPMeetingLocationTagging.getWrapper';
import saveTask from '@salesforce/apex/Ex_CPMeetingLocationTagging.saveTask';
import getPicklist from '@salesforce/apex/Ex_CPMeetingLocationTagging.getPicklistValues';
import { CurrentPageReference } from "lightning/navigation";
import CALL_STATUS_FIELD from '@salesforce/schema/Task.Call_Status__c';
import MEETING_STATUS_FIELD from '@salesforce/schema/Task.Meeting_Status__c';
import MEETING_TYPE_FIELD from '@salesforce/schema/Task.Purpose_of_the_Meeting__c';
import PURPOSE_FIELD from '@salesforce/schema/Task.Purpose_of_Meeting_Cancelled__c';
// import Call_Type__c from '@salesforce/schema/Task.Call_Type__c';
// import PURPOSE_FIELDCPCall from '@salesforce/schema/Task.Purpose_of_Call__c';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TASK_OBJECT from '@salesforce/schema/Task';





export default class Ex_CPMeetingLog extends LightningElement {
    recordTypeId;
    @track t = {};
    @track cpId = '';
    @track subjectOptions = [];
    @track latitude = null;
    @track longitude = null;
    @track subjectCPCallOptions = [];
    @track getRecordTypeName = '';
    @track cpCallStatus = [];
    @track cpMeetingStatus = [];
    @track cpMeetingType = [];
    @track cpMeetingpurpose = [];
    @track getSVWrapperList = [];

    @track cpCallType = [];
    @track cpPurposeofCall = [];

    @track isCPCallActive = true;
    @track isCPMeetingActive = false;

    @track selectedTime = '';
    @track startedAt = '';
    @track runningTime = '00:00:00';
    @track startDateTimeStore = null;
    @track endTime;
    @track endTimeStore = null;
    @track duration = '00:00:00';
    startTime;
    intervalId;


    connectedCallback() {
        // this.getrecordCPCallTypeId();
        // this.getrecordCPMeetingTypeId();
        this.getPicklistValues();
        // this.getPicklistValuesCPMeetinStatus();
        // this.getPicklistValuesCPMeetinType();
        // this.getPicklistValuesCPStatus();
        // this.getPicklistValuesCPMeetingPurpose();


        this.requestLocation();
       
        if (this.isCPCallActive) {
            this.getrecordCPCallTypeId();


            // this.getTaskWrapper();
        }
    }

    startMeeting() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        this.selectedTime = `${hours}:${minutes}`; // Format: HH:MM
    }


    handleTabActive(event) {
        console.log('event.target.value: ' + event.target.value);
        if (event.target.value == 'CP Call') {
            this.isCPMeetingActive = false;
            this.isCPCallActive = true;
            this.getrecordCPCallTypeId();
        }
        else if (event.target.value == 'CP Meeting') {
            this.isCPMeetingActive = true;
            this.isCPCallActive = false;
            this.getrecordCPMeetingTypeId();
            this.startMeeting();
        }
    }

    requestLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.latitude = position.coords.latitude;
                    this.longitude = position.coords.longitude;
                    console.log('Latitude:', this.latitude);
                    console.log('Longitude:', this.longitude);
                },
                (error) => {
                    this.showToast('Error', 'Location access denied or unavailable.', 'error');
                }
            );
        } else {
            this.showToast('Error', 'Geolocation is not supported by this browser.', 'error');
        }
    }

    startMeeting() {
        this.startTime = new Date();
        
        const dateOptions = { year: 'numeric', month: 'long', day: 'numeric' };
        const timeOptions = { hour: '2-digit', minute: '2-digit', second: '2-digit' };
        
        const formattedDate = this.startTime.toLocaleDateString('en-US', dateOptions);
        const formattedTime = this.startTime.toLocaleTimeString('en-US', timeOptions);
        
        this.startedAt = `${formattedDate} - ${formattedTime}`; // Example: March 24, 2025 - 10:25:30 AM
        
        this.intervalId = setInterval(() => this.updateRunningTime(), 1000); // Update every second
    }

    updateRunningTime() {
        const now = new Date();
        const elapsedTime = now - this.startTime;

        const hours = String(Math.floor(elapsedTime / (1000 * 60 * 60))).padStart(2, '0');
        const minutes = String(Math.floor((elapsedTime % (1000 * 60 * 60)) / (1000 * 60))).padStart(2, '0');
        const seconds = String(Math.floor((elapsedTime % (1000 * 60)) / 1000)).padStart(2, '0');

        this.runningTime = `${hours}:${minutes}:${seconds}`;
    }


    get googleMapsLink() {
        if (this.latitude && this.longitude) {
            console.log('this.t: ' + JSON.stringify(this.t.t));

            return `https://www.google.com/maps?q=${this.latitude},${this.longitude}`;
        }
        return null; // Return null if location data is not available
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('currentPageReference: ' + JSON.stringify(currentPageReference));
        if (currentPageReference.type === "standard__recordPage" &&
            currentPageReference.attributes.recordId != "") {
            this.cpId = currentPageReference.attributes.recordId;
            console.log('iscpId: ' + this.cpId);
            //let quickActionPath = currentPageReference.attributes.apiName;

        }
    }



    getrecordCPCallTypeId() {
        const objectApiName = 'Task';
        getRecordType({ objectApiName, recordTypeName: 'CP Call' })
            .then((result) => {
                this.recordTypeId = result;
                console.log('recordTypeId: ', JSON.stringify(this.recordTypeId));
                this.getTaskWrapper();

            })
            .catch((error) => {
                console.error('Error fetching recordTypeId values: ', error);
            });
    }

    getrecordCPMeetingTypeId() {
        const objectApiName = 'Task';
        getRecordType({ objectApiName, recordTypeName: 'CP Meeting' })
            .then((result) => {
                this.recordTypeId = result;
                console.log('recordTypeId: ', JSON.stringify(this.recordTypeId));

                this.getTaskWrapper();

            })
            .catch((error) => {
                console.error('Error fetching recordTypeId values: ', error);
            });
    }

    getPicklistValues() {
        const objectApiName = 'Task';
        getPicklist({ objectApiName, fieldName: 'Subject' })
            .then((result) => {
                this.subjectOptions = result
                    .filter(item => item.includes('CP Meeting')) // Filter values that contain "CP Meeting"
                    .map(value => ({
                        label: value,
                        value: value
                    }));

                this.subjectCPCallOptions = result
                    .filter(item => item.includes('CP Call')) // Filter values that contain "CP Meeting"
                    .map(value => ({
                        label: value,
                        value: value
                    }));

                console.log('Filtered subjectCPOptions: ', JSON.stringify(this.subjectOptions));
                console.log('Filtered subjectCPCallOptions: ', JSON.stringify(this.subjectCPCallOptions));
                this.getTaskWrapper();
            })
            .catch((error) => {
                console.error('Error fetching recordTypeId values: ', error);
            });
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: CALL_STATUS_FIELD })
    wiredCallStatus({ data, error }) {
        if (data) {
            this.cpCallStatus = data.values.map((item) => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching Call_Status__c picklist values:', error);
        }
    }


    // @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: PURPOSE_FIELDCPCall })
    // wiredCallStatusCPCall({ data, error }) {
    //     if (data) {
    //         this.cpPurposeofCall = data.values.map((item) => ({
    //             label: item.label,
    //             value: item.value
    //         }));
    //     } else if (error) {
    //         console.error('Error fetching Call_Status__c picklist values:', error);
    //     }
    // }

    // @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Call_Type__c })
    // wiredCallStatusCPCallType({ data, error }) {
    //     if (data) {
    //         this.cpCallType = data.values.map((item) => ({
    //             label: item.label,
    //             value: item.value
    //         }));
    //     } else if (error) {
    //         console.error('Error fetching Call_Status__c picklist values:', error);
    //     }
    // }

    // Fetch Meeting_Status__c picklist values
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: MEETING_STATUS_FIELD })
    wiredMeetingStatus({ data, error }) {
        if (data) {
            this.cpMeetingStatus = data.values.map((item) => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching Meeting_Status__c picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: MEETING_TYPE_FIELD })
    wiredMeetingType({ data, error }) {
        if (data) {
            this.cpMeetingType = data.values.map((item) => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching Meeting_Type__c picklist values:', error);
        }
    }

    // Fetch Purpose__c picklist values
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: PURPOSE_FIELD })
    wiredMeetingPurpose({ data, error }) {
        if (data) {
            this.cpMeetingPurpose = data.values.map((item) => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching Purpose__c picklist values:', error);
        }
    }



    getTaskWrapper() {
        console.log(
            this.cpId,
            this.recordTypeId
        );
        // getWrapper()
        getWrapper({ recordId: this.cpId, recordTypeId: this.recordTypeId })
            .then((result) => {
                console.log('result: ', JSON.stringify(result));
                this.t = result;
                if (this.t.t.Location_Url__c === undefined) {
                    this.t.t.Location_Url__c = '';
                    this.t.t.Location_Url__c = `https://www.google.com/maps?q=${this.latitude},${this.longitude}`;
                } else {
                    this.t.t.Location_Url__c = `https://www.google.com/maps?q=${this.latitude},${this.longitude}`;
                }
                //this.t.Subject = result.t.Subject;


                console.log('t: ', JSON.stringify(this.t));
            })
            .catch((error) => {
                console.error('Error fetching t values: ', error);
            });
    }
    handleChange(event) {
        console.log('OUTPUT : ', event);
        try {
            const fieldName = event.target.name;
            const fieldValue = event.target.value;

            console.log(`Field Changed: ${fieldName}, New Value: ${fieldValue}`);


            this.t.t[fieldName] = fieldValue;

            console.log('Updated Object:', JSON.stringify(this.t.t));
        } catch (error) {
            console.error('Error in handleChange:', JSON.stringify(error));
        }
    }



    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            })
        );
    }

    async handleSave() {

        console.log('latitude: ', this.latitude, 'longitude: ', this.longitude);
        console.log('insideSave: '+JSON.stringify(this.t));

        if (this.isCPMeetingActive === true && (this.t.t.Meeting_Date__c == null || this.t.t.Meeting_Date__c == null ||
            this.t.t.Meeting_Date__c === undefined || this.t.t.Meeting_Date__c === '')) {
            this.showToast('Error', 'Please fill Meeting Date', 'error');
            return;
        } else if (
            this.isCPMeetingActive === true &&
            (
                !this.t.t.Meeting_Date__c || 
                new Date(this.t.t.Meeting_Date__c).setHours(0, 0, 0, 0) < new Date(new Date().setDate(new Date().getDate() - 1)).setHours(0, 0, 0, 0) || 
                new Date(this.t.t.Meeting_Date__c).setHours(0, 0, 0, 0) > new Date().setHours(0, 0, 0, 0)
            )
        ) {
            this.showToast('Error', 'Meeting Date must be yesterday or today', 'error');
            return;
        }
         else if (this.isCPMeetingActive === true && (this.t.t.Description == null || this.t.t.Description == null ||
            this.t.t.Description === undefined || this.t.t.Description === '')) {
            this.showToast('Error', 'Please fill Remarks', 'error');

        } else if (this.isCPMeetingActive === true && (this.t.t.Meeting_Status__c == null || this.t.t.Meeting_Status__c == null ||
            this.t.t.Meeting_Status__c === undefined || this.t.t.Meeting_Status__c === '')) {
            this.showToast('Error', 'Please fill Meeting Status', 'error');

        }


        else if (this.isCPMeetingActive === true && (this.t.t.Purpose_of_the_Meeting__c == null || this.t.t.Purpose_of_the_Meeting__c == null ||
            this.t.t.Purpose_of_the_Meeting__c === undefined || this.t.t.Purpose_of_the_Meeting__c === '')) {
            this.showToast('Error', 'Please fill Meeting Type', 'error');

        }
        else if (this.isCPMeetingActive === true && (this.t.t.Meeting_Purpose__c == null || this.t.t.Meeting_Purpose__c == null ||
            this.t.t.Meeting_Purpose__c === undefined || this.t.t.Meeting_Purpose__c === '')) {
            this.showToast('Error', 'Please fill Meeting Agenda', 'error');

        } else if ( this.isCPCallActive === true && (this.t.t.Next_Action_Date__c && 
            new Date(this.t.t.Next_Action_Date__c) < new Date().setHours(0, 0, 0, 0))) {
            
            this.showToast('Error', 'Next Action Date cannot be in the past', 'error');
            return;
        }
        
        else if (this.isCPCallActive === true && (this.t.t.Call_date__c === null ||
            this.t.t.Call_date__c === null ||
            this.t.t.Call_date__c === undefined || this.t.t.Call_date__c === '')) {
            this.showToast('Error', 'Please fill Call Date', 'error');
        } else if (this.isCPCallActive === true && (this.t.t.Call_Status__c === null ||
            this.t.t.Call_Status__c === null ||
            this.t.t.Call_Status__c === undefined || this.t.t.Call_Status__c === '')) {
            this.showToast('Error', 'Please fill CP Call Status', 'error');
        } else if (this.isCPCallActive === true && 
            (!this.t.t.Call_date__c || 
             new Date(this.t.t.Call_date__c) < new Date().setHours(0, 0, 0, 0))) {
       this.showToast('Error', 'Call Date cannot be in the past', 'error');
   }
        // else if (this.isCPCallActive === true && (this.t.t.Call_Type__c === null ||
        //     this.t.t.Call_Type__c === null ||
        //     this.t.t.Call_Type__c === undefined || this.t.t.Call_Type__c === '')) {
        //     this.showToast('Error', 'Please fill CP Call Type', 'error');
        // } 
        // else if (this.isCPCallActive === true && (this.t.t.Purpose_of_Call__c === null ||
        //     this.t.t.Purpose_of_Call__c === null ||
        //     this.t.t.Purpose_of_Call__c === undefined || this.t.t.Purpose_of_Call__c === '')) {
        //     this.showToast('Error', 'Please fill Purpose of Call', 'error');
        // }
        else if (this.isCPCallActive === true && (this.t.t.Description == null || this.t.t.Description == null ||
            this.t.t.Description === undefined || this.t.t.Description === '')) {
            this.showToast('Error', 'Please fill Remarks', 'error');

        }
        else if (this.isCPMeetingActive === true && this.latitude === null && this.longitude === null) {
            this.showToast('Error', 'Location is mandatory. Please Enable your Location and Refresh the page.', 'error');

        }
        else {
            this.isLoading = true;

            if(this.isCPMeetingActive && this.t.t.Meeting_Status__c != null && this.t.t.Meeting_Status__c == 'Meeting Completed'){
                clearInterval(this.intervalId);  
                this.endTime = new Date();
                this.startDateTimeStore = this.startTime.toISOString();
                this.endTimeStore = this.endTime.toISOString();
                this.duration = this.runningTime;
                console.log('duration: '+this.duration);
                console.log('startDateTimeStore: '+this.startDateTimeStore);
                console.log('endTimeStore: '+this.endTimeStore);
                console.log('endTime: '+this.endTime);
                if(this.t.t.Meeting_Start_time__c === undefined){
                    this.t.t.Meeting_Start_time__c = this.startDateTimeStore;
                }
                if(this.t.t.Meeting_End_time__c === undefined){
                    this.t.t.Meeting_End_time__c = this.endTimeStore;
                }
                // if(this.t.t.CallDurationInSeconds === undefined){
                //     this.t.t.CallDurationInSeconds = Math.floor((this.endTimeStore - this.startDateTimeStore) / 1000); // In seconds
                // }
                
            }




           

            await saveTask({ t: this.t, latitude: this.latitude, longitude: this.longitude })
                .then(result => {
                    console.log('Apex Result: ', JSON.stringify(result));
                    this.showToast('Success', `Task Created Successfully \n ${result.Subject}`, 'success');
                    this.t = {};
                    this.getTaskWrapper();
                    this.startMeeting();
                    this.isLoading = false;
                })
                .catch(error => {
                    console.log('error: '+JSON.stringify(this.error));
                    console.log('error: '+JSON.stringify(error.body.message));
                    this.showToast('Error', `Something Went Wrong! \n ${error.body.message}`, 'error');
                    this.isLoading = false;
                });

        }

    }


}