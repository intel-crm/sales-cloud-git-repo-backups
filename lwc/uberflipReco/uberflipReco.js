import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jqueryjs from '@salesforce/resourceUrl/jquery_3_6_0';
import widget from '@salesforce/resourceUrl/widget';
import codepenCSS from '@salesforce/resourceUrl/addOnCSS_ufwidget'

export default class UberflipReco extends LightningElement {


     connectedCallback() {
          const targetDiv = document.createElement("DIV");
          targetDiv.id = 'uberflip-tiles';
          this.template.host.appendChild(targetDiv);

          Promise.all([
               loadScript(this, jqueryjs + '/jquery-3.6.0.min.js'),
               loadScript(this, widget + '/widget.js'),
               loadScript(this, widget + '/uf-reco-embed-viewer.min.js'),     
               loadStyle(this, codepenCSS+'/codepen.css')          
          ]).then(() => {
               console.log('loaded script');
               //const widg = WidjetJs+'/components/website-widget/v1/63774/widget.js';
               const ufRecoEmbedViewerConfig = {
                    'base': 'https://flipbot.uberflip.com/',
                    'open_in': 'viewer',
                    'open_in_mobile': 'viewer',
                    'logo': '',
                    'embed_id': 'uberflip-tiles',
                    'cta_label': '',
                    'cta_url': '',
                    'max_per_row': 4,
                    'hub_id': 63774,
                    'auto_link': false,
                    'debug': true,
               };
               ufRecoEmbedViewer.init(ufRecoEmbedViewerConfig);
          }).catch((error) => {
               console.log('Error -->' + error.message);
          });
     }
}