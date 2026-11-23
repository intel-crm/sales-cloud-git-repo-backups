import { LightningElement, api } from 'lwc';

export default class CustomHtmlRenderer extends LightningElement {
    @api htmlContent;

    renderedCallback() {
        this.template.querySelector('.custom-html-renderer').innerHTML = this.htmlContent;
    }
}