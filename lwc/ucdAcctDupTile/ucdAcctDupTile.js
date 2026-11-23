import { LightningElement, api, track, wire } from 'lwc';
import getAccounts from "@salesforce/apex/UCD_AccountDuplicate.getAccounts";   
export default class UcdAcctDupTile extends LightningElement {
    @track dataLoader = {}; //It will store table data
    @track isLoading = false; //variable to use for spinner
    @track accountList;  
    // It will return complete data
    @api
    get regiondata() {
        
        return this.dataLoader;
    }
    set regiondata(value) {
        if (value) {
            this.dataLoader = { ...value };
            console.log('INSIDE' +JSON.stringify(this.dataLoader));
        }
    }
    //It will give region with no. of duplicate count
    get title() {
        return this.dataLoader.region + " (Top - 10)";
    }
    //It will give CIM ids and no. of dupplicate accounts length
    get duplicates() {
        return this.dataLoader.data;
    }
    //It will dispatch event and spiiner logic used
    clickHandler(event) {
        const recordClick = new CustomEvent("recordclick", { detail: event.target.name });
        this.dispatchEvent(recordClick);
        this.isLoading = true;
        setTimeout(() => {
            this.isLoading = false;
        }, 3000);
    }  
    exportToCSV() {  
      this.isLoading = true;
      getAccounts({ region: this.dataLoader.region })
      .then(result => {      
         this.accountList = result;       
      })
      .catch(error => {
          console.log(error);
      })
      .finally(() => {
        if(this.accountList){
           this.downloadCSVFile();
        }
      })
    }  
    downloadCSVFile() {   
      let rowEnd = '\n';
      let csvString = '';
      // this set elminates the duplicates if have any duplicate keys
      let rowData = ["CIMID", "Name","IPA", "SalesGroup","AccountId","Owner"];

      // Array.from() method returns an Array object from any object with a length property or an iterable object.
      rowData = Array.from(rowData);      
      // splitting using ','
      csvString += rowData;
      csvString += rowEnd;
      // main for loop to get the data based on key value
      for(let i=0; i < this.accountList.length; i++){
          let colValue = 0;
          // validating keys in data
          for(let key in rowData) {
              if(rowData.hasOwnProperty(key)) {
                  // Key value 
                  // Ex: Id, Name
                  let rowKey = rowData[key];
                  // add , after every value except the first.
                  if(colValue > 0){
                      csvString += ',';
                  }
                  // If the column is undefined, it as blank in the CSV file.
                  let value = this.accountList[i][rowKey] ;
                  csvString += '"'+ value +'"';
                  colValue++;
                  console.log('J100 ',colValue)
              }
          }
          csvString += rowEnd;
      }
      // Creating anchor element to download
      let downloadElement = document.createElement('a');
      // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
      downloadElement.href = 'data:text/csv;charset=utf-8,' + '\uFEFF' + encodeURIComponent(csvString);
      downloadElement.target = '_self';
      // CSV File Name
      downloadElement.download = 'Account Data.csv';
      // below statement is required if you are using firefox browser
      document.body.appendChild(downloadElement);
      // click() Javascript function to download CSV file
      downloadElement.click(); 
      this.isLoading = false;
  }
}