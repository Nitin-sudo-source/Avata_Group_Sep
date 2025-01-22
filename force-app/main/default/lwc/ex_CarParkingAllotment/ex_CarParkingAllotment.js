import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getBooking from '@salesforce/apex/Ex_CarParkingAllotment.getBooking';
import getCarPark from '@salesforce/apex/Ex_CarParkingAllotment.getCarPark'; 
import getCarParkRequiredWrapper from '@salesforce/apex/Ex_CarParkingAllotment.getCarParkRequiredWrapper'; 
import updateCarParkwithBooking from '@salesforce/apex/Ex_CarParkingAllotment.updateCarParkwithBooking';

export default class Ex_CarParkingAllotment extends NavigationMixin(LightningElement) {

    @api recordId;
    @api bookingRecord = [];
    @track isError = '';
    @track getCarparkData = [];
    @track carParks = [];
    @track getCPRWrapper = [];
    @track carParkType = [];
    @track carParkid = [];
    @track finalCarParkList = [];
    @track clickedCarParks = [];
    @track selectedCarParks = [];
    @track isSpinner = false;
    @track showSave = false;
    @api  getTypefilter = '';
    @track isfilter = true;
    @track carparkfilterWrapper = [];


    @wire(getBooking, { bookingId: '$recordId' })
    getBookingWired({ error, data }) {
        if (data != null) {
            this.bookingRecord = data;
            //alert('bookingRecord: '+JSON.stringify(this.bookingRecord));
            this.error = undefined;
        } else if (data === null) {
            this.isError = 'Error:  While Fetching Booking Record Please Contact System Administrator';
        }
        this.callGetCarPark();
    }//getCarParkRequiredWrapper

    @wire(getCarParkRequiredWrapper, { booking: '$bookingRecord' })
    getCarParkRequiredWrapperWired({ error, data }) {
        if (data != null) {
            this.getCPRWrapper = data;
            console.log('getCPRWrapper: ' + JSON.stringify(this.getCPRWrapper));
            //this.error = undefined;
        } else if (data === null) {
            this.isError = 'Error: While Fetching Car Park Required Record Please Contact System Administrator';
            this.getCPRWrapper = undefined;
        }
    }

    callGetCarPark(){
        this.isSpinner = true;
        getCarPark({booking: this.bookingRecord , gettype: this.getTypefilter })
        .then(data=>{
            if (data != null) {
                this.carParks = data.map(carPark => ({
                    ...carPark,
                    selected: false,
                }));
                this.isSpinner = false;
               
                    console.log('Car Park Details' + JSON.stringify(this.carParks))
                    const floorMap = new Map();
                    data.forEach(carPark => {
                        if (!floorMap.has(carPark.Floor__c)) {
                            floorMap.set(carPark.Floor__c, {
                                carParks: [],
                                availableCount: 0,
                                bookedCount: 0,
                                // blockedCount: 0,
                            });
                        }
                        floorMap.get(carPark.Floor__c).carParks.push(carPark);
                        if (carPark.Status__c === 'Available') {
                            floorMap.get(carPark.Floor__c).availableCount++;
                        } else if (carPark.Status__c === 'Booked') {
                            floorMap.get(carPark.Floor__c).bookedCount++;
                        }
                    });
                    this.getCarparkData = Array.from(floorMap, ([floor, floorData]) => ({
                        floor,
                        ...floorData,
                    }));
                   // alert('getFilterCarpark: '+ JSON.stringify(this.getCarparkData));
            } else if (data === null) {
                this.isError = 'Error: While Fetching CarPark Please Contact System Administrator ';
                this.getCarparkData = undefined;
            }
        })
    }

    handleCarParkClick(event) {
        const carParkType = event.currentTarget.dataset.carParkType;
        this.carParkType = carParkType;
        this.carParkid = event.currentTarget.dataset.key;
        const carParkNumber = event.currentTarget.dataset.carParkNumber;
        const clickedCarPark = this.carParks.find(carPark => carPark.Name === carParkNumber);
        console.log('clickedCarPark: ' + JSON.stringify(clickedCarPark));
        if (clickedCarPark) {
            clickedCarPark.selected = !clickedCarPark.selected;
            const isCarParkAlreadyClicked = this.clickedCarParks.some(item => item === clickedCarPark);
            if (!isCarParkAlreadyClicked) {
                this.clickedCarParks.push(clickedCarPark);
            }
            const clickedCarParks = this.clickedCarParks.filter(finalItem => finalItem.selected && finalItem.Type__c === carParkType);
            this.getCPRWrapper.forEach(carparkList => {
                const selectedCarpark = clickedCarParks.filter(item => item.Type__c === carparkList.carparktype);
                console.log(carParkType);
                const carparkList1 = this.getCPRWrapper.find(item => item.carparktype === carParkType);
                console.log(JSON.stringify(carparkList1));
                console.log('selectedCarpark.length: ' + selectedCarpark.length);
                if (carparkList1 == undefined) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error!',
                        message: `${carParkType} unavailable for booking.`,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    clickedCarPark.selected = false;
                }
                if (carparkList1.unallotedCount < selectedCarpark.length) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error!',
                        message: `${carparkList.carparktype}: You cannot select more than ${carparkList.unallotedCount} required count!`,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    clickedCarPark.selected = false;
                }
            });
            this.finalCarParkList = this.clickedCarParks.filter(finalItem => finalItem.selected);
            console.log('finalCarParkList : ', JSON.stringify(this.finalCarParkList));
            if (this.finalCarParkList.length != 0) {
                this.showSave = true;
            } else {
                this.showSave = false;
            }
            const element = event.currentTarget;
            if (clickedCarPark.selected) {
                element.classList.remove('unselected');
                element.classList.add('selected');
            } else {
                element.classList.remove('selected');
                element.classList.add('unselected');
            }
        }
    }
    handleFilter(event){
        this.getTypefilter = event.currentTarget.dataset.type;
        const selectedRows = this.template.querySelectorAll('tr');
      //  alert('selectedRows: '+JSON.stringify(selectedRows));
        selectedRows.forEach((element) => {
            element.classList.remove('active');
          });
          event.currentTarget.classList.add('active');
       // alert('rowIndex: '+JSON.stringify(this.getTypefilter));
        this.callGetCarPark();
    }

   

    handleSave() {
        // alert('this.finalCarParkList: '+this.finalCarParkList.length);
        if (this.finalCarParkList.length == 0) {
            const toastEvent = new ShowToastEvent({
                title: 'Error!',
                message: `Please Select Car park`,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        } else {
            this.isSpinner = true;
            updateCarParkwithBooking({ finalCarParkList: this.finalCarParkList, bookingId: this.recordId })
                .then(result => {
                    console.log(result);
                    if (result == true) {
                        const toastEvent = new ShowToastEvent({
                            title: 'Success!',
                            message: ' Record saved successfully.',
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                        window.location.href = '/' + this.recordId;
                    } else {
                        this.isError = 'Error: Something Went Wrong Please Contact System Administrator';
                        this.isSpinner = false;
                        return;
                    }
                },
                );
        }
    }
}