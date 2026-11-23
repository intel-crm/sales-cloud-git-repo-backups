import { LightningElement,api } from 'lwc';
import getURLFromApex from '@salesforce/apex/Custom_URL_Embed.getURL';
import getEmbeddingDataForReport from '@salesforce/apex/Custom_URL_Embed.getEmbeddingDataForReport';
import powerbijs from '@salesforce/resourceUrl/powerbijs';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class Custom_URL_Embed extends LightningElement {
    @api recordId;
    @api configName;
    @api roles;
    @api WorkspaceId;
    @api ReportId;
		@api height='600px';
    fullUrl='';
    noAccessMsg = '';
    noAccess = false;
    autoSignInEnabled = false;

    connectedCallback() { 
        this.getURL();
    }
		 get setDIVHeight() {
				const str_height = 'height:' + this.height + ';';
				//console.log('frameheight' + str_height);
        return str_height;
        }
 
    getURL(){
        getURLFromApex({configName:this.configName,recordId:this.recordId})
        .then((data) => {
            
            var saveRes = JSON.parse(JSON.stringify(data));
            console.log('reportURL  '+ saveRes['reportURL']);
            console.log('hasAccess  '+ saveRes['hasAccess']);
            console.log('autoSSOEnabled  '+ saveRes['autoSSOEnabled']);
            console.log('saveRes: '+saveRes);
        
            this.hasAccess = saveRes['hasAccess'];
            if(this.hasAccess){
                if(saveRes['autoSSOEnabled']){
                    this.autoSignInEnabled = true;
                    this.initPowerBi();
                }
                else{
                    this.fullUrl = saveRes['reportURL'];
                }
            }
            else{
                this.noAccess = true;
                this.noAccessMsg = saveRes['reportURL'];
                }  
            
        })
        .catch(error => {
            this.error = error;  
        });
    }

    async initPowerBi(){
        await loadScript(this, powerbijs);
        this.getEmbedURL();
        
    }

    getEmbedURL(){
        getEmbeddingDataForReport({configName:this.configName,WorkspaceId: this.WorkspaceId,ReportId: this.ReportId,roles:this.roles})
        .then(response => {
            console.log(this.configName + ' ' + this.WorkspaceId + ' ' + this.ReportId + ' ' + this.roles);
            console.log('response', response);
                    this.report = response;
                    if (response) {
                        if (response.embedUrl && response.embedToken) {
                            const embedContainer = this.template.querySelector('[data-id="embed-container"');
                            //var reportContainer = this.template.querySelector('[data-id="container"');
                            var reportId = response.reportId;
                            this.embedUrl = response.embedUrl;
                            var token = response.embedToken;
                            const config = {
                                type: 'report',
                                id: reportId,
                                embedUrl: this.embedUrl,
                                accessToken: token,
                                tokenType: 1,
                                panes: {
                                        filters: { expanded: false, visible: false },
                                        pageNavigation: { visible: false }
                                },
                            };
                            console.log('config:' + JSON.stringify(config));

                            const report = powerbi.embed(embedContainer, config);

        report.off('loaded');
        report.on('loaded',() => {
            console.log('report loaded successfully');
        });

        report.off('error');
        report.on('error',(event) => {
            console.error('report load error:',event.detail);
        });
                        }
                        else {
                            console.log('no embedUrl or embedToken');
                        }

                    }
                    else {
                        console.log('no response yet');
                    }
        }).catch(error => {
            this.error = error;  
        });
    }
}