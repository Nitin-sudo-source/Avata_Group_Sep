import { LightningElement, track, api, wire } from 'lwc';
// import getCampaign from '@salesforce/apex/Ex_CallCustomerServices.getCampaign';//getProject
// import getProjectId from '@salesforce/apex/Ex_CallCustomerServices.getProjectId';//getProject//getPreregistration
// import getPreregistration from '@salesforce/apex/Ex_CallCustomerServices.getPreregistration';

export default class Ex_CallCustomerCTI extends LightningElement {
    //@api lead;
   // @api preId;
   // @api recordId;
   // @track getcampList = [];

    /*//get  Project from Lead
    @wire(getProjectId ,{lId: '$recordId'})
    getProjectId({ data }) {
        if (data) {
            this.lead = data;
           // alert('Record:'+JSON.stringify(this.lead));
        }else{
            this.lead = '';
        }
    }

    //getPreregistration
    @wire(getPreregistration ,{preId: '$recordId'})
    getPreregistration({ data }) {
        if (data) {
            this.preId = data;
           // alert('Record:'+JSON.stringify(this.lead));
        }
    }

    //get All Project Campaign
    @wire(getCampaign, { lead: "$lead", preId: "$preId"})
    getCampaigns({ data, error }) {
        let arr = [];
        if (data) {
            for (var i = 0; i < data.length; i++) {
                arr.push({ label: data[i], value: data[i] });
            }
            this.getcampList = arr;
            //console.log('getcampList: '+JSON.stringify(this.getcampList));
        }
        else if (error) {
            this.error = error;
            this.getcampList = undefined;
        }
    }*/
}