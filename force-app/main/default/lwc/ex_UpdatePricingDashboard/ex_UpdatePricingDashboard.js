import { LightningElement, api, wire, track } from 'lwc';
import getAVDetails from '@salesforce/apex/Ex_UpdateAVDetails.getAVDetails'; //updateAVChangeDetails
// import updateAVChangeDetails from '@salesforce/apex/Ex_UpdateAVDetails.updateAVChangeDetails';
import saveAV from '@salesforce/apex/Ex_UpdateAVDetails.saveAV';
import getPriceListMapDetails from '@salesforce/apex/Ex_UpdateAVDetails.getPriceListMapDetails';
import getPriceListGroupMapDetails from '@salesforce/apex/Ex_UpdateAVDetails.getPriceListGroupMapDetails';
import getAllPriceMapDetails from '@salesforce/apex/Ex_UpdateAVDetails.getAllPriceMapDetails';
import getAllPriceInfoFormattedMap from '@salesforce/apex/Ex_UpdateAVDetails.getAllPriceInfoFormattedMap';
import getBookingInfo from '@salesforce/apex/Ex_UpdateAVDetails.getBookingInfo';
import getModifiedPaymentScheduleDetails from '@salesforce/apex/Ex_UpdateAVDetails.getModifiedPaymentScheduleDetails';
import getPaymentScheduleDetails from '@salesforce/apex/Ex_UpdateAVDetails.getPaymentScheduleDetails';
import getPicklistValues from '@salesforce/apex/Ex_GenerateQuotation.getPicklistValues';





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
    @track showPaymentScheduleData = false;
    @track isShowButtonVisiable = true;
    @track paymentMilestoneWrapperList = [];
    @track updatedPaymentMilestoneWrapperList = [];
    @track milestoneType = [];
    @track amountType = [];
    @track isPaymentScheduleEnable = false;
    @track editPaymentScheduleMode = false;
    @track isPaymentScheduleUpdated = false;
    @track discountVisibleCheckbox = false;
    @track actionType = '';
    @track rowIndex = null;
    @track agSeqNumber = 0;
    @track isValidationError = false;
    @track getTotal = 0;





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
            this.getMilestoneType();
            this.getAmountType();
            // this.showPaymentSchedule();
            // if (!this.isPaymentScheduleEnable) {
            //     this.isPaymentScheduleEnable = true;

            // }
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
            this.getUpdatedValue = 0; // Or handle the error as needed
        }
    }



    // handleUpdatedAv(event) {
    //     this.getUpdatedValue = event.detail.value;
    //     // this.avDetails.getAvvalue = this.getUpdatedValue;
    //     //event.detail.value = this.avDetails.getAvvalue;
    //     console.log('You selected an handleUpdatedAv: ' + this.getUpdatedValue);


    // }

    // handleUpdatedAv(event) {
    //     const value = event.target.value;
    //     const decimalValue = parseFloat(value); // Converts the input to a float

    //     if (!isNaN(decimalValue)) {
    //         this.getUpdatedStampValue = decimalValue; 
    //         this.isQuotationModified = true;
    //         this.handlemodified();
    //     } else {
    //         this.getUpdatedStampValue = 0; // Or handle the error as needed
    //     }
    // }


    handleUpdatedGST(event) {
        this.getUpdatedGST = event.detail.value;
        // if(!this.isQuotationModified)
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
                    await this.getAllPriceFormattedMap();
                    //await this.getPaymentSchedule();
                   
                }
            } catch (error) {
                console.log('error: ' + JSON.stringify(error));
                console.error('Error In getAllPriceMap: ', error);
            }
        } else {
            console.warn('priceListGroupMap or priceListMap is null. getAllPriceMap() will not be called.');
        }
    }


    async getAllPriceFormattedMap() {
        await getAllPriceInfoFormattedMap({ allPriceInfoMap: this.allPriceInfoMap })
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

    async getPaymentSchedule() {
        this.paymentMilestoneWrapperList = [];
        this.updatedPaymentMilestoneWrapperList = [];

        await getPaymentScheduleDetails({ uId: this.booking.Unit__c, qId: this.booking.Quotation__c, allPriceInfoMap: this.allPriceInfoMap, priceListMap: this.priceListMap })
            .then(data => {
                if (data) {
                    console.log('paymentMilestoneWrapperList: ' + JSON.stringify(data));
                    this.updatedPaymentMilestoneWrapperList = data;
                    console.log('updatedPaymentMilestoneWrapperListOrginal: ' + JSON.stringify(this.updatedPaymentMilestoneWrapperList));


                    // if(isNaN(data)){
                    //     return ;
                    // }

                    data.forEach(element => {
                        if (element) {
                            if (element.isTotal) {
                                this.paymentMilestoneWrapperList.push({
                                    ...element
                                });
                            } else {
                                var csList = [];
                                if (element.constructionStageList) {
                                    element.constructionStageList.forEach(cs => {
                                        if (cs) {
                                            csList.push({ label: cs.Name, value: cs.Id });
                                        }
                                    });
                                }

                                this.paymentMilestoneWrapperList.push({
                                    ...element,
                                    milestoneType: this.milestoneType,
                                    isConStructionLinked: element.pm && element.pm.Milestone_Type__c === 'Construction Linked',
                                    csListDisplay: csList,
                                    amountType: this.amountType,
                                    isAmount: element.pm && element.pm.Charge_Bucket_1_Type__c === 'Amount',
                                    isPercentage: element.pm && element.pm.Charge_Bucket_1_Type__c === 'Percentage'
                                });
                            }
                        } else {
                            console.warn('Null or undefined element encountered in data:', +JSON.stringify(data));
                        }
                    });
                 //   if(!isNaN(data)){
                        this.updatedPaymentMilestoneWrapperList = data;
                  //  }

                    

                    for (let i = 1; i <= 5; i++) {
                        if (this.updatedPaymentMilestoneWrapperList[0] && this.updatedPaymentMilestoneWrapperList[0].pm) {
                            if (this.updatedPaymentMilestoneWrapperList[0].pm["Charge_Bucket_" + i + "__c"] !== "") {
                                if (this.updatedPaymentMilestoneWrapperList[0].pm["Charge_Bucket_" + i + "__c"] === 'Agreement Value') {
                                    this.agSeqNumber = i;
                                    break;
                                }
                            }
                        }
                    }

                   // this.updatePaymentSchedule();
                    this.handlevalidation();
                    this.isSpinner = false;
                    console.log('updatedPaymentMilestoneWrapperList:', +JSON.stringify(this.updatedPaymentMilestoneWrapperList));
                    console.log('updatedPaymentMilestoneWrapperList Size:', +this.updatedPaymentMilestoneWrapperList.length);
                   
                } else {
                    console.error('Error: Data is undefined');
                }
            })
            .catch(error => {
                console.log('error: '+JSON.stringify(error));
                //console.error('Error In getPaymentSchedule: ', error);
            });
    }

    getMilestoneType() {
        getPicklistValues({ objectName: 'Payment_Milestone__c', picklistField: 'Milestone_Type__c' })
            .then(data => {
                if (data) {
                    console.log('dataPM: ' + JSON.stringify(data));
                    data.forEach(element => {
                        this.milestoneType.push({ label: element, value: element });
                    })
                } else if (error) {
                    console.error('Error In getMilestoneType: ', error);
                }
            })
    }
    showErrorMessage(type, message) {
        if (type === 'Error') {
            this.isValidationError = true;
        }
        if(type === 'success'){
            this.isValidationError = false;
        }
        this.isSpinner = false;
        this.template.querySelector('c-custom-toast').showToast(type, message, 'utility:warning', 10000);
    }

    getAmountType() {
        getPicklistValues({ objectName: 'Payment_Milestone__c', picklistField: 'Charge_Bucket_1_Type__c' })
            .then(data => {
                if (data) {
                    console.log('datapm: ' + JSON.stringify(data));
                    data.forEach(element => {
                        this.amountType.push({ label: element, value: element });
                    })
                } else if (error) {
                    console.error('Error In getAmountType: ', error);
                }
            })
    }


    handleChange(event) {
        this.isSpinner = true;
        var index = parseInt(event.target.dataset.index);
        console.log('index: ' + index);
        var eventName = event.currentTarget.name;
        console.log('name: ' + eventName);

        if (eventName === 'milestoneName') {
            var value = event.target.value;
            console.log('value: ' + value);

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index], [eventName]: value };
            newObj.pm.Milestone_Name__c = value;
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index] = newObj;
            console.log('milestoneName 1: ' + this.updatedPaymentMilestoneWrapperList[index].milestoneName);
            console.log('Milestone_Name__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Milestone_Name__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index], [eventName]: value };
            pmObj.pm.Milestone_Name__c = value;
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index] = pmObj;
            console.log('milestoneName 2: ' + this.paymentMilestoneWrapperList[index].milestoneName);
            console.log('Milestone_Name__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Milestone_Name__c);
            this.isSpinner = false;
        } else if (eventName === 'Number_of_Days__c') {
            var value = parseInt(event.target.value);
            console.log('value: ' + value);

            if (isNaN(value)) {
                value = 0;
            }

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].pm = newObj;
            console.log('Number_of_Days__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Number_of_Days__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].pm = pmObj;
            console.log('Number_of_Days__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Number_of_Days__c);
            this.isSpinner = false;
        } else if (eventName === 'Milestone_Type__c') {
            var value = event.target.value;
            console.log('value: ' + value);

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].pm = newObj;
            console.log('Milestone_Type__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Milestone_Type__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].pm = pmObj;
            console.log('Milestone_Type__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Milestone_Type__c);
            if (value === 'Construction Linked') {
                this.paymentMilestoneWrapperList[index].isConStructionLinked = true;
                this.updatedPaymentMilestoneWrapperList[index].pm.Construction_Stage__c = null;
            } else {
                this.paymentMilestoneWrapperList[index].isConStructionLinked = false;
                this.updatedPaymentMilestoneWrapperList[index].pm.Construction_Stage__c = null;
            }
            this.isSpinner = false;
        } else if (eventName === 'Construction_Stage__c') {
            var value = event.target.value;
            console.log('value: ' + value);

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].pm = newObj;
            console.log('Construction_Stage__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Construction_Stage__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].pm = pmObj;
            console.log('Construction_Stage__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Construction_Stage__c);
            this.isSpinner = false;
        } else if (eventName === 'Charge_Bucket_1_Type__c') {
            var value = event.target.value;
            console.log('value: ' + value);

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].pm = newObj;
            console.log('Charge_Bucket_1_Type__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Charge_Bucket_1_Type__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].pm = pmObj;
            console.log('Charge_Bucket_1_Type__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Charge_Bucket_1_Type__c);
            if (value === 'Amount') {
                this.paymentMilestoneWrapperList[index].isPercentage = false;
                this.paymentMilestoneWrapperList[index].isAmount = true;
            } else if (value === 'Percentage') {
                this.paymentMilestoneWrapperList[index].isPercentage = true;
                this.paymentMilestoneWrapperList[index].isAmount = false;
            }
            this.isSpinner = false;
        } else if (eventName === 'Charge_Bucket_1_Percentage__c') {
            var value = parseFloat(event.target.value);
            console.log('value: ' + value);

            if (isNaN(value)) {
                value = null;
            }

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].pm = newObj;
            console.log('Charge_Bucket_1_Percentage__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Charge_Bucket_1_Percentage__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].pm = pmObj;
            console.log('Charge_Bucket_1_Percentage__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Charge_Bucket_1_Percentage__c);
            this.isSpinner = false;
        } else if (eventName === 'Charge_Bucket_1_Amount__c') {
            var value = parseFloat(event.target.value);
            console.log('value: ' + value);

            if (isNaN(value)) {
                value = null;
            }

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].pm = newObj;
            console.log('Charge_Bucket_1_Amount__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].pm.Charge_Bucket_1_Amount__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].pm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].pm = pmObj;
            console.log('Charge_Bucket_1_Amount__c 2: ' + this.paymentMilestoneWrapperList[index].pm.Charge_Bucket_1_Amount__c);
            this.isSpinner = false;
        } else if (eventName === 'add') {
            this.actionType = 'Add';
            this.rowIndex = index;
            this.getModifiedPaymentSchedule();
        } else if (eventName === 'remove') {
            this.actionType = 'Remove';
            this.rowIndex = index;
            this.getModifiedPaymentSchedule();
        }
    }

    getModifiedPaymentSchedule() {
        console.log('agSeqNumber: ' + this.agSeqNumber);
        getModifiedPaymentScheduleDetails({ actionType: this.actionType, rowIndex: this.rowIndex, paymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList, u: this.booking, agSeqNumber: this.agSeqNumber })
            .then(data => {
                if (data) {
                    this.isPaymentScheduleUpdated = true;
                    this.paymentMilestoneWrapperList = [];
                    this.updatedPaymentMilestoneWrapperList = [];
                    console.log('paymentMilestoneWrapperList: ' + JSON.stringify(data));

                    data.forEach(element => {
                        if (element.isTotal) {
                            this.paymentMilestoneWrapperList.push({
                                ...element
                            });
                        } else {
                            var csList = [];
                            element.constructionStageList.forEach(cs => {
                                csList.push({ label: cs.Name, value: cs.Id });
                            })

                            this.paymentMilestoneWrapperList.push({
                                ...element,
                                milestoneType: this.milestoneType,
                                isConStructionLinked: element.pm.Milestone_Type__c === 'Construction Linked',
                                csListDisplay: csList,
                                amountType: this.amountType,
                                isAmount: element.pm.Charge_Bucket_1_Type__c === 'Amount',
                                isPercentage: element.pm.Charge_Bucket_1_Type__c === 'Percentage'
                            });
                        }
                    })
                    this.updatedPaymentMilestoneWrapperList = data;
                    this.isSpinner = false;
                    console.log('updatedPaymentMilestoneWrapperList: ' + JSON.stringify(this.updatedPaymentMilestoneWrapperList));
                    console.log('updatedPaymentMilestoneWrapperList Size : ' + this.updatedPaymentMilestoneWrapperList.length);
                } else if (error) {
                    console.error('Error In getModifiedPaymentSchedule: ', error);
                }
            })
    }


    showPaymentSchedule() {
        this.showPaymentScheduleData = true;
        this.isShowButtonVisiable = false;
        this.isPaymentScheduleEnable = true;
        this.getPaymentSchedule();

    }

    editPaymentSchedule() {
        this.editPaymentScheduleMode = true;
    }

     updatePaymentSchedule() {
        console.log('check: '+ JSON.stringify(this.updatedPaymentMilestoneWrapperList));
        this.isSpinner = true;
        this.isValidationError = false;
        const validationErrorList = [];
        let errorCount = 0;
        let rowCount = 1;

        for (let i = 0; i < this.updatedPaymentMilestoneWrapperList.length; i++) {
            if (!this.updatedPaymentMilestoneWrapperList[i].isTotal) {
                if (this.updatedPaymentMilestoneWrapperList[i].milestoneName === "" || this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Name__c === "") {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Name.');
                }
                if (this.updatedPaymentMilestoneWrapperList[i].pm.Number_of_Days__c === null) {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide No of Days.');
                }
                if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c === "") {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Type.');
                } else if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c !== "" && this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c === 'Construction Linked') {
                    if (this.updatedPaymentMilestoneWrapperList[i].pm.Construction_Stage__c === null) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Valid Construction Stage.');
                    }
                }
                if (this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === "") {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Amount Type.');
                } else {
                    if (this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === 'Percentage' && this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Percentage__c"] === null) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Percentage.');
                    } else if (this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === 'Amount' && this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Amount__c"] === null) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Amount.');
                    }
                }
            }
            rowCount++;
        }
        console.log('validationErrorList-1: ' + validationErrorList);

        if (validationErrorList.length === 0) {
            validateUpdatedPaymentScheduleDetails({ agSeqNumber: this.agSeqNumber, allPriceInfoMap: this.allPriceInfoMap, updatedPaymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList })
                .then(data => {
                    console.log('validationData: ' + data);
                    if (data != null) {
                        for (let i = 0; i < data.length; i++) {
                            validationErrorList.push(data[i]);
                        }
                        console.log('validationErrorList-2: ' + validationErrorList);

                        if (validationErrorList.length === 0) {
                            this.getUpdatedPaymentSchedule();
                        } else {
                            var errorMessage = '';
                            for (let i = 0; i < validationErrorList.length; i++) {
                                errorMessage += validationErrorList[i] + '\n';
                            }
                            console.log('errorMessage: ' + errorMessage);
                            this.showErrorMessage('Error', errorMessage);
                            this.isSpinner = false;
                        }
                        } else if (error) {
                            console.log('error: '+JSON.stringify(error));
                            console.error('Error In validatePaymentSchedule: ', error);
                    } 
                })
        } else {
            var errorMessage = '';
            for (let i = 0; i < validationErrorList.length; i++) {
                errorMessage += validationErrorList[i] + '\n';
            }
            console.log('errorMessage: ' + errorMessage);
            this.showErrorMessage('Error', errorMessage);
            this.isSpinner = false;
        }
    }

    handlevalidation() {
        //alert('callHandleValidation')
        this.isSpinner = true;
        const validationErrorList = [];
        this.getTotal = 0;
        let errorCount = 0;
        let rowCount = 1;
        console.log('updatedPaymentMilestoneWrapperList ANY Change: ' + JSON.stringify(this.updatedPaymentMilestoneWrapperList));
       // alert('Length: ' + JSON.stringify(this.updatedPaymentMilestoneWrapperList.length));
    
        for (let i = 0; i < this.updatedPaymentMilestoneWrapperList.length; i++) {
                console.log('isTotal: '+JSON.stringify(this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Percentage__c));
                this.getTotal += this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Percentage__c; 
                console.log('getTotal : '+JSON.stringify(this.getTotal));
                console.log('check: '+JSON.stringify(this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Name__c));
                if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Name__c === "" || this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Name__c == undefined) {
                    errorCount++;
                    console.log('errorCount: '+JSON.stringify(errorCount));
                    console.log('rowCount: '+JSON.stringify(rowCount));
                    validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Milestone Name.');
                }
                if (this.updatedPaymentMilestoneWrapperList[i].pm.Number_of_Days__c === null) {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide No of Days.');
                }
                // if (this.updatedPaymentMilestoneWrapperList[i].pm.Deduct_Token__c === true && (this.updatedPaymentMilestoneWrapperList[i].pm.Token_Amount__c === 0 || this.updatedPaymentMilestoneWrapperList[i].pm.Token_Amount__c === "")) {
                //     errorCount++;
                //     console.log('errorCount: '+JSON.stringify(errorCount));
                //     console.log('rowCount: '+JSON.stringify(rowCount));
                //     validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Token Amount.');
                // }
                if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c === "") {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Milestone Type.');
                } else if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c !== "" && this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c === 'Construction Linked') {
                    if (this.updatedPaymentMilestoneWrapperList[i].pm.Construction_Stage__c === null) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Valid Construction Stage.');
                    }
                }
                if (this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Type__c === "") {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Amount Type.');
                } else {
                    if (this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Type__c === 'Percentage' && (this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Percentage__c === null)) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Milestone Percentage.');
                    } else if (this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Type__c === 'Amount' && (this.updatedPaymentMilestoneWrapperList[i].pm.Charge_Bucket_1_Amount__c === null )) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ' : On Row - ' + rowCount + '- Please Provide Milestone Amount.');
                    }
                }
            rowCount++;
        }
        console.log('getTotalAfterLoop: '+JSON.stringify(this.getTotal));

        if(parseFloat(this.getTotal) != parseFloat(100)){
            validationErrorList.push('Error ' +' Please check SUM of All percentage should be equal to 100 %');
        }
        alert('validationErrorList-1: ' + validationErrorList);
       
        if(validationErrorList == [] || validationErrorList.length === 0){
            this.getPaymentSchedule();
        }else{
            alert(validationErrorList.join("\n")); 
            this.isSpinner = false;
            return ;
            
        }     
    }

    getUpdatedPaymentSchedule() {
        getUpdatedPaymentScheduleDetails({ u: this.booking, agSeqNumber: this.agSeqNumber, priceListMap: this.priceListMap, allPriceInfoMap: this.allPriceInfoMap, updatedPaymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList })
            .then(data => {
                if (data) {
                    this.isPaymentScheduleUpdated = true;
                    this.paymentMilestoneWrapperList = [];
                    this.updatedPaymentMilestoneWrapperList = [];
                    console.log('data: ' + JSON.stringify(data));

                    data.forEach(element => {
                        if (element.isTotal) {
                            this.paymentMilestoneWrapperList.push({
                                ...element
                            });
                        } else {
                            var csList = [];
                            element.constructionStageList.forEach(cs => {
                                csList.push({ label: cs.Name, value: cs.Id });
                            })

                            this.paymentMilestoneWrapperList.push({
                                ...element,
                                milestoneType: this.milestoneType,
                                isConStructionLinked: element.pm.Milestone_Type__c === 'Construction Linked',
                                csListDisplay: csList,
                                amountType: this.amountType,
                                isAmount: element.pm.Charge_Bucket_1_Type__c === 'Amount',
                                isPercentage: element.pm.Charge_Bucket_1_Type__c === 'Percentage'
                            });
                        }
                    })
                    this.updatedPaymentMilestoneWrapperList = data;
                    //this.getCalculatedNPV();
                    this.isSpinner = false;
                } else if (error) {
                    console.error('Error In getUpdatedPaymentSchedule: ', error);
                }
            })
    }

    confirmPaymentSchedule() {
        this.editPaymentScheduleMode = false;
    }

    cancelPaymentSchedule() {
        this.isSpinner = true;
        this.getPaymentSchedule();
        this.editPaymentScheduleMode = false;
        this.isValidationError = false;
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
                allPriceOriginalInfoMap: this.allPriceOriginalInfoMap, allPriceInfoMap: this.allPriceInfoMap,
                paymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList
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