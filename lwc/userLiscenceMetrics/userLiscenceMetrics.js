import { LightningElement,wire,track } from 'lwc';
import getUserLicence from '@salesforce/apex/ObjectMetrics.getUserLicence'
export default class UserLiscenceMetrics extends LightningElement {
      @track userLicencecolumns=[{
                      label:'Name ',
                      Type:'text',
                      fieldName:'licenceName'
                     },
                    {
                         label:'Status ',
                        Type:'text',
                        fieldName:'licenceStatus'
                    },{
                        label:'Total Licenses ',
                        Type:'number',
                        fieldName:'licenceTotal'
                    },{
                        label:'Used Licenses  ',
                        Type:'number',
                        fieldName:'licenceUsed'
                    },{
                        label:'Licences Remaining',
                        Type:'number',
                        fieldName:'licenceRemaining'
                    }           ];
 @track userLicenceData=[];
 
  @wire(getUserLicence)
  UserLicenceDetails ({error, data}) {
      var userLiscenceDetails=[]; 
      if (data) {
        data.forEach(element => {
              var remainingLicence=element.TotalLicenses-element.UsedLicenses;
              userLiscenceDetails.push({
                licenceName:element.Name,
                licenceStatus:element.Status,
                licenceTotal:element.TotalLicenses,
                licenceUsed:element.UsedLicenses,
                licenceRemaining:remainingLicence
              });
          }
          
          );
          this.userLicenceData=userLiscenceDetails;
      } else if (error) {
          // TODO: Data handling
      }
  }
}