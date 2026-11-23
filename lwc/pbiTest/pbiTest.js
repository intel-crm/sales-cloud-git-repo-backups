import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import pbi from '@salesforce/resourceUrl/pbi'; // jslibra
export default class PbiTest extends LightningElement {


    // connectedCallback() {
    //     Promise.all([
    //         loadScript(this, pbi + '/powerbi.js'),
    //     ]).then(() => {
    //         console.log('Loaded');
    //         this.initializePowerBI();
    //     })
    //         .catch(error => {
    //             console.log('Error -->', error);
    //         })
    // }
    // initializePowerBI() {
    //     let embedConfig = {
    //         type: 'report',
    //         id: 'ac638c8f-4fa7-4c51-8f9c-56cd0920e22f',
    //         embedUrl: 'https://app.powerbi.com/reportEmbed?reportId=82afee12-5220-4a31-ba4e-53feab008a97&autoAuth=true&navContentPaneEnabled=false',
    //         // accessToken: 'ACCESS_TOKEN',
    //         // tokenType: models.TokenType.Aad,
    //         // permissions: models.Permissions.All,
    //         settings: { filterPaneEnabled: false, navContentPaneEnabled: true }
    //     };

    //     var reportContainer = this.template.querySelector('.abc');
    //     var report = powerbi.embed(reportContainer, embedConfig);
    // }
}