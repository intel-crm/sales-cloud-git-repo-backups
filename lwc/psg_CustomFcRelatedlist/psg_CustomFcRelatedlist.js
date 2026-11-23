import {
  LightningElement,
  wire,
  api,
  track
} from 'lwc';
import fetchfclist from '@salesforce/apex/PSG_ProductBusinessLogic.fetchFCRelatedList';
import NAME from '@salesforce/schema/price_forward_cost__c.Name';
import Fc_id from '@salesforce/schema/price_forward_cost__c.Id';
import LightningConfirm from 'lightning/confirm';
import {
  deleteRecord,
  getFieldValue,
  getRecord,
  createRecord
} from 'lightning/uiRecordApi';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
  NavigationMixin
} from 'lightning/navigation';
import Prod_opn from '@salesforce/schema/Product2.Core_OPN__c';
import {
  encodeDefaultFieldValues
} from 'lightning/pageReferenceUtils';
import fwdc_opn from '@salesforce/schema/price_forward_cost__c.core_cpq_product_opn_txt__c';
import {
  refreshApex
} from '@salesforce/apex';
import FCPeriodname from '@salesforce/schema/price_forward_cost__c.core_cpq_forward_cost_period_name_nm__c';
import FCActive from '@salesforce/schema/price_forward_cost__c.core_cpq_fc_active_cb__c';
import Startdate from '@salesforce/schema/price_forward_cost__c.core_cpq_fc_start_date_dt__c';
import Enddate from '@salesforce/schema/price_forward_cost__c.core_cpq_fc_end_date_dt__c';
import FCamount from '@salesforce/schema/price_forward_cost__c.price_forward_cost_amt__c';
import FC_Object from '@salesforce/schema/price_forward_cost__c';
import strUserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import hasCustomPermission from '@salesforce/customPermission/PSG_Internal_PMS';
import hassysusrPermission from '@salesforce/customPermission/PSG_System_User';

const actions = [{
      label: 'Edit',
      name: 'Edit'
  },
 /* {
      label: 'Delete',
      name: 'delete'
  },*/
];


export default class Psg_CustomFcRelatedlist extends NavigationMixin(LightningElement) {
  @api recordId;
  records = [];
  recordCount = 0;
  title;
  Fc_opn = '';
  recordurl;
  @track isLoading = false;
  wiredFclistResult;
  // defaultrecords=[];
  recordpageurl;
  @track customFormModal = false;
  opn = '';
  fcname = '';
  fcactive = true;
  fcperiodname = '';
  fcstdate = '';
  fcenddate = '';
  fccost = '';
  fcfields = {};
  objectApiName = FC_Object.objectApiName;
  fc_id = '';
  customeditFormModal = false;
  form;
  isValid = true;
  @track prfName;
  fcamt = '';
  stdate = '';
  endate = '';
  @api sortBy = 'core_cpq_fc_start_date_dt__c';
  @api sortDirection = 'ASC';
  @track DefaultView = false;
  deletecount = 0;
  disableBtn=false;
  disableSN=false;
  get columns() {
      let columns = [{
              label: 'FC Period Name',
              fieldName: 'recordurl',
              type: 'url',
              typeAttributes: {
                  label: {
                      fieldName: 'Name'
                  },
                  target: '_blank'
              }
          },
          {
              label: 'Forward cost $',
              fieldName: 'fcamt',
              type: 'currency',
              cellAttributes: {
                  alignment: 'left'
              }
          },
          {
              label: 'Start Date',
              fieldName: 'stdate',
              type: 'date',
              typeAttributes: {
                  day: "numeric",
                  month: "numeric",
                  year: "numeric"
              }
          },
          {
              label: 'End Date',
              fieldName: 'endate',
              type: 'date',
              typeAttributes: {
                  day: "numeric",
                  month: "numeric",
                  year: "numeric"
              }
          }
      ];
      if (this.userviewaccess) {
          columns.push({
              label: 'Actions',
              type: 'action',
              typeAttributes: {
                  rowActions: actions,
                  menuAlignment: 'right'
              },
              cellAttributes: {
                alignment: 'left'
              }
          });
      }
      return columns;
  }


  async handleRowAction(event) {
      const actionName = event.detail.action.name;
      const row = event.detail.row;
      switch (actionName) {
          case 'Edit':
              this.customeditFormModalhandle(row);
              break;
         /* case 'delete':
              const result = await LightningConfirm.open({
                  message: 'Are you sure to delete?',
                  variant: 'header',
                  label: 'Delete Forward Cost',
                  theme :'inverse'
                  // setting theme would have no effect
              });
              if(result)
                this.handledelete(row);
              break;*/
          default:
      }
  }


  @wire(getRecord, {
      recordId: strUserId,
      fields: [PROFILE_NAME_FIELD]
  })
  wireuser({
      error,
      data
  }) {
      if (error) {
          this.error = error;
      } else if (data) {
          console.log('userdetails' + JSON.stringify(data));
          this.prfName = data.fields.Profile.value.fields.Name.value;
      }
  }

  @wire(getRecord, {
      recordId: '$recordId',
      fields: [Prod_opn]
  })
  fwd_opn;

  @wire(fetchfclist, {
      Prod_id: '$recordId',
      sortby: '$sortBy',
      sortOrder: '$sortDirection'
  })
  imperativeWiring(result) {
      this.wiredFclistResult = result;
      if (result.data) {
          this.myData = result.data;
          this.deletecount = result.data.length;
      }
      if (this.deletecount > 0) {
          this.DefaultView = true;
      } else {
          this.DefaultView = false;
      }



  }


  @wire(fetchfclist, {
      Prod_id: '$recordId',
      sortby: '$sortBy',
      sortOrder: '$sortDirection'
  })
  Fclist({
      error,
      data
  }) {
      console.log(data);

      if (data) {
          let tempRecords = [];
          data.forEach((item) => {
              let tempRecord = {};
              tempRecord.Id = item.Id;
              tempRecord.Name = item.Name;
              tempRecord.recordurl = '/' + item.Id;
              tempRecord.fcamt = item.price_forward_cost_amt__c;
              tempRecord.stdate = item.core_cpq_fc_start_date_dt__c;
              tempRecord.endate = item.core_cpq_fc_end_date_dt__c;
              tempRecords.push(tempRecord);
          });

          this.records = tempRecords;
          this.recordCount = data.length;
          this.title = "Forward Costs " + "(" + this.recordCount + ")";
          // this.defaultrecords=[...this.records].splice(0,3);
          console.log(tempRecords);
          if (this.recordCount > 0) {
              this.DefaultView = true;
          }

      } else if (error) {
          console.log(error);
      }
  }

  get userviewaccess() {

      console.log('userid-->' + strUserId);
      console.log('pms-->' + hasCustomPermission);
      console.log('prf-->' + this.prfName);
      console.log('sysusr-->' + hassysusrPermission);
      if (hasCustomPermission == true || this.prfName == 'IT Admin' || this.prfName == 'System Administrator' || hassysusrPermission == true) {
          return true;
      } else {
          return false;
      }

  }


  handleChange(e) {
      if (e.target.label === "Forward Cost Name") {
          this.fcname = e.target.value;
          console.log(this.fcname);
      } else if (e.target.label === "Active") {
          this.fcactive = e.target.value;
          console.log(this.fcactive);
      } else if (e.target.label === "Product/OPN") {
          this.opn = e.target.value;
          console.log(this.opn);
      } else if (e.target.label === "Forward Cost Period Name") {
          this.fcperiodname = e.target.value;
      } else if (e.target.label === "FC Start Date") {
          this.fcstdate = e.target.value;
          console.log(this.fcstdate);
      } else if (e.target.label === "FC End Date") {
          this.fcenddate = e.target.value;

      } else if (e.target.label === "Forward Cost $") {
          this.fccost = e.target.value;
      }

  }
  handlesavenew() {
    this.disableSN=true;
      // Map the data to the fields
      this.fcfields[NAME.fieldApiName] = this.fcname;
      this.fcfields[FCActive.fieldApiName] = this.fcactive;
      this.fcfields[fwdc_opn.fieldApiName] = this.opn;
      this.fcfields[FCPeriodname.fieldApiName] = this.fcperiodname;
      this.fcfields[Startdate.fieldApiName] = this.fcstdate;
      this.fcfields[Enddate.fieldApiName] = this.fcenddate;
      this.fcfields[FCamount.fieldApiName] = this.fccost;

      // Prepare config object with object and field API names 
      const recordInput = {
          apiName: FC_Object.objectApiName,
          fields: this.fcfields
      };
      console.log(recordInput);
      this.isInputValid();

      // Invoke createRecord by passing the config object
      if (!this.isInputValid()) {
          const toast = new ShowToastEvent({
              message: 'Fill all the mandatory fields',
              variant: "error",
          });
          this.dispatchEvent(toast);
          this.disableSN=false;

      } else if (!this.validatenewFields()) {
          const toast = new ShowToastEvent({
              message: 'Review the error message below to correct the data',
              variant: "error",
          });
          this.dispatchEvent(toast);
          this.disableSN=false;
      } else {

          createRecord(recordInput).then((record) => {
                  console.log(record);
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Success',
                          message: 'Forward Cost ' + '"' + this.fcname + '"' + ' was Created.',
                          variant: 'success'
                      })
                  )
                  this.disableSN=false;
                  this.customFormModal = false;
                  this.fcfields = {};
                  this.fcname = '';
                  this.fcenddate = '';
                  this.fcstdate = '';
                  this.fcperiodname = '';
                  this.fccost = '';
                  refreshApex(this.wiredFclistResult);
                  this.customFormModal = true;
              })
              .catch(error => {
                  console.log(error.body);
                  this.customFormModal = false;
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error while Creating record',
                          message: error.body.message,
                          variant: 'error'
                      })
                  );
                  this.disableSN=false;
                  this.fcfields = {};
                  this.fcname = '';
                  this.fcenddate = '';
                  this.fcstdate = '';
                  this.fcperiodname = '';
                  this.fccost = '';
              });
      }
  }

  handleSubmit(event) {
      event.preventDefault;

      if (!this.validateeditFields()) {
          const toast = new ShowToastEvent({
              message: 'Review the error message below to correct the data',
              variant: "error",
          });
          this.dispatchEvent(toast);
      }
      // Otherwise submit save
      else {
          this.template.querySelector('lightning-record-edit-form').submit();

      }

  }

  validateeditFields() {
      return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
          // Return whether all fields up to this point are valid and whether current field is valid
          // reportValidity returns validity and also displays/clear message on element based on validity
          return (validSoFar && field.reportValidity());
      }, true);
  }
  validatenewFields() {
      return [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
          // Return whether all fields up to this point are valid and whether current field is valid
          // reportValidity returns validity and also displays/clear message on element based on validity
          return (validSoFar && field.reportValidity());
      }, true);
  }
  isInputValid() {

      let inputFields = this.template.querySelectorAll('.validate');
      console.log(inputFields);
      inputFields.forEach(inputField => {
          if (!inputField.checkValidity()) {
              inputField.reportValidity();
              this.isValid = false;
          } else {
              this.isValid = true;
          }

      });
      return this.isValid;
  }

  handleerror(event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error while Updating record',
              message: 'Error while Updating record Try Again',
              variant: 'error'
          })
      );
      this.customeditFormModal = false;
  }

  refreshrecord() {
      this.customeditFormModal = false;
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Success',
              message: 'Forward Cost ' + '"' + this.fcname + '"' + ' was saved.',
              variant: 'success'
          })
      );
      refreshApex(this.wiredFclistResult);
  }

  handlesave() {
    this.disableBtn=true;
      // Map the data to the fields
      this.fcfields[NAME.fieldApiName] = this.fcname;
      this.fcfields[FCActive.fieldApiName] = this.fcactive;
      this.fcfields[fwdc_opn.fieldApiName] = this.opn;
      this.fcfields[FCPeriodname.fieldApiName] = this.fcperiodname;
      this.fcfields[Startdate.fieldApiName] = this.fcstdate;
      this.fcfields[Enddate.fieldApiName] = this.fcenddate;
      this.fcfields[FCamount.fieldApiName] = this.fccost;

      // Prepare config object with object and field API names 
      const recordInput = {
          apiName: FC_Object.objectApiName,
          fields: this.fcfields
      };
      console.log(recordInput);

      console.log(this.isInputValid());
      // Invoke createRecord by passing the config object
      if (!this.isInputValid()) {
          const toast = new ShowToastEvent({
              message: 'Fill all the mandatory fields',
              variant: "error",
          });
          this.dispatchEvent(toast);
          this.disableBtn=false;



      } else if (!this.validatenewFields()) {
          const toast = new ShowToastEvent({
              message: 'Review the error message below to correct the data',
              variant: "error",
          });
          this.dispatchEvent(toast);
          this.disableBtn=false;
      } else {

          createRecord(recordInput).then((record) => {
                  console.log(record);

                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Success',
                          message: 'Forward Cost ' + '"' + this.fcname + '"' + ' was Created.',
                          variant: 'success'
                      })
                  )
                  this.disableBtn=false;
                  this.customFormModal = false;
                  this.fcfields = {};
                  this.fcname = '';
                  this.fcenddate = '';
                  this.fcstdate = '';
                  this.fcperiodname = '';
                  this.fccost = '';
                  refreshApex(this.wiredFclistResult);
              })
              .catch(error => {
                  console.log(error.body);
                  this.customFormModal = false;
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error while Creating record',
                          message: error.body.message,
                          variant: 'error'
                      })
                  );
                  this.disableBtn=false;
                  this.fcfields = {};
                  this.fcname = '';
                  this.fcenddate = '';
                  this.fcstdate = '';
                  this.fcperiodname = '';
                  this.fccost = '';
                  refreshApex(this.wiredFclistResult);
              });
      }

  }


  customFormModalview() {
      this.customFormModal = !this.customFormModal;
      console.log(this.customFormModal);
      this.opn = getFieldValue(this.fwd_opn.data, Prod_opn);
      console.log(this.opn);
      this.fcname = '';
      this.fcenddate = '';
      this.fcstdate = '';
      this.fcperiodname = '';
      this.fccost = '';

  }
  customeditFormModalhandle(row) {
      console.log('event-->' + JSON.stringify(row));
      this.customeditFormModal = !this.customeditFormModal;
      //let strIndex = event.target.dataset.recordId;
      //let recs =  JSON.parse( JSON.stringify( this.records ) );
      let rowId = row.Id;
      let FC_name = row.Name;
      this.fc_id = rowId;
      this.fcname = FC_name
  }
  editmodal(event) {
      event.preventDefault;
      this.customeditFormModal = !this.customeditFormModal;
      this.fcname = '';
      this.fcenddate = '';
      this.fcstdate = '';
      this.fcperiodname = '';
      this.fccost = '';

  }


   /*handledelete(row) {
      console.log('event-->' + JSON.stringify(row));
      //let strIndex = row.target.dataset.recordId;
      //let recs =  JSON.parse( JSON.stringify( this.records ) );
      //let rowId = recs[ strIndex ].Id;
      //let FC_name=recs[ strIndex ].Name;
      let rowId = row.Id;
      let FC_name = row.Name;
      let strIndex = this.recordCount - 1;
      console.log('Record Id is' + rowId);
      console.log('StrIndex is' + strIndex);
      //event.preventDefault();
      //event.stopPropagation();
      this.isLoading = true;
      
          deleteRecord(rowId)
              .then(() => {
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Success',
                          message: 'Forward Cost ' + '"' + FC_name + '"' + ' was deleted.',
                          variant: 'success'
                      })
                  )
                  this.isLoading = false;
                  refreshApex(this.wiredFclistResult);
                  if (this.recordCount > 0) {
                      this.DefaultView = true;
                  }

              }).catch(error=> {
                
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

  }*/

}