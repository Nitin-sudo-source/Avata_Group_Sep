/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 29-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, wire, track } from 'lwc';
import getProject from '@salesforce/apex/Ex_BulkDemandDownload.getProject';
import getTower from '@salesforce/apex/Ex_BulkDemandDownload.getTower';
import getCS from '@salesforce/apex/Ex_BulkDemandDownload.getCS';
import updateEmailSentOnDemandRecords from '@salesforce/apex/Ex_BulkDemandDownload.updateEmailSentOnDemandRecords';
import fetchFiles from '@salesforce/apex/Ex_BulkDemandDownload.fetchFiles';
import { NavigationMixin } from 'lightning/navigation';
import getDemandPdf from '@salesforce/apex/Ex_BulkDemandDownload.getDemandPdf';
import getDemandSinglePdf from '@salesforce/apex/Ex_BulkDemandDownload.getDemandSinglePdf';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import JSZip from '@salesforce/resourceUrl/JSZip';


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
  @track mainList = [];
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
  @track zipInitialized = false;

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
    return this.mainList.length;
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
    if (this.projectId === null) {
      this.showToast('Error !', 'Please select the Project', 'Error');
      return;

    } else if (this.towerId === null) {
      this.showToast('Error !', 'Please select the Tower', 'Error');
      return;


    } else if (this.demandtype === null) {
      this.showToast('Error !', 'Please select the View', 'Error');
      return;


    } else if (this.csId === null) {
      this.showToast('Error !', 'Please select the Milestone Type', 'Error');
      return;


    } else {
      this.showTable = false;
      this.isSpinner = true;
      fetchFiles({ objectName: 'Demand__c', CSId: this.csId, TowerId: this.towerId, Dtype: this.demandtype })
        .then((result) => {
          this.demandData = result.map((item, index) => ({
            ...item,
            isSelected: false,
            isDownloaded: item.isDownloaded ? true : false,
            preview: `/apex/Ex_PrintDemand?dId=${item.demandId}`,
            "serialNumber": index + 1
          }));
          this.showTable = true;
          this.isSpinner = false;
          this.selectedList = this.demandData;
          this.selectAllcheckBox = false;
          console.log('GetData:::' + JSON.stringify(this.demandData));
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
    this.demandId = event.target.dataset.key;
    var valueset = event.target.checked;
    //console.log('valueset: ' + valueset);
    var fieldName = event.currentTarget.name;
    //console.log('fieldName: ' + fieldName);
    var Name = event.target.dataset.name;


    //console.log('Name: ' + Name);
    if (fieldName == 'SelectAll') {
      if (this.selectAllcheckBox == true) {
        for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
          for (var i = 0; i < this.currentPageData.length; i++) {
            const value = this.currentPageData[i].demandId;
            this.currentPageData[i].isSelected = true;
            if (!this.mainList.includes(value)) {
              this.mainList.push(value);
              if (!this.url.includes(this.currentPageData[i].demandId)) {
                this.url.push(this.currentPageData[i].demandId);
              }
            }
          }
          break;
        }
      } else {
        //console.log('inside else ');
        for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
          for (var j = 0; j < this.currentPageData.length; j++) {
            const value = this.currentPageData[j].demandId;
            this.currentPageData[j].isSelected = false;
            if (this.mainList.includes(value)) {
              const index = this.mainList.indexOf(value);
              if (index !== -1) {
                this.mainList.splice(index, 1);
              }
            }
            if (this.url.includes(this.currentPageData[j].demandId)) {
              const index = this.url.indexOf(this.currentPageData[j].demandId);
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
              this.mainList.push(value);
              this.url.push(Name);
            } else {
              this.mainList = this.mainList.filter(finalItem => finalItem !== this.demandId);
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
    console.log('FinalMainList: ' + JSON.stringify(this.mainList));
    console.log('url ' + JSON.stringify(this.url));
  }





  async handleDownloadAllDemand(event) {
    this.isSpinner = true;
    const button = event.currentTarget;
    button.disabled = true;

    const selectedDemands = this.currentPageData.filter(d => d.isSelected);

    if (selectedDemands.length === 0) {
      this.isSpinner = false;
      button.disabled = false;
      this.showToast('Error !', 'Please select the checkbox before Downloading', 'Error');
      return;
    }

    const demandIds = selectedDemands.map(d => d.demandId);

    try {
      await loadScript(this, JSZip);
      const zip = new window.JSZip();

      const response = await getDemandPdf({ demandRecordIds: demandIds });
      if (response && response.length > 0) {
        const folder = zip.folder("BulkDemands"); // Single folder

        for (const re of response) {
          const base64String = re.base64Pdf;
          const demandName = re?.demandName || '';
          const customerName = re?.customerName || '';
          const bookingName = re?.bookingName || '';
          const projectName = re?.projectName || '';

          // Clean up the filename and make it unique
          const filename = `${demandName}/${customerName}/${bookingName}/${projectName}.pdf`.replace(/[\/\\?%*:|"<>]/g, '_');
          folder.file(filename, base64String, { base64: true });
        }

        const content = await zip.generateAsync({ type: 'blob' });
        const downloadLink = document.createElement("a");
        downloadLink.href = URL.createObjectURL(content);
        downloadLink.download = "BulkDemands.zip";
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
        location.reload();
      } else {
        console.log("No PDF found in the response.");
      }
    } catch (error) {
      console.error("Error during ZIP creation:", error);
    }

    this.isSpinner = false;
    button.disabled = false;
  }

  async handleDownloadSingleDemand(event) {
    this.isSpinner = true;
    const button = event.currentTarget;
    button.disabled = true;
    const dId = event.currentTarget.dataset.key;
    console.log("dId: ", dId);

    try {
      const result = await getDemandSinglePdf({ dId: dId });

      if (result && result.base64PdfList.length > 0) {
        const base64String = result.base64PdfList[0];
        const demandRecord = result.demandList.length > 0 ? result.demandList[0] : null;
        const demandName = demandRecord ? demandRecord.Name : '';
        const customerName = demandRecord ? demandRecord.Customer_Name__c : '';
        const bookingName = demandRecord.Booking__r ? demandRecord.Booking__r.Name : '';
        const projectName = demandRecord.Booking__r.Project__r ? demandRecord.Booking__r.Project__r.Name : '';

        const byteCharacters = atob(base64String);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
          byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const pdfBlob = new Blob([byteArray], { type: "application/pdf" });
        const downloadLink = document.createElement("a");
        downloadLink.href = URL.createObjectURL(pdfBlob);
        downloadLink.download = `${demandName}/${customerName}/${bookingName}/${projectName}.pdf`;
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
        location.reload();
      } else {
        console.log("No PDF found in the response.");
      }
    } catch (error) {
      console.error("Error downloading demand letter:", error);
    } finally {
      this.isSpinner = false;
      button.disabled = false;
    }
  }


 updateEmailSent() {
  if (this.mainList.length === 0) {
    this.showToast('Error !', 'Please select the checkbox before sending mail', 'Error');
    return;
  } else if (this.mainList.length > 0) {
    this.isSpinner = true;
    updateEmailSentOnDemandRecords({ demandIds: this.mainList })
      .then(result => {
        console.log('Response: ' + JSON.stringify(result));
        this.isSpinner = false;
        if (result != null && result.length > 0) {

          // Separate messages
          let mailAlreadySentList = result.filter(msg => msg.includes('Mail Already Sent'));
          let noEmailFoundList = result.filter(msg => msg.includes('No email found'));
          let emailSentList = result.filter(msg => msg.includes('Mail Sending'));

          // Show toasts based on message type
          if (mailAlreadySentList.length > 0) {
            this.showToast('Info - Mail Already Sent', mailAlreadySentList.join('\n'), 'info');
          }

          if (noEmailFoundList.length > 0) {
            this.showToast('Warning - No Email Found', noEmailFoundList.join('\n'), 'warning');
          }

          if (emailSentList.length > 0) {
            this.showToast('Success - Mail Sending', emailSentList.join('\n'), 'success');
          }


          // Clear selections
          this.mainList = [];
          this.url = [];
          location.reload();

        } else {
          this.isSpinner = false;
          this.showToast('Error !', 'Please check customer Email or Please Contact System Administrator', 'Error');
        }
      })
      .catch(error => {
        this.isSpinner = false;
        console.error('Error: ', error);
        this.showToast('Error !', 'Something went wrong. Please contact your administrator.', 'error');
      });
  }
}



  get hasFilesToDownload() {
    return this.mainList.length > 0;
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