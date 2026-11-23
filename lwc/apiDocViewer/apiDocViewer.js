import { LightningElement, api } from 'lwc';
import apiDocResource from '@salesforce/resourceUrl/CoreMDFAPIDocumentation';

export default class ApiDocViewer extends LightningElement {
    @api frameHeight = 900;

    get docUrl() {
        return apiDocResource;
    }
}