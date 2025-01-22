import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import createBlockingRecord from '@salesforce/apex/EX_BlockingDetailsController.createBlockingRecord'
import unblockLogic from '@salesforce/apex/EX_BlockingDetailsController.unblockLogic';
import fetchUnits from '@salesforce/apex/EX_BlockingDetailsController.fetchUnits';
import getBlockDetails from '@salesforce/apex/EX_BlockingDetailsController.getBlockDetails';
import getOppName from '@salesforce/apex/EX_BlockingDetailsController.getOppName';
import getModeOfFundingPicklist from '@salesforce/apex/EX_BlockingDetailsController.getModeOfFundingPicklist';

import { NavigationMixin } from "lightning/navigation";
export default class BlockingDetailPage extends NavigationMixin(LightningElement) {
  // searchUnit = '';
  @track blockData;
  selected = null;
  unblockComment;
  clickBtn = '';
  boolVisible = false;
  units = [];
  untNm = '';
  @track blockId;
  blockWithoutTokenCheckbox = false;
  blockWithTokenCheckbox = false;
  blockWithoutTokenCheckbox1 = false;
  blockWithTokenCheckbox1 = false;
  blockAmount;
  chequeNo;
  blockComment;
  @track unitTrue = true;
  @api uniValue;
  @api oppvalue;
  @api projValue;
  @track projectName;
  @track towerName;
  @track oppName;
  @track blockAmount1;
  @track MOPpicklist = [];
  @track MOPpicklistValue = ''
  connectedCallback() {
    console.log('Received uId in ex_CreateQuate:', this.uniValue);
    console.log('Received pId in ex_CreateQuate:', this.projValue);
    console.log('Received oId in ex_CreateQuate:', this.oppvalue);

  }
  @wire(getModeOfFundingPicklist)
  wiredPicklistValues({ error, data }) {
      if (data) {
          this.MOPpicklist = data.Mode_of_Payment__c.map(item => ({
              label: item,
              value: item
          }));
        }
      }
  @wire(fetchUnits, { uniId: '$uniValue' })
  units({ data, error }) {
    if (data) {
      this.units = data;
      this.untNm = this.units[0].Name;
      this.projectName = this.units[0].Project__r.Name;
      this.towerName = this.units[0].Tower__r.Name
      console.log(this.units[0].Sale_Status__c);
      if (this.units[0].Sale_Status__c == 'Vacant') {
        this.unitTrue = false;
        this.clickBtn = 'Confirm Blocking'
      } else {
        this.unitTrue = true;
        this.clickBtn = 'Unblock'
      }
    }
    if (error) {
      console.error(error);
    }
  }
  @wire(getOppName, { oppId: '$oppvalue' })
  opportunity__c({ data, error }) {
    if (data) {
      this.oppName = data[0].Name;
    }
  }
  @wire(getBlockDetails, { uniId: '$uniValue' })
  blockdetail({ data, error }) {
    if (data) {
      this.blockData = data;
      this.blockId = data.Id;
      console.log(' blockId', JSON.stringify(this.blockId));
      console.log(' this.blockData', JSON.stringify(this.blockData));
      this.blockWithTokenCheckbox = data.Blocked_by_token__c;
      console.log(this.blockWithTokenCheckbox );
      this.blockAmount = data.Amount__c;
      this.chequeNo = data.Cheque_Number__c;
      this.blockComment = data.Blocking_Comment__c;
    }
  }

  BlockWithTokenHandler(event) {
    this.blockWithTokenCheckbox1 = event.target.checked;
  }
  amountHandler(event) {
    this.blockAmount1 = event.target.value;
  }
  chequeNoHandler(event) {
    this.chequeNo = event.target.value;
  }
  commentHandler(event) {
    this.blockComment = event.target.value;
  }
  commentHandler(event) {
    this.blockComment = event.target.value;
  }
  UnblockcommentHandler(event) {
    this.unblockComment = event.target.value;
  }
  handleMOPChange(event){
    this.MOPpicklistValue = event.target.value; 
    console.log(this.MOPpicklistValue);
  }
  BlockingHandler(event) {

    this.selected = this.clickBtn;
    if (this.selected === 'Confirm Blocking') {
      if (this.blockWithTokenCheckbox1 === true && ((this.blockAmount1 === undefined || this.blockAmount1 === '' )  || (this.MOPpicklistValue === undefined || this.MOPpicklistValue === '')  || (this.chequeNo === undefined || this.chequeNo === ''))) {
        const event = new ShowToastEvent({
          title: 'Error !!',
          message: 'Please Enter Amount , Mode of Payment and Transaction ID !',
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
      }else if(this.blockComment === undefined || this.blockComment === ''){
        const event = new ShowToastEvent({
          title: 'Error !!',
          message: 'Please Enter Block Comment!',
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
      }
      else{
        createBlockingRecord({ blockByToken: this.blockWithTokenCheckbox1, amount: this.blockAmount1, blockComment: this.blockComment, chequeNo: this.chequeNo, unitName: this.uniValue, oppId: this.oppvalue ,MOPpicklistValue :this.MOPpicklistValue})
          .then((result) => {
              this.showToastMsg('Success', 'Blocking record created successfully');
              var compDefinition = {
                componentDef: "c:ex_InventoryComponent",
                attributes: {
                  oppId: this.oppvalue
                }
              };
              var encodedCompDef = btoa(JSON.stringify(compDefinition));

              var url = "/one/one.app#" + encodedCompDef;
              console.log(url);

              var link = document.createElement('a');
              window.close();
              link.href = url;
              link.target = '_self';
              link.click();
              console.log("BlockingDetailResult: ", result);
              location.reload();

            getRecordNotifyChange([{ recordId: this.recordId }])
          }).catch(error => {
            this.showToastMsg('Error in creating  blocking record', error.body.message, error)
            console.error(error);
          })
        if ((this.blockWithTokenCheckbox1 === true && this.blockAmount != null && this.chequeNo != null)) {
          this.boolVisible = true;
        }
      }
    
    }
    else if (this.selected === 'Unblock') {
      if (!this.unblockComment) {
        const event = new ShowToastEvent({
          title: 'Error  !!',
          message: 'Please Enter Unblock Comment!',
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
      } else {
        unblockLogic({ blockId: this.blockId, unblockComment: this.unblockComment }).then((result) => {
          console.log("UnblockResult: ", JSON.stringify(result));
          if (this.unblockComment) {
            this.showToastMsg('Success!!', 'block and unit status updated successfully!');
            var compDefinition = {
              componentDef: "c:ex_InventoryComponent",
              attributes: {
                oppId: this.oppvalue
              }
            };
            var encodedCompDef = btoa(JSON.stringify(compDefinition));

            var url = "/one/one.app#" + encodedCompDef;
            console.log(url);

            var link = document.createElement('a');
            window.close();
            link.href = url;
            link.target = '_self';
            link.click();
            location.reload();
          }

        }).catch(error => {
          this.showToastMsg('Error in updating record', error.body.message, error);
          console.error(error);
        })
        this.boolVisible = false;
      }
    }
  }

  showToastMsg(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant || 'Success'
      })
    )
  }

}