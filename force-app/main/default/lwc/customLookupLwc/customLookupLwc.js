/* eslint-disable @lwc/lwc/valid-api */
/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable default-case */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable eqeqeq */
// Edited by Harshal More
// Date : 05/09/2024 
import { LightningElement,api} from 'lwc';
import fetchLookupData from '@salesforce/apex/Ex_SiteVisitFormController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/Ex_SiteVisitFormController.fetchDefaultRecord';
const DELAY = 300; // dealy apex callout timing in miliseconds  


export default class CustomLookupLwc extends LightningElement {
  // public properties with initial default values 
//   @api label = 'custom lookup label';
  @api placeholder = 'search...'; 
  @api iconName = 'standard:account';
  @api sObjectApiName = 'Channel_Partner__c';
  @api defaultRecordId = '';
  @api lstResult = [];   
  hasRecords = true; 
  @api searchKey='';   
  isSearchLoading = false; 
  delayTimeout;
  selectedRecord = {};
  @api searchName;
  @api searchNameSourcing;
  @api projectId; // add projectId attribute
  @api value; 
  // eslint-disable-next-line no-undef
  @api storeprojectId = '';
  @api prefilled = '';
  connectedCallback(){
    this.storeprojectId = this.projectId;
    //alert('projectId: '+this.projectId);
    console.log('sourcing Manager: '+this.defaultRecordId);
    console.log('this.sObjectApiName: '+this.sObjectApiName);
    if(this.storeprojectId && this.sObjectApiName === 'user'){
        if(this.prefilled === ''){
            this.calldefaultlookup();
        }
    }
    if(this.storeprojectId && this.sObjectApiName === 'Channel_Partner__c'){
        if(this.prefilled === ''){
            this.calldefaultlookup();
        }
    }

  }

  

  handlefetchLookupdata(){
    console.log('handlefetchLookupdataafter: ' + this.searchKey);
    console.log('sObjectApiName: ' + this.sObjectApiName);
    console.log('storeprojectId: ' + this.storeprojectId); 

    if(this.sObjectApiName === 'Channel_Partner__c'){
        this.callLookup();
    }
    if(this.sObjectApiName === 'user'){
        this.prefilled = 'no';
        this.callLookup();
    }
   
  }

  calldefaultlookup(){
    if(this.defaultRecordId != ''){
        fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName, projectId: this.storeprojectId})
        .then((result) => {
            if(result != null){
                this.selectedRecord = result;
                this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
            }
        })
        .catch((error) => {
            this.error = error;
            this.selectedRecord = {};
        });
     }
  }

  callLookup(){
    fetchLookupData({ searchKey: this.searchKey , sObjectApiName : this.sObjectApiName, projectId: this.storeprojectId})
  .then((result) => {
    console.log('result: '+JSON.stringify(result));
    //const { data, error } = result; // destructure the provisioned value
    //this.isSearchLoading = false;
    if (result) {
         this.hasRecords = result.length == 0 ? false : true; 
         console.log('this.hasRecords: '+JSON.stringify(this.hasRecords));
         this.lstResult = JSON.parse(JSON.stringify(result)); 
         console.log('this.lstResult: '+ JSON.stringify(this.lstResult));
     }}).catch(error => {
        //this.error = error;
        console.log('error fetchLookupData: ' + JSON.stringify(error));
    }).catch(error => {
        console.error('An unexpected error occurred:', error);
    });
  }

 
  handleKeyChange(event) {
    //alert('Inside handleKeychange: ');
     // this.isSearchLoading = true;
      window.clearTimeout(this.delayTimeout);
      this.searchKey = event.target.value;
      this.projectId = event.target.projectid;
      console.log('projectId: '+ this.storeprojectId);
      console.log('searchKey: '+ this.searchKey);
    //   this.delayTimeout = setTimeout(() => {
    //   this.searchKey = searchKey;
    //   }, DELAY);
      console.log('this.searchKey: '+this.searchKey);
      if(this.searchKey != ''){
        this.handlefetchLookupdata();
      }


  }

  // method to toggle lookup result section on UI 
  toggleResult(event){
    //alert('Inside toggleResult: ');
      const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
      const clsList = lookupInputContainer.classList;
      const whichEvent = event.target.getAttribute('data-source');
      switch(whichEvent) {
          case 'searchInputField':
              clsList.add('slds-is-open');
             break;
          case 'lookupContainer':
              clsList.remove('slds-is-open');    
          break;                    
         }
  }
 // method to clear selected lookup record  
 handleRemove(){
  this.searchKey = '';    
  this.selectedRecord = {};
  this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
  
  const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
   searchBoxWrapper.classList.remove('slds-hide');
   searchBoxWrapper.classList.add('slds-show');
   const pillDiv = this.template.querySelector('.pillDiv');
   pillDiv.classList.remove('slds-show');
   pillDiv.classList.add('slds-hide');
}
handelSelectedRecord(event){   
   var objId = event.target.getAttribute('data-recid'); 
   this.selectedRecord = this.lstResult.find(data => data.Id === objId); 
   this.lookupUpdatehandler(this.selectedRecord); 
   this.handelSelectRecordHelper(); 
}

handelSelectRecordHelper(){
  this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
   const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
   searchBoxWrapper.classList.remove('slds-show');
   searchBoxWrapper.classList.add('slds-hide');
   const pillDiv = this.template.querySelector('.pillDiv');
   pillDiv.classList.remove('slds-hide');
   pillDiv.classList.add('slds-show');     
}

lookupUpdatehandler(value){    
  const oEvent = new CustomEvent('lookupupdate',
  {
      'detail': {selectedRecord: value}
  }
);
this.dispatchEvent(oEvent);
}
}