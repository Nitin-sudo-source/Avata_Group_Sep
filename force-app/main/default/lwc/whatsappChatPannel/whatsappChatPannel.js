import { LightningElement, api, track } from 'lwc';
import styles from './whatsappChatPannel.css';
import AllMessages from '@salesforce/apex/Ex_whatsAppMsgService.AllMsgs';
import refreshMessages from '@salesforce/apex/Ex_whatsAppMsgService.refreshMessages';
import InsertMessage from '@salesforce/apex/Ex_whatsAppMsgService.InsertMessage';
import InsertAttachment from '@salesforce/apex/Ex_whatsAppMsgService.InsertAttachment';
import getTemplate from '@salesforce/apex/Ex_whatsAppMsgService.getTemplate';
import generateHTMLString from '@salesforce/apex/Ex_whatsAppMsgService.generateHTMLString';
import SendTemplate from '@salesforce/apex/Ex_whatsAppMsgService.SendTemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSObjectName from '@salesforce/apex/Ex_whatsAppMsgService.getSObjectName';
import getCoversationStartDateTime from '@salesforce/apex/Ex_whatsAppMsgService.getConversationStartDateTime';
import avatarIcon from '@salesforce/resourceUrl/avatar';
import avatarIcon2 from '@salesforce/resourceUrl/avatar2';
import fileIcon from '@salesforce/resourceUrl/fileicon';
import { refreshApex } from '@salesforce/apex';


const CategoryValues = [
    //{ label: 'UTILITY', value: 'UTILITY' },
    { label: 'MARKETING', value: 'MARKETING' }
];

export default class WhatsappChatPannel extends LightningElement {
    
    static styles = [styles];
    avatarIconUrl = avatarIcon2;
    fileIconUrl = fileIcon;
    @api recordId;
    @track timeRemaining;
    @track targetDate;
    @track menu = true;
    @track totalsize;
    @track visible = false;
    @track CustomerName;
    @track msg = '';
    @track caption = '';
    @track allmessages;
    @track attachmentFile;
    @track fname = '';
    @track templateList = [];
    @track templates = [];
    @track filevisible;
    @track visibletemplate = false;
    @track templateIconColor='att2';
    @track folderId = null;
    @track viewtemplates;
    @track selectedtemplate = null;
    @track fileData;
    @track CategoryOptions = [];
    @track disableChatWindow = false;
    

    refreshData() {
        refreshApex(this.RefreshWhatsappMessages());
        console.log('refreshApex :');

        getCoversationStartDateTime({ recId: this.recordId })
        .then((result) => {
            console.log('getCoversationStartDateTime .: ',result);

            if (result != null) {
                this.targetDate = new Date(result);

                console.log('If this.targetDate .: ',this.targetDate);
            } else {
                this.targetDate = new Date();
                console.log('Else this.targetDate .: ',this.targetDate);
            }

            // Start the countdown
            this.startCountdown();
        })
        .catch((error) => {
            console.error('Error = ' + JSON.stringify(error));
        });
    }

    refreshchatwindow(evt){
        this.getAllMessages();
    }

    RefreshWhatsappMessages(){
    
        refreshMessages({recId: this.recordId})
        .then((result) => {
          console.log('result = ' + JSON.stringify(result));
          this.allmessages = this.formatMessages(result);
          //alert('in');
          console.log('refereshmessages = ' + JSON.stringify(this.allmessages));
          // setTimeout(() => {
          //   const msgContainer = this.template.querySelector('.chat-body-container');
          //   msgContainer.scrollTop = msgContainer.scrollHeight;
          // }, 0);
        })
        .catch((error) => {
          console.log(JSON.stringify(error));
        });
    
      }
    

   

    toggleVisibility() {
        this.visible = !this.visible;
        const chatWindow = this.template.querySelector('.chat-window-container');
        const minimizeIcon = this.template.querySelector('.minimize-icon');
        if (this.visible) {
            chatWindow.style.setProperty('transform', 'translateY(0px)');
            minimizeIcon.style.setProperty('transform', 'rotate(0deg)');
        } else {
            chatWindow.style.setProperty('transform', `translateY(${this.totalsize}px)`);
            minimizeIcon.style.setProperty('transform', 'rotate(180deg)');
        }
    }

    toggleOverlay() {
        const overlayElem = this.template.querySelector('.overlay');
        overlayElem.classList.toggle('toggleVisibility');
    };

    toggleModal() {
        const modalElem = this.template.querySelector('.attachment-modal');
        modalElem.classList.toggle('slideUp');
    }

    toggleTemplate() {
        /* const menuElems = this.template.querySelectorAll('.menu');
        // const submenuElem = this.template.querySelector('.submenu');
        // console.log("Menu Element: ", menuElems);
        // console.log("Menu Element: ", submenuElem);
        if(!this.menu) {
            menuElems.forEach(element => {
                console.log("Inside None");
                element.style.setProperty('display', 'none');
            });
            this.menu = !this.menu;
        }
        else {
            menuElems.forEach(element => {
                console.log("Inside Show");
                element.style.setProperty('display', 'block');
            });
            this.menu = !this.menu;
        } */
        this.menu = !this.menu;
        if(!this.menu) {
            const menuElem = this.template.querySelector('.temp');
            menuElem.style.setProperty('display', 'none');
            
            const templateElem = this.template.querySelector('.template');
            templateElem.style.setProperty('display', 'block');
        }
        else {
            const menuElem = this.template.querySelector('.temp');
            menuElem.style.setProperty('display', 'block');
            
            const templateElem = this.template.querySelector('.template');
            templateElem.style.setProperty('display', 'none');
        }
    }

    handleCancel() {
        this.toggleModal();
        this.toggleOverlay();
        if(!this.menu) {
            this.menu = !this.menu;
            const menuElem = this.template.querySelector('.temp');
            menuElem.style.setProperty('display', 'block');
            
            const templateElem = this.template.querySelector('.template');
            templateElem.style.setProperty('display', 'none');
        }
    }

    connectedCallback() {
        setTimeout(() => {
            const chatWindow = this.template.querySelector('.chat-window-container');
            const chatWindowSize = chatWindow.offsetHeight;
            const marginSize = parseInt(window.getComputedStyle(chatWindow).marginBottom);
            const header = chatWindow.firstChild;
            const headerSize = header.offsetHeight;

            this.totalsize = chatWindowSize + marginSize - headerSize;
            chatWindow.style.setProperty('transform', `translateY(${this.totalsize}px)`);
            
            // Not Working - Auto scroll to bottom
            ///const chatContainer = chatWindow.lastChild;
            //const chatContainerNew = chatContainer.childNodes;
            //chatContainer.scrollTop = chatSection.scrollHeight;
        }, 0);

        //alert(this.recordId);
        getSObjectName({recId: this.recordId})
        .then((result) => {
            console.log(result);
            this.CustomerName = result;
        })
        .catch((error) => {
            console.log('Error = ' + JSON.stringify(error));
        })

        this.getAllMessages();
        this.CategoryOptions = CategoryValues;

        getCoversationStartDateTime({ recId: this.recordId })
        .then((result) => {
            console.log('getCoversationStartDateTime .: ',result);

            if (result != null) {
                this.targetDate = new Date(result);

                console.log('If this.targetDate .: ',this.targetDate);
            } else {
                this.targetDate = new Date();
                console.log('Else this.targetDate .: ',this.targetDate);
            }

            // Start the countdown
            this.startCountdown();
        })
        .catch((error) => {
            console.error('Error = ' + JSON.stringify(error));
        });

        //this.refreshData();
        //setInterval(this.refreshData.bind(this), 1000);
    }

    startCountdown() {
      // Update the countdown every second
      this.intervalId = setInterval(() => {
        // Get the current date and time
        const currentDate = new Date();

        // Calculate the time difference in seconds
        const timeDiffInSeconds = Math.floor((this.targetDate - currentDate) / 1000);

        // Calculate hours, minutes, and seconds
        const hours = Math.floor(timeDiffInSeconds / 3600);
        const minutes = Math.floor((timeDiffInSeconds % 3600) / 60);
        const seconds = timeDiffInSeconds % 60;

        // Display the countdown
        this.timeRemaining = `${hours}h ${minutes}m ${seconds}s`;

        // Stop the interval when the countdown expires
        if (timeDiffInSeconds <= 0) {
            this.timeRemaining = 'Inactive';
            this.disableChatWindow = true;
            clearInterval(this.intervalId);
        }else{
          this.disableChatWindow = false;
        }

        //console.log('timeRemaining = ' + this.timeRemaining);
      }, 1000);
    }
  

    handleClose() {
        const chatWindow = this.template.querySelector('.chat-window-container');
        if (!this.visible) {
            this.visible = !this.visible;
            chatWindow.style.setProperty('transform', 'translateY(0px)');
        } else {
            this.visible = !this.visible;
            chatWindow.style.setProperty('transform', `translateY(${this.totalsize}px)`);
        }
    }

    handleFileClose() {
        this.filevisible = false;
        this.fname = '';
    }

    RefreshWhatsappMessages(){
    
        refreshMessages({recId: this.recordId})
        .then((result) => {
            console.log('result = ' + JSON.stringify(result));
            this.allmessages = this.formatMessages(result);
            //alert('in');
            console.log('refereshmessages = ' + JSON.stringify(this.allmessages));
            setTimeout(() => {
            const msgContainer = this.template.querySelector('.chat-body-container');
            msgContainer.scrollTop = msgContainer.scrollHeight;
            }, 0);
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
        });

    }

    getAllMessages() {
        AllMessages({recId: this.recordId})
        .then((result) => {
            console.log('result = ' + JSON.stringify(result));
            this.allmessages = this.formatMessages(result);
            console.log('allmessages = ' + JSON.stringify(this.allmessages));
            setTimeout(() => {
                const msgContainer = this.template.querySelector('.chat-body-container');
                msgContainer.scrollTop = msgContainer.scrollHeight;
            }, 0);
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
        });
    }

    formatMessages(messages) {
      return messages.map((message) => {
          const createdDate = new Date(message.CreatedDate);
          const formattedTime = createdDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
          const formattedDate = `${createdDate.getDate().toString().padStart(2, '0')}/${(createdDate.getMonth() + 1).toString().padStart(2, '0')}/${createdDate.getFullYear()}`;
          
          const CreatedTime = `${formattedDate} ${formattedTime}`;
  
          // Initialize status flags
          let sent = false;
          let delivered = false;
          let read = false;

          //alert('in =: '+ message.Message_Status__c)
          // Set status flags based on Message_Status__c
          if (message.Message_Status__c == 'sent') {
              //alert('in')
              sent = true;
          } else if (message.Message_Status__c == 'delivered') {
              delivered = true;
          } else if (message.Message_Status__c == 'read') {
              read = true;
          }

          return {
              ...message,
              CreatedTime,
              sent,
              delivered,
              read
          };
      });
  }

    handleblur(evt) {
        this.msg = evt.target.value;
        console.log(this.msg);
        this.selectedtemplate = null;
    }
    
    handlecaption(evt){
        this.caption = evt.target.value;
        console.log(this.caption);
        this.msg = '';
    }



    handleAttachmentClick() {
        //OLD CODE.
        /* const fileInput = this.template.querySelector('input[type="file"]');
        fileInput.click(); */
        this.toggleModal();
        this.toggleOverlay();
    }

    handleDocumentUpload() {
        const fileInput = this.template.querySelector('input[type="file"]');
        fileInput.click();
    }

    handleFileChange(event) {
        console.log('handleFileChange called');
        console.log(event.target); // Log the event target
        console.log(event.target.files); // Log the files property
        this.attachmentFile = event.target.files[0];
        console.log(this.attachmentFile);
    
        if (this.attachmentFile) {
            this.filevisible = true;
            this.fname = this.attachmentFile.name;
            // this.handleCancel();
        } else {
            this.filevisible = false;
            this.fname = '';
        }
    }

    /* For Template By Yash 
    //template Window
    handletemplate(){
        this.menu = false;
        this.viewtemplates = false;
        this.att = 'attachment-modal2';
       //alert(this.menu)
    } */

    handlecategory(evt){
        let category = evt.target.value;
    
        getTemplate({recId: this.recordId, category: category})
          .then((result) => {
            console.log(JSON.stringify(result));
            this.templates = result;
            if(result.length > 0){
              this.viewtemplates = true
              this.notemplates = false;
              let tempArray = [];
    
              for(let key in result){
                tempArray.push({label:result[key].Whatsapp_Template_Name__c,value:result[key].Id});
              }
    
              this.templateList = tempArray;
              console.log(JSON.stringify(this.templateList));
            }else{
              this.viewtemplates = false;
              this.notemplates = true;
            }
          })
        .catch((error) => {
          console.log(JSON.stringify(error));
        })
      }
    
      handleselectedtemplate(evt){
        this.selectedtemplate = evt.target.value;
        console.log('Template Id .: ',this.selectedtemplate);
        console.log(JSON.stringify(this.templates));
        const foundRecord = this.templates.find(record => record.Id === this.selectedtemplate);
        console.log(JSON.stringify(foundRecord));
    
        generateHTMLString({recordId: this.recordId, parameters: foundRecord.Parameters__c, template: foundRecord.Template__c})
        .then((result) => {
          let newmsg = String(result);
          console.log(JSON.stringify(newmsg));
          this.msg = newmsg;
          this.disableChatWindow = true;
          console.log(this.msg);
          //Insert here
          this.handleCancel();
          
          //Resetting Combobox Values
          const combobox = this.template.querySelectorAll('.combobox');
          let comboboxValues = Object.values(combobox);
          comboboxValues.forEach((cb) => {
            cb.value = null;
          });
        })
        .catch(error => {
          console.log(JSON.stringify(error));
          this.handleCancel();
        })  
      }


      handletitle1(evt){
        const key = evt.target.dataset.index;

        if(this.allmessages[key].Type_1__c == 'URL')
          window.open(this.allmessages[key].Value_1__c)
        else
          window.open('tel:'+ this.allmessages[key].Value_1__c)
      }

      handletitle2(evt){
        const key = evt.target.dataset.index;
        if(this.allmessages[key].Type_2__c == 'URL')
          window.open(this.allmessages[key].Value_2__c)
        else
          window.open('tel:'+ this.allmessages[key].Value_2__c)      }

      sendchat() {
        // alert(this.msg);
        // alert(this.selectedtemplate);
        // alert(this.disableChatWindow);
        if (((this.msg != null && this.msg != '') || this.attachmentFile) && this.selectedtemplate == null && this.disableChatWindow == false){
          //alert(this.msg)
          InsertMessage({msg: this.msg,recordId: this.recordId})
            .then((result) => {
              console.log('result = ' + JSON.stringify(result));
                this.msg = '';
                // Add attachment logic
                // if (this.attachmentFile) {
                //   const fileReader = new FileReader();
                //   fileReader.onload = () => {
                //     const fileContents = fileReader.result;
                //     this.fileData = {
                //       FileName: this.attachmentFile.name,
                //       ContentType: this.attachmentFile.type,
                //       Body: fileContents.split(',')[1],
                //       ParentId: result.Id,
                //     };  
                //     this.uploadFile(this.fileData);
                //   };
                //   fileReader.readAsDataURL(this.attachmentFile);
                // }
                const now = new Date();
                let hours = now.getHours();
                const minutes = now.getMinutes();
                const period = hours >= 12 ? 'PM' : 'AM';
    
                // Convert to 12-hour format
                hours = hours % 12 || 12;
    
                const formattedTime = `${hours}:${minutes.toString().padStart(2, '0')} ${period}`;
    
                console.log(formattedTime);
                var newEntry;
                
                  newEntry = {
                    Id: result.Id,
                    Message_Text__c: result.Message_Text__c,
                    CreatedTime: formattedTime,
                    Outbound__c: true,
                    Success__c: result.Success__c
                  };
                
                console.log(JSON.stringify(newEntry));
                this.allmessages = [...this.allmessages, newEntry];
                this.selectedtemplate = null; 
                //this.templateList = [];
                // Initialize and update allmessages
                console.log('allmessages = ' + JSON.stringify(this.allmessages));
                this.msg = '';
                this.fname = '';
                setTimeout(() => {
                  const msgContainer = this.template.querySelector('.msg-container');
                  msgContainer.scrollTop = msgContainer.scrollHeight;
                }, 0);
    
                
            
            })
            .catch((error) => {
              console.log('error' + JSON.stringify(error));
            });
        }
    
        else if(this.selectedtemplate != null && this.selectedtemplate != undefined /*&& this.disableChatWindow == true*/){
          this.disableChatWindow = false;
          this.visibletemplate = false;
          this.templateIconColor = 'att';
          console.log(this.selectedtemplate);
          
          const foundRecord = this.templates.find(record => record.Id === this.selectedtemplate);
          console.log(JSON.stringify(foundRecord));
    
          console.log(this.recordId);

          SendTemplate({tId: this.selectedtemplate, recId: this.recordId})
          .then((result) => {
            this.msg = '';
            console.log(JSON.stringify(result));
            const now = new Date();
                let hours = now.getHours();
                const minutes = now.getMinutes();
                const period = hours >= 12 ? 'PM' : 'AM';
    
                // Convert to 12-hour format
                hours = hours % 12 || 12;
    
                const formattedTime = `${hours}:${minutes.toString().padStart(2, '0')} ${period}`;
    
                console.log(formattedTime);
                var newEntry;
                if (this.attachmentFile) {
                  newEntry = {
                    Id: result.Id,
                    Message_Text__c: result.Message_Text__c,
                    CreatedTime: formattedTime,
                    Contains_File__c: true,
                    Outbound__c: true,
                    Success__c: result.Success__c,
                    Title_1__c: result.Title_1__c,
                    Title_2__c: result.Title_2__c,
                    Type_1__c: result.Type_1__c,
                    Type_2__c: result.Type_2__c,
                    Value_1__c: result.Value_1__c,
                    Value_2__c: result.Value_2__c,
                    Reply1__c: result.Reply1__c,
                    Reply2__c: result.Reply2__c,
                    Interactive__c: result.Interactive__c,
                    Quick_Replies__c: result.Quick_Replies__c
                  };
                }else{
                  newEntry = {
                    Id: result.Id,
                    Message_Text__c: result.Message_Text__c,
                    CreatedTime: formattedTime,
                    Outbound__c: true,
                    Success__c: result.Success__c,
                    Title_1__c: result.Title_1__c,
                    Title_2__c: result.Title_2__c,
                    Type_1__c: result.Type_1__c,
                    Type_2__c: result.Type_2__c,
                    Value_1__c: result.Value_1__c,
                    Value_2__c: result.Value_2__c,
                    Reply1__c: result.Reply1__c,
                    Reply2__c: result.Reply2__c,
                    Interactive__c: result.Interactive__c,
                    Quick_Replies__c: result.Quick_Replies__c
                  };
                }
                console.log(JSON.stringify(newEntry));
                this.allmessages = [...this.allmessages, newEntry];
                this.selectedtemplate = null; 
                this.templateList = [];
                // Initialize and update allmessages
                console.log('allmessages = ' + JSON.stringify(this.allmessages));
                this.msg = '';
                this.fname = '';
                setTimeout(() => {
                  const msgContainer = this.template.querySelector('.msg-container');
                  msgContainer.scrollTop = msgContainer.scrollHeight;
                }, 0);
    
          })
          .catch(error => {
            console.log(JSON.stringify(error));
          })
      
    
        }
      }

      async sendatt() {
        try {
            const result = await InsertMessage({ msg: this.caption, recordId: this.recordId });
            console.log('result = ' + JSON.stringify(result));
    
            if (result != null) {
                if (this.attachmentFile) {
                    const fileReader = new FileReader();
    
                    // Promisify FileReader.onload
                    const readAsDataURL = () => new Promise((resolve) => {
                        fileReader.onload = () => resolve(fileReader.result);
                    });
    
                    fileReader.readAsDataURL(this.attachmentFile);
                    const fileContents = await readAsDataURL();
    
                    this.fileData = {
                        FileName: this.attachmentFile.name,
                        ContentType: this.attachmentFile.type,
                        Body: fileContents.split(',')[1],
                        ParentId: result.Id,
                    };
    
                    await this.uploadFile(this.fileData);
                }
    
                const now = new Date();
                let hours = now.getHours();
                const minutes = now.getMinutes();
                const period = hours >= 12 ? 'PM' : 'AM';
    
                // Convert to 12-hour format
                hours = hours % 12 || 12;
    
                const formattedTime = `${hours}:${minutes.toString().padStart(2, '0')} ${period}`;
    
                console.log(formattedTime);
                let newEntry = this.allmessages[0];
                if (this.attachmentFile) {
                    newEntry.Id = result.Id;
                    console.log('result.Message_Text__c = ',result.Message_Text__c);
                    newEntry.Message_Text__c = result.Message_Text__c;
                    newEntry.CreatedTime = formattedTime;
                    newEntry.Contains_File__c = true;
                    newEntry.Outbound__c = true;
                }
    
                console.log('newEntry = ', JSON.stringify(newEntry));
                this.allmessages = [...this.allmessages, newEntry];
                //this.refreshData();
                this.selectedtemplate = null;
                
                // Initialize and update allmessages
                console.log('allmessages = ' + JSON.stringify(this.allmessages));
                this.msg = '';
                this.fname = '';
                this.caption = '';
    
                setTimeout(() => {
                    const msgContainer = this.template.querySelector('.chat-body-container');
                    msgContainer.scrollTop = msgContainer.scrollHeight;
                }, 0);
            }
        } catch (error) {
            console.error('error' + JSON.stringify(error));
        }
    }
    
    async uploadFile(fileData) {
        console.log('fileData' + JSON.stringify(fileData));
        console.log('attachmentFile' + this.attachmentFile);
    
        try {
            const result = await InsertAttachment({ attachmentData: fileData, caption: this.caption });
            console.log('Attachment saved successfully:', result);
    
            // Show a success toast message
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Attachment saved successfully',
                variant: 'success',
            });
            this.dispatchEvent(toastEvent);
            this.filevisible = false;
            this.fname = '';
        } catch (error) {
            console.error('Error saving attachment:', JSON.stringify(error));
    
            // Show an error toast message
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Error saving attachment',
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
        }
    }    
}