/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 05-06-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, wire, track } from 'lwc';
import OBJECT from '@salesforce/schema/Construction_Stage__c';
import Actual_Completion_Date__c from '@salesforce/schema/Construction_Stage__c.Actual_Completion_Date__c';
import Expected_Completion_Date__c from '@salesforce/schema/Construction_Stage__c.Expected_Completion_Date__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Cosnstructionupdate from '@salesforce/apex/Ex_ConstructionStageUpdate.Cosnstructionupdate';
import getFloor from '@salesforce/apex/Ex_ConstructionStageUpdate.getFloor';
import saveMethod from '@salesforce/apex/Ex_ConstructionStageUpdate.saveMethod';
import getCosnstructionStage from '@salesforce/apex/Ex_ConstructionStageUpdate.getCosnstructionStage';


export default class Ex_ConstructionStageUpdate extends NavigationMixin(LightningElement) {

    @api recordId;
    Namess;
    @track csfetch;
    @api csfetch2 = [];
    @api Name;
    @api projectName;
    @api ActualDate;
    @api ExpectedDate = undefined;

    @track SelectPhase = '';
    @track selectedOption;
    isExpectedDateSelected = false;
    isActualDateSelected = false;
    csName;
    maxDate;
    @track isFileSelected = false;
    isConstructionStageSelected = false;
    showSpinner = false;
    objectApi = OBJECT;
    //Project__c = Project__c;
    //Tower__c = Tower__c;
    Actual_Completion_Date__c = Actual_Completion_Date__c;
    Expected_Completion_Date__c = Expected_Completion_Date__c;
    _selected = [];
    selectedFloorId;
    @api date;
    boolean = false;
    showFloorOption = false;
    @track fileData = [];
    @track showFileName = '';
    @track isError = false;
    @track csId;
    EnterExpectedDate = false;
    @track isSpinner = false;

    @wire(Cosnstructionupdate, { recordID: '$recordId' })
    fet({ data, error }) {
        if (data) {
            if (data.length === 0) {
                const evt = new ShowToastEvent({
                    title: 'No construction stages',
                    message: 'There are no construction stages on this tower.',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            } else {
                this.csfetch = data;
                console.log('Data' + JSON.stringify(this.csfetch));
                this.Name = this.csfetch[0].Tower__r.Name;
                this.projectName = this.csfetch[0].Tower__r.Project__r.Name;
                console.log('Project' + this.projectName);
                this.ActualDate = this.csfetch[0].Actual_Completion_Date__c;
                this.ExpectedDate = this.csfetch[0].Expected_Completion_Date__c;

                this.cstage = data.map(item => {
                    return {
                        label: item.Name,
                        value: item.Id
                    }
                });
            }
        } else if (error) {
            console.error(error);
        }
    }
    Handleunitcheckbox(event) {
        getCosnstructionStage({ recordID: this.csId })
            .then(result => {
                this.boolean = result[0].Unit_Wise_Milestone__c;
                console.log(this.boolean);
                if (this.boolean === true) {
                    this.showFloorOption = true;
                } else {
                    this.showFloorOption = false;

                }
            })

    }


    handlePhaseChange(event) {
        this.csId = event.detail.value;
        console.log('CsID' + this.csId);
        // getCosnstructionStage({recordID: this.csfetch })
        this.Handleunitcheckbox();
        if (this.csId) {
            this.isConstructionStageSelected = true;
        } else {
            this.isConstructionStageSelected = false;
        }
    }


    @wire(getFloor, { recordID: '$recordId' })
    floorData;

    // get floorOptions() {
    //     let options = [{ label: '', value: '' }];
    //     if (this.floorData.data) {
    //         for (let floorNum in this.floorData.data) {
    //             options.push({ label: '' + floorNum, value: floorNum });
    //         }
    //     }
    //     return options;
    // }

    get floorOptions() {
    let options = [];
    if (this.floorData?.data) {
        for (let floorNum in this.floorData.data) {
            options.push({ label: floorNum.toString(), value: floorNum });
        }
    }
    return options;
}


    get selected() {
        return this._selected.length ? this._selected : 'None';
    }

    handleChange(event) {
        this._selected = event.detail.value;
        console.log(this._selected);
    }


    get options() {
        return [
            { label: 'Actual Completion Date', value: 'Actual Completion Date' },
            { label: 'Expected Completion Date', value: 'Expected Completion Date' },
        ];
    }

    handleRadioChange(event) {
        this.selectedOption = event.target.value;
        console.log(' date' + this.selectedOption);
        if (this.selectedOption === 'Expected Completion Date') {
            this.isExpectedDateSelected = true;
            this.isActualDateSelected = false;
            this.isFileSelected = false;

        } else if (this.selectedOption === 'Actual Completion Date') {
            this.isActualDateSelected = true;
            this.isExpectedDateSelected = false;

        } else {
            this.isExpectedDateSelected = false;
            this.isActualDateSelected = false;
        }
    }



    handleactualcompletion(event) {
        this.ActualDate = event.target.value;
        console.log(this.ActualDate);
    }

    handleexpectedcompletion(event) {
        this.ExpectedDate = event.target.value;
        console.log(this.ExpectedDate);
    }

    handleFloorSelection(event) {
        this.selectedFloorId = event.target.value;
    }


    handleFileChange(event) {
        this.isFileSelected = true;
        const file = event.target.files[0];
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64

            }
            this.showFileName = file.name;
            console.log('File Name: ' + JSON.stringify(this.showFileName));
        }
        reader.readAsDataURL(file)
    }
    //Validation rule is applied on this method.
    handleSaveNew() {
        //alert('d : '+this.date);
        let currentDate = new Date().toISOString().slice(0, 10);
        //alert('csId:  '+ this.csId);  
        // alert('this.ExpectedDate: '+this.ExpectedDate);          
        if (this.csId === undefined) {
            this.isError = true;
            // alert('this.isConstructionStageSelected:'+this.isConstructionStageSelected);
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select Construction Stage to Proceed',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);

        } else if (!this.isActualDateSelected && !this.isExpectedDateSelected) {
            this.isError = true;
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select Either Actual or Expected Completion date to proceed.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;
        } else if (this.isActualDateSelected && !this.ActualDate) {
            this.isError = true;
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select Actual completion date .',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;

        }else if(this.isActualDateSelected == true && (this.showFileName == '' || this.showFileName === '')){
            this.isError = true;
           const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select file to upload .',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;

        } else {
            if (this.ActualDate && this.ActualDate > currentDate) {
                this.isError = true;
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'You cannot select a future date for Actual Completion Date.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);

            } else if (this.ExpectedDate == undefined && this.isExpectedDateSelected == true) {
                this.isError = true;
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Select Expected Completion Date',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);

            }
            else {
                this.isError = false;
                // alert('this.isError : '+ this.isError);
                if (this.selectedOption === 'Actual Completion Date') {
                    this.date = this.ActualDate;
                    console.log('Actual Date::::' + this.date);
                } else if (this.selectedOption === 'Expected Completion Date') {
                    this.date = this.ExpectedDate;
                    console.log('Expected Date : ' + this.date);
                }
                if (!this.isError) {
                    this.isSpinner = true;

                    saveMethod({
                        options: this.selectedOption,
                        d: this.date,
                        recordId: this.csId,
                        floors: this._selected,
                        base64: this.fileData.base64,
                        filename: this.fileData.filename
                    })
                        .then(result => {
                            this.isSpinner = false;

                            // Handle success
                            console.log('Fields updated successfully.' + result);
                            const toastEvent = new ShowToastEvent({
                                title: 'Success!',
                                message: 'Construction Stage record saved successfully.',
                                variant: 'success'
                            });
                            this.dispatchEvent(toastEvent);
                            window.location.href = '/' + this.csId;
                        })
                        .catch(error => {
                            // Handle error
                            console.error(error);
                        });


                    //  this.navigateToRecord();
                    //  location.reload();
                }

            }
        }
    }
}