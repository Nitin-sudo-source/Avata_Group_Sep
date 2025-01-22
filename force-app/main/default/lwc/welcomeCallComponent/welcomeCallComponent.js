import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getWelcomCallDetails from '@salesforce/apex/Ex_WelcomeCall.getWelcomCallDetails';
import updateRecords from '@salesforce/apex/Ex_WelcomeCall.updateRecords';
import changeGenarateCheckBoxValue from '@salesforce/apex/Ex_WelcomeCall.changeGenarateCheckBoxValue';
import checkGenerateWelcomeCallChecklist from '@salesforce/apex/Ex_WelcomeCall.checkGenerateWelcomeCallChecklist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WelcomeCallComponent extends LightningElement {

    @api recordId;
    @track wccList;
    @track selectedval;
    @api options;
    @api showButton = false;
    @track acceptAll = false;
    @track rejectAll = false;
    @track result;
    @track error;
    @api showDetails = false;
    @track selectedValues;
    @track finalList = [];
    @api trueVar = false;
    @track emptyVar;
    @track remark;
    @api isLoading = false;
		@track isSpinner = false;
    
    categoryData = [];
    get options() {
        return [
            { label: 'Accepted', value: 'Accepted' },
            { label: 'Rejected', value: 'Rejected' },
        ];
    }
    @wire (checkGenerateWelcomeCallChecklist,{recId : '$recordId'}) fetchData ({data,error}){
        if (data) {
            this.data = data;
            console.log('needToShow is::' + JSON.stringify(this.data));
            let needToShow = false;
            for (let i = 0; i < this.data.length; i++) {
                if (this.data[i].Id) {
                    needToShow = true;
                    break;
                }
            }
            if (needToShow) {
                this.showButton = true;
            } else {
               
                this.showButton = false;
                this.showDetails = true;
                this.getWelcomeCallChecklist();
            }
        } else if (error) {
            this.error = error;
        }
    }
    generateWelcomeCall(){
        this.isLoading = true;
        this.showButton = false;
        changeGenarateCheckBoxValue({ rId: this.recordId })
        .then(result => {
            console.log('result is::'+JSON.stringify(this.result));
            this.showDetails = true;
            if(this.showDetails === true){
                this.getWelcomeCallChecklist();

            }
        })
        .catch(error => {
            console.error('error is::'+JSON.stringify(this.error));
        });
    }

    getWelcomeCallChecklist() {
       
        getWelcomCallDetails({bId : this.recordId})
        .then(result=>{
            this.wccList = result; 
            this.isLoading = false;   
            console.log('this.wccList is::'+JSON.stringify(this.wccList));     
            let categories = new Map();
            this.wccList.forEach(item => {
                let categoryName = item.Category__c;
                if (!categories.has(categoryName)) {
                    categories.set(categoryName, []);
                }
                categories.get(categoryName).push(item);
            });
            this.categoryData = Array.from(categories, ([categoryName, items]) => ({categoryName, items}));
        })
        .catch(error => {
            this.error = error;
            console.log('this.error is::'+JSON.stringify(this.error));  
        });
    }

    handleOptions(event){

        this.selectedValues = event.detail.value;
        console.log('selectedValues: '+this.selectedValues);
       

        const key = parseInt(event.target.dataset.key);
        console.log(key);

        const idx = parseInt(event.target.dataset.idx);

        const category = this.categoryData[key];
        console.log('this.categoryData[key] :: ' +JSON.stringify(this.categoryData[key]));

        const item = category.items[idx];
        console.log('item :: ' +JSON.stringify( category.items[idx]));

        if (this.selectedValues == 'Accepted') {
            var newEntry = {Id: item.Id,
                            Decision__c: 'Accepted',
                            Accepted__c : true
                            }
        }
        else{
            var newEntry = {Id: item.Id,
                            Decision__c: 'Rejected',
                            Accepted__c : false
                            }
            console.log(item.Decision__c);

        }
        this.finalList.push(newEntry);
        console.log('fin list is::'+JSON.stringify(this.finalList));
    }

    handleAllAcceptChange(event) {
        this.acceptAll = event.target.checked;
        console.log('acceptAll: '+this.acceptAll);
        if (this.acceptAll) {
            this.rejectAll = false; 
            this.selectedval = this.options[0].value;
        } else {
            this.selectedval = '';
        }
    }

    handleAllRejectChange(event) {
        this.rejectAll = event.target.checked;
        console.log('acceptAll: '+this.rejectAll);

        console.log('')
        if (this.rejectAll) {
            this.acceptAll = false; 
            this.selectedval = this.options[1].value;
        } else {
            this.selectedval = '';
        }
    }

    handleRemarks(event){
        this.remark = event.target.value;
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
    
    handleSave() {
        if (!this.remark || this.remark.trim() === '') {
            this.showToast('Error', 'Please Enter Remarks.', 'error');
            return;
				}
        // }else if( !this.acceptAll && !this.rejectAll){
        //     this.showToast('Error', 'Please Select AcceptAll or RejectAll ', 'error');
        //     return;
        // }
        let updatedRecords = [];
        if (this.acceptAll) {
            this.wccList.forEach(item => {
                if (!item.Accepted__c) {
                    updatedRecords.push({
                        Id: item.Id,
                        Decision__c: 'Accepted',
                        Accepted__c: true
                    });
                }
            });
        } else if (this.rejectAll) {
            this.wccList.forEach(item => {
                if (!item.Accepted__c) {
                    updatedRecords.push({
                        Id: item.Id,
                        Decision__c: 'Rejected',
                        Accepted__c: false
                    });
                }
            });
        }
        if (updatedRecords.length > 0 || this.finalList.length > 0) {
            console.log('updatedRecords are::' + JSON.stringify(updatedRecords));
						 this.isSpinner = true;
            updateRecords({ records: updatedRecords, finalList: this.finalList, bookId: this.recordId, rem: this.remark })
                .then(result => {
                    this.showSuccess();
							    	window.location.href = '/' + result;
								 })

							
// 								
//                     let delay = 1000;
//                     setTimeout(() => {
//                         window.location.href = 'https://customization-velocity-7183--satyamsb.sandbox.lightning.force.com/lightning/r/Booking__c/' + this.recordId + '/view';
//                     }, delay);
//                
                .catch(error => {
                    this.error = error;
                    console.log('this.error is::'+JSON.stringify(this.error));
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: this.message,
                        variant: "error"
                    });
                    this.dispatchEvent(evt);
                });
        }
    }

    
    showSuccess() {
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Records Updated Successfully",
            variant: "success"
        });
        this.dispatchEvent(evt);
    }
}