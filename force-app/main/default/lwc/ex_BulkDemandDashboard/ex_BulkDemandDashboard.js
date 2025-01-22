import { LightningElement, api, wire, track } from 'lwc';
import getProject from '@salesforce/apex/Ex_BulkDemandDashboard.getProject';
import getTower from '@salesforce/apex/Ex_BulkDemandDashboard.getTower';
import getCS from '@salesforce/apex/Ex_BulkDemandDashboard.getCS';
import updateEmailSentOnDemandRecords from '@salesforce/apex/Ex_BulkDemandDashboard.updateEmailSentOnDemandRecords';
import fetchFiles from '@salesforce/apex/Ex_BulkDemandDashboard.fetchFiles';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import MY_IMAGE from '@salesforce/resourceUrl/BulkDemandDownload_IsLoading';

export default class Ex_BulkDemandDashboard extends NavigationMixin(LightningElement) {
    projectId;
    towerId;
    @track csId = '';
    checkboxesState = {};
    demandtype;
    // imageSrc = MY_IMAGE;
    @api objectApiName;
    @api recordId;
    @track demandId = '';
    @track demandData = [];
    @track currentPage = 1;
    @track pageSize = 10;
    @track index = 0;
    @track selectedList = [];
    @track updateList = [];
    // @track finalList = [];
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
        { label: 'Fresh', value: 'Fresh' },
        { label: 'Reminder 1', value: 'Reminder 1' },
        { label: 'Reminder 2', value: 'Reminder 2' },
        { label: 'Reminder 3', value: 'Reminder 3' }
  
  
  
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
    handleReset(){
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
      let value =  event.target.value;
      this.demandtype = value;
      if(value == "Reminder 1" || value == "Reminder 2" || value == "Reminder 3"){
          this.reminderType = value;
      }
      else{
          this.reminderType = '';
      }
  
      //alert(this.demandtype);
    }
  
  
    fetchDocumentRecords(event) {
      if (this.csId != null) {
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
            console.log('GetData:::' + JSON.stringify(this.demandData));
            this.selectedList = this.demandData;
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
      //console.log('finalListBefore: ' + JSON.stringify(this.finalList));
      //console.log('Checkbox checked:', event.target.checked);
      const { name, checked } = event.target;
      this.checkboxesState = { ...this.checkboxesState, [name]: checked };
      this.visible = true;
      this.demandId = event.target.dataset.key;
      //var Name = event.target.dataset.name;
      var valueset = event.target.checked;
      console.log('valueset: '+valueset);
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
              // if (!this.currentPageData[i].isDownloaded) {
              //   if (!this.finalList.includes(value)) {
              //     this.demandId = value;
              //     this.finalList.push(value);
              //     //this.url.push(this.currentPageData[i].contentDocumentId);
              //   }
              // }
              if (!this.finalList1.includes(value)) {
                this.finalList1.push(value);
              }
            }
            break;
          }
        } else {
          console.log('inside else ');
          for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
            for (var j = 0; j < this.currentPageData.length; j++) {
              const value = this.currentPageData[j].demandId;
              this.currentPageData[j].isSelected = false;
              // if (this.finalList.includes(value)) {
              //   this.demandId = value;
              //   const index = this.finalList.indexOf(value);
              //   if (index !== -1) {
              //     this.finalList.splice(index, 1);
              //   }
              //   // const urlIndex = this.url.indexOf(this.currentPageData[j].contentDocumentId);
              //   // if (urlIndex !== -1) {
              //   //   this.url.splice(urlIndex, 1);
              //   // }
              // }
  
              if (this.finalList1.includes(value)) {
                const index = this.finalList1.indexOf(value);
                if (index !== -1) {
                  this.finalList1.splice(index, 1);
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
                //this.finalList.push(value);
                this.finalList1.push(value);
                //this.url.push(Name);
              } else {
                //this.finalList = this.finalList.filter(finalItem => finalItem !== this.demandId);
                this.finalList1 = this.finalList1.filter(finalItem => finalItem !== this.demandId);
                //this.url = this.url.filter(finalItem => finalItem !== Name);
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
      console.log('currentPageData: ' + JSON.stringify(this.currentPageData));
      // this.selectedFinalist = this.currentPageData.filter(record => record.isSelected);
      //console.log('selectedFinalist: ' + JSON.stringify(this.selectedFinalist));
      //console.log('url: ' + JSON.stringify(this.url));
      console.log('final list to send email: ' + JSON.stringify(this.finalList1));
      //this.updateFinalUrl();
    }
  
  
    updateFinalUrl() {
      console.log('url: ' + JSON.stringify(this.url));
      this.finalurl = '';
      console.log('url: ' + JSON.stringify(this.url));
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
        this.isError = true;
        this.errorMsg = 'Please select the checkbox before sending mail ';
        const toastEvent = new ShowToastEvent({
          title: 'Error',
          message: this.errorMsg,
          variant: 'error',
        });
        this.dispatchEvent(toastEvent);
        return;
      } else if (this.finalList1.length > 0) {
        // alert('finalList : '+JSON.stringify(this.finalList));
        this.isSpinner = true;
        updateEmailSentOnDemandRecords({ demandIds: this.finalList1, reminderType : this.reminderType })
          .then(result => {
            console.log('Response: ' + JSON.stringify(result));
            this.isSpinner = false;
            if (result != null) {
            //alert(result.join("\n"));
            this.finalList1 = [];
            } else {
              this.isSpinner = false;
              alert('Error: Something went Wrong Please Contact System Administrator ');
            }
          })
      }
    }
  
  
    handledownloadcheck(event) {
      // const key = event.target.dataset.index;
      const dId = event.target.dataset.key;
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
      console.log('selectedList List::' + JSON.stringify(this.selectedList));
      console.log('finalList1: ' + JSON.stringify(this.finalList1));
      if (this.finalList1.length === 0) {
        this.isError = true;
        this.errorMsg = 'Please select the checkbox before sending mail ';
        const toastEvent = new ShowToastEvent({
          title: 'Error',
          message: this.errorMsg,
          variant: 'error',
        });
        this.dispatchEvent(toastEvent);
        return;
      } else {
        this.updateEmailSent();
      }
  
   }
  
  
    handlePreviousPage() {
      this.isSpinner = true;
      this.currentPage = Math.max(1, this.currentPage - 1);
      this.index = ((this.currentPage - 1) * this.pageSize);
      this.isSpinner = false;
      //this.resetSelectAllCheckbox();
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
  }