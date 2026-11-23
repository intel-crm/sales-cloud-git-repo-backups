/* fileupload_aws_s3bucket.js */
/* eslint-disable no-console */
import { LightningElement, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { loadScript } from "lightning/platformResourceLoader";
import AWS_SDK from "@salesforce/resourceUrl/AWSSDK";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertCompanyResourceRecord from '@salesforce/apex/PMP_APICalloutS3Brightcove.insertCompanyResourceRecord';

export default class Fileupload_aws_s3bucket extends LightningElement {
  /*========= Start - variable declaration =========*/
  s3; //store AWS S3 object
  isAwsSdkInitialized = false; //flag to check if AWS SDK initialized
  @track awsSettngRecordId; //store record id of custom metadata type where AWS configurations are stored
  selectedFilesToUpload; //store selected file
  @track showSpinner = false; //used for when to show spinner
  @track fileName; //to display the selected file name
  @track fileType; //to display the selected file type
  data;
  s3bucketName;
  s3VideoURL;
  s3VideoDownloadURL;
  response;

  /*========= End - variable declaration =========*/

  //Called after every render of the component. This lifecycle hook is specific to Lightning Web Components,
  //it isn’t from the HTML custom elements specification.
  renderedCallback() {
    if (this.isAwsSdkInitialized) {
      return;
    }
    Promise.all([loadScript(this, AWS_SDK)])
      .then(() => {
        //For demo, hard coded the Record Id. It can dynamically be passed the record id based upon use cases
        this.awsSettngRecordId = "m1r8A0000008OIo";
      })
      .catch(error => {
        console.error("error -> " + error);
      });
  }

  //Using wire service getting AWS configuration from Custom Metadata type based upon record id passed

  @wire(getRecord, {
    recordId: "$awsSettngRecordId",
    fields: [
      "AWS_Setting__mdt.S3_Bucket_Name__c",
      "AWS_Setting__mdt.AWS_Access_Key_ID__c",
      "AWS_Setting__mdt.AWS_Secret_Key_ID__c",
      "AWS_Setting__mdt.S3_Region_Name__c"
    ]
  })
  awsConfigData({ error, data }) {
    if (data) {
      let awsS3MetadataConf = {};
      let currentData = data.fields;
      console.log("AWS Conf ====> " + JSON.stringify(currentData));
      awsS3MetadataConf = {
        s3bucketName: currentData.S3_Bucket_Name__c.value,
        awsAccessKeyId: currentData.AWS_Access_Key_ID__c.value,
        awsSecretAccessKey: currentData.AWS_Secret_Key_ID__c.value,
        s3RegionName: currentData.S3_Region_Name__c.value
      };
      this.s3bucketName = currentData.S3_Bucket_Name__c.value;
      this.initializeAwsSdk(awsS3MetadataConf); //Initializing AWS SDK based upon configuration data
    } else if (error) {
      console.error("error ====> " + JSON.stringify(error));
    }
  }

  //Initializing AWS SDK
  initializeAwsSdk(confData) {
    console.log("accessKeyId ====> " + confData.awsAccessKeyId);
    console.log("secretAccessKey ====> " + confData.awsSecretAccessKey);
    const AWSObj = window.AWS;
    AWSObj.config.update({
      accessKeyId: confData.awsAccessKeyId, //Assigning access key id
      secretAccessKey: confData.awsSecretAccessKey //Assigning secret access key
    });

    AWSObj.config.region = confData.s3RegionName; //Assigning region of S3 bucket
    
    this.s3 = new AWSObj.S3({
      apiVersion: "2006-03-01",
      params: {
        Bucket: confData.s3bucketName //Assigning S3 bucket name
      }
    });
    // Create initial parameters JSON for putBucketCors
    const thisConfig = {
      AllowedHeaders:["Authorization"],
      AllowedMethods:["*"],
      AllowedOrigins:["*"],
      ExposeHeaders:[],
      MaxAgeSeconds:3000
    };

    this.isAwsSdkInitialized = true;
  }
  //get the file name from user's selection
  handleSelectedFiles(event) {
    if (event.target.files.length > 0) {
      this.selectedFilesToUpload = event.target.files[0];
      this.fileName = event.target.files[0].name;
      this.fileType = event.target.files[0].type;
      console.log("fileName ====> " + this.fileName);
      console.log("fileName ===type=> " + event.target.files[0].type);
      console.log("All ====> " + JSON.stringify(event.target.files[0]));    }
  }

  //file upload to AWS S3 bucket
  uploadToAWS() {
    if (this.selectedFilesToUpload) {
      this.showSpinner = true;
      let objKey = this.selectedFilesToUpload.name
        .replace(/\s+/g, "_") //each space character is being replaced with _
        .toLowerCase();

      //starting file upload
      this.s3.putObject(
        {
          Key: objKey,
          ContentType: this.selectedFilesToUpload.type,
          Body: this.selectedFilesToUpload,
         // ACL: "public-read"
        },
        err => {
          if (err) {
            this.showSpinner = false;
            console.error(err);
          } else {
            this.showSpinner = false;
            console.log("Success--->138");
            //const fileName = this.fileName;
            //const S3bucketName = this.s3bucketName;
            this.s3VideoURL = 's3://'+ this.s3bucketName + '/' + this.fileName.toString().toLowerCase();
            this.s3VideoDownloadURL = 'https://'+ this.s3bucketName + '.s3.amazonaws.com/' + this.fileName.toString().toLowerCase();
            console.log('s3VideoURL---->',this.s3VideoURL.toString().toLowerCase());
            console.log('s3VideoDownloadURL---->',this.s3VideoDownloadURL.toString().toLowerCase());
            insertCompanyResourceRecord({file_Name:this.fileName,file_Type:this.fileType, S3_Video_URL:this.s3VideoURL, s3_VideoDownload_URL:this.s3VideoDownloadURL}).then(response => {
                this.response = response;
                if(this.response){
                  const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Uploaded to AWS successfully.',
                    variant: 'success',
                    mode: 'dismissable',
                    duration:'5000',
                    key: 'info_alt'
                    });
                 this.dispatchEvent(evt);
                }
            }).catch(error=>{
              const evt = new ShowToastEvent({
                title: 'Error!',
                message: 'Didnt upload to AWS.',
                variant: 'error',
                mode: 'dismissable',
                duration:'5000',
                key: 'info_alt'
                });
             this.dispatchEvent(evt);
            });
           
            this.listS3Objects();
          }
        }
      );
    }
  }

  //listing all stored documents from S3 bucket
  listS3Objects() {
    //console.log("AWS -> " + JSON.stringify(this.s3));
    this.s3.listObjects((err, data) => {
      if (err) {
        console.log("Error", err);
      } else {
        this.data = data;
        console.log("Success------155", JSON.stringify(this.data));
      }
    });
  }
}