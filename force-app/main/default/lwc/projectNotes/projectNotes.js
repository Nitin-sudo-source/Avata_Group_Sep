import { LightningElement, track, wire } from 'lwc';
import searchpro from '@salesforce/apex/ProjectLwc.searchpro';
import notes from '@salesforce/apex/ProjectLwc.notes';
// import download from '@salesforce/resourceUrl/icon';
import { getDataConnectorSourceFields } from 'lightning/analyticsWaveApi';
export default class ProjectNotes extends LightningElement {

    // icon = download + '/file.png'

    @track value = '';
    @track options = [];
    @track notesAtt = [];
    visibleProjects;
    @wire(searchpro)
    projects({ data, error }) {
        let arr = [];
        if (data) {
            for (var i = 0; i < data.length; i++) {
                arr.push({ label: data[i].Name, value: data[i].Id });
            }
            this.options = arr;
        }

    }
    projectCall(event) {
        this.value = event.detail.value;
    }
    get options() {
        return this.options;
    }
    @wire(notes, { ProId: '$value' })
    project({ data, error }) {
        let arrs = [];
        if (data) {
            //console.log(data);

            for (var i = 0; i < data.length; i++) {
                arrs.push({
                    projectName: data[i].LinkedEntity.Name, Title: data[i].ContentDocument.Title,
                    Description: data[i].ContentDocument.Description, url: `/sfc/servlet.shepherd/document/download/${data[i].ContentDocumentId}`
                });

            }

            this.notesAtt = arrs;

        }
    }

    updateProject(event) {
        this.visibleProjects = [...event.detail.records]
        console.log(event.detail.records)
    }
}