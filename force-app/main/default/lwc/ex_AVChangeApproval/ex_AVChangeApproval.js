/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 08-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, wire, api, track } from 'lwc';
import getCurrentUserDetails from '@salesforce/apex/Ex_UserInfoController.getCurrentUserDetails';
import getBooking from '@salesforce/apex/Ex_UserInfoController.getBooking';
import updateBooking from '@salesforce/apex/Ex_UserInfoController.updateBooking';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Ex_AVChangeApproval extends LightningElement {

    userName;
    profileName;

    @api recordId;
    @track BookingWrapper;
    @track bookingInfo;
    showModal = false;

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    connectedCallback(){
        const urlSearchParams = new URLSearchParams(window.location.search);
        this.recordId = urlSearchParams.get("recordId");
        //this.getCurrentUserDetails();
        this.getBookingInfo();
        this.openModal();
    }

    openModal() {
        this.showModal = true;
    }

    handleYes() {
        this.showModal = false;
        console.log('User clicked YES');
        this.callBookingApprovalProcess();
        // Add your YES logic here
    }

    callBookingApprovalProcess(){
        updateBooking({recordId: this.recordId, profileName: this.profileName})
        .then(result => {
            console.log(result);
            this.BookingWrapper = result;
            console.log('BookingWrapper: '+JSON.stringify(this.BookingWrapper));
            if(this.BookingWrapper.success){
                this.showToast('Success', this.BookingWrapper.message, 'success');
                setTimeout(() => {
                    location.replace('/' + this.bookingInfo.Id);
                }, 3000); // 3000 milliseconds = 3 seconds

            }else{
                this.showToast('Info', this.BookingWrapper.message, 'Info');
                return ;
            }
            
        })
        .catch(error => {
            console.error(error);
            return ;
            // TODO Error handling
        });

    }

    handleNo() {
        this.showModal = false;
        //console.log('User clicked NO');
        location.replace('/' + this.bookingInfo.Id);

        // Add your NO logic here
    }

    getBookingInfo(){
        getBooking({recordId: this.recordId})
        .then(result => {
            console.log(result);
            this.bookingInfo = result;
            
        })
        .catch(error => {
            console.error(error);
            // TODO Error handling
        });

    }

    

    @wire(getCurrentUserDetails)
    wiredUserDetails({ error, data }) {
        if (data) {
            this.userName = data.userName;
            this.profileName = data.profileName;
            console.log('userName: ' + this.userName);
            console.log('profileName: ' + this.profileName);
        } else if (error) {
            console.error('Error fetching user details', error);
            this.showToast('Error', error, 'error');

        }
    }

}