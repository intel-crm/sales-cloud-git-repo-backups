import { LightningElement,api,track } from 'lwc';
import getURLFromApex from '@salesforce/apex/pBI_Embed_Cloud.getURL'; 
import getEmbeddingDataForReport from '@salesforce/apex/pBI_Embed_Cloud.getEmbeddingDataForReport';
import powerbijs from '@salesforce/resourceUrl/powerbijs';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class EmbedPBICloud extends LightningElement {
    @api recordId;
    @api configName;
    fullUrl='https://app.powerbi.com/reportEmbed?reportId=a9c961d0-738f-4e13-b8fa-f8997472ecd7&groupId=1f0210e2-2cb4-432a-99c0-28d3f4d5e58a&w=2&config=eyJjbHVzdGVyVXJsIjoiaHR0cHM6Ly9XQUJJLVdFU1QtVVMtQi1QUklNQVJZLXJlZGlyZWN0LmFuYWx5c2lzLndpbmRvd3MubmV0IiwiZW1iZWRGZWF0dXJlcyI6eyJtb2Rlcm5FbWJlZCI6dHJ1ZSwidXNhZ2VNZXRyaWNzVk5leHQiOnRydWV9fQ%3d%3d&uid=68vkc7';
    noAccessMsg = '';
    hasAccess = false;
    noAccess = false;
    @api WorkspaceId = '1f0210e2-2cb4-432a-99c0-28d3f4d5e58a';
    @api ReportId = 'a9c961d0-738f-4e13-b8fa-f8997472ecd7';
    //@api ReportId = 'ecfd80ac-274c-4235-b255-bc8fd23b5f5d';
    @track report;
    embedUrl;
    ealUrl;

    embedContainer;

    renderedCallback(){
        if(this.embedContainer){
            return;
        }
        
        //this.embedContainer = elem;
        this.initPowerBi();
                            
    }

    async initPowerBi(){
        await loadScript(this, powerbijs);
        this.getEmbedURL();
        
    }

    connectedCallback() { 
        
    }
    // connectedCallback() { 
    //     loadScript(this, powerbijs).then(() => {
    //         this.getEmbedURL();
    //     })
    //     .catch(error => {
    //         console.log('Eror', error);
    //     })
        
    //     //this.getURL();
    //     console.log('in here 1');
    // }

    getURL(){
        getURLFromApex({configName:this.configName,recordId:this.recordId})
        .then((data) => {
            console.log('in here');
            this.hasAccess = true;
            //this.fullUrl ='https://app.powerbi.com/reportEmbed?reportId=a9c961d0-738f-4e13-b8fa-f8997472ecd7&groupId=1f0210e2-2cb4-432a-99c0-28d3f4d5e58a&w=2&config=eyJjbHVzdGVyVXJsIjoiaHR0cHM6Ly9XQUJJLVdFU1QtVVMtQi1QUklNQVJZLXJlZGlyZWN0LmFuYWx5c2lzLndpbmRvd3MubmV0IiwiZW1iZWRGZWF0dXJlcyI6eyJtb2Rlcm5FbWJlZCI6dHJ1ZSwidXNhZ2VNZXRyaWNzVk5leHQiOnRydWV9fQ%3d%3d&uid=68vkc7';
            
            var saveRes = JSON.parse(JSON.stringify(data));
            console.log('saveRes: '+saveRes);
            for(var key in saveRes){
                if(key == "true"){
                    this.hasAccess = true;
                    this.fullUrl = saveRes[key];
                }
                else if(key == "false"){
                    this.noAccess = true;
                    this.noAccessMsg = saveRes[key];
                }  
            }
        })
        .catch(error => {
            this.error = error;  
        });
    }

    getEmbedURL(){
        // Promise.all([this,loadScript]).then(() => {
        //     console.log('Rendering');
        getEmbeddingDataForReport({WorkspaceId: this.WorkspaceId,ReportId: this.ReportId})
        .then(response => {
            
            console.log('response', response);
                    this.report = response;
                    if (response) {
                        if (response.embedUrl && response.embedToken) {
														const elem = this.template.querySelector('div');
                            //var reportContainer = this.template.querySelector('[data-id="embed-container"');
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
                                }
                            };
                            console.log('config:' + JSON.stringify(config));
														console.log('config1:' + JSON.parse(JSON.stringify(config)));
                            const report = powerbi.embed(this.template.querySelector('div'),config);

        report.off('loaded');
        report.on('loaded',() => {
            console.log('report loaded successfully');
        });

        report.off('error');
        report.on('error',(event) => {
            console.error('report load error:',event.detail);
        });
   
                            // Embed the report and display it within the div container.
                            //var report = powerbi.embed(reportContainer, config);

                            
                            // this.ealUrl = report.config.embedUrl+'&uid='+report.config.uniqueId;
                            // console.log('loaded ', report);
                            
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
    // .catch(error => {
    //     console.log('Eror', error);
    // })
    // }
    
}