import { LightningElement, wire, track,api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/CustomUploadButtonClass.readCSVFile';
import getData from '@salesforce/apex/CustomUploadButtonClass.getData';
export default class CustomUploadButton extends LightningElement {

    @track fileData = [];
    /*@api myRecordId;
    
    @track isLoading = false;
    MAX_FILE_SIZE = 5000000; //Max file size 5.0 MB
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;

    get encryptedToken() {
        //use apex to get
    }

    get acceptedFormats() {
        return ['.csv'];
    }

    connectedCallback(){
        
    }

    downloadCSV() {
        var csv = 'Name,Title\n';
        data.forEach(function(row) {
                csv += row.join(',');
                csv += "\n";
        });
    
        console.log(csv);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'people.csv';
        hiddenElement.click();
    }

    handleUploadFinished(event) {
        console.log("--->"+event.target.files[0]);
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.file = this.filesUploaded[0];
            if (this.file.size > this.MAX_FILE_SIZE) {
                this.fileName = 'File Size is to long. File size should be less then 5MB';
            } else {
                this.handleUpload(event);
            }
        }
    }

    handleUpload(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        
        /*if (this.filesUploaded.length > 0) {
            this.isLoading = true;
            this.file = this.filesUploaded[0];
            // create a FileReader object 
            this.fileReader = new FileReader();
            // set onload function of FileReader object  
            this.fileReader.onloadend = (() => {
                    this.fileContents = this.fileReader.result;
                    let base64 = 'base64,';
                    this.content = this.fileContents.indexOf(base64) + base64.length;
                    this.fileContents = this.fileContents.substring(this.content);
            });
        }
        console.log("file content--->"+this.fileContents);*/
        /*console.log('reslt'+uploadedFiles[0].documentId);
        readCSV({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Contacts are created based on file!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
        })
        
    }*/

    Upload() {
        var fileUpload = this.template.querySelector('.fileUpload');
        var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
        if (regex.test(fileUpload.value.toLowerCase())) {
            if (typeof (FileReader) != "undefined") {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var table = document.createElement("table");
                    var rows = e.target.result.split("\n");
                    var dataJson = [];
                    for (var i = 1; i < rows.length; i++) {
                        var cells = rows[i].split(",");
                        if (cells.length > 1) {
                            dataJson.push({
                                "Firstname" : cells[0],
                                "Lastname" : cells[1],
                                "Email" : cells[2],
                                "CountryRegion" : cells[3],
                                "PreferredLanguage" : cells[4]
                            });
                        }
                    }
                    this.fileData = [...dataJson];
                    console.log(this.fileData );
                    getData({
            jsonResponce : this.fileData
            })
        .then(result => {
            //this.data = result;
        })
        .catch(error => {
            //this.error = error;
        })
                    
                }
				reader.readAsText(fileUpload.files[0]);
                setTimeout(() => {
                    //this.createContactInApex();
                }, 100);                 
            } else {
                alert("This browser does not support HTML5.");
            }
        } else {
            alert("Please upload a valid CSV file.");
        }
    }

    createContactInApex() {
        console.log(this.fileData);
        getData({
            jsonResponce : this.fileData
            })
        .then(result => {
            //this.data = result;
        })
        .catch(error => {
            //this.error = error;
        })
        
    }
}