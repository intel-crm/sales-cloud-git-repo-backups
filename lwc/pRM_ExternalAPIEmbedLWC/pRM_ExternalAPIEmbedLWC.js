import { LightningElement, api, wire, track } from 'lwc';
import getAccountId from '@salesforce/apex/PRM_ExternalAPIController.getAccountId';
import getError from '@salesforce/label/c.PRM_PowerBI_Report_Error_Message';
import infoMessage from '@salesforce/label/c.PRM_no_data_info_msg';
import getEmbeddingDataForReport from '@salesforce/apex/PRM_ExternalAPIController.getEmbeddingDataForReport';
import hasAccess from '@salesforce/apex/PRM_ExternalAPIController.checkAccess';
import getReportDetails from '@salesforce/apex/PRM_ExternalAPIController.getReportDetails';
import powerbijs from '@salesforce/resourceUrl/powerbijs';
import UNAUTHORIZED_ACCESS from '@salesforce/label/c.PRM_Unauthorize_Access';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class PRM_ExternalAPIEmbedLWC extends LightningElement {
  // Properties
  @track errorMessage = getError;
  @track infoMessage = infoMessage;
  @api configName;
  @api embedPowerBIReport = false;
  @api accountId;
  @track loaded = false;
  
  @track hasAccountId;
  @track error;
  @track accesserror = UNAUTHORIZED_ACCESS;
  @api WorkspaceId;
  @api ReportId;
  @api pageName;
  @api DeveloperName;
  @track report;
  @track isaccessible = false;

  connectedCallback() {
    console.log('checkreport -->', this.report);
    console.log('reportDetails -->', this.reportDetails);

    // Retrieve report details
    console.log('12report -->',this.powerbijs);
    console.log('12report -->',window.location.pathname);
    const pathname = window.location.pathname
     // Split the pathname to get the last segment which represents the page name
     const segments = pathname.split('/');
     const pageName = segments[segments.length - 1];
     console.log('pageName -->',pageName);
    getReportDetails({pageName}).then((result) => {
      console.log('result -->',result);
      this.DeveloperName= result.developerName;
      this.ReportId = result.reportId;
      this.WorkspaceId = result.workspaceId;
      this.columnName = result.columnName;
      this.tableName = result.tableName;

      // Check access permission
      hasAccess().then((result) => {
        if (result === true) {
          this.isaccessible = true;

          // Get the account ID
          getAccountId({pageName})
            .then((result) => {
              if (result != null) {
                this.accountId = result;
                this.hasAccountId = true;
                this.loaded = true;
                this.error = false;

                // Load Power BI JavaScript library
                Promise.all([loadScript(this, powerbijs)]).then(() => {
                  console.log('Rendering');
                  console.log('pageName', pageName);
                  // Get embedding data for the report
                  getEmbeddingDataForReport({
                    WorkspaceId: this.WorkspaceId,
                    ReportId: this.ReportId,
                    pageName: pageName,
                  })
                    .then((response) => {
                      console.log('response', response);
                      this.report = response;

                      if (response) {
                        console.log('Account Id -->', this.accountId);
                        if (response.embedUrl && response.embedToken) {
                          // Get the report container element
                          var reportContainer = this.template.querySelector(
                            '[data-id="embed-container"]'
                          );

                          // Extract necessary data from the response
                          var reportId = response.reportId;
                          var embedUrl = response.embedUrl;
                          var token = response.embedToken;

                          // Define the basic filter to be applied
                          var basicFilter = {
                            $schema: 'http://powerbi.com/product/schema#basic',
                            target: {
                              table: this.tableName,
                              column: this.columnName,
                            },
                            operator: 'In',
                            values: [this.accountId],
                          };

                          // Configure the embedding options
                          var config = {
                            type: 'report',
                            filters: [basicFilter],
                            id: reportId,
                            embedUrl: embedUrl,
                            accessToken: token,
                            tokenType: 1,
                            settings: {
                              panes: {
                                filters: { expanded: false, visible: false },
                                pageNavigation: { visible: false },
                              },
                            },
                          };

                          // Embed the report and display it within the div container
                          var report = powerbi.embed(reportContainer, config);

                          console.log('loaded ', report);
                        } else {
                          console.log('no embedUrl or embedToken');
                        }
                      } else {
                        console.log('no response yet');
                      }
                    })
                    .catch((error) => {
                      console.log('error -->', error);
                    });
                }).catch((error) => {
                  console.log('Eror', error);
                  this.loaded = true;
                });
              } else {
                this.isaccessible = false;
                this.loaded = true;
              }
            })
            .catch((error) => {
              this.loaded = true;
              this.error = true;
              this.hasAccountId = false;
              console.log('Exception ex -->', error);
            });
        } else {
          this.isaccessible = false;
          this.loaded = true;
        }
      }).catch((error) => {
        console.log('Error -->', error);
        this.loaded = true;
      });
    }).catch((error) => {
      console.log('Error from get report details method', error);
      this.loaded = true;
    });
    console.log('Account Id -->', this.accountId);
  }
}