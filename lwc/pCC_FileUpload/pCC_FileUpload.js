import { LightningElement } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



const columns = [
    {label:'Action', type:'button-icon', initialWidth:100, typeAttributes: {iconName: 'utility:delete', name: 'delete', title: 'Delete', variant:'destructive'}
    },
    {label:'File Name', type:'text', fieldName : 'Title', wrapText : true},
]
export default class PCC_FileUpload extends LightningElement {
    columns = columns;
    uploadedFiles = [];
    size = 0;

    get openTable(){
        return this.uploadedFiles.length>0?true:false;
    }

    get filesSize(){
        return this.uploadedFiles.length;
    }
    get acceptedFormats() {
        return ['.pdf','.jpg', '.jpeg', '.png', '.doc', '.docx','.txt'];
    }

    handleUploadFinished(event) {
		const uploadedFiles = event.detail.files;
		const filesList = uploadedFiles.map((file, index) => {
			// this.documentIdObj.push(file.documentId);
			return {
				Title: file.name,
                Size : file.size,
                DocumentId:file.documentId,
			};
		});
		this.uploadedFiles = [...this.uploadedFiles, ...filesList];
        this.size = this.uploadedFiles.length;
        console.log('size -->', this.size);
        this.dispatchEvent(new CustomEvent('fileupload',{detail:this.uploadedFiles}));
	}
    handleSelectedRow(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            this.deleteFile(row);
        }
    }

    async deleteFileFromServer(recordId) {
        //const recordId = event.target.dataset.recordid;

        try {
            await deleteRecord(recordId);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'File Removed',
                    variant: 'success'
                })
            );
            this.dispatchEvent(new CustomEvent('fileupload',{detail:this.uploadedFiles}));
            return true;
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error,
                    variant: 'error'
                })
            );
        }
    }

    deleteFile(row) {
        if(this.deleteFileFromServer(row.DocumentId)){
            this.uploadedFiles = this.uploadedFiles.filter(file => file.Title !== row.Title);
            console.log('uploadedFiles -->', this.uploadedFiles);
        }
        
    }
}