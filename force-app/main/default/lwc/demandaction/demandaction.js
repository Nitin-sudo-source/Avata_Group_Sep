import { LightningElement ,api,track} from 'lwc';
import demandobject from '@salesforce/schema/Demand__c';
import demand from '@salesforce/apex/Ex_DemandAction.demandrecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';



export default class Demandaction extends NavigationMixin (LightningElement) {

@api recordId;
@track Selectoption;
@track Remarksvalue;
@track isSaving = false; 

demandobjectapi = demandobject;
value = '';
get options() {
return [
{ label: 'Delete', value: 'Delete' },
{ label: 'Reverse', value: 'Reverse' },
];
}

handleRadioChange(event) {
    this.Selectoption = event.target.value;
    console.log(this.Selectoption);
}

handleremark(event){
    this.Remarksvalue = event.target.value;
    console.log(this.Remarksvalue);
}

Save(){
this.showSpinner = true;

if(this.Selectoption == undefined){
       const Aevents = new ShowToastEvent({
            title: 'Error',
            message: 'Please select Demand Action',
            variant: 'Error'
        })
        this.dispatchEvent(Aevents);
        setTimeout(() => {
            this.isSaving = false;
        }, 10000);

     }else if(this.Remarksvalue == undefined){
          const Revents = new ShowToastEvent({
            title: 'Error',
            message: 'Please enter Remarks',
            variant: 'Error'
        })
        this.dispatchEvent(Revents);
        setTimeout(() => {
            this.isSaving = false;
        }, 10000);
    } else {
        demand({Selectoption : this.Selectoption, Remarks: this.Remarksvalue, recordId: this.recordId})
        .then((result) => {
            this.result = result;  
            if (this.result === true && this.Selectoption == 'Reverse') {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Reversed Successfully.',
                        variant: 'Success'
                    })
                    this.dispatchEvent(event);
                    this.navigateToViewDemandPage();
                    setTimeout(() => {
                        this.isSaving = false;
                    }, 10000);

             }else if(this.result === true && this.Selectoption == 'Delete'){    
                  const events = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record Deleted successfully.',
                    variant: 'Success'
                })
                this.dispatchEvent(events);
                this.navigateToHomePage();
                setTimeout(() => {
                    this.isSaving = false;
                }, 10000);
            } 
            else {
                   const errevents =  new ShowToastEvent({
                    title : 'Error',
                    message : 'Error occured while processing. Please Contact System Adminstrator',
                    variant : 'error'
                })
                this.dispatchEvent(errevents);
                this.navigateToViewDemandPage();
                setTimeout(() => {
                    this.isSaving = false;
                }, 10000);
             }
      });
      
    /*  .catch(error =>{
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Error occured',
            variant: 'Error'
        })
        this.dispatchEvent(evt); 
        setTimeout(() => {
            this.isSaving = false;
        }, 10000);
        
    }) */
   }
  }
    navigateToViewDemandPage() {
        console.log('RecordId:  ' +this.recordId);
        console.log('Demand:  ' +this.Demand__c);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Demand__c',
                actionName: 'view'
            },
        });
    }

    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
               pageName: 'home'
           },
        });
       } 
}