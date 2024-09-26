import { LightningElement, api, wire, track } from 'lwc';
import getOppDetails from '@salesforce/apex/Ex_GenerateQuotation.getOppDetails';
import getUnitDetails from '@salesforce/apex/Ex_GenerateQuotation.getUnitDetails';
import getPaymentSchemeDetails from '@salesforce/apex/Ex_GenerateQuotation.getPaymentSchemeDetails';
import getCarParkDetails from '@salesforce/apex/Ex_GenerateQuotation.getCarParkDetails';
import getPriceListMapDetails from '@salesforce/apex/Ex_GenerateQuotation.getPriceListMapDetails';
import getPriceListGroupMapDetails from '@salesforce/apex/Ex_GenerateQuotation.getPriceListGroupMapDetails';
import getDiscountGroupMapDetails from '@salesforce/apex/Ex_GenerateQuotation.getDiscountGroupMapDetails';
import getAllPriceMapDetails from '@salesforce/apex/Ex_GenerateQuotation.getAllPriceMapDetails';
import getAllPriceInfoFormattedMap from '@salesforce/apex/Ex_GenerateQuotation.getAllPriceInfoFormattedMap';
import getPaymentScheduleDetails from '@salesforce/apex/Ex_GenerateQuotation.getPaymentScheduleDetails';
import getPicklistValues from '@salesforce/apex/Ex_GenerateQuotation.getPicklistValues';
import validateUpdatedPaymentScheduleDetails from '@salesforce/apex/Ex_GenerateQuotation.validateUpdatedPaymentScheduleDetails';
import getUpdatedPaymentScheduleDetails from '@salesforce/apex/Ex_GenerateQuotation.getUpdatedPaymentScheduleDetails';
import getCalculatedNPVDetails from '@salesforce/apex/Ex_GenerateQuotation.getCalculatedNPVDetails';
import getModifiedPaymentScheduleDetails from '@salesforce/apex/Ex_GenerateQuotation.getModifiedPaymentScheduleDetails';
import saveQuotationDetails from '@salesforce/apex/Ex_GenerateQuotation.saveQuotationDetails';
export default class Ex_GenerateQuotation extends LightningElement {
    @api uId;
    @api oppId;
    @track unit;
    @track opp = [];
    @track isError = false;
    @track isValidationError = false;
    @track errorMsg;
    @track isSpinner = false;
    @track showTable = false;
    @track paymentSchemeList = [];
    @track carParkList = [];
    @track updatedCarParkList = [];
    @track totalCarParkAmountString;
    @track totalCarParkAmount = 0;
    @track priceListMap = [];
    @track priceListGroupMap = [];
    @track discountGroupMap = [];
    @track originalDiscountGroupMap = [];
    @track updatedDiscountGroupMap = [];
    @track totalDiscountAmountString;
    @track totalDiscountAmount = 0;
    @track appliedDiscountGroup = [];
    @track appliedDiscountList = [];
    @track allPriceOriginalInfoMap = [];
    @track allPriceInfoMap = [];
    @track allPriceOriginalInfoFormattedMap = [];
    @track allPriceInfoFormattedMap = [];
    @track allPriceDetailMap = []; //For Display Use
    @track isQuotationModified = false;
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
    @track originalNPV = null;
    @track originalNPVPSF = null;
    @track updatedNPV = null;
    @track updatedNPVPSF = null;
    @track discountNPV = null;
    @track discountNPVPSF = null;
    @track paymentSchemePremium = null;
    @track originalBaseRate = 0;
    @track unitdetails = [];

    connectedCallback() {
        if (this.oppId) {
            getOppDetails({ oppId: this.oppId })
                .then(data => {
                    if (data) {
                        console.log('opp: ' + JSON.stringify(data));
                        this.opp = data;
                        if (!this.opp.Is_Active__c) {
                            this.isError = true;
                            this.errorMsg = 'You are Not Able to Create Quotation on Inactive Opportunity.';
                        } else if (this.opp.Project__c) {
                            this.getUnit();
                        }
                    }
                });
        }
    }

    getUnit() {
        getUnitDetails({ uId: this.uId })
            .then(data => {
                if (data) {
                    console.log('unit: ' + JSON.stringify(data));
                    this.unit = data;
                    this.unitdetails.push(this.unit);
                    if (this.unit.RERA_Carpet_Area_Sq_Ft__c != null) {
                        this.unit.RERA_Carpet_Area_Sq_Ft__c = parseFloat(this.unit.RERA_Carpet_Area_Sq_Ft__c).toFixed(2);
                    }
                    if (this.unit.Saleable_Area__c != null) {
                        this.unit.Saleable_Area__c = parseFloat(this.unit.Saleable_Area__c).toFixed(2);
                    }
                    if ((this.unit.Sales_Status__c !== 'Vacant') && ((this.unit.Opportunity__c !== this.oppId) && this.unit.Sales_Status__c !== 'Blocked')) {
                        this.isError = true;
                        this.errorMsg = 'Unit Not Available For Sale';
                    } else if (this.opp.Project__c != this.unit.Tower__r.Project__c) {
                        this.isError = true;
                        this.errorMsg = 'Project of Opportunity & Unit Is Not Same.';
                    } else {
                        this.getPaymentScheme();
                        this.getCarPark();
                        this.getPriceListGroupMap();
                        this.getPriceListMap();
                        this.getDiscountGroupMap();
                        this.getMilestoneType();
                        this.getAmountType();
                    }
                }
            })
    }

    getPaymentScheme() {
        getPaymentSchemeDetails({ tId: this.unit.Tower__c })
            .then(data => {
                if (data) {
                    console.log('paymentSchemeList: ' + JSON.stringify(data));
                    let array = [];
                    for (let i = 0; i < data.length; i++) {
                        array.push({ label: data[i].Name, value: data[i].Id, isEditable: data[i].Is_Editable__c });
                    }
                    this.paymentSchemeList = array;
                }

            })
    }

    getCarPark() {
        getCarParkDetails({ pId: this.unit.Tower__r.Project__c, tId: this.unit.Tower__c })
            .then(data => {
                if (data) {
                    console.log('carParkList: ' + JSON.stringify(data));
                    this.carParkList = data;
                    this.updatedCarParkList = data;
                }
            })
    }

    getPriceListGroupMap() {
        getPriceListGroupMapDetails({ uId: this.unit.Id })
            .then(data => {
                if (data) {
                    for (var key in data) {
                        if (key === 'Basic Charge') {
                            console.log('Basic Charge: ' + data[key]);
                            this.originalBaseRate = data[key].Charge_Rate__c;
                        }
                        //this.priceListMap.push({value:conts[key], key:key});
                    }
                    this.priceListGroupMap = data;
                }
            })
    }

    getPriceListMap() {
        getPriceListMapDetails({ uId: this.unit.Id })
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

    getDiscountGroupMap() {
        getDiscountGroupMapDetails({ pId: this.unit.Tower__r.Project__c, tId: this.unit.Tower__c })
            .then(data => {
                if (data) {
                    console.log('discountGroupMap: ' + JSON.stringify(data));
                    this.updatedDiscountGroupMap = data;
                    this.originalDiscountGroupMap = this.updatedDiscountGroupMap;

                    for (let group in data) {
                        //console.log('group: '+group);

                        const discountList = data[group];
                        //console.log('discountList: '+discountList);

                        const updatedDiscountList = [];
                        discountList.forEach(element => {
                            //console.log('element: '+element);

                            updatedDiscountList.push({
                                ...element,
                                isPSF: element.Discount_Type__c === 'PSF',
                                isLumpsum: element.Discount_Type__c === 'Lumpsum',
                                isPercentage: element.Discount_Type__c === 'Percentage'
                            });
                        });
                        this.discountGroupMap.push({ key: group, value: updatedDiscountList });
                    }
                    //console.log('discountGroupMap: '+JSON.stringify(this.discountGroupMap));
                } else if (error) {
                    console.error('Error In getDiscountGroupMap: ', error);
                }
            })
    }

    handlePaymentSchemeChange(event) {
        this.isSpinner = true;
        this.showTable = true;
        this.selectedPaymentScheme = event.target.value;
        this.selectedPaymentSchemeName = this.paymentSchemeList.find(option => option.value === this.selectedPaymentScheme).label;
        this.isPaymentScheduleEnable = this.paymentSchemeList.find(option => option.value === this.selectedPaymentScheme).isEditable;
        this.getAllPriceMap();
        this.showPaymentSchedule();
        //this.isSpinner = false;
    }

    handleChange(event) {

        this.isSpinner = true;
        var index = parseInt(event.target.dataset.index);
        console.log('index: ' + index);
        var eventName = event.currentTarget.name;
        console.log('name: ' + eventName);

        if (eventName === 'carParkRequiredCount') {
            var value = parseInt(event.target.value);
            console.log('value: ' + value);
            //console.log('Available Count: '+this.updatedCarParkList[index].carParkAvailableCount);

            if (isNaN(value)) {
                value = 0;
            }
            if (this.updatedCarParkList[index].carParkAvailableCount < value) {
                this.showErrorMessage('Warning', 'You are not allowed to apply more car parks than the available count.');
                event.target.value = this.updatedCarParkList[index].carParkRequiredCount;
                return;
            } else if (value < 0) {
                this.showErrorMessage('Warning', 'Please Provide Valid Required Count.');
                event.target.value = this.updatedCarParkList[index].carParkRequiredCount;
                return;
            } else {
                const carParkObj = { ...this.carParkList[index], [eventName]: value };
                this.carParkList = [...this.carParkList];
                this.carParkList[index] = carParkObj;

                const newObj = { ...this.updatedCarParkList[index], [eventName]: value };
                this.updatedCarParkList = [...this.updatedCarParkList];
                this.updatedCarParkList[index] = newObj;

                this.totalCarParkAmount = 0;
                this.updatedCarParkList.forEach(element => {
                    console.log('Test: ' + element.carParkRequiredCount);
                    this.totalCarParkAmount += (element.carParkAmount * element.carParkRequiredCount);
                })
                this.isQuotationModified = true;
                this.applyDiscount();
                this.getAllPriceMap();
            }
        } else if (eventName === 'Amount__c') {
            var value = parseFloat(event.target.value);
            console.log('value: ' + value);
            var key = event.target.dataset.valueId;
            console.log('key: ' + key);

            if (isNaN(value)) {
                value = 0;
            }

            if (value < 0) {
                this.showErrorMessage('Warning', 'Please Provide Valid Lumpsum Amount');
                event.target.value = this.updatedDiscountGroupMap[key][index].Amount__c;
                return;
            } else if (this.originalDiscountGroupMap[key][index].Amount__c < value) {
                this.showErrorMessage('Warning', 'Lumpsum Amount Cannot be Increased Beyond What is Already Defined');
                event.target.value = this.updatedDiscountGroupMap[key][index].Amount__c;
                return;
            } else {
                const newObj = { ...this.updatedDiscountGroupMap[key][index], [eventName]: value };
                this.updatedDiscountGroupMap = { ...this.updatedDiscountGroupMap };
                this.updatedDiscountGroupMap[key][index] = newObj;
                this.isQuotationModified = true;
                this.applyDiscount();
                this.getAllPriceMap();
            }
        } else if (eventName === 'PSF_Amount__c') {
            var value = parseFloat(event.target.value);
            console.log('value: ' + value);
            var key = event.target.dataset.valueId;
            console.log('key: ' + key);

            if (isNaN(value)) {
                value = 0;
            }

            if (value < 0) {
                this.showErrorMessage('Warning', 'Please Provide Valid PSF Amount');
                event.target.value = this.updatedDiscountGroupMap[key][index].PSF_Amount__c;
                return;
            } else if (this.originalDiscountGroupMap[key][index].PSF_Amount__c < value) {
                console.log('1: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                this.showErrorMessage('Warning', 'PSF Cannot be Increased Beyond What is Already Defined');
                event.target.value = this.updatedDiscountGroupMap[key][index].PSF_Amount__c;
                return;
            } else {
                console.log('2: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                const newObj = { ...this.updatedDiscountGroupMap[key][index], [eventName]: value };
                console.log('3: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                this.updatedDiscountGroupMap = { ...this.updatedDiscountGroupMap };
                console.log('4: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                this.updatedDiscountGroupMap[key][index] = newObj;
                console.log('5: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                this.isQuotationModified = true;
                console.log('6: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                this.applyDiscount();
                console.log('7: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
                this.getAllPriceMap();
                console.log('8: ' + this.originalDiscountGroupMap[key][index].PSF_Amount__c);
            }
        } else if (eventName === 'Percentage_of_AV__c') {
            var value = parseFloat(event.target.value);
            console.log('value: ' + value);
            var key = event.target.dataset.valueId;
            console.log('key: ' + key);

            if (isNaN(value)) {
                value = 0;
            }

            if (value < 0) {
                this.showErrorMessage('Warning', 'Please Provide Valid Percentage');
                event.target.value = this.updatedDiscountGroupMap[key][index].Percentage_of_AV__c;
                return;
            } else if (this.originalDiscountGroupMap[key][index].Percentage_of_AV__c < value) {
                this.showErrorMessage('Warning', 'Percentage Cannot be Increased Beyond What is Already Defined');
                event.target.value = this.updatedDiscountGroupMap[key][index].Percentage_of_AV__c;
                return;
            } else {
                const newObj = { ...this.updatedDiscountGroupMap[key][index], [eventName]: value };
                this.updatedDiscountGroupMap = { ...this.updatedDiscountGroupMap };
                this.updatedDiscountGroupMap[key][index] = newObj;
                this.isQuotationModified = true;
                this.applyDiscount();
                this.getAllPriceMap();
            }
        } else if (eventName === 'Applied__c') {
            var value = event.target.checked;
            console.log('value: ' + value);
            var key = event.target.dataset.valueId;
            console.log('key: ' + key);

            if (value) {
                if (this.appliedDiscountGroup.includes(key)) {
                    this.showErrorMessage('Warning', 'You cannot apply more than one discount from the group: ' + key);
                    event.target.checked = false;
                    return;
                } else {
                    this.appliedDiscountGroup.push(key);
                    const newObj = { ...this.updatedDiscountGroupMap[key][index], [eventName]: value };
                    this.updatedDiscountGroupMap = { ...this.updatedDiscountGroupMap };
                    this.updatedDiscountGroupMap[key][index] = newObj;
                    this.isQuotationModified = true;
                    this.applyDiscount();
                    this.getAllPriceMap();
                }
            } else {
                const groupIndex = this.appliedDiscountGroup.indexOf(key);
                if (groupIndex > -1) {
                    // only splice array when item is found
                    this.appliedDiscountGroup.splice(groupIndex, 1); // 2nd parameter means remove one item only
                }
                const newObj = { ...this.updatedDiscountGroupMap[key][index], [eventName]: value };
                this.updatedDiscountGroupMap = { ...this.updatedDiscountGroupMap };
                this.updatedDiscountGroupMap[key][index] = newObj;
                this.isQuotationModified = true;
                this.applyDiscount();
                this.getAllPriceMap();
            }
        } else if (eventName === 'milestoneName') {
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
                value = null;
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

            const newObj = { ...this.updatedPaymentMilestoneWrapperList[index].psm, [eventName]: value };
            this.updatedPaymentMilestoneWrapperList = [...this.updatedPaymentMilestoneWrapperList];
            this.updatedPaymentMilestoneWrapperList[index].psm = newObj;
            console.log('Charge_Bucket_1_Type__c 1: ' + this.updatedPaymentMilestoneWrapperList[index].psm.Charge_Bucket_1_Type__c);

            const pmObj = { ...this.paymentMilestoneWrapperList[index].psm, [eventName]: value };
            this.paymentMilestoneWrapperList = [...this.paymentMilestoneWrapperList];
            this.paymentMilestoneWrapperList[index].psm = pmObj;
            console.log('Charge_Bucket_1_Type__c 2: ' + this.paymentMilestoneWrapperList[index].psm.Charge_Bucket_1_Type__c);
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

    applyDiscount() {
        this.totalDiscountAmount = 0;
        this.appliedDiscountList = [];

        for (let discountGroup in this.updatedDiscountGroupMap) {
            const discountList = this.updatedDiscountGroupMap[discountGroup];
            //console.log('discountList: '+JSON.stringify(discountList));

            for (let d in discountList) {
                //console.log('d['+d+']: '+JSON.stringify(discountList[d]));
                if (discountList[d].Applied__c) {
                    //console.log('Applied Discount: '+JSON.stringify(discountList[d]));
                    if (discountList[d].Discount_Type__c === 'Lumpsum') {
                        discountList[d].Total__c = discountList[d].Amount__c;
                        console.log('Lumpsum Discount Total: ' + discountList[d].Total__c);
                        if (discountList[d].Discount_Category__c === 'Discount') {
                            this.totalDiscountAmount += discountList[d].Total__c;
                        }
                        this.appliedDiscountList.push(discountList[d]);
                    } else if (discountList[d].Discount_Type__c === 'PSF') {
                        discountList[d].Total__c = (discountList[d].PSF_Amount__c * this.unit.Saleable_Area__c);
                        console.log('PSF Discount Total: ' + discountList[d].Total__c);
                        if (discountList[d].Discount_Category__c === 'Discount') {
                            this.totalDiscountAmount += discountList[d].Total__c;
                        }
                        this.appliedDiscountList.push(discountList[d]);
                    }
                    //console.log('this.appliedDiscountList: '+JSON.stringify(this.appliedDiscountList));
                }
            }
        }

        for (let discountGroup in this.updatedDiscountGroupMap) {
            const discountList = this.updatedDiscountGroupMap[discountGroup];
            //console.log('discountList: '+JSON.stringify(discountList));

            for (let d in discountList) {
                //console.log('d['+d+']: '+JSON.stringify(discountList[d]));
                if (discountList[d].Applied__c) {
                    //console.log('Applied Discount: '+JSON.stringify(discountList[d]));
                    if (discountList[d].Discount_Type__c === 'Percentage') {
                        discountList[d].Total__c = ((discountList[d].Percentage_of_AV__c * this.allPriceInfoMap['Agreement Value']) / 100);
                        console.log('Percentage Discount Total: ' + discountList[d].Total__c);
                        if (discountList[d].Discount_Category__c === 'Discount') {
                            this.totalDiscountAmount += discountList[d].Total__c;
                        }
                        this.appliedDiscountList.push(discountList[d]);
                    }
                    //console.log('this.appliedDiscountList: '+JSON.stringify(this.appliedDiscountList));
                }
            }
        }
        console.log('totalDiscountAmount: ' + this.totalDiscountAmount);
    }

    getAllPriceMap() {
        getAllPriceMapDetails({ uId: this.unit.Id, priceListGroupMap: this.priceListGroupMap, priceListMap: this.priceListMap, carParkAmount: this.totalCarParkAmount, discountAmount: this.totalDiscountAmount })
            .then(data => {
                if (data) {
                    console.log('allPriceInfoMap: ' + JSON.stringify(data));
                    if (!this.isQuotationModified) {
                        this.allPriceOriginalInfoMap = data;
                        this.allPriceInfoMap = data;
                    } else {
                        this.allPriceInfoMap = data;
                    }
                    this.getAllPriceFormattedMap();
                    this.getPaymentSchedule();
                } else if (error) {
                    console.error('Error In getAllPriceMap: ', error);
                }
            })
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
                        //console.log('chargeList: '+chargeList);

                        var chargeValues = [];
                        chargeList.forEach(element => {
                            //console.log('element: '+element);

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
                        //console.log('chargeValues: '+JSON.stringify(chargeValues));

                        if (chargeBucket !== 'Other Charges') {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: false });
                        } else {
                            this.allPriceDetailMap.push({ value: chargeValues, key: chargeBucket, isOtherCharge: true });
                        }
                    }
                    this.totalCarParkAmountString = this.allPriceInfoFormattedMap['Total Car Park Price'];
                    this.totalDiscountAmountString = this.allPriceInfoFormattedMap['Total Discount Price'];
                    //console.log('allPriceDetailMap: '+JSON.stringify(this.allPriceDetailMap));
                } else if (error) {
                    console.error('Error In getAllPriceFormattedMap: ', error);
                }
            })
    }

    getPaymentSchedule() {
        this.paymentMilestoneWrapperList = [];
        this.updatedPaymentMilestoneWrapperList = [];

        getPaymentScheduleDetails({ uId: this.unit.Id, selectedScheme: this.selectedPaymentScheme, allPriceInfoMap: this.allPriceInfoMap, priceListMap: this.priceListMap })
            .then(data => {
                if (data) {
                    //console.log('paymentMilestoneWrapperList: '+JSON.stringify(data));

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
                                    isAmount: element.psm && element.psm.Charge_Bucket_1_Type__c === 'Amount',
                                    isPercentage: element.psm && element.psm.Charge_Bucket_1_Type__c === 'Percentage'
                                });
                            }
                        } else {
                            console.warn('Null or undefined element encountered in data:', +JSON.stringify(data));
                        }
                    });

                    this.updatedPaymentMilestoneWrapperList = data;

                    for (let i = 1; i <= 5; i++) {
                        if (this.updatedPaymentMilestoneWrapperList[0] && this.updatedPaymentMilestoneWrapperList[0].psm) {
                            if (this.updatedPaymentMilestoneWrapperList[0].psm["Charge_Bucket_" + i + "__c"] !== "") {
                                if (this.updatedPaymentMilestoneWrapperList[0].psm["Charge_Bucket_" + i + "__c"] === 'Agreement Value') {
                                    this.agSeqNumber = i;
                                    break;
                                }
                            }
                        }
                    }

                    this.getCalculatedNPV();
                    this.isSpinner = false;
                    console.log('updatedPaymentMilestoneWrapperList:', +JSON.stringify(this.updatedPaymentMilestoneWrapperList));
                    console.log('updatedPaymentMilestoneWrapperList Size:', +this.updatedPaymentMilestoneWrapperList.length);
                } else {
                    console.error('Error: Data is undefined');
                }
            })
            .catch(error => {
                console.error('Error In getPaymentSchedule: ', error);
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

    getAmountType() {
        getPicklistValues({ objectName: 'Payment_Scheme_Milestone__c', picklistField: 'Charge_Bucket_1_Type__c' })
            .then(data => {
                if (data) {
                    console.log('dataPSM: ' + JSON.stringify(data));
                    data.forEach(element => {
                        this.amountType.push({ label: element, value: element });
                    })
                } else if (error) {
                    console.error('Error In getAmountType: ', error);
                }
            })
    }

    getModifiedPaymentSchedule() {
        console.log('agSeqNumber: ' + this.agSeqNumber);
        getModifiedPaymentScheduleDetails({ actionType: this.actionType, rowIndex: this.rowIndex, paymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList, u: this.unit, agSeqNumber: this.agSeqNumber })
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
                                isAmount: element.psm.Charge_Bucket_1_Type__c === 'Amount',
                                isPercentage: element.psm.Charge_Bucket_1_Type__c === 'Percentage'
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
    }

    editPaymentSchedule() {
        this.editPaymentScheduleMode = true;
    }

    updatePaymentSchedule() {
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
                if (this.updatedPaymentMilestoneWrapperList[i].psm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === "") {
                    errorCount++;
                    validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Amount Type.');
                } else {
                    if (this.updatedPaymentMilestoneWrapperList[i].psm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === 'Percentage' && this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Percentage__c"] === null) {
                        errorCount++;
                        validationErrorList.push('Error ' + errorCount + ': On Row-' + rowCount + '- Please Provide Milestone Percentage.');
                    } else if (this.updatedPaymentMilestoneWrapperList[i].psm["Charge_Bucket_" + this.agSeqNumber + "_Type__c"] === 'Amount' && this.updatedPaymentMilestoneWrapperList[i].pm["Charge_Bucket_" + this.agSeqNumber + "_Amount__c"] === null) {
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
                    if (data) {
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

    getUpdatedPaymentSchedule() {
        getUpdatedPaymentScheduleDetails({ u: this.unit, agSeqNumber: this.agSeqNumber, priceListMap: this.priceListMap, allPriceInfoMap: this.allPriceInfoMap, updatedPaymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList })
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
                                isAmount: element.psm.Charge_Bucket_1_Type__c === 'Amount',
                                isPercentage: element.psm.Charge_Bucket_1_Type__c === 'Percentage'
                            });
                        }
                    })
                    this.updatedPaymentMilestoneWrapperList = data;
                    this.getCalculatedNPV();
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

    getCalculatedNPV() {
        getCalculatedNPVDetails({ isPaymentScheduleUpdated: this.isPaymentScheduleUpdated, paymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList, u: this.unit })
            .then(data => {
                if (data) {
                    console.log('data: ' + JSON.stringify(data));

                    for (let key in data) {
                        if (key === 'Original NPV') {
                            this.originalNPV = data[key];
                        } else if (key === 'Original NPV PSF') {
                            this.originalNPVPSF = data[key];
                        } else if (key === 'Modified NPV') {
                            this.updatedNPV = data[key];
                            this.discountNPV = (this.originalNPV - this.updatedNPV);
                        } else if (key === 'Modified NPV PSF') {
                            this.updatedNPVPSF = data[key];
                            this.discountNPVPSF = (this.discountNPV / this.unit.Saleable_Area__c);
                        }
                    }
                    this.isSpinner = false;
                } else if (error) {
                    console.error('Error In getCalculatedNPV: ', error);
                }
            })
    }

    saveQuotation() {
        this.isSpinner = true;
        saveQuotationDetails({ u: this.unit, oppId: this.opp.Id, selectedSchemeId: this.selectedPaymentScheme, priceListGroupMap: this.priceListGroupMap, priceListMap: this.priceListMap, allPriceOriginalInfoMap: this.allPriceOriginalInfoMap, allPriceInfoMap: this.allPriceInfoMap, appliedDiscountList: this.appliedDiscountList, carParkList: this.updatedCarParkList, paymentMilestoneWrapperList: this.updatedPaymentMilestoneWrapperList })
            .then(data => {
                if (data) {
                    console.log('data: ' + JSON.stringify(data));
                    this.isSpinner = false;
                    if (data !== null) {
                        location.replace('/' + data);
                    } else {
                        console.log('Quotation Id is null');
                        this.showValidationMessage('Error', 'Error Occured While Generating Quotation. Please Contact System Administrator.');
                    }
                } else if (error) {
                    console.error('Error In saveQuotation: ', error);
                    this.showValidationMessage('Error', error.message);
                }
            })
    }

    showErrorMessage(type, message) {
        if (type === 'Error') {
            this.isValidationError = true;
        }
        this.isSpinner = false;
        this.template.querySelector('c-custom-toast').showToast(type, message, 'utility:warning', 10000);
    }
}