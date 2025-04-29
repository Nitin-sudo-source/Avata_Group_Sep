/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
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
import updatedgetPaymentScheduleDetails from '@salesforce/apex/Ex_UpdateAVDetails.updatedgetPaymentScheduleDetails';
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
    @track isValidationError = false;
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
    @track showPaymentScheduleData = true;
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
    @track agSeqNumber = 1;
    @track isValidationError = false;
    @track getTotal = 0;
    @track showCalculate = true;
    @track isOrginal = false;
    @track allPriceModifiedInfoMap = [];
    @track isSpinner = false;


    @wire(getAVDetails, { recordId: '$recordId' })
    getAVDetails({ error, data }) {
        if (data) {
            this.avDetails = data;
            //console.log('getAVDetails : ' + JSON.stringify(this.avDetails))
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
        // alert('recordId: '+this.recordId);
        if (this.recordId) {
            this.isSpinner = true;
            this.getBookingInfo();
            this.getMilestoneType();
            this.getAmountType();
           
        }
       else{
        this.isSpinner = false;
       } 
    }

    async getBookingInfo() {
        await getBookingInfo({ recordId: this.recordId })
            .then(data => {
                //console.log('getBookingInfo: ' + JSON.stringify(data));
                if (data) {
                    this.booking = data;
                }
                //console.log('getBookingInfo: ' + JSON.stringify(this.booking));

            })
        await this.getPriceListMap();
        await this.getPriceListGroupMap();
        await this.getAllPriceMap();
        this.showPaymentSchedule();
    }

    handleUpdatedAv(event) {
        const value = event.target.value;
        const decimalValue = parseFloat(value); 
        console.log('decimalValue' + decimalValue);// Converts the input to a float

        if (!isNaN(decimalValue)) {
            this.getUpdatedValue = decimalValue;
            this.isQuotationModified = true;
            this.showCalculate = true;
        } else {
            this.getUpdatedValue = 0; 
        }
    }

    handlecalculateValues(){
        this.isSpinner = true;
        this.getAllPriceMap();
        this.isQuotationModified = false;        
    }


    handleRemarks(event) {
        this.getRemarks = event.detail.value;
        console.log('You selected an getRemarks: ' + this.getRemarks);
        this.showErrorMessage('Warning', this.getRemarks);

    }

    async getPriceListGroupMap() {
        await getPriceListGroupMapDetails({ uId: this.booking.Quotation__c })
            .then(data => {
                //console.log('getPriceListGroupMap: ' + JSON.stringify(data));
                if (data) {
                    this.priceListGroupMap = data;
                }
                //console.log('priceListGroupMap: ' + JSON.stringify(this.priceListGroupMap));
            })
    }

    async getPriceListMap() {
        //alert('this.booking.Unit__c: ' + this.booking.Quotation__c);
        await getPriceListMapDetails({ uId: this.booking.Quotation__c })
            .then(data => {
                if (data) {
                    //console.log('priceListMap: ' + JSON.stringify(data));
                    /*var conts = data;
                    for(var key in data) {
                        this.priceListMap.push({value:conts[key], key:key});
                    }*/
                    this.priceListMap = data;
                }
            })
    }

    async getAllPriceMap() {
        // this.isSpinner = true;
        // Check if both arrays are not null before proceeding
        if (this.priceListGroupMap && this.priceListMap) {
            //console.log('this.priceListGroupMap: ' + JSON.stringify(this.priceListGroupMap));
            //console.log('priceListMap ' + JSON.stringify(this.priceListMap));

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
                    //console.log('allPriceInfoMap: ' + JSON.stringify(data));
                    if (!this.isOrginal) {
                        this.allPriceOriginalInfoMap = data;
                        this.allPriceInfoMap = data;
                        await this.getAllPriceFormattedMap();
                    } else {
                        this.allPriceModifiedInfoMap = data;
                        await this.getAllPriceModifiedFormattedMap();
                        await this.updatePaymentSchedule();                  }
                   
                        // this.isSpinner = false;
                   
                }
            } catch (error) {
                //console.log('error: ' + JSON.stringify(error));
                console.error('Error In getAllPriceMap: ', error);
                this.isSpinner = false;
            }
        } else {
            console.warn('priceListGroupMap or priceListMap is null. getAllPriceMap() will not be called.');
        }
    }

    async updatePaymentSchedule(){
        this.isSpinner = true;
        // alert('called '+'Nitin');
        console.log('check allPriceModifiedInfoMap:  '+JSON.stringify(this.allPriceModifiedInfoMap));
        console.log('before updatedPaymentMilestoneWrapperList: '+JSON.stringify(this.updatedPaymentMilestoneWrapperList[0]));

    //    this.paymentMilestoneWrapperList = [];
        // this.updatedPaymentMilestoneWrapperList = [];

        await updatedgetPaymentScheduleDetails({agSeqNumber : parseInt(this.agSeqNumber,10), uId: this.booking.Unit__c, qId: this.booking.Quotation__c, allPriceInfoMap: this.allPriceModifiedInfoMap, priceListMap: this.priceListMap , updatedPaymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList})
            .then(data => {
                if (data) {
                    console.log('paymentMilestoneWrapperList: ' + JSON.stringify(data.length));
                    this.paymentMilestoneWrapperList = []
                    this.updatedPaymentMilestoneWrapperList = data;

                    data.forEach(element => {
                        if (element) {
                          
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
                    });
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

                 
                   
                    this.isSpinner = false;
                    console.log('paymentMilestoneWrapperList:' +JSON.stringify(this.paymentMilestoneWrapperList.length));
                    console.log('priceListGroupMap:' +JSON.stringify(this.priceListGroupMap));
                    console.log('priceListMap:' +JSON.stringify(this.priceListMap));
                    console.log('allPriceOriginalInfoMap:' +JSON.stringify(this.allPriceOriginalInfoMap));
                    console.log('allPriceModifiedInfoMap:' +JSON.stringify(this.allPriceModifiedInfoMap));

                    this.isSpinner = false;
                   
                } else {
                    this.isSpinner = false;
                    console.error('Error: Data is undefined');
                }
            }).catch(error => {
                this.isSpinner = false;
                console.log('error: '+JSON.stringify(error));
            });

    }


    async getAllPriceModifiedFormattedMap() {
        await getAllPriceInfoFormattedMap({ allPriceInfoMap: this.allPriceModifiedInfoMap })
            .then(data => {
                if (data) {
                    //console.log('allPriceOriginalInfoFormattedMap: ' + JSON.stringify(data));
                    if (!this.isOrginal) {
                        this.allPriceOriginalInfoFormattedMap = data;
                        //this.allPriceInfoFormattedMap = data;
                    } else {
                        this.allPriceInfoFormattedMap = data;
                    }

                    this.allPriceDetailMap = [];
                    for (let chargeBucket in this.priceListGroupMap) {
                        ////console.log('chargeBucket: '+chargeBucket);

                        const chargeList = this.priceListGroupMap[chargeBucket];

                        //console.log('chargeList: ' + chargeList);

                        var chargeValues = [];
                        // var getAllInPrice = [];
                        chargeList.forEach(element => {
                            //console.log('element: ' + element);

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
                        //console.log('chargeValues: ' + JSON.stringify(chargeValues));

                        if (chargeBucket !== 'Other Charges') {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: false });
                        } else {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: true });
                        }
                        this.isOrginal = true;
                    }
                   
                } else if (error) {
                    console.error('Error In getAllPriceFormattedMap: ', error);
                }
            })
    }


    async getAllPriceFormattedMap() {
        await getAllPriceInfoFormattedMap({ allPriceInfoMap: this.allPriceInfoMap })
            .then(data => {
                if (data) {
                    //console.log('allPriceOriginalInfoFormattedMap: ' + JSON.stringify(data));
                    if (!this.isOrginal) {
                        this.allPriceOriginalInfoFormattedMap = data;
                        this.allPriceInfoFormattedMap = data;
                    } else {
                        this.allPriceInfoFormattedMap = data;
                    }

                    this.allPriceDetailMap = [];
                    for (let chargeBucket in this.priceListGroupMap) {
                        ////console.log('chargeBucket: '+chargeBucket);

                        const chargeList = this.priceListGroupMap[chargeBucket];

                        //console.log('chargeList: ' + chargeList);

                        var chargeValues = [];
                        // var getAllInPrice = [];
                        chargeList.forEach(element => {
                            //console.log('element: ' + element);

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
                        //console.log('chargeValues: ' + JSON.stringify(chargeValues));

                        if (chargeBucket !== 'Other Charges') {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: false });
                        } else {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: true });
                        }
                        this.isOrginal = true;
                    }
                   
                } else if (error) {
                    console.error('Error In getAllPriceFormattedMap: ', error);
                }
            })
    }

  

    async getPaymentSchedule() {
        this.isSpinner = true;
        // alert('called '+'Nitin');
        console.log('check allPriceInfoMap:  '+JSON.stringify(this.allPriceInfoMap));
        console.log('check priceListMap: '+JSON.stringify(this.priceListMap));

        this.paymentMilestoneWrapperList = [];
        this.updatedPaymentMilestoneWrapperList = [];

        await getPaymentScheduleDetails({ uId: this.booking.Unit__c, qId: this.booking.Quotation__c, allPriceInfoMap: this.allPriceInfoMap, priceListMap: this.priceListMap })
            .then(data => {
                if (data) {
                    console.log('paymentMilestoneWrapperList: ' + JSON.stringify(data));
                    this.updatedPaymentMilestoneWrapperList = data;

                    data.forEach(element => {
                        if (element) {
                          
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
                    });
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

                 
                   
                    this.isSpinner = false;
                    console.log('paymentMilestoneWrapperList:' +JSON.stringify(this.paymentMilestoneWrapperList));
                    
                   
                } else {
                    this.isSpinner = false;
                    console.error('Error: Data is undefined');
                }
            }).catch(error => {
                this.isSpinner = false;
                console.log('error: '+JSON.stringify(error));
            });
    }

    getMilestoneType() {
        getPicklistValues({ objectName: 'Payment_Milestone__c', picklistField: 'Milestone_Type__c' })
            .then(data => {
                if (data) { 
                    //console.log('dataPM: ' + JSON.stringify(data));
                    data.forEach(element => {
                        this.milestoneType.push({ label: element, value: element });
                    })
                } else if (error) {
                    console.error('Error In getMilestoneType: ', error);
                }
            })
    }

  

    getAmountType() {
        getPicklistValues({ objectName: 'Payment_Milestone__c', picklistField: 'Charge_Bucket_1_Type__c' })
            .then(data => {
                if (data) {
                    //console.log('datapm: ' + JSON.stringify(data));
                    data.forEach(element => {
                        this.amountType.push({ label: element, value: element });
                    })
                } else if (error) {
                    console.error('Error In getAmountType: ', error);
                }
            })
    }

    showPaymentSchedule() {
        this.showPaymentScheduleData = true;
        this.isShowButtonVisiable = false;
        this.isPaymentScheduleEnable = true;
        this.getPaymentSchedule();
    }

    get isSaveActionDisabled() {
        return !this.isQuotationModified;
    }

    //  updatePaymentSchedule() {
    //     console.log('this.updatedPaymentMilestoneWrapperList: '+JSON.stringify(this.updatedPaymentMilestoneWrapperList));
    //         // this.isSpinner = true;
    //         this.isValidationError = false;
    //         const validationErrorList = [];
    //         let errorCount = 0;
    //         let rowCount = 1;
    
    //         for (let i = 0; i < this.updatedPaymentMilestoneWrapperList.length; i++) {
    //             if (!this.updatedPaymentMilestoneWrapperList[i].isTotal) {
    //                 if (this.updatedPaymentMilestoneWrapperList[i].milestoneName === "" || this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Name__c === "") {
    //                     errorCount++;
    //                     validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Name.');
    //                 }
    //                 if (this.updatedPaymentMilestoneWrapperList[i].pm.Number_of_Days__c === null) {
    //                     errorCount++;
    //                     validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide No of Days.');
    //                 }
    //                 if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c === "") {
    //                     errorCount++;
    //                     validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Type.');
    //                 } else if (this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c !== "" && this.updatedPaymentMilestoneWrapperList[i].pm.Milestone_Type__c === 'Construction Linked') {
    //                     if (this.updatedPaymentMilestoneWrapperList[i].pm.Construction_Stage__c === null) {
    //                         errorCount++;
    //                         validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Valid Construction Stage.');
    //                     }
    //                 }
    //                 if (this.updatedPaymentMilestoneWrapperList[i].psm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === "") {
    //                     errorCount++;
    //                     validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Amount Type.');
    //                 } else {
    //                     if (this.updatedPaymentMilestoneWrapperList[i].psm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === 'Percentage' && this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Percentage__c"] === null) {
    //                         errorCount++;
    //                         validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Percentage.');
    //                     } else if (this.updatedPaymentMilestoneWrapperList[i].psm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === 'Amount' && this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Amount__c"] === null) {
    //                         errorCount++;
    //                         validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Amount.');
    //                     }
    //                 }
    //             }
    //             rowCount++;
    //         }
    //         console.log('validationErrorList-1: ' + validationErrorList);
    
    //         if (validationErrorList.length === 0) {
    //             validateUpdatedPaymentScheduleDetails({ agSeqNumber: this.agSeqNumber, allPriceInfoMap: this.allPriceInfoMap, updatedPaymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList })
    //                 .then(data => {
    //                     console.log('validationData: '+data);
    //                     if (data != null) {
    //                         for (let i = 0; i < data.length; i++) {
    //                             validationErrorList.push(data[i]);
    //                         }
    //                         console.log('validationErrorList final: ' + validationErrorList);
    
    //                         if (validationErrorList.length === 0) {
    //                             this.getUpdatedPaymentSchedule();
    //                         } else {
    //                             var errorMessage = '';
    //                             for (let i = 0; i < validationErrorList.length; i++) {
    //                                 errorMessage += validationErrorList[i] + '\n';
    //                             }
    //                             console.log('errorMessage: ' + errorMessage);
    //                             this.showErrorMessage('Error', errorMessage);
    //                             // this.isSpinner = false;
    //                         }
    //                     // } else if (error) {
    //                     //     console.log('error: '+JSON.stringify(error));
    //                     //     console.error('Error In validatePaymentSchedule: ', error);
    //                     }else{
    //                         var successMsg = '';
    //                         successMsg = 'Payment Schedule Updated Successfully';
    //                         this.showErrorMessage('Error', successMsg);
    //                         // this.isSpinner = false;
    //                     }
    //                 })
    //         } else {
    //             var errorMessage = '';
    //             for (let i = 0; i < validationErrorList.length; i++) {
    //                 errorMessage += validationErrorList[i] + '\n';
    //             }
    //             console.log('errorMessage: ' + errorMessage);
    //             this.showErrorMessage('Error', errorMessage);
    //             // this.isSpinner = false;
    //         }
    //     }
    
    //     getUpdatedPaymentSchedule() {
    //         getUpdatedPaymentScheduleDetails({ u: this.booking, agSeqNumber: this.agSeqNumber, priceListMap: this.priceListMap, allPriceInfoMap: this.allPriceInfoMap, updatedPaymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList })
    //             .then(data => {
    //                 if (data) {
    //                     this.isPaymentScheduleUpdated = true;
    //                     this.paymentMilestoneWrapperList = [];
    //                     this.updatedPaymentMilestoneWrapperList = [];
    //                     console.log('data getUpdatedPaymentSchedule: ' + JSON.stringify(data));
    
    //                     data.forEach(element => {
    //                         if (element.isTotal) {
    //                             this.paymentMilestoneWrapperList.push({
    //                                 ...element
    //                             });
    //                         } else {
    //                             var csList = [];
    //                             element.constructionStageList.forEach(cs => {
    //                                 csList.push({ label: cs.Name, value: cs.Id });
    //                             })
    
    //                             this.paymentMilestoneWrapperList.push({
    //                                 ...element,
    //                                 milestoneType: this.milestoneType,
    //                                 isConStructionLinked: element.pm.Milestone_Type__c === 'Construction Linked',
    //                                 csListDisplay: csList,
    //                                 amountType: this.amountType,
    //                                 isAmount: element.psm.Charge_Bucket_1_Type__c === 'Amount',
    //                                 isPercentage: element.psm.Charge_Bucket_1_Type__c === 'Percentage'
    //                             });
    //                         }
    //                     })
    //                     this.updatedPaymentMilestoneWrapperList = data;
    //                     //this.getCalculatedNPV();
    //                     //this.isSpinner = false;
    //                 } else if (error) {
    //                     console.error('Error In getUpdatedPaymentSchedule: ', error);
    //                 }
    //             })
    //     }

    handleSave() {
        this.isSpinner = true;
        if (this.getRemarks === undefined) {
            this.isSpinner = false;
            this.showErrorMessage('Error', 'Please Enter Remarks.');
          //  this.showToast('Error', 'Please Enter Remarks', 'error', 'dismissible');
            return;
        } else {
            saveAV({
                recordId: this.recordId, updatedAVvalue: this.getModifiedData.getAvvalue,
                gstValue: this.getUpdatedGST, stampValue: this.getUpdatedStampValue,
                remarks: this.getRemarks, priceListGroupMap: this.priceListGroupMap, priceListMap: this.priceListMap,
                allPriceOriginalInfoMap: this.allPriceOriginalInfoMap, allPriceInfoMap: this.allPriceModifiedInfoMap,
                paymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList
            })
                .then((result) => {
                    this.isSpinner = false;
                    //console.log('result: ' + result);
                    if (result == true) {
                        this.isSpinner = false;
                       // this.showToast('success', 'AV Changes Successfully', 'success', 'dismissible');
                        this.showErrorMessage('success', 'AV Changes Successfully.');
                        window.location.href = '/' + this.recordId;
                    } else {
                        this.isSpinner = false;
                        this.showErrorMessage('Error', 'Something Went Wrong Please Contact System Administrator.');
                     //   this.showToast('Error', 'Something Went Wrong Please Contact System Administrator', 'error', 'sticky');
                    }
                })
                .catch((error) => {
                    this.isSpinner = false;
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
}