/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 28-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, wire, track } from 'lwc';
import getProject from '@salesforce/apex/Ex_BulkDemandDownload.getProject';
import getTower from '@salesforce/apex/Ex_BulkDemandDownload.getTower';
import getCS from '@salesforce/apex/Ex_BulkDemandDownload.getCS';
import updateEmailSentOnDemandRecords from '@salesforce/apex/Ex_BulkDemandDownload.updateEmailSentOnDemandRecords';
import fetchFiles from '@salesforce/apex/Ex_BulkDemandDownload.fetchFiles';
import updateIsDownloaded from '@salesforce/apex/Ex_BulkDemandDownload.updateIsDownloaded';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import MY_IMAGE from '@salesforce/resourceUrl/BulkDemandDownload_IsLoading';


export default class Ex_BulkDemandDownload extends NavigationMixin(LightningElement) {

  @track projectId = null;
  @track towerId = null;
  @track csId = null;
  checkboxesState = {};
  @track demandtype = null;
  @api objectApiName;
  @api recordId;
  @track demandId = '';
  @track demandData = [];
  @track currentPage = 1;
  @track pageSize = 10;
  @track index = 0;
  @track selectedList = [];
  @track updateList = [];
  @track finalList1 = [];
  @track selectedFiles = new Set();
  @track url = [];
  @track finalurl;
  @track downloadLink = '';
  @track isDownloadCheck;
  @track valueList = [];
  @track isSpinner = false;
  @track showSpinner = false;
  @track selectAllcheckBox;
  @track showTable = false;
  @track selectedFinalist = [];
  @track reminderType = '';

  @wire(getProject)
  projectResult;
  @wire(getTower, { ProjectId: '$projectId' })
  towerResult;
  @wire(getCS, { TowerId: '$towerId' })
  csResult;


  get projectOptions() {
    return this.projectResult.data ? this.projectResult.data.map(p => ({ label: p.Name, value: p.Id })) : [];
  }

  get towerOptions() {
    return this.towerResult.data ? this.towerResult.data.map(t => ({ label: t.Name, value: t.Id })) : [];
  }

  get csOptions() {
    let options = [];
    if (this.csResult.data) {
      options.push({ label: 'All', value: 'All' });
      options.push({ label: 'Date Linked', value: 'Date Linked' });
      options.push({ label: 'Registration Linked', value: 'Registration Linked' });

      options.push(...this.csResult.data.map(c => ({ label: c.Name, value: c.Id })));
    }
    return options;
  }


  get demandOptions() {
    return [
      { label: 'All Demands', value: 'All Demands' },
      { label: 'Fresh', value: 'Fresh' }
      // { label: 'Reminder 1', value: 'Reminder 1' },
      // { label: 'Reminder 2', value: 'Reminder 2' },
      // { label: 'Reminder 3', value: 'Reminder 3' }
    ];
  }


  get totalPages() {
    return Math.ceil(this.demandData.length / this.pageSize);
  }
  get startRecord() {
    return (this.currentPage - 1) * this.pageSize;
  }
  get endRecord() {
    return Math.min(this.startRecord + this.pageSize, this.demandData.length);
  }
  get currentPageData() {
    return this.demandData.slice(this.startRecord, this.endRecord);
  }
  get isPreviousDisabled() {
    return this.currentPage === 1;
  }
  get isNextDisabled() {
    return this.currentPage === this.totalPages;
  }
  handleReset() {
    location.reload();
  }

  get arraySize() {
    return this.finalList1.length;
  }


  handleProjectChange(event) {
    console.log(this.projectResult.data);
    this.projectId = event.target.value;
    //alert(this.projectId);
  }


  handleTowerChange(event) {
    this.towerId = event.target.value;
    //alert(this.towerId);
  }


  handleCSChange(event) {
    this.csId = event.target.value;
    console.log(this.csId);
  }


  handleViewChange(event) {
    let value = event.target.value;
    this.demandtype = value;
    if (value == "Reminder 1" || value == "Reminder 2" || value == "Reminder 3") {
      this.reminderType = value;
    }
    else {
      this.reminderType = '';
    }
  }


  fetchDocumentRecords(event) {
    if(this.projectId === null){
      this.showToast('Error !','Please select the Project', 'Error');
      return;
      
    }else if(this.towerId === null){
      this.showToast('Error !','Please select the Tower', 'Error');
      return;


    }else if(this.demandtype === null){
      this.showToast('Error !','Please select the View', 'Error');
      return;


    }else if(this.csId === null){
      this.showToast('Error !','Please select the Milestone Type', 'Error');
      return;


    }else{
      this.showTable = false;
      this.isSpinner = true;
      fetchFiles({ objectName: 'Demand__c', CSId: this.csId, TowerId: this.towerId, Dtype: this.demandtype })
        .then((result) => {
          this.demandData = result.map((item, index) => ({
            ...item,
            contentSizeKB: (item.contentSize / 1024).toFixed(2) + 'KB',
            isSelected: false,
            isDownloaded: item.isDownloaded,
            "url": `/sfc/servlet.shepherd/document/download/${item.contentDocumentId}`,
            "serialNumber": index + 1
          }));
          this.showTable = true;
          this.isSpinner = false;
          this.selectedList = this.demandData;
          //console.log('GetData:::' + JSON.stringify(this.demandData));
        })
        .catch((error) => {
          console.error(error);
        });
    }
  }

  opendemand(event) {
    var value = event.target.dataset.id;
    console.log(value);
    window.open(`/${value}`, '_blank');
  }


  handleAllSelected(event) {
    const checkboxes = this.template.querySelectorAll('[data-id^="checkbox"]');
    for (const ch of checkboxes) {
      ch.checked = event.target.checked;
      this.selectAllcheckBox = ch.checked;
    }
    this.handleChange(event);
  }


  handleChange(event) {
    const { name, checked } = event.target;
    this.checkboxesState = { ...this.checkboxesState, [name]: checked };
    this.visible = true;
    this.demandId = event.target.dataset.key;
    var Name = event.target.dataset.name;
    //console.log('Name: ' + Name);
    var valueset = event.target.checked;
    //console.log('valueset: ' + valueset);
    var fieldName = event.currentTarget.name;
    if (fieldName === undefined) {
      for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
        this.currentPageData[i].isSelected = false;
      }
    } else if (fieldName == 'SelectAll') {
      if (this.selectAllcheckBox == true) {
        for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
          for (var i = 0; i < this.currentPageData.length; i++) {
            const value = this.currentPageData[i].demandId;
            this.currentPageData[i].isSelected = true;
            if (!this.finalList1.includes(value)) {
              this.finalList1.push(value);
              if (!this.url.includes(this.currentPageData[i].contentDocumentId)) {
                this.url.push(this.currentPageData[i].contentDocumentId);
              }
            }
          }
          break;
        }
      } else {
        console.log('inside else this.selectAllcheckBox: ' + this.selectAllcheckBox);
        for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
          for (var j = 0; j < this.currentPageData.length; j++) {
            const value = this.currentPageData[j].demandId;
            this.currentPageData[j].isSelected = false;
            if (this.finalList1.includes(value)) {
              const index = this.finalList1.indexOf(value);
              if (index !== -1) {
                this.finalList1.splice(index, 1);
              }
            }
            if (this.url.includes(this.currentPageData[j].contentDocumentId)) {
              const index = this.url.indexOf(this.currentPageData[j].contentDocumentId);
              if (index !== -1) {
                this.url.splice(index, 1);
              }
            }
          }
          break;
        }
      }
    } else {
      for (var i = 0; i < this.selectedList.length; i++) {
        const value = this.selectedList[i].demandId;
        if (!this.selectedList[i].isDownloaded) {
          if (value == this.demandId) {
            if (valueset == true) {
              this.finalList1.push(value);
              this.url.push(Name);
            } else {
              this.finalList1 = this.finalList1.filter(finalItem => finalItem !== this.demandId);
              this.url = this.url.filter(finalItem => finalItem !== Name);
            }
          }
        } else if (this.selectedList[i].isDownloaded && !this.selectedList[i].isMailSent) {
          if (value == this.demandId) {
            if (valueset == true) {
              this.finalList1.push(value);
              this.url.push(Name);
            } else {
              this.finalList1 = this.finalList1.filter(finalItem => finalItem !== this.demandId);
              this.url = this.url.filter(finalItem => finalItem !== Name);
            }
          }
        }
      }
      for (var i = 0; i < this.currentPageData.length; i++) {
        if (this.currentPageData[i].demandId == this.demandId) {
          this.currentPageData[i].isSelected = valueset;
          break;
        }
      }
    }
    //console.log('currentPageData: ' + JSON.stringify(this.currentPageData));
    console.log('final list to send email: ' + JSON.stringify(this.finalList1));
    this.updateFinalUrl();
  }


  updateFinalUrl() {
    this.finalurl = '';
    console.log('url: ' + JSON.stringify(this.url));
    // console.log('url: ' + JSON.stringify(this.url));
    for (let i = 0; i < this.currentPageData.length; i++) {
      if (this.url.length != 0) {
        var idArray = this.url.join(',').split(',');
        this.finalurl = `/sfc/servlet.shepherd/document/download/${idArray.join('/')}`;
      }
    }
    console.log('final : ' + this.finalurl);
  }

  updateEmailSent() {
    if (this.finalList1.length === 0) {
      //this.isError = true;
      // this.errorMsg = 'Please select the checkbox before sending mail ';
      // const toastEvent = new ShowToastEvent({
      //   title: 'Error',
      //   message: this.errorMsg,
      //   variant: 'error',
      // });
      // this.dispatchEvent(toastEvent);
      this.showToast('Error !','Please select the checkbox before sending mail', 'Error');
      return;
    } else if (this.finalList1.length > 0) {
      this.isSpinner = true;
      updateEmailSentOnDemandRecords({ demandIds: this.finalList1 })
        .then(result => {
          console.log('Response: ' + JSON.stringify(result));
          this.isSpinner = false;
          if (result != null) {
            //alert(result.join("\n"));
            this.showToast('Success !', result.join("\n") , 'success');
            this.finalList1 = [];
            location.reload();
          } else {
            this.isSpinner = false;
            this.showToast('Error !','Please check customer Email or Please Contact System Administrator', 'Error');
            //alert('Error: Something went Wrong Please Contact System Administrator ');
            return ;
          }
        })
    }
  }

  handleDownload() {
    console.log('final url In Download' + JSON.stringify(this.finalurl));
    console.log('finalList1' + JSON.stringify(this.finalList1));
    if (this.finalurl == '' || this.finalurl == undefined || this.finalList1.length === 0) {
      // const showToastEvent = new ShowToastEvent({
      //   title: 'Error!',
      //   message: 'Please Select File to Download',
      //   variant: 'Error',
      // });
      // this.dispatchEvent(showToastEvent);
      this.showToast('Error !','Please Select File to Download', 'Error');
      return;
    } else {
      updateIsDownloaded({ demandIds: this.finalList1 })
        .then((result) => {
          console.log('Response: ' + JSON.stringify(result));
          this.showSpinner = true;
          // const showToastEvent = new ShowToastEvent({
          //   title: 'Success!',
          //   message: 'Attachment saved successfully. Please check your Downloads.',
          //   variant: 'success',
          // });
          // this.dispatchEvent(showToastEvent);
          this.showToast('Success !','Attachment saved successfully. Please check your Downloads.', 'success');
          setTimeout(() => {
            this.showSpinner = false;
            location.reload();
          }, 4000);
        })
        .catch(error => {
          console.log('error: ', JSON.stringify(this.error));
          console.error(error);
        });
    }
  }



  handledownloadcheck(event) {
    //event.preventDefault(); // Prevent default action of <a> tag
    //event.stopPropagation(); // Stop event bubbling

    const dId = event.target.dataset.key;
    console.log('dId' + dId);
    if (this.finalList1.length === 0 || !this.finalList1.includes(dId)) {
      this.showToast('Error !','Please Select File to Download', 'Error');
      return;
    } else if (this.finalList1.includes(dId)) {
      console.log('this.finalList1 Inside else' + JSON.stringify(this.finalList1));
      this.selectedFinalist = this.currentPageData.filter(record => record.isSelected);
      this.selectedFinalist = this.selectedFinalist.filter(record => {
        if (record.demandId === dId) {
            record.isDownloaded = true;
            if (this.finalList1.includes(dId)) {
                this.finalList1.push(dId);
                const index = this.finalList1.indexOf(dId);
                if (index !== -1) {
                  this.finalList1.splice(index, 1);
                }
            }
            return true;
          }
          return false;
      });
      this.handleDownload();
    }
  }

  get hasFilesToDownload() {
    return this.finalList1.length > 0;
}


  handlePreviousPage() {
    this.isSpinner = true;
    this.currentPage = Math.max(1, this.currentPage - 1);
    this.index = ((this.currentPage - 1) * this.pageSize);
    this.isSpinner = false;
    var allSelected = true;
    for (var i = 0; i < this.currentPageData.length; i++) {
      if (!this.currentPageData[i].isSelected) {
        allSelected = false;
        break;
      }
    }
    this.selectAllcheckBox = allSelected;
  }


  handleNextPage() {
    this.isSpinner = true;
    this.currentPage = Math.min(this.totalPages, this.currentPage + 1);
    this.index = ((this.currentPage - 1) * this.pageSize);
    this.isSpinner = false;
    var allSelected = true;
    for (var i = 0; i < this.currentPageData.length; i++) {
      if (!this.currentPageData[i].isSelected) {
        allSelected = false;
        break;
      }
    }
    this.selectAllcheckBox = allSelected;
  }


  handleRecordsPerPageChange(event) {
    this.isSpinner = true;
    const selectedValue = parseInt(event.target.value, 10);
    this.pageSize = selectedValue;
    this.currentPage = 1;
    this.isSpinner = false;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(event);
}

      
}