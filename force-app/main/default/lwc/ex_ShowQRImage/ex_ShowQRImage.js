import { LightningElement,api, track } from 'lwc';
import getProject from '@salesforce/apex/Ex_ShowQRImage.getProject';


export default class Ex_ShowQRImage extends LightningElement {
    @api recordId;
    @track getProject = {};


    connectedCallback(){
       if(this.recordId != undefined){
         this.getProjectData()
         this.generateQRCode(this.recordId);
       }
    }

    getProjectData(){
        getProject({recordId :this.recordId})
            .then(result => {
                console.log('result: '+JSON.stringify(this.result));
                this.getProject = result;
                console.log('result: '+JSON.stringify(this.getProject));
            })
            .catch(error => {
                
            });

    }

    generateQRCode(projectId) {
        const baseURL = "https://qrcode.tec-it.com/API/QRCode?data=";
        const dynamicURL = `https://velocity-innovation-745--avantsb.sandbox.my.salesforce-sites.com/SearchPage?project=${projectId}`;
        const encodedURL = encodeURIComponent(dynamicURL);
        const qrCodeURL = `${baseURL}${encodedURL}`;
        this.qrCodeURL = qrCodeURL;
        console.log('qrCodeURL: '+this.qrCodeURL);
        //return qrCodeURL;
    }
    
    
    
}