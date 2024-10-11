import { LightningElement, api, wire, track } from 'lwc';
import getAVDetails from '@salesforce/apex/Ex_UpdateAVDetails.getAVDetails'; //updateAVChangeDetails
import updateAVChangeDetails from '@salesforce/apex/Ex_UpdateAVDetails.updateAVChangeDetails';
import saveAV from '@salesforce/apex/Ex_UpdateAVDetails.saveAV';
import getPriceListMapDetails from '@salesforce/apex/Ex_UpdateAVDetails.getPriceListMapDetails';
import getPriceListGroupMapDetails from '@salesforce/apex/Ex_UpdateAVDetails.getPriceListGroupMapDetails';
import getAllPriceMapDetails from '@salesforce/apex/Ex_UpdateAVDetails.getAllPriceMapDetails';
import getAllPriceInfoFormattedMap from '@salesforce/apex/Ex_UpdateAVDetails.getAllPriceInfoFormattedMap';
import getBookingInfo from '@salesforce/apex/Ex_UpdateAVDetails.getBookingInfo';




import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Ex_UpdatePricingDashboard extends LightningElement {


    @api recordId;
    @track avDetails = [];
    @track isErrormsg = '';
    @track isError = false;
    @track getUpdatedValue;
    @track getUpdatedStampValue;
    @track getUpdatedGST;
    @track getRemarks;
    @track getModifiedData = [];

    @track allPriceInfoMap = [];
    @track allPriceOriginalInfoFormattedMap = [];
    @track allPriceInfoFormattedMap = [];
    @track allPriceDetailMap = []; //For Display Use
    @track isQuotationModified = false;
    @track allPriceOriginalInfoMap = [];

    @track priceListMap = [];
    @track priceListGroupMap = [];
    @track booking;

    @track totalCarParkAmount = 0;
    @track totalDiscountAmount = 0;

    @track isLoaded = false;




    @wire(getAVDetails, { recordId: '$recordId' })
    getAVDetails({ error, data }) {
        if (data) {
            this.avDetails = data;
            console.log('getAVDetails : ' + JSON.stringify(this.avDetails))
        } else if (error) {
            this.error = error;
        } else if (this.avDetails == undefined) {
            this.isError = true;
            this.isErrormsg = 'Something Went Wrong Please Contact System Administrator';
        }
    }

    connectedCallback() {
        const urlSearchParams = new URLSearchParams(window.location.search);
        this.recordId = urlSearchParams.get("recordId");
        if (this.recordId) {
            this.getBookingInfo();
        }
    }

    async getBookingInfo() {
        await getBookingInfo({ recordId: this.recordId })
            .then(data => {
                console.log('getBookingInfo: ' + JSON.stringify(data));
                if (data) {
                    this.booking = data;
                }
                console.log('getBookingInfo: ' + JSON.stringify(this.booking));

            })
        await this.getPriceListMap();
        await this.getPriceListGroupMap();
        await this.getAllPriceMap();

    }

    renderedCallback() {
        if (this.isLoaded)
            return;
        const STYLE = document.createElement("style");
        STYLE.innerText = `.uiModal--medium .modal-container{
width: 100% !important;
max-width: 95%;
min-width: 480px;
max-height:100%;
min-height:480px;
};`
        this.template.querySelector('lightning-card').appendChild(STYLE);
        this.isLoaded = true;
    }

    handleUpdatedAv(event) {
        const value = event.target.value;
        const decimalValue = parseFloat(value); // Converts the input to a float
    
        if (!isNaN(decimalValue)) {
            this.getUpdatedValue = decimalValue; 
            this.isQuotationModified = true;
            this.handlemodified();
        } else {
            this.updatedAV = 0; // Or handle the error as needed
        }
    }
    


    // handleUpdatedAv(event) {
    //     this.getUpdatedValue = event.detail.value;
    //     // this.avDetails.getAvvalue = this.getUpdatedValue;
    //     //event.detail.value = this.avDetails.getAvvalue;
    //     console.log('You selected an handleUpdatedAv: ' + this.getUpdatedValue);
       
        
    // }

    handleUpdatedAv(event) {
        const value = event.target.value;
        const decimalValue = parseFloat(value); // Converts the input to a float
    
        if (!isNaN(decimalValue)) {
            this.getUpdatedStampValue = decimalValue; 
            this.isQuotationModified = true;
            this.handlemodified();
        } else {
            this.getUpdatedStampValue = 0; // Or handle the error as needed
        }
    }

   
    handleUpdatedGST(event) {
        this.getUpdatedGST = event.detail.value;
       // this.isQuotationModified = true;
        // this.avDetails.getTaxalue = this.getUpdatedGST;
        console.log('You selected an handleUpdatedAv: ' + this.getUpdatedGST);
        this.handlemodified();
    }
    handleRemarks(event) {
        this.getRemarks = event.detail.value;
        console.log('You selected an getRemarks: ' + this.getRemarks);
    }

    handlemodified() {
        //this.isQuotationModified = true;
        this.getAllPriceMap();
        /* updateAVChangeDetails({ recordId: this.recordId, updatedAVvalue: this.getUpdatedValue, getUpdatedStampValue: this.getUpdatedStampValue, getUpdatedGST: this.getUpdatedGST })
             .then((result) => {
                 console.log('result: ' + JSON.stringify(result));
                 if (result) {
                     this.getModifiedData = result;
                     if (this.getModifiedData.errorMsg !== null && this.getModifiedData.errorMsg !== '') {
                         this.isError = true;
                         this.isErrormsg = 'Please Check the default value for Stamp Duty & GST value on ' + this.avDetails.bookingName + ' OR Please Contact System Administrator';
                     } else {
                         this.getModifiedData = result;
                     }
                 }
             })
             .catch((error) => {
                 this.error = error;
             });*/
    }

    async getPriceListGroupMap() {
        await getPriceListGroupMapDetails({ uId: this.booking.Quotation__c })
            .then(data => {
                console.log('getPriceListGroupMap: ' + JSON.stringify(data));
                if (data) {
                    this.priceListGroupMap = data;
                }
                console.log('priceListGroupMap: ' + JSON.stringify(this.priceListGroupMap));
            })
    }

    async getPriceListMap() {
        //alert('this.booking.Unit__c: ' + this.booking.Quotation__c);
        await getPriceListMapDetails({ uId: this.booking.Quotation__c })
            .then(data => {
                if (data) {
                    console.log('priceListMap: ' + JSON.stringify(data));
                    /*var conts = data;
                    for(var key in data) {
                        this.priceListMap.push({value:conts[key], key:key});
                    }*/
                    this.priceListMap = data;
                }
            })
    }

    async getAllPriceMap() {
        // Check if both arrays are not null before proceeding
        if (this.priceListGroupMap && this.priceListMap) {
            console.log('this.priceListGroupMap: ' + JSON.stringify(this.priceListGroupMap));
            console.log('priceListMap ' + JSON.stringify(this.priceListMap));

            try {
                const data = await getAllPriceMapDetails({
                    uId: this.booking.Quotation__c,
                    updatedAV: this.getUpdatedValue,
                    updatedSDR: this.getUpdatedStampValue,
                    updatedGST: this.getUpdatedGST,
                    priceListGroupMap: this.priceListGroupMap,
                    priceListMap: this.priceListMap,
                    carParkAmount: this.totalCarParkAmount,
                    discountAmount: this.totalDiscountAmount
                });

                if (data) {
                    console.log('allPriceInfoMap: ' + JSON.stringify(data));
                    if (!this.isQuotationModified) {
                        this.allPriceOriginalInfoMap = data;
                        this.allPriceInfoMap = data;
                    } else {
                        this.allPriceInfoMap = data;
                    }
                    this.getAllPriceFormattedMap();
                    //this.getPaymentSchedule();
                }
            } catch (error) {
                console.log('error: ' + JSON.stringify(error));
                console.error('Error In getAllPriceMap: ', error);
            }
        } else {
            console.warn('priceListGroupMap or priceListMap is null. getAllPriceMap() will not be called.');
        }
    }


    getAllPriceFormattedMap() {
        getAllPriceInfoFormattedMap({ allPriceInfoMap: this.allPriceInfoMap })
            .then(data => {
                if (data) {
                    console.log('allPriceOriginalInfoFormattedMap: ' + JSON.stringify(data));
                    if (!this.isQuotationModified) {
                        this.allPriceOriginalInfoFormattedMap = data;
                        this.allPriceInfoFormattedMap = data;
                    } else {
                        this.allPriceInfoFormattedMap = data;
                    }

                    this.allPriceDetailMap = [];
                    for (let chargeBucket in this.priceListGroupMap) {
                        //console.log('chargeBucket: '+chargeBucket);

                        const chargeList = this.priceListGroupMap[chargeBucket];

                        console.log('chargeList: ' + chargeList);

                        var chargeValues = [];
                        // var getAllInPrice = [];
                        chargeList.forEach(element => {
                            console.log('element: ' + element);

                            var isChange;
                            if (this.allPriceOriginalInfoFormattedMap[element] !== this.allPriceInfoFormattedMap[element]) {
                                isChange = true;
                            } else {
                                isChange = false;
                            }
                            chargeValues.push({
                                chargeName: element,
                                originalAmountString: this.allPriceOriginalInfoFormattedMap[element],
                                originalTaxString: this.allPriceOriginalInfoFormattedMap[element + ' TAX'],
                                modifiedAmountString: this.allPriceInfoFormattedMap[element],
                                modifiedTaxString: this.allPriceInfoFormattedMap[element + ' TAX'],
                                isChange: isChange,
                                isTotal: false
                            });
                            console.log('chargeValues: ' + JSON.stringify(chargeValues));
                            // getAllInPrice.push({
                            //     'All In Price': this.allPriceInfoFormattedMap[element] + this.allPriceInfoFormattedMap[element + ' TAX']
                            // })
                        });

                        var isChange;
                        if (this.allPriceOriginalInfoFormattedMap[chargeBucket] !== this.allPriceInfoFormattedMap[chargeBucket]) {
                            isChange = true;
                        } else {
                            isChange = false;
                        }
                        chargeValues.push({
                            chargeName: 'Total',
                            originalAmountString: this.allPriceOriginalInfoFormattedMap[chargeBucket],
                            originalTaxString: this.allPriceOriginalInfoFormattedMap[chargeBucket + ' TAX'],
                            modifiedAmountString: this.allPriceInfoFormattedMap[chargeBucket],
                            modifiedTaxString: this.allPriceInfoFormattedMap[chargeBucket + ' TAX'],
                            isChange: isChange,
                            isTotal: true
                        });
                        console.log('chargeValues: ' + JSON.stringify(chargeValues));

                        if (chargeBucket !== 'Other Charges') {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: false });
                        } else {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: true });
                        }

                        //this.showAllIn.push(getAllInPrice);
                        //console.log('All: '+JSON.stringify(this.showAllIn));
                    }
                    //this.totalCarParkAmountString = this.allPriceInfoFormattedMap['Total Car Park Price'];
                    //this.totalDiscountAmountString = this.allPriceInfoFormattedMap['Total Discount Price'];
                    console.log('allPriceDetailMap: ' + JSON.stringify(this.allPriceDetailMap));
                } else if (error) {
                    console.error('Error In getAllPriceFormattedMap: ', error);
                }
            })
    }

    handleSave() {
        if (this.getRemarks == undefined) {
            this.showToast('Error', 'Please Enter Remarks', 'error', 'dismissible');
            // }if(!this.getUpdatedStampValue){
            //     this.showToast('Error', 'Please Enter Valid Stamp Duty', 'error', 'dismissible');
            // }if(!this.getUpdatedGST){
            //     this.showToast('Error', 'Please Enter Valid GST %', 'error', 'dismissible');
        } else {
            saveAV({
                recordId: this.recordId, updatedAVvalue: this.getModifiedData.getAvvalue,
                gstValue: this.getUpdatedGST, stampValue: this.getUpdatedStampValue,
                remarks: this.getRemarks, priceListGroupMap: this.priceListGroupMap, priceListMap: this.priceListMap, 
                allPriceOriginalInfoMap: this.allPriceOriginalInfoMap, allPriceInfoMap: this.allPriceInfoMap
            })
                .then((result) => {
                    console.log('result: ' + result);
                    if (result == true) {
                        this.showToast('success', 'AV Changes Successfully', 'success', 'dismissible');
                        window.location.href = '/' + this.recordId;
                    } else {
                        this.showToast('Error', 'Something Went Wrong Please Contact System Administrator', 'error', 'sticky');
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
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