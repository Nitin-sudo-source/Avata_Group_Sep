import { LightningElement, track, api, wire } from 'lwc';
import getMobileNumber from '@salesforce/apex/Ex_CallCustomerServices.getMobileNumber';
import getCampaign from '@salesforce/apex/Ex_CallCustomerServices.getCampaign';
import ClickToCall from '@salesforce/apex/Ex_CallCustomerServices.ClickToCall';
import FORM_FACTOR from '@salesforce/client/formFactor';


export default class Ex_CallCustomerLWC extends LightningElement {
    @api recordId;
    @track call = [];
    @track selectedNo;
    @track selectedcamp;
    @track getcampList = [];
    @track isError = '';
    @api formType;
    @track response = '';
    @track isSpinner = false;
    @track didNo;

    connectedCallback(){
        //alert('FORM_FACTOR: '+FORM_FACTOR);
        this.formType = FORM_FACTOR;
        console.log('formType: '+this.formType);
    }
    @wire(getCampaign, { recordId: '$recordId' , getFormType: '$formType'})
    getCampaigns({ data, error }) {
        console.log('this.getcampList :'+JSON.stringify(data));
        let arr = [];
        if (data != null) {
            for (var i = 0; i < data.length; i++) {
                arr.push({ label: data[i].ozoneTelcampName, value: data[i].didNumber });
            }
            this.getcampList = arr;
            console.log('this.getcampList :'+JSON.stringify(this.getcampList));
            this.isError = '';
        }else if(data == null || this.getcampList == undefined){
            this.getcampList = null;
            this.isError = 'No Available Campaign Found for Calling';
        }
    }

    @wire(getMobileNumber, { recordId: '$recordId' })
    getNumber({ data }) {
        if (data) {
            this.call = data;
            console.log('Record:' + JSON.stringify(this.call));
        } else {
            this.call = '';
        }
    }
    handlecamp(event) {
        this.selectedcamp = event.target.options[0].label;
        //alert('call: ' + JSON.stringify(this.selectedcamp));
        this.didNo = event.target.value;
       // alert('didNo : '+this.didNo);
    }

    handlecall(event) {
    if(this.selectedcamp == undefined){
        alert('Please Select Campaign to Call')
        return ;
    }else{
        this.selectedNo = event.target.dataset.id;
        //console.log('selectedNo : '+this.selectedNo);
        this.handleClickToCall();
    }
        
    }

    handleClickToCall() {
       // alert('this.recordId: '+this.recordId);
        this.isSpinner = true;
       
      //  alert('Calling..........'+ this.selectedNo + 'campName: '+this.selectedcamp);
        ClickToCall({ customerPh: this.selectedNo, campaignName: this.selectedcamp, did: this.didNo, getFormType: this.formType, uui: this.recordId }).then((result) => {
            console.log('Result: '+JSON.stringify(result));
            if(result){
                console.log('Result: '+JSON.stringify(result));
                this.response = result;
                this.isSpinner = false;
            }else{
                this.isError = 'Error Occur Something Went Wrong';
            }
        })
            .catch((error) => {
                this.error = error;
            });
    }

}